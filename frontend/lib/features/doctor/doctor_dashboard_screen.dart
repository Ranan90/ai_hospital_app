
import 'package:flutter/material.dart';
import '../../models/doctor_models.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorDashboardScreen({super.key, required this.doctor});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  bool _isLoading = true;
  DashboardData? _data;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    try {
      final data = await ApiService.getDoctorDashboard(widget.doctor.id);
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleAvailability(String date, bool isMorning, bool currentValue) async {
    // Optimistic Update
    final index = _data!.availability.indexWhere((availability) => availability.date == date);
    if (index == -1) return;

    final availability = _data!.availability[index];
    
    // Prevent toggling if booked
    if (isMorning && availability.morning.booked) return;
    if (!isMorning && availability.evening.booked) return;

    // Toggle
    setState(() {
      if (isMorning) {
        availability.morning.available = !currentValue;
      } else {
        availability.evening.available = !currentValue;
      }
    });

    try {
      await ApiService.updateAvailability(
        doctorId: widget.doctor.id,
        date: date,
        morning: availability.morning.available,
        evening: availability.evening.available,
      );
    } catch (e) {
      // Revert on error
      setState(() {
         if (isMorning) {
          availability.morning.available = currentValue;
        } else {
          availability.evening.available = currentValue;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dr. ${widget.doctor.name}"),
        backgroundColor: Colors.teal[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchDashboard();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
                // Determine logout logic - usually just pop or clear auth
                Navigator.of(context).pushReplacementNamed('/'); // or back to auth
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text("Error: $_errorMessage"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Availability
                      const Text(
                        "Doctor's Availability (Next 7 Days)",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildAvailabilityGrid(),
                      
                      const SizedBox(height: 32),
                      
                      // Section 2: Appointments
                      const Text(
                        "Upcoming Appointments",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildAppointmentsList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAvailabilityGrid() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _data!.availability.length,
      itemBuilder: (context, index) {
        final day = _data!.availability[index];
        return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                            DateFormat('EEEE, MMM d').format(DateTime.parse(day.date)),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                            children: [
                                Expanded(child: _buildSlotTile("Morning (8am-2pm)", day.date, true, day.morning)),
                                const SizedBox(width: 8),
                                Expanded(child: _buildSlotTile("Evening (4pm-7pm)", day.date, false, day.evening)),
                            ],
                        )
                    ],
                ),
            ),
        );
      },
    );
  }

  Widget _buildSlotTile(String label, String date, bool isMorning, SlotStatus status) {
    Color bgColor = Colors.grey.shade100;
    Color textColor = Colors.black;
    Color borderColor = Colors.grey.shade400;

    if (status.booked) {
        bgColor = Colors.blue.shade100;
        borderColor = Colors.blue;
        textColor = Colors.blue.shade900;
    } else if (status.available) {
        bgColor = Colors.green.shade100;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
    }

    return GestureDetector(
        onTap: status.booked ? null : () => _toggleAvailability(date, isMorning, status.available),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
                children: [
                    Icon(
                        status.booked ? Icons.lock : (status.available ? Icons.check_circle : Icons.circle_outlined),
                        size: 20,
                        color: textColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            label,
                            style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                        ),
                    ),
                ],
            ),
        ),
    );
  }

  Widget _buildAppointmentsList() {
    if (_data!.appointments.isEmpty) {
        return const Text("No upcoming appointments.", style: TextStyle(color: Colors.grey));
    }
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _data!.appointments.length,
        itemBuilder: (context, index) {
            final appt = _data!.appointments[index];
            return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text(appt.patientName[0]),
                    ),
                    title: Text(appt.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${appt.date} • ${appt.slotType.toUpperCase()}"),
                    trailing: const Chip(label: Text("Scheduled"), backgroundColor: Colors.orangeAccent),
                ),
            );
        },
    );
  }
}
