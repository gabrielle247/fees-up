class Attendance {
  final String id;
  final String schoolId;
  final String studentId;
  final String? classId;
  final DateTime date;
  final String status; // 'present', 'absent', 'late', 'excused'
  final String? remarks;
  final String? recordedBy;

  Attendance({
    required this.id,
    required this.schoolId,
    required this.studentId,
    this.classId,
    required this.date,
    this.status = 'present',
    this.remarks,
    this.recordedBy,
  });

  factory Attendance.fromRow(Map<String, dynamic> row) {
    return Attendance(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      studentId: row['student_id'] as String,
      classId: row['class_id'] as String?,
      date: DateTime.parse(row['date']),
      status: row['status'] ?? 'present',
      remarks: row['remarks'] as String?,
      recordedBy: row['recorded_by'] as String?,
    );
  }
}

class AttendanceSession {
  final String id;
  final String schoolId;
  final String classId;
  final String teacherId;
  final DateTime sessionDate;
  final bool isConfirmedByTeacher;
  final DateTime? confirmedAt;

  AttendanceSession({
    required this.id,
    required this.schoolId,
    required this.classId,
    required this.teacherId,
    required this.sessionDate,
    this.isConfirmedByTeacher = false,
    this.confirmedAt,
  });

  factory AttendanceSession.fromRow(Map<String, dynamic> row) {
    return AttendanceSession(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      classId: row['class_id'] as String,
      teacherId: row['teacher_id'] as String,
      sessionDate: DateTime.parse(row['session_date']),
      isConfirmedByTeacher: (row['is_confirmed_by_teacher'] == 1),
      confirmedAt: row['confirmed_at'] != null 
          ? DateTime.tryParse(row['confirmed_at']) 
          : null,
    );
  }
}