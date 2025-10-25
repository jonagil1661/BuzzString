import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'stringer_dashboard.dart';
import 'update_string_types.dart';
import 'statistics_page.dart';

class StringerHomePage extends StatefulWidget {
  const StringerHomePage({super.key});

  @override
  State<StringerHomePage> createState() => _StringerHomePageState();
}

class _StringerHomePageState extends State<StringerHomePage> {
  bool _isDashboardHovered = false;
  bool _isStringTypesHovered = false;
  bool _isStatsHovered = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF003057),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF003057),
              Color(0xFF001A2E),
              Color(0xFF000F1A),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width > 600 
                ? MediaQuery.of(context).size.width * 0.6
                : MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: const Color(0xFF001A2E),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 48),
                        const Expanded(
                          child: Text(
                            "BuzzString Stringer Portal",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () => _signOut(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/buzz_string_logo.png',
                      height: 150,
                      width: 150,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome, ${user?.displayName ?? user?.email ?? 'Stringer'}!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    const SizedBox(height: 25),
                    Center(
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isDashboardHovered = true),
                        onExit: (_) => setState(() => _isDashboardHovered = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.identity()..scale(_isDashboardHovered ? 1.05 : 1.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StringerDashboard(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.dashboard),
                            label: const Text(
                              'Stringer Dashboard',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB3A369),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isStringTypesHovered = true),
                        onExit: (_) => setState(() => _isStringTypesHovered = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.identity()..scale(_isStringTypesHovered ? 1.05 : 1.0),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UpdateStringTypes(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text(
                              'Update String Types',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isStatsHovered = true),
                        onExit: (_) => setState(() => _isStatsHovered = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.identity()..scale(_isStatsHovered ? 1.05 : 1.0),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StatisticsPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.analytics),
                            label: const Text(
                              'Statistics',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      color: Colors.white.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Stringer Tools:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: SizedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '• View and manage all stringing requests',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    const Text(
                                      '• Update request progress and payment status',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    const Text(
                                      '• Manage available string types and pricing',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    const Text(
                                      '• Access detailed customer information',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Version 1.4.1',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final authService = AuthService();
      await authService.signOut();
      
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
          ),
        );
      }
    }
  }
}