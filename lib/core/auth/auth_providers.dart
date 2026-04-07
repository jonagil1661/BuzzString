import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth_service.dart';

enum AppUserRole { customer, stringer }

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

const Set<String> kStringerEmails = {
  'jona.gil1661@gmail.com',
  'buzzstring.badminton@gmail.com',
};

bool isStringerEmail(String? email) {
  if (email == null) {
    return false;
  }
  return kStringerEmails.contains(email.trim().toLowerCase());
}

AppUserRole roleForEmail(String? email) {
  return isStringerEmail(email) ? AppUserRole.stringer : AppUserRole.customer;
}
