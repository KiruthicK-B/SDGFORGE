
import 'package:flutter/material.dart';
import 'package:vfarm/home.dart';

class AskExpertScreen extends StatelessWidget {
  const AskExpertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainWrapper(
      currentRoute: '/askExpert',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.question_answer, size: 64, color: Color(0xFF0A9D88)),
            SizedBox(height: 16),
            Text(
              "Ask an Expert",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Get advice from farming experts",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
