import 'package:flutter/material.dart';
import '../../shared/widgets/primary_button.dart';
import '../../app/router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.menu_book_rounded, size: 64),
              const SizedBox(height: 18),
              const Text('Dar El Fikr', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const Text(
                'Digital Islamic Library\nNo ads • Pure knowledge',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                text: 'Continue',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: const Text('Privacy & Terms (later)'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
