import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'addData.dart';
import 'model/MoneyData.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 초기화
  await initializeDateFormatting('ko'); 
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
  String _selectedView = '일별'; 
  int _currentIndex = 0; // BottomNavigationBar 현재 선택된 인덱스
  Future<List<Map<String, dynamic>>>? _moneyDataFuture;

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
      setState(() {
        _moneyDataFuture = getGroupedData(androidId, _selectedDate.year, _selectedDate.month);
        
      });
    } else {
      _moneyDataFuture = Future.value([]);
    }
  }

  Color _getDayColor(DateTime date) {
  if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
    return Colors.red; // 토요일, 일요일: 빨간색
  } else {
    return Colors.blue; // 월요일 ~ 금요일: 파란색
  }
}

  Future<List<Map<String, dynamic>>> getGroupedData(String androidId, int year, int month) async {
    final List<Map<String, dynamic>> moneyDataList = await sendDataToServer(androidId, year, month);

    final Map<String, List<MoneyData>> groupedData = {};
    for (var group in moneyDataList) {
      final date = group['date'] as String; // 날짜 키
      final List<MoneyData> moneyList = group['data'] as List<MoneyData>;

      // 날짜를 키로 그룹화
      if (!groupedData.containsKey(date)) {
        groupedData[date] = [];
      }
      groupedData[date]!.addAll(moneyList); // 그룹화된 리스트에 데이터 추가
    }

    return groupedData.entries.map((entry) {
      final result = {
        'date': entry.key,
        'data': entry.value.map((money) => money.toJson()).toList(),
      };
      return result;
    }).toList();
  }

  Future<String?> getAndroidId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // Android 고유 ID
  }

  Future<List<Map<String, dynamic>>> sendDataToServer(String androidId, int year, int month) async {
    final url = Uri.parse('http://61.72.81.36:8080/money/day');
    try {
      final response = await http.get(
        url.replace(queryParameters: {
          'androidID': androidId,
          'year': year.toString(),
          'month': month.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData.map((item) {
          return {
            'date': item['date'],
            'data': (item['data'] as List<dynamic>)
                .map((data) => MoneyData.fromJson(data as Map<String, dynamic>))
                .toList(),
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  void _goToPreviousMonth() async {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });

    final androidId = await getAndroidId();
    if (androidId != null) {
      setState(() {
        // _moneyDataFuture에 새로운 Future 값을 할당하여 FutureBuilder가 재빌드되도록 만듦
        _moneyDataFuture = getGroupedData(androidId, _selectedDate.year, _selectedDate.month);
    });
  }
}

  void _goToNextMonth() async {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });

    final androidId = await getAndroidId();
    if (androidId != null) {
      setState(() {
        _moneyDataFuture = getGroupedData(androidId, _selectedDate.year, _selectedDate.month);
      });
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
        color: const Color.fromARGB(255, 31, 31, 31), 
        child: Column(
          children: [
            Container(
              color: Colors.black,
              child: Column(
                children: [
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _moneyDataFuture, // 그룹화된 데이터를 가져오는 Future
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  }

                  // 데이터 처리
                  final groupedData = snapshot.data!;

                  return ListView.builder(
                    itemCount: groupedData.length,
                    itemBuilder: (context, index) {
                      final group = groupedData[index];
                      final date = group['date'] as String; // 날짜 키
                      final moneyList = (group['data'] as List<dynamic>)
                          .map((item) => MoneyData.fromJson(item as Map<String, dynamic>))
                          .toList();

                      return Container(
                        margin: EdgeInsets.only(bottom: 0), // 그룹 간 간격 추가
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 날짜 출력
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.white, width: 0.2),
                                  bottom: BorderSide(color: Colors.white, width: 0.2),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // 날짜 표시
                                  Text(
                                    DateFormat('dd').format(DateTime.parse(date)),
                                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  SizedBox(width: 7), // 날짜와 요일 사이 간격
                                  // 요일 표시
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getDayColor(DateTime.parse(date)),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      DateFormat('EEEE', 'ko').format(DateTime.parse(date)), // 요일 축약형 표시
                                      style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 해당 날짜의 데이터 리스트 출력
                            ...moneyList.map((money) {
                              return Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white, width: 0.2), // 아래쪽 흰색 구분선만 추가
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      money.category,
                                      style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold,),
                                      
                                    ),
                                    SizedBox(width: 18), // 항목 간 간격 추가
                                    if (money.content.isNotEmpty)
                                      Expanded(
                                        flex:4,
                                        child: Text(
                                          money.content,
                                          style: TextStyle(fontSize: 14, color: Colors.white),
                                          overflow: TextOverflow.ellipsis, // 말줄임표 설정
                                          maxLines: 1, // 한 줄로 제한
                                        ),
                                    ),
                                    Spacer(),
                                    Text(
                                      '${NumberFormat('#,###').format(money.amount)}원', 
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: money.type == 'income' ? Colors.blue : Colors.red, // type에 따라 색상 설정
                                        fontWeight: FontWeight.bold, // 강조 (선택 사항)
                                      ),
                                    ), 
                                  ],
                                )
                              );
                            }).toList(),
                            Container(
                              width: double.infinity,
                              color: Colors.black, // 검정색 배경
                              height: 20, // 원하는 높이로 설정
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
          final result = await Navigator.push( // <-- 변경된 부분
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

          if (result == true) { // <-- 변경된 부분
            final androidId = await getAndroidId(); // <-- 변경된 부분
            if (androidId != null) {
              await getGroupedData(androidId, _selectedDate.year, _selectedDate.month); // <-- 변경된 부분
            }
          }
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      )
    : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async{
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) { // 가계부 탭 인덱스
            final androidId = await getAndroidId();
            if (androidId != null) {
              await getGroupedData(androidId, _selectedDate.year, _selectedDate.month);
            }
          }
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
