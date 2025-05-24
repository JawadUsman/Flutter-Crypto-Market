import 'package:crypto_exchange_app/screens/currency_detail_screen.dart';
import 'package:crypto_exchange_app/viewmodels/currency_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrencyListScreen extends StatefulWidget {
  const CurrencyListScreen({super.key});

  @override
  State<CurrencyListScreen> createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  @override
  void initState() {
    super.initState();
    // Access the ViewModel and fetch currencies
    // We set listen to false because we don't need to rebuild this widget when data changes.
    // The Consumer widget below will handle rebuilding the UI.
    Provider.of<CurrencyListViewModel>(context, listen: false)
        .fetchCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    // Access the ViewModel
    // No need to call Provider.of<CurrencyListViewModel>(context) here
    // as the Consumer widget below will provide the ViewModel instance.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Prices'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or symbol',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              ),
              onChanged: (query) {
                // Use listen:false for actions that don't require UI rebuilds at this level
                Provider.of<CurrencyListViewModel>(context, listen: false)
                    .updateSearchQuery(query);
              },
            ),
          ),
          Expanded(
            child: Consumer<CurrencyListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.currencies.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null && viewModel.currencies.isEmpty) {
                  return Center(child: Text(viewModel.errorMessage!));
                }

                if (viewModel.currencies.isEmpty && !viewModel.isLoading) {
                  return const Center(child: Text('No currencies found or match your search.'));
                }
                
                if (viewModel.currencies.isEmpty && viewModel.isLoading) {
                   return const Center(child: CircularProgressIndicator());
                }


                return ListView.builder(
                  itemCount: viewModel.currencies.length,
                  itemBuilder: (context, index) {
                    final currency = viewModel.currencies[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(currency.image),
                        onBackgroundImageError: (exception, stackTrace) {
                          // Optionally log the error
                          // print('Error loading image for ${currency.name}: $exception');
                        },
                        // Show a placeholder if image is empty or fails to load
                        child: NetworkImage(currency.image).toString().isEmpty 
                               || currency.image.isEmpty // Added check for empty currency.image string
                            ? const Icon(Icons.error) 
                            : null,
                      ),
                      title: Text(currency.name),
                      subtitle: Text(currency.symbol.toUpperCase()),
                      trailing: Text('\$${currency.currentPrice.toStringAsFixed(2)}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CurrencyDetailScreen(currency: currency),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
