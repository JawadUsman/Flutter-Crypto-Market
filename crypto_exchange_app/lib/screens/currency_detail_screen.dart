import 'package:crypto_exchange_app/models/currency_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Added for number formatting

class CurrencyDetailScreen extends StatelessWidget {
  final Currency currency;

  const CurrencyDetailScreen({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    final priceChangeColor = currency.priceChange24h >= 0 ? Colors.green : Colors.red;
    final compactFormat = NumberFormat.compact(locale: 'en_US');

    return Scaffold(
      appBar: AppBar(
        title: Text(currency.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  currency.image,
                  // Add errorBuilder to NetworkImage
                  errorBuilder: (context, error, stackTrace) {
                    // Log the error for debugging if needed
                    // print('Error loading image for ${currency.name} in DetailScreen: $error');
                    // Return a placeholder widget
                    return const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey, // Default background
                      child: Icon(
                        Icons.broken_image, // Placeholder icon
                        color: Colors.white,
                        size: 40,
                      ),
                    );
                  },
                ),
                // Fallback child if backgroundImage itself is null or fails before errorBuilder is called
                // (though errorBuilder in NetworkImage should handle most cases)
                child: currency.image.isEmpty 
                    ? const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 40,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                currency.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                currency.symbol.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                NumberFormat.currency(locale: 'en_US', symbol: '\$').format(currency.currentPrice),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Details Section
              _buildDetailItem(
                context: context,
                label: "Market Cap",
                value: '\$${compactFormat.format(currency.marketCap)}',
              ),
              _buildDetailItem(
                context: context,
                label: "Price Change (24h)",
                value: NumberFormat.currency(locale: 'en_US', symbol: '\$').format(currency.priceChange24h),
                valueColor: priceChangeColor,
              ),
              _buildDetailItem(
                context: context,
                label: "Market Cap Rank",
                value: '#${currency.marketCapRank}',
              ),
              _buildDetailItem(
                context: context,
                label: "Total Volume (24h)",
                value: NumberFormat.compactCurrency(locale: 'en_US', symbol: '\$').format(currency.totalVolume),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                ),
          ),
        ],
      ),
    );
  }
}
