# Flutter Crypto Market Application

A Flutter application that displays cryptocurrency market data.

## Main Business Logic

The application's core business logic revolves around fetching, managing, and displaying cryptocurrency data:

- **Data Fetching**: The `ApiService` class (located in `crypto_exchange_app/lib/services/api_service.dart`) is responsible for fetching live cryptocurrency data. It makes HTTP GET requests to the CoinGecko API.
- **State Management**: The `CurrencyListViewModel` class (in `crypto_exchange_app/lib/viewmodels/currency_list_viewmodel.dart`) handles the state for the currency list screen. This includes:
    - Managing loading states while data is being fetched.
    - Handling potential errors during API calls.
    - Implementing search functionality to filter currencies by name or symbol.
    - Notifying the UI of any changes to the state or data.
- **Data Modeling**: The `Currency` class (defined in `crypto_exchange_app/lib/models/currency_model.dart`) defines the structure for cryptocurrency data. It includes properties like ID, name, symbol, current price, market cap, price change, etc., and includes a factory constructor `fromJson` to parse the API response.

## UI Templates

The application consists of two main screens that serve as UI templates for presenting cryptocurrency data:

- **`CurrencyListScreen`** (`crypto_exchange_app/lib/screens/currency_list_screen.dart`):
    - This is the main screen of the application.
    - It displays a scrollable list of cryptocurrencies, showing key information like the currency's image, name, symbol, and current price.
    - It includes a search bar at the top, allowing users to filter the list by currency name or symbol.
    - Tapping on a currency in the list navigates the user to the `CurrencyDetailScreen`.

- **`CurrencyDetailScreen`** (`crypto_exchange_app/lib/screens/currency_detail_screen.dart`):
    - This screen provides a more detailed view of a selected cryptocurrency.
    - It displays information such as the currency's image, name, symbol, current price, market capitalization, 24-hour price change, market cap rank, and total volume.
    - The price change is color-coded (green for positive, red for negative) for quick visual understanding.

## API Used

The application utilizes the **CoinGecko API** to fetch cryptocurrency data.

- **Endpoint**: `https://api.coingecko.com/api/v3/coins/markets`
- **Description**: This endpoint provides a wide range of market data for various cryptocurrencies. The data includes current price, market capitalization, trading volume, 24-hour price change, market cap rank, and more.
- **Key Query Parameters Used**:
    - `vs_currency=usd`: To get prices in US dollars.
    - `order=market_cap_desc`: To sort currencies by market capitalization in descending order.
    - `per_page=100`: To fetch 100 currencies per page.
    - `page=1`: To fetch the first page of results.
    - `sparkline=false`: To exclude sparkline data.

This API is crucial for providing the real-time data displayed within the application.
