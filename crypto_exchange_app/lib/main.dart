import 'package:crypto_exchange_app/screens/currency_list_screen.dart';
import 'package:crypto_exchange_app/viewmodels/currency_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrencyListViewModel()),
        // Other providers if any
      ],
      child: MaterialApp(
        title: 'Crypto Exchange App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const CurrencyListScreen(),
      ),
    );
  }
}
