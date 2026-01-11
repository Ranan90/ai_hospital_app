import 'package:flutter/material.dart';
import 'package:frontend/features/ai/ai_screen.dart';

class LiveCareScreen extends StatelessWidget {
  const LiveCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C), // Dark teal color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'LIVECARE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            onPressed: () {
              // Navigate to home
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why LiveCare?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F36),
              ),
            ),
            const SizedBox(height: 20),
            _buildBenefitItem(
              'No need to wait you will get Medical consultation immediately via Video call',
            ),
            const SizedBox(height: 16),
            _buildBenefitItem('The doctor will see your medical file'),
            const SizedBox(height: 16),
            _buildBenefitItem('Free prescription delivery service'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Color(0xFF4A5568), height: 1.5),
                  children: [
                    TextSpan(
                      text:
                          '** The service is included with some insurance companies\naccording to the terms and conditions with our ',
                    ),
                    TextSpan(
                      text: 'best wishes',
                      style: TextStyle(
                        backgroundColor: Color(0xFFFFF176), // Yellow highlight
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(text: ' for\nhealth and wellness'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildActionCard(
              title: 'Get consultation\nimmediately',
              icon: Icons.videocam,
              iconColor: Colors.white,
              iconBgColor: const Color(0xFF00695C),
              showBadge: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Schedule video\ncall',
              icon: Icons.calendar_today,
              iconColor: Colors.white,
              iconBgColor: const Color(0xFF00695C),
              showBadge: true,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Pharma\nLiveCare',
              icon: Icons.monitor_heart_outlined, // Using monitor/pharma icon
              iconColor: Colors.white,
              iconBgColor: const Color(0xFF00695C),
              showBadge: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.teal,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    bool showBadge = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),

            if (showBadge)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
