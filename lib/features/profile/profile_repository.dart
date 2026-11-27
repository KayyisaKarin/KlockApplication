import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';

final profileRepositoryProvider = Provider.autoDispose<ProfileRepository?>((ref) {
  ref.watch(sessionProvider);
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  return ProfileRepository(FirebaseFirestore.instance, uid);
});

final avatarProvider = StreamProvider.autoDispose<Uint8List?>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  if (repo == null) return Stream.value(null);
  return repo.watch();
});

class ProfileRepository {
  ProfileRepository(this.db, this.uid);

  final FirebaseFirestore db;
  final String uid;

  DocumentReference<Map<String, dynamic>> get document =>
      db.collection('students').doc(uid).collection('profile').doc('photo');

  Stream<Uint8List?> watch() {
    return document.snapshots().map((doc) => (doc.data()?['bytes'] as Blob?)?.bytes);
  }

  Future<void> save(Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length > 102400) {
      throw StateError('Profile photo must be 100 KB or less.');
    }
    await document.set({
      'bytes': Blob(bytes),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
