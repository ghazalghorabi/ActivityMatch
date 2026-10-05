import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120B06),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              const Center(
                child: Text(
                  'ActivityMatch',
                  style: TextStyle(
                    color: Color(0xFFFFA33A),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Meet people. Do things together.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'Email',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: const TextStyle(
                    color: Colors.white54,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF211A15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: const TextStyle(
                    color: Colors.white54,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF211A15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA33A),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const SignUpPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Create account',
                        style: TextStyle(
                          color: Color(0xFFFFA33A),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}