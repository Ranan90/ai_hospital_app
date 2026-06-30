import 'package:flutter/material.dart';
import 'dart:async';

// ---------------------------
// 1. Dummy Video Call Screen
// ---------------------------
class DummyVideoCallScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DummyVideoCallScreen({super.key, required this.doctor});

  @override
  State<DummyVideoCallScreen> createState() => _DummyVideoCallScreenState();
}

class _DummyVideoCallScreenState extends State<DummyVideoCallScreen> {
  bool _isConnected = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Simulate connection delay
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Main Video Feed (Doctor)
          Positioned.fill(
            child: _isConnected
                ? Container(
                    color: Colors.grey[900],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person,
                            size: 150,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.doctor['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Specialist", // Could pass specialty if available
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.teal),
                          SizedBox(height: 20),
                          Text(
                            "Connecting to secure line...",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // 2. Self View (Front Camera Placeholder)
          if (_isConnected)
            Positioned(
              bottom: 120, // Above control bar
              right: 20,
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_front, color: Colors.white54),
                      SizedBox(height: 8),
                      Text(
                        "You",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 3. Call Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlBtn(Icons.mic_off, Colors.white24, () {}),
                _buildControlBtn(Icons.call_end, Colors.red, () {
                  Navigator.pop(context);
                }),
                _buildControlBtn(Icons.videocam_off, Colors.white24, () {}),
              ],
            ),
          ),

          // 4. Time Indicator (Top)
          if (_isConnected)
            const Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "00:12",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 30,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

// ---------------------------
// 2. Dummy Audio/Phone Call Screen
// ---------------------------
class DummyAudioCallScreen extends StatefulWidget {
  final String callType; // "Audio" or "Phone"
  final Map<String, dynamic> doctor;

  const DummyAudioCallScreen({
    super.key,
    required this.callType,
    required this.doctor,
  });

  @override
  State<DummyAudioCallScreen> createState() => _DummyAudioCallScreenState();
}

class _DummyAudioCallScreenState extends State<DummyAudioCallScreen> {
  bool _isRingEnded = false;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    // Simulate ringing for 3 seconds
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isRingEnded = true;
          _startTimer();
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  String get _formattedTime {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark blue/slate
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 60),

            // Avatar & Name
            Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.teal.shade200,
                  child: const Icon(Icons.person, size: 60, color: Colors.teal),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.doctor['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRingEnded ? _formattedTime : "Calling...",
                  style: TextStyle(
                    color: _isRingEnded ? Colors.white70 : Colors.tealAccent,
                    fontSize: 18,
                    fontWeight: _isRingEnded
                        ? FontWeight.normal
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Middle waves animation placeholder (optional)
            if (!_isRingEnded)
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.emergency_recording,
                    color: Colors.white.withOpacity(0.1),
                    size: 100,
                  ),
                ),
              )
            else
              const Spacer(),

            // Controls
            Container(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionBtn(Icons.volume_up, "Speaker"),
                  _buildCallEndBtn(),
                  _buildOptionBtn(Icons.mic_off, "Mute"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionBtn(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white.withOpacity(0.1),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCallEndBtn() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: const CircleAvatar(
        radius: 35,
        backgroundColor: Colors.red,
        child: Icon(Icons.call_end, color: Colors.white, size: 32),
      ),
    );
  }
}
