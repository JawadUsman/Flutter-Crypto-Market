import 'package:crypto_exchange_app/models/currency_model.dart';
import 'package:crypto_exchange_app/services/api_service.dart';
import 'package:flutter/material.dart';

class CurrencyListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Currency> _allCurrencies = [];
  List<Currency> _filteredCurrencies = [];
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
    notifyListeners();

    try {
      _allCurrencies = await _apiService.fetchCurrencies();
      _filteredCurrencies = _allCurrencies; // Initialize filtered list
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
