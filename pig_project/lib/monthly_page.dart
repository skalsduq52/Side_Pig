import 'package:flutter/material.dart';

class MonthlyPage extends StatelessWidget {
  const MonthlyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('월별 보기'),
      ),
      body: const Center(
        child: Text('월별 화면', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
