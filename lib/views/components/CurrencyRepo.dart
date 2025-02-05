import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class CurrencyRepository {
  String API_KEY = dotenv.env['API_KEY']!;
  final client = Client();
  final baseUrl = 'https://api.exchangeratesapi.io/v1/';

  Future<double> getCurrencyConversionRate(
      {String? convertFrom, String? convertTo, num? amount}) async {
    final response = await client.get(Uri.parse('${baseUrl}convert?access_key=$API_KEY&from=$convertFrom&to=$convertTo&amount=$amount'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json.info!.rate!;
    } else {
      print(response.reasonPhrase);
      throw Exception('Unable to get data');
    }
  }
}