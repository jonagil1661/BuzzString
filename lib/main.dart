import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'google_login_page.dart';
import 'home_page.dart';
import 'stringer_home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  try {
    print('Starting app initialization...');
    WidgetsFlutterBinding.ensureInitialized();
    print('WidgetsFlutterBinding initialized');
    
    if (!kIsWeb) {
      await dotenv.load(fileName: ".env");
      print('Dotenv loaded');
    }

    print('Initializing Firebase...');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully');

    print('Running MyApp...');
    runApp(const MyApp());
    print('MyApp started');
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print('Stack trace: $stackTrace');
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error Initializing App', style: TextStyle(fontSize: 24, color: Colors.white)),
              const SizedBox(height: 20),
              Text('Error: $e', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              const Text('Check browser console for more details', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BuzzString App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF003057),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const GoogleLoginPage(),
        '/home': (context) => const HomePage(),
        '/stringer': (context) => const StringerHomePage(),
      },
    );
  }
}
