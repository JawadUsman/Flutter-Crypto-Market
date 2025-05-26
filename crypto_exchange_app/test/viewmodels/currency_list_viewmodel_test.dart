import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:crypto_exchange_app/models/currency_model.dart';
import 'package:crypto_exchange_app/services/api_service.dart';
import 'package:crypto_exchange_app/viewmodels/currency_list_viewmodel.dart';
// import 'package:http/http.dart' as http; // Not strictly needed for this manual mock

// Manual MockApiService implementation
class MockApiService implements ApiService {
  Future<List<Currency>> Function()? _fetchCurrenciesMock;
  int fetchCurrenciesCallCount = 0;

  void setFetchCurrenciesMock(Future<List<Currency>> Function() mock) {
    _fetchCurrenciesMock = mock;
  }

  @override
  Future<List<Currency>> fetchCurrencies() {
    fetchCurrenciesCallCount++;
    if (_fetchCurrenciesMock != null) {
      return _fetchCurrenciesMock!();
    }
    return Future.value([]); // Default empty list
  }
}

void main() {
  late CurrencyListViewModel viewModel;
  late MockApiService mockApiService;

  // Sample currency data for testing
  final mockCurrencies = [
    Currency(id: 'bitcoin', symbol: 'btc', name: 'Bitcoin', image: 'btc.png', currentPrice: 50000.0, marketCap: 1000000000, priceChange24h: 1000.0, marketCapRank: 1, totalVolume: 100000.0),
    Currency(id: 'ethereum', symbol: 'eth', name: 'Ethereum', image: 'eth.png', currentPrice: 3000.0, marketCap: 500000000, priceChange24h: 200.0, marketCapRank: 2, totalVolume: 50000.0),
  ];

  setUp(() {
    mockApiService = MockApiService();
    viewModel = CurrencyListViewModel(apiService: mockApiService);
  });

  test('Initial state is correct', () {
    expect(viewModel.currencies, isEmpty);
    expect(viewModel.isLoading, false);
    expect(viewModel.errorMessage, null);
  });

  group('fetchCurrencies', () {
    test('loads currencies successfully', () async {
      // Arrange
      mockApiService.setFetchCurrenciesMock(() async => mockCurrencies);

      // Act
      await viewModel.fetchCurrencies();

      // Assert
      expect(viewModel.currencies.length, 2);
      expect(viewModel.currencies[0].name, 'Bitcoin');
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(mockApiService.fetchCurrenciesCallCount, 1);
    });

    test('handles API error gracefully', () async {
      // Arrange
      final exception = Exception('API Error');
      mockApiService.setFetchCurrenciesMock(() async => throw exception);

      // Act
      await viewModel.fetchCurrencies();

      // Assert
      expect(viewModel.currencies, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, contains('Failed to load currencies: Exception: API Error'));
      expect(mockApiService.fetchCurrenciesCallCount, 1);
    });

    test('sets isLoading to true while fetching and false afterwards', () async {
      // Arrange
      // A variable to check isLoading state *during* the async operation
      bool isLoadingDuringFetch = false;
      
      mockApiService.setFetchCurrenciesMock(() async {
        // This part of the mock function is executed when `await _apiService.fetchCurrencies()` is called.
        // At this point, `_isLoading` should have been set to true by the ViewModel.
        isLoadingDuringFetch = viewModel.isLoading;
        return mockCurrencies;
      });

      // Act
      final future = viewModel.fetchCurrencies(); // Don't await yet

      // Assert that isLoading is true immediately after calling fetchCurrencies (due to notifyListeners before async call)
      // This relies on the fact that `notifyListeners()` is called right before `await _apiService.fetchCurrencies()`.
      expect(viewModel.isLoading, isTrue, reason: "isLoading should be true right after fetchCurrencies is called.");

      await future; // Now await completion

      // Assert isLoading is false after completion
      expect(viewModel.isLoading, isFalse, reason: "isLoading should be false after fetchCurrencies completes.");
      // Assert that isLoading was indeed true during the execution of the mock's async part
      expect(isLoadingDuringFetch, isTrue, reason: "isLoading should have been true during the async fetch operation.");
    });
  });

  group('updateSearchQuery', () {
    test('filters currencies based on search query (name)', () async {
      // Arrange
      mockApiService.setFetchCurrenciesMock(() async => mockCurrencies);
      await viewModel.fetchCurrencies(); // Load initial data

      // Act
      viewModel.updateSearchQuery('Bitcoin');

      // Assert
      expect(viewModel.currencies.length, 1);
      expect(viewModel.currencies[0].name, 'Bitcoin');
    });

    test('filters currencies based on search query (symbol)', () async {
      // Arrange
      mockApiService.setFetchCurrenciesMock(() async => mockCurrencies);
      await viewModel.fetchCurrencies();

      // Act
      viewModel.updateSearchQuery('eth');

      // Assert
      expect(viewModel.currencies.length, 1);
      expect(viewModel.currencies[0].name, 'Ethereum');
    });

    test('returns all currencies if search query is empty', () async {
      // Arrange
      mockApiService.setFetchCurrenciesMock(() async => mockCurrencies);
      await viewModel.fetchCurrencies();
      viewModel.updateSearchQuery('Bitcoin'); // First filter
      
      // Act
      viewModel.updateSearchQuery(''); // Then clear filter

      // Assert
      expect(viewModel.currencies.length, 2);
    });

    test('search is case-insensitive', () async {
      // Arrange
      mockApiService.setFetchCurrenciesMock(() async => mockCurrencies);
      await viewModel.fetchCurrencies();

      // Act
      viewModel.updateSearchQuery('bItCoIn');

      // Assert
      expect(viewModel.currencies.length, 1);
      expect(viewModel.currencies[0].name, 'Bitcoin');
    });
  });
}
