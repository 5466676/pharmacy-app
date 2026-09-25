import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'دوايا'**
  String get appName;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get required;

  /// No description provided for @invalidNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم غير صحيح'**
  String get invalidNumber;

  /// No description provided for @units.
  ///
  /// In ar, this message translates to:
  /// **'{count} علبة'**
  String units(String count);

  /// No description provided for @none.
  ///
  /// In ar, this message translates to:
  /// **'—'**
  String get none;

  /// No description provided for @offline.
  ///
  /// In ar, this message translates to:
  /// **'يعمل بدون إنترنت'**
  String get offline;

  /// No description provided for @signOut.
  ///
  /// In ar, this message translates to:
  /// **'تبديل الموظف'**
  String get signOut;

  /// No description provided for @owner.
  ///
  /// In ar, this message translates to:
  /// **'مالك'**
  String get owner;

  /// No description provided for @employee.
  ///
  /// In ar, this message translates to:
  /// **'موظف'**
  String get employee;

  /// No description provided for @setupTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلين بدوايا'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'خلّينا نجهّز هالجهاز للصيدلية. كل شي بينحفظ على الجهاز وبيشتغل بدون إنترنت.'**
  String get setupSubtitle;

  /// No description provided for @pharmacyNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الصيدلية'**
  String get pharmacyNameLabel;

  /// No description provided for @deviceNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم هالجهاز'**
  String get deviceNameLabel;

  /// No description provided for @deviceNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: لابتوب الكاونتر'**
  String get deviceNameHint;

  /// No description provided for @ownerNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسمك (المالك)'**
  String get ownerNameLabel;

  /// No description provided for @pinLabel.
  ///
  /// In ar, this message translates to:
  /// **'رمز الدخول (٤ أرقام)'**
  String get pinLabel;

  /// No description provided for @pinConfirmLabel.
  ///
  /// In ar, this message translates to:
  /// **'أعد الرمز'**
  String get pinConfirmLabel;

  /// No description provided for @pinMismatch.
  ///
  /// In ar, this message translates to:
  /// **'الرمزين مو متطابقين'**
  String get pinMismatch;

  /// No description provided for @pinInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الرمز لازم يكون ٤ أرقام'**
  String get pinInvalid;

  /// No description provided for @startButton.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get startButton;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'مين عم يشتغل هلق؟'**
  String get loginTitle;

  /// No description provided for @loginEnterPin.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز {name}'**
  String loginEnterPin(String name);

  /// No description provided for @wrongPin.
  ///
  /// In ar, this message translates to:
  /// **'الرمز غلط'**
  String get wrongPin;

  /// No description provided for @changeEmployee.
  ///
  /// In ar, this message translates to:
  /// **'غيّر الموظف'**
  String get changeEmployee;

  /// No description provided for @navDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get navDashboard;

  /// No description provided for @navPos.
  ///
  /// In ar, this message translates to:
  /// **'البيع'**
  String get navPos;

  /// No description provided for @navInventory.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية والمخزون'**
  String get navInventory;

  /// No description provided for @navDebts.
  ///
  /// In ar, this message translates to:
  /// **'الزبائن والديون'**
  String get navDebts;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @navSectionMain.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلية'**
  String get navSectionMain;

  /// No description provided for @navSectionAdmin.
  ///
  /// In ar, this message translates to:
  /// **'الإدارة'**
  String get navSectionAdmin;

  /// No description provided for @greeting.
  ///
  /// In ar, this message translates to:
  /// **'أهلين {name}'**
  String greeting(String name);

  /// No description provided for @newSale.
  ///
  /// In ar, this message translates to:
  /// **'بيع جديد'**
  String get newSale;

  /// No description provided for @statSalesToday.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات اليوم'**
  String get statSalesToday;

  /// No description provided for @statSalesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عملية'**
  String statSalesCount(String count);

  /// No description provided for @statOpenDebts.
  ///
  /// In ar, this message translates to:
  /// **'ديون مفتوحة'**
  String get statOpenDebts;

  /// No description provided for @statCustomersCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} زبون'**
  String statCustomersCount(String count);

  /// No description provided for @statNearExpiry.
  ///
  /// In ar, this message translates to:
  /// **'قرب تنتهي صلاحيته'**
  String get statNearExpiry;

  /// No description provided for @statWithinDays.
  ///
  /// In ar, this message translates to:
  /// **'خلال {days} يوم'**
  String statWithinDays(String days);

  /// No description provided for @statLowStock.
  ///
  /// In ar, this message translates to:
  /// **'مخزون قليل'**
  String get statLowStock;

  /// No description provided for @statProductsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} صنف'**
  String statProductsCount(String count);

  /// No description provided for @recentSales.
  ///
  /// In ar, this message translates to:
  /// **'آخر المبيعات'**
  String get recentSales;

  /// No description provided for @noSalesYet.
  ///
  /// In ar, this message translates to:
  /// **'ما في مبيعات لسا'**
  String get noSalesYet;

  /// No description provided for @colTime.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get colTime;

  /// No description provided for @colTotal.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get colTotal;

  /// No description provided for @colPayment.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get colPayment;

  /// No description provided for @colEmployee.
  ///
  /// In ar, this message translates to:
  /// **'الموظف'**
  String get colEmployee;

  /// No description provided for @colDevice.
  ///
  /// In ar, this message translates to:
  /// **'الجهاز'**
  String get colDevice;

  /// No description provided for @colCustomer.
  ///
  /// In ar, this message translates to:
  /// **'الزبون'**
  String get colCustomer;

  /// No description provided for @paymentCash.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get paymentCash;

  /// No description provided for @paymentDebt.
  ///
  /// In ar, this message translates to:
  /// **'دين'**
  String get paymentDebt;

  /// No description provided for @walkInCustomer.
  ///
  /// In ar, this message translates to:
  /// **'زبون عابر'**
  String get walkInCustomer;

  /// No description provided for @nearExpiryAlerts.
  ///
  /// In ar, this message translates to:
  /// **'كميات قريبة الانتهاء'**
  String get nearExpiryAlerts;

  /// No description provided for @nearExpiryAlertLine.
  ///
  /// In ar, this message translates to:
  /// **'{qty} من {product} بتنتهي {date}'**
  String nearExpiryAlertLine(String qty, String product, String date);

  /// No description provided for @noNearExpiry.
  ///
  /// In ar, this message translates to:
  /// **'ما في شي قريب ينتهي'**
  String get noNearExpiry;

  /// No description provided for @expiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get expiredLabel;

  /// No description provided for @posTitle.
  ///
  /// In ar, this message translates to:
  /// **'بيع جديد'**
  String get posTitle;

  /// No description provided for @posSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم أو المادة الفعالة أو امسح الباركود'**
  String get posSearchHint;

  /// No description provided for @scannerReady.
  ///
  /// In ar, this message translates to:
  /// **'قارئ الباركود جاهز'**
  String get scannerReady;

  /// No description provided for @addToCart.
  ///
  /// In ar, this message translates to:
  /// **'أضف'**
  String get addToCart;

  /// No description provided for @inStock.
  ///
  /// In ar, this message translates to:
  /// **'متوفر: {count}'**
  String inStock(String count);

  /// No description provided for @lowLeft.
  ///
  /// In ar, this message translates to:
  /// **'باقي {count}'**
  String lowLeft(String count);

  /// No description provided for @outOfStock.
  ///
  /// In ar, this message translates to:
  /// **'نفد'**
  String get outOfStock;

  /// No description provided for @showAlternatives.
  ///
  /// In ar, this message translates to:
  /// **'اعرض البديل'**
  String get showAlternatives;

  /// No description provided for @alternativesTitle.
  ///
  /// In ar, this message translates to:
  /// **'بدائل بنفس المادة الفعالة'**
  String get alternativesTitle;

  /// No description provided for @noAlternatives.
  ///
  /// In ar, this message translates to:
  /// **'ما في بديل متوفر'**
  String get noAlternatives;

  /// No description provided for @alternativeHint.
  ///
  /// In ar, this message translates to:
  /// **'بديل متوفر: {name}'**
  String alternativeHint(String name);

  /// No description provided for @invoice.
  ///
  /// In ar, this message translates to:
  /// **'الفاتورة'**
  String get invoice;

  /// No description provided for @cartEmpty.
  ///
  /// In ar, this message translates to:
  /// **'امسح باركود أو ابحث لتضيف أصناف'**
  String get cartEmpty;

  /// No description provided for @perUnit.
  ///
  /// In ar, this message translates to:
  /// **'{price} للعلبة'**
  String perUnit(String price);

  /// No description provided for @subtotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In ar, this message translates to:
  /// **'حسم'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @completeSale.
  ///
  /// In ar, this message translates to:
  /// **'إتمام البيع'**
  String get completeSale;

  /// No description provided for @registeredCustomer.
  ///
  /// In ar, this message translates to:
  /// **'زبون مسجّل'**
  String get registeredCustomer;

  /// No description provided for @chooseCustomer.
  ///
  /// In ar, this message translates to:
  /// **'اختار زبون'**
  String get chooseCustomer;

  /// No description provided for @newCustomer.
  ///
  /// In ar, this message translates to:
  /// **'زبون جديد'**
  String get newCustomer;

  /// No description provided for @customerNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الزبون'**
  String get customerNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل'**
  String get phoneLabel;

  /// No description provided for @notesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notesLabel;

  /// No description provided for @shortcuts.
  ///
  /// In ar, this message translates to:
  /// **'اختصارات:'**
  String get shortcuts;

  /// No description provided for @shortcutSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get shortcutSearch;

  /// No description provided for @shortcutDebt.
  ///
  /// In ar, this message translates to:
  /// **'دين'**
  String get shortcutDebt;

  /// No description provided for @shortcutComplete.
  ///
  /// In ar, this message translates to:
  /// **'إتمام'**
  String get shortcutComplete;

  /// No description provided for @saleDone.
  ///
  /// In ar, this message translates to:
  /// **'تمّ البيع: {total}'**
  String saleDone(String total);

  /// No description provided for @barcodeNotFound.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا صنف بهالباركود: {code}'**
  String barcodeNotFound(String code);

  /// No description provided for @errEmptyCart.
  ///
  /// In ar, this message translates to:
  /// **'الفاتورة فاضية'**
  String get errEmptyCart;

  /// No description provided for @errDebtNeedsCustomer.
  ///
  /// In ar, this message translates to:
  /// **'البيع بالدين بدو زبون مسجّل'**
  String get errDebtNeedsCustomer;

  /// No description provided for @errDiscount.
  ///
  /// In ar, this message translates to:
  /// **'الحسم أكبر من المجموع'**
  String get errDiscount;

  /// No description provided for @errStock.
  ///
  /// In ar, this message translates to:
  /// **'الكمية مو متوفرة بالمخزون'**
  String get errStock;

  /// No description provided for @errBadQty.
  ///
  /// In ar, this message translates to:
  /// **'كمية غير صحيحة'**
  String get errBadQty;

  /// No description provided for @nearExpiryNudge.
  ///
  /// In ar, this message translates to:
  /// **'في {qty} بتنتهي {date}، بيع منها أول'**
  String nearExpiryNudge(String qty, String date);

  /// No description provided for @prescriptionOnly.
  ///
  /// In ar, this message translates to:
  /// **'بوصفة'**
  String get prescriptionOnly;

  /// No description provided for @inventoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية والمخزون'**
  String get inventoryTitle;

  /// No description provided for @addProduct.
  ///
  /// In ar, this message translates to:
  /// **'صنف جديد'**
  String get addProduct;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @filterLow.
  ///
  /// In ar, this message translates to:
  /// **'مخزون قليل'**
  String get filterLow;

  /// No description provided for @filterNearExpiry.
  ///
  /// In ar, this message translates to:
  /// **'قريب الانتهاء'**
  String get filterNearExpiry;

  /// No description provided for @filterOut.
  ///
  /// In ar, this message translates to:
  /// **'نفد'**
  String get filterOut;

  /// No description provided for @colProduct.
  ///
  /// In ar, this message translates to:
  /// **'الصنف'**
  String get colProduct;

  /// No description provided for @colIngredient.
  ///
  /// In ar, this message translates to:
  /// **'المادة الفعالة'**
  String get colIngredient;

  /// No description provided for @colStock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get colStock;

  /// No description provided for @colPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get colPrice;

  /// No description provided for @colNearestExpiry.
  ///
  /// In ar, this message translates to:
  /// **'أقرب انتهاء'**
  String get colNearestExpiry;

  /// No description provided for @colShelf.
  ///
  /// In ar, this message translates to:
  /// **'الرف'**
  String get colShelf;

  /// No description provided for @noProducts.
  ///
  /// In ar, this message translates to:
  /// **'ما في أصناف لسا. ضيف أول صنف.'**
  String get noProducts;

  /// No description provided for @productFormNew.
  ///
  /// In ar, this message translates to:
  /// **'صنف جديد'**
  String get productFormNew;

  /// No description provided for @productFormEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الصنف'**
  String get productFormEdit;

  /// No description provided for @tradeNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم التجاري (لاتيني)'**
  String get tradeNameLabel;

  /// No description provided for @arabicNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالعربي'**
  String get arabicNameLabel;

  /// No description provided for @ingredientLabel.
  ///
  /// In ar, this message translates to:
  /// **'المادة الفعالة'**
  String get ingredientLabel;

  /// No description provided for @strengthLabel.
  ///
  /// In ar, this message translates to:
  /// **'التركيز'**
  String get strengthLabel;

  /// No description provided for @formLabel.
  ///
  /// In ar, this message translates to:
  /// **'الشكل'**
  String get formLabel;

  /// No description provided for @manufacturerLabel.
  ///
  /// In ar, this message translates to:
  /// **'الشركة المصنعة'**
  String get manufacturerLabel;

  /// No description provided for @shelfLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرف'**
  String get shelfLabel;

  /// No description provided for @priceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر البيع ({symbol})'**
  String priceLabel(String symbol);

  /// No description provided for @lowThresholdLabel.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه المخزون القليل عند'**
  String get lowThresholdLabel;

  /// No description provided for @barcodesLabel.
  ///
  /// In ar, this message translates to:
  /// **'الباركود (افصل بفاصلة)'**
  String get barcodesLabel;

  /// No description provided for @prescriptionLabel.
  ///
  /// In ar, this message translates to:
  /// **'بحاجة وصفة'**
  String get prescriptionLabel;

  /// No description provided for @duplicateBarcode.
  ///
  /// In ar, this message translates to:
  /// **'الباركود {code} مستعمل لصنف تاني'**
  String duplicateBarcode(String code);

  /// No description provided for @productDetail.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الصنف'**
  String get productDetail;

  /// No description provided for @batches.
  ///
  /// In ar, this message translates to:
  /// **'الدفعات'**
  String get batches;

  /// No description provided for @batchReceived.
  ///
  /// In ar, this message translates to:
  /// **'استلام {date}'**
  String batchReceived(String date);

  /// No description provided for @noExpiry.
  ///
  /// In ar, this message translates to:
  /// **'بدون تاريخ'**
  String get noExpiry;

  /// No description provided for @expiresOn.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي {date}'**
  String expiresOn(String date);

  /// No description provided for @receiveStock.
  ///
  /// In ar, this message translates to:
  /// **'استلام بضاعة'**
  String get receiveStock;

  /// No description provided for @quantityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantityLabel;

  /// No description provided for @expiryLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء'**
  String get expiryLabel;

  /// No description provided for @expiryHint.
  ///
  /// In ar, this message translates to:
  /// **'اختياري · يوم/شهر/سنة'**
  String get expiryHint;

  /// No description provided for @unitCostLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر الشراء للعلبة'**
  String get unitCostLabel;

  /// No description provided for @adjustStock.
  ///
  /// In ar, this message translates to:
  /// **'تعديل جرد'**
  String get adjustStock;

  /// No description provided for @adjustHelp.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الكمية الفعلية الموجودة بالرف'**
  String get adjustHelp;

  /// No description provided for @actualQtyLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية الفعلية'**
  String get actualQtyLabel;

  /// No description provided for @removeExpired.
  ///
  /// In ar, this message translates to:
  /// **'إزالة كمية منتهية'**
  String get removeExpired;

  /// No description provided for @removeExpiredConfirm.
  ///
  /// In ar, this message translates to:
  /// **'رح نشيل {qty} من المخزون كمنتهية الصلاحية.'**
  String removeExpiredConfirm(String qty);

  /// No description provided for @invalidDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ غير صحيح'**
  String get invalidDate;

  /// No description provided for @history.
  ///
  /// In ar, this message translates to:
  /// **'الحركات'**
  String get history;

  /// No description provided for @evReceived.
  ///
  /// In ar, this message translates to:
  /// **'استلام'**
  String get evReceived;

  /// No description provided for @evSold.
  ///
  /// In ar, this message translates to:
  /// **'بيع'**
  String get evSold;

  /// No description provided for @evReturned.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع'**
  String get evReturned;

  /// No description provided for @evAdjusted.
  ///
  /// In ar, this message translates to:
  /// **'تعديل جرد'**
  String get evAdjusted;

  /// No description provided for @evExpiredRemoved.
  ///
  /// In ar, this message translates to:
  /// **'إزالة منتهي'**
  String get evExpiredRemoved;

  /// No description provided for @debtsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الزبائن والديون'**
  String get debtsTitle;

  /// No description provided for @addCustomer.
  ///
  /// In ar, this message translates to:
  /// **'زبون جديد'**
  String get addCustomer;

  /// No description provided for @balance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get balance;

  /// No description provided for @owes.
  ///
  /// In ar, this message translates to:
  /// **'عليه {amount}'**
  String owes(String amount);

  /// No description provided for @settled.
  ///
  /// In ar, this message translates to:
  /// **'مسدّد'**
  String get settled;

  /// No description provided for @recordPayment.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دفعة'**
  String get recordPayment;

  /// No description provided for @amountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ ({symbol})'**
  String amountLabel(String symbol);

  /// No description provided for @debtAdded.
  ///
  /// In ar, this message translates to:
  /// **'دين من بيع'**
  String get debtAdded;

  /// No description provided for @paymentReceived.
  ///
  /// In ar, this message translates to:
  /// **'دفعة'**
  String get paymentReceived;

  /// No description provided for @noCustomers.
  ///
  /// In ar, this message translates to:
  /// **'ما في زبائن لسا'**
  String get noCustomers;

  /// No description provided for @filterOwing.
  ///
  /// In ar, this message translates to:
  /// **'عليهم ديون'**
  String get filterOwing;

  /// No description provided for @totalOpenDebts.
  ///
  /// In ar, this message translates to:
  /// **'مجموع الديون المفتوحة'**
  String get totalOpenDebts;

  /// No description provided for @paymentTooLarge.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ أكبر من الدين'**
  String get paymentTooLarge;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @pharmacySection.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلية'**
  String get pharmacySection;

  /// No description provided for @currencySection.
  ///
  /// In ar, this message translates to:
  /// **'العملة'**
  String get currencySection;

  /// No description provided for @currencyCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'رمز العملة (ISO)'**
  String get currencyCodeLabel;

  /// No description provided for @currencySymbolLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرمز الظاهر'**
  String get currencySymbolLabel;

  /// No description provided for @currencyDecimalsLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد الخانات العشرية'**
  String get currencyDecimalsLabel;

  /// No description provided for @currencyHelp.
  ///
  /// In ar, this message translates to:
  /// **'الافتراضي الليرة السورية الجديدة. غيّرها إذا بتسعّر بعملة تانية.'**
  String get currencyHelp;

  /// No description provided for @nearExpiryDaysLabel.
  ///
  /// In ar, this message translates to:
  /// **'نبّهني قبل الانتهاء بـ (يوم)'**
  String get nearExpiryDaysLabel;

  /// No description provided for @employeesSection.
  ///
  /// In ar, this message translates to:
  /// **'الموظفين'**
  String get employeesSection;

  /// No description provided for @addEmployee.
  ///
  /// In ar, this message translates to:
  /// **'موظف جديد'**
  String get addEmployee;

  /// No description provided for @employeeNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الموظف'**
  String get employeeNameLabel;

  /// No description provided for @deactivate.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get activate;

  /// No description provided for @inactive.
  ///
  /// In ar, this message translates to:
  /// **'موقوف'**
  String get inactive;

  /// No description provided for @thisDevice.
  ///
  /// In ar, this message translates to:
  /// **'هالجهاز'**
  String get thisDevice;

  /// No description provided for @saved.
  ///
  /// In ar, this message translates to:
  /// **'انحفظ'**
  String get saved;

  /// No description provided for @ownerOnly.
  ///
  /// In ar, this message translates to:
  /// **'هالقسم للمالك بس'**
  String get ownerOnly;

  /// No description provided for @loadDemo.
  ///
  /// In ar, this message translates to:
  /// **'عبّي بيانات تجريبية'**
  String get loadDemo;

  /// No description provided for @demoLoaded.
  ///
  /// In ar, this message translates to:
  /// **'انضافت بيانات تجريبية'**
  String get demoLoaded;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
