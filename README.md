# Safolio Currency Converter

This application is a Flutter app that converts currencies, displays historical rates, and analyzes currency trends using the Frankfurter API.

## Features

### Currency Converter Screen
- Convert between two currencies ("from" and "to")
- Real-time conversion results
- User-friendly interface
- Easy currency swapping
- Loading states and error handling

### Historical Rates Screen
- Historical exchange rate information for a specific date
- Date picker to view rates on desired dates
- Interactive chart showing the trend between two currencies
- Trend analysis by selecting a date range

## Technologies Used

- **Flutter**: UI development framework
- **Dart**: Programming language
- **BLoC Pattern**: Architecture used for state management
- **Frankfurter API**: Open-source API used for exchange rate data
- **fl_chart**: Package used for chart visualization
- **http**: Package used for API requests
- **intl**: Package used for date and number formatting
- **equatable**: Package used for object comparison

## Architecture

This application was developed using the BLoC (Business Logic Component) architecture. This architecture provides a cleaner, more testable, and maintainable codebase by separating business logic from the UI layer.

### Project Structure

```
lib/
├── blocs/                  # BLoC components
│   └── currency/
│       ├── currency_bloc.dart
│       ├── currency_event.dart
│       ├── currency_state.dart
│       └── currency_bloc_exports.dart
├── models/                 # Data models
│   ├── currency_model.dart
│   └── historical_rate_model.dart
├── screens/                # Application screens
│   ├── currency_converter_screen.dart
│   └── historical_rates_screen.dart
├── services/               # API services
│   └── currency_service.dart
├── widgets/                # Reusable widgets
│   ├── amount_input.dart
│   ├── currency_dropdown.dart
│   └── historical_chart.dart
└── main.dart               # Application entry point
```

## Installation

1. Install Flutter (https://flutter.dev/docs/get-started/install)
2. Clone the project
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run
   ```

## Time Spent

Approximately 4 hours were spent on this project:

- **1 hour**: Project setup, architecture planning, and API service creation
- **1.5 hours**: Implementation of the currency converter screen and BLoC integration
- **1 hour**: Implementation of the historical rates screen and chart visualization
- **0.5 hours**: Debugging, code cleaning, and documentation

## Optional Improvements

The following optional improvements have been implemented in the project:

1. **Chart Visualization**: Interactive line chart to visualize historical exchange rate trends
2. **Currency Swap Feature**: Easily switch between "From" and "To" currencies
3. **User-Friendly Numerical Input**: Decimal precision and number formatting
4. **Enhanced UI/UX**: Loading states, error messages, and user feedback

## Future Enhancements

- Multi-language support
- Theme switching (dark/light mode)
- Favorite currencies list
- Offline mode support
- Notification system (when a specific exchange rate is reached)

## License

This project was developed as a case study for Safolio.


--Serhan Can Sayın