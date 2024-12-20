import 'package:flutter/material.dart';

class DailyPage extends StatelessWidget {
  const DailyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일별 보기'),
      ),
      body: const Center(
        child: Text('일별 화면', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
