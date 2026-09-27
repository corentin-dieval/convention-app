import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'Convention App'**
  String get appTitle;

  /// Refill / stock management mode tab label
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get modeRefill;

  /// Convention mode tab label
  ///
  /// In en, this message translates to:
  /// **'Conventions'**
  String get modeConvention;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get modeSettings;

  /// No description provided for @itemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsTitle;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get deleteItem;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteItemConfirm(String name);

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get itemName;

  /// No description provided for @itemDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get itemDescription;

  /// No description provided for @itemPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get itemPrice;

  /// No description provided for @itemStock.
  ///
  /// In en, this message translates to:
  /// **'Stock quantity'**
  String get itemStock;

  /// No description provided for @itemImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get itemImage;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get pickFromGallery;

  /// No description provided for @pickFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get pickFromCamera;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeImage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @conventionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conventions'**
  String get conventionsTitle;

  /// No description provided for @addConvention.
  ///
  /// In en, this message translates to:
  /// **'New convention'**
  String get addConvention;

  /// No description provided for @editConvention.
  ///
  /// In en, this message translates to:
  /// **'Edit convention'**
  String get editConvention;

  /// No description provided for @deleteConvention.
  ///
  /// In en, this message translates to:
  /// **'Delete convention'**
  String get deleteConvention;

  /// No description provided for @conventionName.
  ///
  /// In en, this message translates to:
  /// **'Convention name'**
  String get conventionName;

  /// No description provided for @conventionStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get conventionStartDate;

  /// No description provided for @conventionEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date (optional)'**
  String get conventionEndDate;

  /// No description provided for @conventionClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get conventionClosed;

  /// No description provided for @conventionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get conventionOpen;

  /// No description provided for @closeConvention.
  ///
  /// In en, this message translates to:
  /// **'Close convention'**
  String get closeConvention;

  /// No description provided for @reopenConvention.
  ///
  /// In en, this message translates to:
  /// **'Reopen convention'**
  String get reopenConvention;

  /// No description provided for @conventionDetail.
  ///
  /// In en, this message translates to:
  /// **'Convention detail'**
  String get conventionDetail;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add item to sale'**
  String get addEntry;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get quantity;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @shareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share receipt'**
  String get shareReceipt;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items yet. Add some in Stock mode.'**
  String get noItems;

  /// No description provided for @noConventions.
  ///
  /// In en, this message translates to:
  /// **'No conventions yet.'**
  String get noConventions;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No items added yet.'**
  String get noEntries;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price (e.g. 5.00)'**
  String get invalidPrice;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @exportDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Export all items and conventions as JSON (for backup / device transfer)'**
  String get exportDataDesc;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importData;

  /// No description provided for @importDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore from a previously exported JSON file'**
  String get importDataDesc;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get exportSuccess;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully'**
  String get importSuccess;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importError(String error);

  /// No description provided for @importConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will replace all current data. Continue?'**
  String get importConfirm;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorGeneric;

  /// No description provided for @stockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock: {qty}'**
  String stockLabel(int qty);

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'{price}'**
  String priceLabel(String price);

  /// No description provided for @analyticsStatistics.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Statistics'**
  String get analyticsStatistics;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @averageCart.
  ///
  /// In en, this message translates to:
  /// **'Average Cart Value'**
  String get averageCart;

  /// No description provided for @totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get totalTransactions;

  /// No description provided for @topItems.
  ///
  /// In en, this message translates to:
  /// **'Top Selling Items'**
  String get topItems;

  /// No description provided for @conventionStats.
  ///
  /// In en, this message translates to:
  /// **'Convention Statistics'**
  String get conventionStats;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @payCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get payCash;

  /// No description provided for @payCard.
  ///
  /// In en, this message translates to:
  /// **'Bank card'**
  String get payCard;

  /// No description provided for @allConventions.
  ///
  /// In en, this message translates to:
  /// **'All conventions'**
  String get allConventions;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @cashRevenue.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashRevenue;

  /// No description provided for @cardRevenue.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get cardRevenue;

  /// No description provided for @paymentBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Payment breakdown'**
  String get paymentBreakdown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
