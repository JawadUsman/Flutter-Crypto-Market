import 'package:crypto_exchange_app/models/currency_model.dart';
import 'package:crypto_exchange_app/services/api_service.dart';
import 'package:flutter/material.dart';

class CurrencyListViewModel extends ChangeNotifier {
  // Allow ApiService to be injected, defaulting to a new instance if not provided.
  final ApiService _apiService;

  // Constructor for injection
  CurrencyListViewModel({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<Currency> _allCurrencies = [];
  // List<Currency> _filteredCurrencies = []; // This line seems redundant now as filtering is done in the getter
  String _searchQuery = '';

  List<Currency> get currencies {
    if (_searchQuery.isEmpty) {
      return _allCurrencies;
    } else {
      return _allCurrencies
          .where((currency) =>
              currency.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              currency.symbol.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCurrencies() async {
    _isLoading = true;
    _errorMessage = null;
    // Crucially, notify listeners *before* the async gap if you want UI to update to loading state immediately.
    // However, in view model tests, this specific timing might not be what you're testing unless
    // you're also testing listener notifications.
    notifyListeners(); 

    try {
      _allCurrencies = await _apiService.fetchCurrencies();
      // _filteredCurrencies = _allCurrencies; // Redundant
    } catch (e) {
      _errorMessage = 'Failed to load currencies: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
