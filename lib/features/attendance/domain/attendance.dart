import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_policy.dart';

class Attendance {
  const Attendance({
    required this.id,
    required this.createdAt,
    this.status,
    this.note,
  });

  final String id;
  final DateTime? createdAt;
  final AttendanceStatus? status;
  final String? note;

  AttendanceStatus get resolvedStatus => AttendancePolicy.resolveStatus(this);

  String get statusLabel => AttendancePolicy.label(createdAt, status);

  factory Attendance.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final rawStatus = data?['status'] as String?;
    final parsedStatus = switch (rawStatus) {
      'onTime' => AttendanceStatus.onTime,
      'late' => AttendanceStatus.late,
      'absent' => AttendanceStatus.absent,
      'excused' => AttendanceStatus.excused,
      _ => null,
    };
    return Attendance(
      id: doc.id,
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate(),
      status: parsedStatus,
      note: data?['note'] as String?,
    );
  }
}
