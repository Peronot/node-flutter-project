class AppointmentModel {
  final int? id;
  final int? patientId;
  final int? doctorId;
  final DateTime? scheduledAt;
  final String? status;
  final String? notes;
  final String? patientName;
  final String? doctorName;
  final String? phone;

  AppointmentModel({
    this.id,
    this.patientId,
    this.doctorId,
    this.scheduledAt,
    this.status,
    this.notes,
    this.patientName,
    this.doctorName,
    this.phone,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int?,
      patientId: json['patientId'] as int?,
      doctorId: json['doctorId'] as int?,
      scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at']) : null,
      status: json['status'] as String?,
      notes: json['notes'] as String?,
      // backend list currently returns ids only; these optional extra fields can be injected if backend is expanded
      patientName: json['patient_name'] as String?,
      doctorName: json['doctor_name'] as String?,
      phone: json['phone'] as String?,
    );
  }
}
