
class Doctor {
  final String id;
  final String name;
  final String email;
  final int? departmentId;

  Doctor({required this.id, required this.name, required this.email, this.departmentId});

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      departmentId: json['department_id'],
    );
  }
}

class DashboardData {
  final List<Appointment> appointments;
  final List<DayAvailability> availability;

  DashboardData({required this.appointments, required this.availability});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      appointments: (json['appointments'] as List)
          .map((e) => Appointment.fromJson(e))
          .toList(),
      availability: (json['availability'] as List)
          .map((e) => DayAvailability.fromJson(e))
          .toList(),
    );
  }
}

class Appointment {
  final String id;
  final String date;
  final String slotType;
  final String status;
  final String patientName;
  final int? patientAge;
  final String? patientGender;

  Appointment({
    required this.id,
    required this.date,
    required this.slotType,
    required this.status,
    required this.patientName,
    this.patientAge,
    this.patientGender,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] ?? {};
    return Appointment(
      id: json['id'],
      date: json['appointment_date'],
      slotType: json['slot_type'],
      status: json['status'],
      patientName: patient['name'] ?? 'Unknown',
      patientAge: patient['age'],
      patientGender: patient['gender'],
    );
  }
}

class DayAvailability {
  final String date;
  final SlotStatus morning;
  final SlotStatus evening;

  DayAvailability({required this.date, required this.morning, required this.evening});

  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    return DayAvailability(
      date: json['date'],
      morning: SlotStatus.fromJson(json['morning']),
      evening: SlotStatus.fromJson(json['evening']),
    );
  }
}

class SlotStatus {
  bool available;
  bool booked;

  SlotStatus({required this.available, required this.booked});

  factory SlotStatus.fromJson(Map<String, dynamic> json) {
    return SlotStatus(
      available: json['available'] ?? false,
      booked: json['booked'] ?? false,
    );
  }
}
