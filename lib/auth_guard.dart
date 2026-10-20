import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';

Future<bool> requireLogin(BuildContext context) async {
  if (FirebaseAuth.instance.currentUser != null) {
    return true;
  }

  final result = await Navigator.of(context)
      .push<bool>(MaterialPageRoute(builder: (_) => const LoginPage()));

  return result == true && FirebaseAuth.instance.currentUser != null;
}
