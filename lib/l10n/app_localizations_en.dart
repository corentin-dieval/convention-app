// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Convention App';

  @override
  String get modeRefill => 'Stock';

  @override
  String get modeConvention => 'Conventions';

  @override
  String get modeSettings => 'Settings';

  @override
  String get itemsTitle => 'Items';

  @override
  String get addItem => 'Add item';

  @override
  String get editItem => 'Edit item';

  @override
  String get deleteItem => 'Delete item';

  @override
  String deleteItemConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get itemName => 'Name';

  @override
  String get itemDescription => 'Description';

  @override
  String get itemPrice => 'Unit price';

  @override
  String get itemStock => 'Stock quantity';

  @override
  String get itemImage => 'Image';

  @override
  String get pickFromGallery => 'Gallery';

  @override
  String get pickFromCamera => 'Camera';

  @override
  String get removeImage => 'Remove image';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get conventionsTitle => 'Conventions';

  @override
  String get addConvention => 'New convention';

  @override
  String get editConvention => 'Edit convention';

  @override
  String get deleteConvention => 'Delete convention';

  @override
  String get conventionName => 'Convention name';

  @override
  String get conventionStartDate => 'Start date';

  @override
  String get conventionEndDate => 'End date (optional)';

  @override
  String get conventionClosed => 'Closed';

  @override
  String get conventionOpen => 'Open';

  @override
  String get closeConvention => 'Close convention';

  @override
  String get reopenConvention => 'Reopen convention';

  @override
  String get conventionDetail => 'Convention detail';

  @override
  String get addEntry => 'Add item to sale';

  @override
  String get quantity => 'Qty';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get receipt => 'Receipt';

  @override
  String get shareReceipt => 'Share receipt';

  @override
  String get noItems => 'No items yet. Add some in Stock mode.';

  @override
  String get noConventions => 'No conventions yet.';

  @override
  String get noEntries => 'No items added yet.';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get invalidPrice => 'Enter a valid price (e.g. 5.00)';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get exportData => 'Export data';

  @override
  String get exportDataDesc =>
      'Export all items and conventions as JSON (for backup / device transfer)';

  @override
  String get importData => 'Import data';

  @override
  String get importDataDesc => 'Restore from a previously exported JSON file';

  @override
  String get exportSuccess => 'Data exported successfully';

  @override
  String get importSuccess => 'Data imported successfully';

  @override
  String importError(String error) {
    return 'Import failed: $error';
  }

  @override
  String get importConfirm => 'This will replace all current data. Continue?';

  @override
  String get errorGeneric => 'An error occurred. Please try again.';

  @override
  String stockLabel(int qty) {
    return 'Stock: $qty';
  }

  @override
  String priceLabel(String price) {
    return '$price';
  }

  @override
  String get analyticsStatistics => 'Analytics & Statistics';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get averageCart => 'Average Cart Value';

  @override
  String get totalTransactions => 'Total Transactions';

  @override
  String get topItems => 'Top Selling Items';

  @override
  String get conventionStats => 'Convention Statistics';

  @override
  String get noData => 'No data available';

  @override
  String get revenue => 'Revenue';

  @override
  String get name => 'Name';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get payCash => 'Cash';

  @override
  String get payCard => 'Bank card';

  @override
  String get allConventions => 'All conventions';

  @override
  String get clients => 'Clients';

  @override
  String get cashRevenue => 'Cash';

  @override
  String get cardRevenue => 'Card';

  @override
  String get paymentBreakdown => 'Payment breakdown';
}
