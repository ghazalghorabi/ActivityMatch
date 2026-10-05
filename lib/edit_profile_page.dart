import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120B06),
      appBar: AppBar(
        backgroundColor: const Color(0xFF120B06),
        foregroundColor: Colors.white,
        title: const Text('Edit profile'),
      ),
      body: const Center(
        child: Text(
          'Edit profile works!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}