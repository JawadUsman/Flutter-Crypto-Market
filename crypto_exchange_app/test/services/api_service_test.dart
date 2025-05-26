import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
// Mockito is not strictly needed for this manual mock, but good to have for other tests
// import 'package:mockito/mockito.dart'; 
import 'package:crypto_exchange_app/models/currency_model.dart';
import 'package:crypto_exchange_app/services/api_service.dart';
import 'dart:convert'; // For jsonEncode

// Manual Mock for http.Client
class MockHttpClient implements http.Client {
  // Store expected responses for URLs
  final Map<String, Future<http.Response> Function(http.Request)> _mockResponses = {};
  final List<http.Request> requests = []; // To track requests made

  void addMockResponse(String urlSubstring, Future<http.Response> Function(http.Request) responseBuilder) {
    _mockResponses[urlSubstring] = responseBuilder;
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    final request = http.Request('GET', url);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    requests.add(request);
    
    for (var key in _mockResponses.keys) {
      if (url.toString().contains(key)) {
        return _mockResponses[key]!(request);
      }
    }
    // Default response if no mock is found for the URL, or throw
    return Future.value(http.Response('Not Found by MockHttpClient', 404));
  }

  // Implement other methods from http.Client if they were used by ApiService.
  // For ApiService, only 'get' is used.
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // This method needs to be implemented as it's abstract in http.Client.
    // However, it's not directly used by the ApiService's current implementation.
    // For robustness in the mock, provide a basic implementation or throw if unexpected.
    if (request is http.Request && request.method == 'GET') {
      return get(request.url, headers: request.headers).then((response) {
        return http.StreamedResponse(
          Stream.value(response.bodyBytes),
          response.statusCode,
          contentLength: response.contentLength,
          headers: response.headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase,
          request: response.request,
        );
      });
    }
    throw UnimplementedError('MockHttpClient.send called with unhandled request type: ${request.method}');
  }

  @override
  void close() {
    // Can be left empty if no resources need to be cleaned up.
  }

  // Add other methods like post, put, delete, read, readBytes if needed.
  // For this specific test, only 'get' is essential.
   @override
  Future<String> read(Uri url, {Map<String, String>? headers}) => throw UnimplementedError();
  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) => throw UnimplementedError();
  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) => throw UnimplementedError();
  @override
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => throw UnimplementedError();
  @override
  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => throw UnimplementedError();
  @override
  Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => throw UnimplementedError();
  @override
  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => throw UnimplementedError();
}


void main() {
  late ApiService apiService;
  late MockHttpClient mockHttpClient;

  // Base URL for the API
  const String baseUrl = 'https://api.coingecko.com/api/v3/coins/markets';

  setUp(() {
    mockHttpClient = MockHttpClient();
    apiService = ApiService(client: mockHttpClient);
  });

  // Sample API response data
  final mockApiResponse = [
    {'id': 'bitcoin', 'symbol': 'btc', 'name': 'Bitcoin', 'image': 'img_url', 'current_price': 50000.0, 'market_cap': 1000000000.0, 'price_change_24h': 1000.0, 'market_cap_rank': 1, 'total_volume': 100000.0},
    {'id': 'ethereum', 'symbol': 'eth', 'name': 'Ethereum', 'image': 'img_url', 'current_price': 3000.0, 'market_cap': 500000000.0, 'price_change_24h': 200.0, 'market_cap_rank': 2, 'total_volume': 50000.0},
  ];

  final mockApiErrorBody = {'status': {'error_code': 404, 'error_message': 'Not Found'}};


  test('fetchCurrencies returns a list of currencies on successful API call', () async {
    // Arrange
    mockHttpClient.addMockResponse(baseUrl, (request) async {
      // Verify query parameters
      expect(request.url.queryParameters['vs_currency'], 'usd');
      expect(request.url.queryParameters['order'], 'market_cap_desc');
      expect(request.url.queryParameters['per_page'], '100');
      expect(request.url.queryParameters['page'], '1');
      expect(request.url.queryParameters['sparkline'], 'false');
      return http.Response(jsonEncode(mockApiResponse), 200);
    });

    // Act
    final currencies = await apiService.fetchCurrencies();

    // Assert
    expect(currencies, isA<List<Currency>>());
    expect(currencies.length, 2);
    expect(currencies[0].name, 'Bitcoin');
    expect(currencies[1].currentPrice, 3000.0);
    expect(mockHttpClient.requests.length, 1); // Verify client was called
    expect(mockHttpClient.requests.first.url.toString(), startsWith(baseUrl));
  });

  test('fetchCurrencies throws an exception on API error (non-200 status)', () async {
    // Arrange
    mockHttpClient.addMockResponse(baseUrl, (request) async {
      return http.Response(jsonEncode(mockApiErrorBody), 404);
    });

    // Act & Assert
    expect(
      () async => await apiService.fetchCurrencies(),
      // Check for the specific exception message from ApiService
      throwsA(isA<Exception>().having(
        (e) => e.toString(), 
        'message', 
        contains('Failed to load currencies (status code: 404)')
      ))
    );
    expect(mockHttpClient.requests.length, 1); // Verify client was called
  });

  test('fetchCurrencies throws an exception on http client error (e.g., network issue)', () async {
    // Arrange
    mockHttpClient.addMockResponse(baseUrl, (request) async {
      throw http.ClientException('Network error');
    });

    // Act & Assert
      expect(
      () async => await apiService.fetchCurrencies(),
      throwsA(isA<Exception>().having(
        (e) => e.toString(), 
        'message', 
        // This checks that the original ClientException is part of the new Exception's message
        contains('Failed to load currencies: ClientException: Network error') 
      ))
    );
    expect(mockHttpClient.requests.length, 1);
  });
}
