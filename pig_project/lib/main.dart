import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedView = '일별'; // 현재 선택된 보기 ("일별", "월별", "달력")

  String get formattedDate {
    return DateFormat('yyyy년 MM월').format(_selectedDate);
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(2.0), // AppBar의 높이 설정
        child: AppBar(
        backgroundColor: Colors.black, // AppBar 배경색
        centerTitle: true,
      ),
),
      body: Column(
        children: [
          // Custom Header
          Container(
            color: Colors.black,
            child: Column(
              children: [
                // 날짜와 화살표 영역
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _goToPreviousMonth,
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _goToNextMonth,
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                    ),
                  ],
                ),
                // 일별, 월별, 달력 버튼
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildToggleButton('일별'),
                      _buildToggleButton('월별'),
                      _buildToggleButton('달력'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Body
          Expanded(
            child: Center(
              child: Text(
                "$_selectedView 화면 테스트.",
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String view) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedView = view; // 선택된 보기 업데이트
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: _selectedView == view ? Colors.red : Colors.transparent, // 선택된 버튼 강조
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          view,
          style: TextStyle(
            color: _selectedView == view ? Colors.white : Colors.grey[400],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
