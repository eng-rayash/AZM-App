/// Supported currencies in the Mudiri ERP system.
///
/// YER — Yemeni Rial  (ريال يمني)
/// SAR — Saudi Riyal  (ريال سعودي)
/// USD — US Dollar    (دولار أمريكي)
class AppCurrencies {
  AppCurrencies._();

  static const String yer = 'YER';
  static const String sar = 'SAR';
  static const String usd = 'USD';

  static const String defaultCurrency = sar;

  static const List<CurrencyInfo> all = [
    CurrencyInfo(
      code: yer,
      nameAr: 'ريال يمني',
      nameEn: 'Yemeni Rial',
      symbol: '﷼',
      flag: '🇾🇪',
      decimalPlaces: 0,
    ),
    CurrencyInfo(
      code: sar,
      nameAr: 'ريال سعودي',
      nameEn: 'Saudi Riyal',
      symbol: '﷼',
      flag: '🇸🇦',
      decimalPlaces: 2,
    ),
    CurrencyInfo(
      code: usd,
      nameAr: 'دولار أمريكي',
      nameEn: 'US Dollar',
      symbol: '\$',
      flag: '🇺🇸',
      decimalPlaces: 2,
    ),
  ];

  /// Returns the CurrencyInfo for a given code, defaults to SAR.
  static CurrencyInfo fromCode(String code) {
    return all.firstWhere(
      (c) => c.code == code,
      orElse: () => all[1], // SAR as fallback
    );
  }

  /// Formats an amount with the currency symbol.
  /// Example: formatAmount(1500.5, 'SAR') → '1,500.50 ﷼'
  static String formatAmount(double amount, String currencyCode) {
    final info = fromCode(currencyCode);
    final formatted = amount.toStringAsFixed(info.decimalPlaces);
    // Add thousands separator
    final parts = formatted.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    final result = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    return '$result ${info.symbol}';
  }

  /// Formats with currency name in Arabic.
  static String formatWithName(double amount, String currencyCode) {
    final info = fromCode(currencyCode);
    final formatted = amount.toStringAsFixed(info.decimalPlaces);
    final parts = formatted.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    final result = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    return '$result ${info.nameAr}';
  }

  /// Compact format for KPI cards (1,500,000 → 1.5M ﷼).
  static String formatCompact(double amount, String currencyCode) {
    final info = fromCode(currencyCode);
    final symbol = info.symbol;
    final abs = amount.abs();
    final sign = amount < 0 ? '−' : '';

    if (abs >= 1000000000) {
      return '$sign${(abs / 1000000000).toStringAsFixed(1)}B $symbol';
    } else if (abs >= 1000000) {
      return '$sign${(abs / 1000000).toStringAsFixed(1)}M $symbol';
    } else if (abs >= 1000) {
      return '$sign${(abs / 1000).toStringAsFixed(1)}K $symbol';
    } else {
      return '$sign${abs.toStringAsFixed(0)} $symbol';
    }
  }

  /// Returns the currency flag emoji for a code.
  static String flagFor(String code) => fromCode(code).flag;
}

/// Data class for currency information.
class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.symbol,
    required this.flag,
    required this.decimalPlaces,
  });

  final String code;
  final String nameAr;
  final String nameEn;
  final String symbol;
  final String flag;
  final int decimalPlaces;

  @override
  String toString() => '$flag $nameAr ($code)';
}