import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'addData.dart';

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
  int _currentIndex = 0; // BottomNavigationBar 현재 선택된 인덱스

  String get formattedDate {
    return DateFormat('yyyy년 MM월').format(_selectedDate);
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final androidId = await getAndroidId();
    if (androidId != null) {
      await sendDataToServer(androidId, _selectedDate.year, _selectedDate.month);
    }
  }

  Future<String?> getAndroidId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // Android 고유 ID
  }

  Future<void> sendDataToServer(String androidId, int year, int month) async {
    final url = Uri.parse('http://61.72.81.36:8080/'); // 백엔드 URL
    final response = await http.get(
      url.replace(queryParameters: {
        'androidId': androidId,
        'year': year.toString(),
        'month': month.toString(),
      }),
    );

    if (response.statusCode == 200) {
      print('Data sent successfully: ${response.body}');
    } else {
      print('Failed to send data: ${response.statusCode}');
    }
  }

  void _goToPreviousMonth() async {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });

    final androidId = await getAndroidId();
    if (androidId != null) {
      await sendDataToServer(androidId, _selectedDate.year, _selectedDate.month);
    }
  }

  void _goToNextMonth() async {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });

    final androidId = await getAndroidId();
    if (androidId != null) {
      await sendDataToServer(androidId, _selectedDate.year, _selectedDate.month);
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return Center(
          child: Text(
            "가계부 화면",
            style: const TextStyle(fontSize: 24),
          ),
        );
      case 1:
        return Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "통계 화면",
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ],
        );
      case 2:
        return Center(
          child: Text(
            "물가비교 화면",
            style: const TextStyle(fontSize: 24),
          ),
        );
      default:
        return Center(
          child: Text(
            "가계부 화면",
            style: const TextStyle(fontSize: 24),
          ),
        );
    }
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
      body: Container(
        color: const Color.fromARGB(255, 31, 31, 31), // Body 배경색 설정
        child: Column(
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
            // 수입, 지출, 합계 영역
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(color: Colors.white, width: 0.2),
                  bottom: BorderSide(color: Colors.white, width: 0.2),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryCard("수입", "₩2,000,000", Colors.blue),
                  _buildSummaryCard("지출", "₩1,200,000", Colors.red),
                  _buildSummaryCard("합계", "₩800,000", Colors.white),
                ],
              ),
            ),
            // Main Body
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const AddDataPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '가계부',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            label: '물가비교',
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

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
