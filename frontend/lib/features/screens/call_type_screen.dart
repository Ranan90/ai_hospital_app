import 'package:flutter/material.dart';

class CallTypeScreen extends StatefulWidget {
  const CallTypeScreen({super.key});

  @override
  State<CallTypeScreen> createState() => _CallTypeScreenState();
}

class _CallTypeScreenState extends State<CallTypeScreen> {
  // Track selected option: 'video', 'audio', or 'phone'. Default to 'video'.
  String _selectedType = 'video';

  final Color _tealColor = const Color(0xFF00796B); // Match design teal
  final Color _darkIconBg = const Color(
    0xFF37474F,
  ); // Dark grey for unselected icons

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _tealColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Select Call Type',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            onPressed: () {
              // Handle home navigation
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Options Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionCard(
                    id: 'video',
                    label: 'Video\nCall',
                    icon: Icons.videocam,
                  ),
                  const SizedBox(width: 16),
                  _buildOptionCard(
                    id: 'audio',
                    label: 'Audio\nCall',
                    icon: Icons.headset_mic,
                  ),
                  const SizedBox(width: 16),
                  _buildOptionCard(
                    id: 'phone',
                    label: 'Phone\nCall',
                    icon: Icons
                        .phone, // Using phone instead of phone_in_talk to match simpler icon style
                  ),
                ],
              ),
              const Spacer(),
              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle next action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tealColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedType == id;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = id;
          });
        },
        child: Container(
          height: 160, // Fixed height for consistency
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? _tealColor : Colors.grey.shade200,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: _tealColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? _tealColor : _darkIconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F36), // Dark text color
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
