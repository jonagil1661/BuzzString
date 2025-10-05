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
    WidgetsFlutterBinding.ensureInitialized();
    
    if (!kIsWeb) {
      await dotenv.load(fileName: ".env");
    }

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    runApp(const MyApp());
  } catch (e) {
    print('Error initializing app: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error: $e'),
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
