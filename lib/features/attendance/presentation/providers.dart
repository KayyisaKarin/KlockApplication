import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_providers.dart';
import '../data/attendance_repository.dart';
import '../domain/attendance.dart';
import '../domain/attendance_policy.dart';

class _SignedOutAttendanceRepository implements AttendanceRepository {
  const _SignedOutAttendanceRepository();

  @override
  Stream<List<Attendance>> watch() => Stream.value(const <Attendance>[]);

  @override
  Future<void> submit(Uint8List photo) async {
    throw StateError('Please log in first.');
  }

  @override
  Future<void> submitExcuse(String reason, {String? note}) async {
    throw StateError('Please log in first.');
  }

  @override
  Future<Uint8List> photo(String id) async {
    throw StateError('Please log in first.');
  }
}

final repositoryProvider = Provider.autoDispose<AttendanceRepository>((ref) {
  ref.watch(sessionProvider);
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return const _SignedOutAttendanceRepository();
  }
  return FirestoreAttendanceRepository(FirebaseFirestore.instance, uid);
});

final attendanceProvider = StreamProvider.autoDispose<List<Attendance>>(
  (ref) => ref.watch(repositoryProvider).watch(),
);

final photoProvider = FutureProvider.autoDispose.family<Uint8List, String>(
  (ref, id) => ref.watch(repositoryProvider).photo(id),
);

class NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int next) => state = next;
}

final navIndexProvider = NotifierProvider<NavIndexNotifier, int>(NavIndexNotifier.new);

class HistoryFilterNotifier extends Notifier<AttendanceStatus?> {
  @override
  AttendanceStatus? build() => null;

  void setFilter(AttendanceStatus? next) => state = next;
}

final historyFilterProvider =
    NotifierProvider<HistoryFilterNotifier, AttendanceStatus?>(HistoryFilterNotifier.new);
