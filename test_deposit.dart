import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://goldenpowerbd.shop/payment/deposit-create.php');
  final requestBody = jsonEncode({
    'uid': 'test_uid_123',
    'amount': 150.0,
  });

  print('==== DEBUG DEPOSIT CREATE ====');
  print('URL: $url');
  print('Headers: {"Content-Type": "application/json"}');
  print('Body: $requestBody');
  print('==============================');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: requestBody,
  );

  print('==== DEBUG DEPOSIT RESPONSE ====');
  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');
  print('================================');
}
