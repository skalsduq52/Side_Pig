import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('달력 보기'),
      ),
      body: const Center(
        child: Text('달력 화면', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
