class MoneyData {
  final int amount;
  final String category;
  final String paymentMethod;
  final String content;
  final String type;
  final String date;

  MoneyData({
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.content,
    required this.type,
    required this.date,
  });

  factory MoneyData.fromJson(Map<String, dynamic> json) {
    return MoneyData(
      amount: json['amount'] ?? 0, // null 값인 경우 기본값 0 사용
      category: json['category'] ?? 'N/A', // null 값인 경우 기본값 "N/A" 사용
      paymentMethod: json['paymentMethod'] ?? 'N/A', // null 값인 경우 기본값 "N/A" 사용
      content: json['content'] ?? 'N/A', // null 값인 경우 기본값 "N/A" 사용
      type: json['type'] ?? 'N/A', // null 값인 경우 기본값 "N/A" 사용
      date: json['date'] ?? '', // null 값인 경우 기본값 빈 문자열 사용
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'content': content,
      'type': type,
      'date': date,
    };
  }

  
}