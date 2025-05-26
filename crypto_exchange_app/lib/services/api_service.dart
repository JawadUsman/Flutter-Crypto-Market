import 'dart:convert';
import 'package:crypto_exchange_app/models/currency_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Allow http.Client to be injected, defaulting to a new instance if not provided.
  final http.Client _client;

  // Constructor for injection
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Currency>> fetchCurrencies() async {
    const String apiUrl = 'https://api.coingecko.com/api/v3/coins/markets';
    final Map<String, String> queryParams = {
      'vs_currency': 'usd',
      'order': 'market_cap_desc',
      'per_page': '100',
      'page': '1',
      'sparkline': 'false',
    };

    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Currency.fromJson(json)).toList();
      } else {
        print('API request failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load currencies');
      }
    } catch (e) {
      print('Error fetching currencies: $e');
      throw Exception('Failed to load currencies: $e');
    }
  }
}

// Optional: For manual testing
/*
void main() async {
  final apiService = ApiService();
  try {
    final currencies = await apiService.fetchCurrencies();
    for (var currency in currencies) {
      print('Name: ${currency.name}, Price: \$${currency.currentPrice}');
    }
  } catch (e) {
    print('Error in main: $e');
  }
}
*/
