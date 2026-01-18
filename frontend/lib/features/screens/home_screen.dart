import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';
import 'live_care_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text(
                  'AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Medical App Interface Design',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StreamBuilder<AuthState>(
              stream: Supabase.instance.client.auth.onAuthStateChange,
              builder: (context, snapshot) {
                final session = snapshot.data?.session;
                // Also check current session directly for initial state
                final isLoggedIn =
                    session != null ||
                    Supabase.instance.client.auth.currentUser != null;

                return ElevatedButton(
                  onPressed: () async {
                    if (isLoggedIn) {
                      await Supabase.instance.client.auth.signOut();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoggedIn ? Colors.red : Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isLoggedIn ? 'Log Out' : 'Login'),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMedicalFileCard(),
                  const SizedBox(height: 16),
                  _buildQuickAccessCards(),
                  const SizedBox(height: 24),
                  _buildServicesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildMedicalFileCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.teal[400],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Medical File',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'To view your medical profile, please log in or register now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal[700],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCards() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickCard(
            'Emergency Services',
            'Always at your service',
            Icons.local_hospital,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickCard(
            'Online Pharmacy',
            'Ecommerce Solution',
            Icons.medication,
            Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    final services = [
      {
        'icon': Icons.calendar_month,
        'title': 'Book\nAppointment',
        'subtitle': '',
      },
      {
        'icon': Icons.video_call,
        'title': 'Live Care',
        'subtitle': 'Online Consulting',
      },
      {
        'icon': Icons.location_on,
        'title': 'Hospital\nNavigation',
        'subtitle': '',
      },
      {
        'icon': Icons.local_shipping,
        'title': 'Emergency\nCheck-in',
        'subtitle': '',
      },
      {'icon': Icons.home, 'title': 'Home Health\nCare', 'subtitle': ''},
      {
        'icon': Icons.person_add,
        'title': 'Checkup',
        'subtitle': 'Comprehensive',
      },
      {
        'icon': Icons.credit_card,
        'title': 'Online Payment',
        'subtitle': '',
        'badges': true,
      },
      {'icon': Icons.description, 'title': 'E-Referral', 'subtitle': 'Service'},
      {'icon': Icons.shield, 'title': 'COVID-19', 'subtitle': 'Test'},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'HMG Service',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All Services'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                final title = service['title'] as String;

                if (title.contains('Live Care')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LiveCareScreen()),
                  );
                }
              },
              child: _buildServiceCard(
                service['icon'] as IconData,
                service['title'] as String,
                service['subtitle'] as String,
                service['badges'] as bool? ?? false,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    IconData icon,
    String title,
    String subtitle,
    bool showBadges,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.teal, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
          if (showBadges) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'VISA',
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'MC',
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.folder, 'Medical File', 0),
          _buildNavItem(Icons.people, 'My Family', 1),
          const SizedBox(width: 40),
          _buildNavItem(Icons.list, 'Todo List', 2),
          _buildNavItem(Icons.help_outline, 'Help', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.teal : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.teal : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: Colors.teal,
      elevation: 8,
      icon: const Icon(Icons.calendar_today, size: 20),
      label: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('BOOK', style: TextStyle(fontSize: 10)),
          Text('APPOINTMENT', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
