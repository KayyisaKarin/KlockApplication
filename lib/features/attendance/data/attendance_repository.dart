import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/attendance.dart';

abstract class AttendanceRepository {
  Stream<List<Attendance>> watch();
  Future<void> submit(Uint8List photo);
  Future<void> submitExcuse(String reason, {String? note});
  Future<Uint8List> photo(String id);
}

class FirestoreAttendanceRepository implements AttendanceRepository {
  FirestoreAttendanceRepository(this.db, this.uid);

  final FirebaseFirestore db;
  final String uid;

  CollectionReference<Map<String, dynamic>> get records =>
      db.collection('students').doc(uid).collection('attendance');

  @override
  Stream<List<Attendance>> watch() => records
      .orderBy('createdAt', descending: true)
      .limit(60)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Attendance.fromDoc(doc)).toList(),
      );

  @override
  Future<void> submit(Uint8List photo) async {
    if (photo.isEmpty || photo.length > 102400) {
      throw StateError(
        'Photo must be 100 KB or less. Please retake your photo.',
      );
    }
    final batch = db.batch();
    final record = records.doc();
    batch.set(record, {'createdAt': FieldValue.serverTimestamp()});
    batch.set(record.collection('evidence').doc('photo'), {
      'bytes': Blob(photo),
    });
    final guard = db
        .collection('students')
        .doc(uid)
        .collection('guards')
        .doc('daily');
    batch.set(guard, {
      'lastAt': FieldValue.serverTimestamp(),
      'recordId': record.id,
    });
    await batch.commit();
  }

  @override
  Future<void> submitExcuse(String reason, {String? note}) async {
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) {
      throw StateError('Please select an excuse reason.');
    }
    final cleanNote = (note ?? '').trim();
    final combinedNote = cleanNote.isEmpty
        ? cleanReason
        : '$cleanReason — ${cleanNote.length > 120 ? cleanNote.substring(0, 120) : cleanNote}';

    final batch = db.batch();
    final record = records.doc();
    batch.set(record, {
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'excused',
      'note': combinedNote,
    });
    final guard = db
        .collection('students')
        .doc(uid)
        .collection('guards')
        .doc('daily');
    batch.set(guard, {
      'lastAt': FieldValue.serverTimestamp(),
      'recordId': record.id,
    });
    await batch.commit();
  }

  @override
  Future<Uint8List> photo(String id) async {
    final doc = await records.doc(id).collection('evidence').doc('photo').get();
    final data = doc.data();
    if (data == null || data['bytes'] == null) {
      throw StateError('No photo attachment found for this entry.');
    }
    return (data['bytes'] as Blob).bytes;
  }
}
