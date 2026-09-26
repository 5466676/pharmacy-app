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
  /// **'رمز الدخول (4 أرقام)'**
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
  /// **'الرمز لازم يكون 4 أرقام'**
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

  /// No description provided for @navStaff.
  ///
  /// In ar, this message translates to:
  /// **'حسابات الموظفين'**
  String get navStaff;

  /// No description provided for @staffTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابات الموظفين'**
  String get staffTitle;

  /// No description provided for @periodToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get periodToday;

  /// No description provided for @periodWeek.
  ///
  /// In ar, this message translates to:
  /// **'هالأسبوع'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In ar, this message translates to:
  /// **'هالشهر'**
  String get periodMonth;

  /// No description provided for @staffTotalSales.
  ///
  /// In ar, this message translates to:
  /// **'مجموع المبيعات'**
  String get staffTotalSales;

  /// No description provided for @staffCashSales.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get staffCashSales;

  /// No description provided for @staffDebtSales.
  ///
  /// In ar, this message translates to:
  /// **'بالدين'**
  String get staffDebtSales;

  /// No description provided for @staffPayments.
  ///
  /// In ar, this message translates to:
  /// **'دفعات ديون قبضها'**
  String get staffPayments;

  /// No description provided for @staffCashToHandIn.
  ///
  /// In ar, this message translates to:
  /// **'المفروض يسلّم نقدي'**
  String get staffCashToHandIn;

  /// No description provided for @staffDiscounts.
  ///
  /// In ar, this message translates to:
  /// **'حسومات'**
  String get staffDiscounts;

  /// No description provided for @staffUnits.
  ///
  /// In ar, this message translates to:
  /// **'علب مباعة'**
  String get staffUnits;

  /// No description provided for @staffSalesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} فاتورة'**
  String staffSalesCount(String count);

  /// No description provided for @staffNoActivity.
  ///
  /// In ar, this message translates to:
  /// **'ما في مبيعات بهالفترة'**
  String get staffNoActivity;

  /// No description provided for @staffTopProducts.
  ///
  /// In ar, this message translates to:
  /// **'أكثر شي باعه'**
  String get staffTopProducts;

  /// No description provided for @staffInvoices.
  ///
  /// In ar, this message translates to:
  /// **'فواتيره'**
  String get staffInvoices;

  /// No description provided for @lineItem.
  ///
  /// In ar, this message translates to:
  /// **'{product} × {qty}'**
  String lineItem(String product, String qty);

  /// No description provided for @staffCashHint.
  ///
  /// In ar, this message translates to:
  /// **'النقدي = المبيعات النقدية + دفعات الديون − المرتجع النقدي'**
  String get staffCashHint;

  /// No description provided for @unitBox.
  ///
  /// In ar, this message translates to:
  /// **'علبة'**
  String get unitBox;

  /// No description provided for @unitStrip.
  ///
  /// In ar, this message translates to:
  /// **'ظرف'**
  String get unitStrip;

  /// No description provided for @packsAndStrips.
  ///
  /// In ar, this message translates to:
  /// **'{packs} علبة + {strips} ظرف'**
  String packsAndStrips(String packs, String strips);

  /// No description provided for @stripsOnly.
  ///
  /// In ar, this message translates to:
  /// **'{strips} ظرف'**
  String stripsOnly(String strips);

  /// No description provided for @unitsPerPackLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد الظروف بالعلبة'**
  String get unitsPerPackLabel;

  /// No description provided for @unitsPerPackHelp.
  ///
  /// In ar, this message translates to:
  /// **'1 = بيع بالعلبة بس'**
  String get unitsPerPackHelp;

  /// No description provided for @stripPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر الظرف ({symbol})'**
  String stripPriceLabel(String symbol);

  /// No description provided for @unitsPerPackLocked.
  ///
  /// In ar, this message translates to:
  /// **'ما فيك تغيّر عدد الظروف بعد ما صار في حركة مخزون لهالصنف'**
  String get unitsPerPackLocked;

  /// No description provided for @receiveQtyBoxes.
  ///
  /// In ar, this message translates to:
  /// **'الكمية (علب)'**
  String get receiveQtyBoxes;

  /// No description provided for @looseStripsLabel.
  ///
  /// In ar, this message translates to:
  /// **'ظروف فرط'**
  String get looseStripsLabel;

  /// No description provided for @addBox.
  ///
  /// In ar, this message translates to:
  /// **'علبة'**
  String get addBox;

  /// No description provided for @addStrip.
  ///
  /// In ar, this message translates to:
  /// **'ظرف'**
  String get addStrip;

  /// No description provided for @returnsButton.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع'**
  String get returnsButton;

  /// No description provided for @returnsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع'**
  String get returnsTitle;

  /// No description provided for @returnFromInvoice.
  ///
  /// In ar, this message translates to:
  /// **'من فاتورة'**
  String get returnFromInvoice;

  /// No description provided for @returnFree.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع حر'**
  String get returnFree;

  /// No description provided for @pickInvoice.
  ///
  /// In ar, this message translates to:
  /// **'اختار الفاتورة'**
  String get pickInvoice;

  /// No description provided for @noInvoices.
  ///
  /// In ar, this message translates to:
  /// **'ما في فواتير'**
  String get noInvoices;

  /// No description provided for @returnable.
  ///
  /// In ar, this message translates to:
  /// **'قابل للإرجاع: {qty}'**
  String returnable(String qty);

  /// No description provided for @refundMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الإرجاع'**
  String get refundMethod;

  /// No description provided for @refundCash.
  ///
  /// In ar, this message translates to:
  /// **'نقدي من الصندوق'**
  String get refundCash;

  /// No description provided for @refundDebtCredit.
  ///
  /// In ar, this message translates to:
  /// **'خصم من دين الزبون'**
  String get refundDebtCredit;

  /// No description provided for @returnTotal.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ المرتجع'**
  String get returnTotal;

  /// No description provided for @confirmReturn.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد المرتجع'**
  String get confirmReturn;

  /// No description provided for @returnDone.
  ///
  /// In ar, this message translates to:
  /// **'انسجّل المرتجع: {total}'**
  String returnDone(String total);

  /// No description provided for @errReturnEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما اخترت شي للإرجاع'**
  String get errReturnEmpty;

  /// No description provided for @errReturnTooMany.
  ///
  /// In ar, this message translates to:
  /// **'الكمية أكتر من يلي انباع'**
  String get errReturnTooMany;

  /// No description provided for @errReturnNeedsCustomer.
  ///
  /// In ar, this message translates to:
  /// **'الخصم من الدين بدو زبون'**
  String get errReturnNeedsCustomer;

  /// No description provided for @errReturnCreditTooBig.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ أكبر من دين الزبون'**
  String get errReturnCreditTooBig;

  /// No description provided for @errReturnUnknown.
  ///
  /// In ar, this message translates to:
  /// **'هالصنف ما إله مخزون سابق'**
  String get errReturnUnknown;

  /// No description provided for @unitPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر الوحدة'**
  String get unitPriceLabel;

  /// No description provided for @debtCredited.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع (خصم)'**
  String get debtCredited;

  /// No description provided for @staffReturns.
  ///
  /// In ar, this message translates to:
  /// **'مرتجعات'**
  String get staffReturns;

  /// No description provided for @staffCashRefunds.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع نقدي'**
  String get staffCashRefunds;

  /// No description provided for @perStrip.
  ///
  /// In ar, this message translates to:
  /// **'{price} للظرف'**
  String perStrip(String price);

  /// No description provided for @navTill.
  ///
  /// In ar, this message translates to:
  /// **'الصندوق'**
  String get navTill;

  /// No description provided for @paymentTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل'**
  String get paymentTransfer;

  /// No description provided for @paymentTransferHint.
  ///
  /// In ar, this message translates to:
  /// **'شام كاش أو أي تحويل إلكتروني (ما بيدخل الصندوق)'**
  String get paymentTransferHint;

  /// No description provided for @discountLabel.
  ///
  /// In ar, this message translates to:
  /// **'حسم ({symbol})'**
  String discountLabel(String symbol);

  /// No description provided for @tenderedLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المقبوض ({symbol})'**
  String tenderedLabel(String symbol);

  /// No description provided for @changeDue.
  ///
  /// In ar, this message translates to:
  /// **'الباقي للزبون'**
  String get changeDue;

  /// No description provided for @errTendered.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المقبوض أقل من الإجمالي'**
  String get errTendered;

  /// No description provided for @tillClosedBanner.
  ///
  /// In ar, this message translates to:
  /// **'الصندوق مسكّر. افتحه لتبدأ البيع.'**
  String get tillClosedBanner;

  /// No description provided for @openTill.
  ///
  /// In ar, this message translates to:
  /// **'افتح الصندوق'**
  String get openTill;

  /// No description provided for @openingFloatLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ الموجود بالصندوق هلق ({symbol})'**
  String openingFloatLabel(String symbol);

  /// No description provided for @tillTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصندوق'**
  String get tillTitle;

  /// No description provided for @tillOpenedAt.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح من {time}'**
  String tillOpenedAt(String time);

  /// No description provided for @tillFloat.
  ///
  /// In ar, this message translates to:
  /// **'رصيد الافتتاح'**
  String get tillFloat;

  /// No description provided for @tillCashSales.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات نقدية'**
  String get tillCashSales;

  /// No description provided for @tillDebtPayments.
  ///
  /// In ar, this message translates to:
  /// **'دفعات ديون'**
  String get tillDebtPayments;

  /// No description provided for @tillCashRefunds.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع نقدي'**
  String get tillCashRefunds;

  /// No description provided for @tillCashIn.
  ///
  /// In ar, this message translates to:
  /// **'إضافة نقد'**
  String get tillCashIn;

  /// No description provided for @tillCashOut.
  ///
  /// In ar, this message translates to:
  /// **'سحب نقد'**
  String get tillCashOut;

  /// No description provided for @tillTransfers.
  ///
  /// In ar, this message translates to:
  /// **'تحويلات (خارج الصندوق)'**
  String get tillTransfers;

  /// No description provided for @tillExpected.
  ///
  /// In ar, this message translates to:
  /// **'المفروض بالصندوق'**
  String get tillExpected;

  /// No description provided for @addCash.
  ///
  /// In ar, this message translates to:
  /// **'إضافة نقد'**
  String get addCash;

  /// No description provided for @withdrawCash.
  ///
  /// In ar, this message translates to:
  /// **'سحب نقد'**
  String get withdrawCash;

  /// No description provided for @reasonLabel.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get reasonLabel;

  /// No description provided for @closeTill.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق الصندوق'**
  String get closeTill;

  /// No description provided for @countedLabel.
  ///
  /// In ar, this message translates to:
  /// **'العدّ الفعلي ({symbol})'**
  String countedLabel(String symbol);

  /// No description provided for @countHelp.
  ///
  /// In ar, this message translates to:
  /// **'عدّ المصاري يلي بالصندوق واكتب المبلغ'**
  String get countHelp;

  /// No description provided for @shortage.
  ///
  /// In ar, this message translates to:
  /// **'عجز {amount}'**
  String shortage(String amount);

  /// No description provided for @surplus.
  ///
  /// In ar, this message translates to:
  /// **'زيادة {amount}'**
  String surplus(String amount);

  /// No description provided for @balanced.
  ///
  /// In ar, this message translates to:
  /// **'مطابق'**
  String get balanced;

  /// No description provided for @tillClosedResult.
  ///
  /// In ar, this message translates to:
  /// **'انسكّر الصندوق'**
  String get tillClosedResult;

  /// No description provided for @tillIsClosed.
  ///
  /// In ar, this message translates to:
  /// **'الصندوق مسكّر'**
  String get tillIsClosed;

  /// No description provided for @shiftsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الورديات'**
  String get shiftsTitle;

  /// No description provided for @noShifts.
  ///
  /// In ar, this message translates to:
  /// **'ما في ورديات بهالفترة'**
  String get noShifts;

  /// No description provided for @shiftOpenNow.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get shiftOpenNow;

  /// No description provided for @shiftLine.
  ///
  /// In ar, this message translates to:
  /// **'من {from} لـ {to}'**
  String shiftLine(String from, String to);

  /// No description provided for @staffTransferSales.
  ///
  /// In ar, this message translates to:
  /// **'تحويلات'**
  String get staffTransferSales;

  /// No description provided for @evReturnedToSupplier.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع للمستودع'**
  String get evReturnedToSupplier;

  /// No description provided for @navPurchases.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات'**
  String get navPurchases;

  /// No description provided for @purchasesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات'**
  String get purchasesTitle;

  /// No description provided for @tabInvoices.
  ///
  /// In ar, this message translates to:
  /// **'فواتير الشراء'**
  String get tabInvoices;

  /// No description provided for @tabSuppliers.
  ///
  /// In ar, this message translates to:
  /// **'الموردين'**
  String get tabSuppliers;

  /// No description provided for @newPurchase.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة شراء'**
  String get newPurchase;

  /// No description provided for @addSupplier.
  ///
  /// In ar, this message translates to:
  /// **'مورد جديد'**
  String get addSupplier;

  /// No description provided for @supplierNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستودع / المورد'**
  String get supplierNameLabel;

  /// No description provided for @repNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المندوب'**
  String get repNameLabel;

  /// No description provided for @noSuppliers.
  ///
  /// In ar, this message translates to:
  /// **'ما في موردين لسا'**
  String get noSuppliers;

  /// No description provided for @noPurchases.
  ///
  /// In ar, this message translates to:
  /// **'ما في فواتير شراء لسا'**
  String get noPurchases;

  /// No description provided for @chooseSupplier.
  ///
  /// In ar, this message translates to:
  /// **'اختار المورد'**
  String get chooseSupplier;

  /// No description provided for @supplierInvoiceNoLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم فاتورة المورد'**
  String get supplierInvoiceNoLabel;

  /// No description provided for @colQty.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get colQty;

  /// No description provided for @colBonus.
  ///
  /// In ar, this message translates to:
  /// **'بونص'**
  String get colBonus;

  /// No description provided for @colUnitPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر الشراء'**
  String get colUnitPrice;

  /// No description provided for @colDiscountPct.
  ///
  /// In ar, this message translates to:
  /// **'حسم %'**
  String get colDiscountPct;

  /// No description provided for @colExpiry.
  ///
  /// In ar, this message translates to:
  /// **'الانتهاء'**
  String get colExpiry;

  /// No description provided for @colSalePrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر المبيع'**
  String get colSalePrice;

  /// No description provided for @colLineTotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع'**
  String get colLineTotal;

  /// No description provided for @colSupplier.
  ///
  /// In ar, this message translates to:
  /// **'المورد'**
  String get colSupplier;

  /// No description provided for @colInvoiceNo.
  ///
  /// In ar, this message translates to:
  /// **'رقم الفاتورة'**
  String get colInvoiceNo;

  /// No description provided for @purchaseSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'امسح باركود أو ابحث عن صنف لتضيفه للفاتورة'**
  String get purchaseSearchHint;

  /// No description provided for @gross.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي قبل الحسم'**
  String get gross;

  /// No description provided for @lineDiscounts.
  ///
  /// In ar, this message translates to:
  /// **'حسومات الأسطر'**
  String get lineDiscounts;

  /// No description provided for @invoiceDiscountLabel.
  ///
  /// In ar, this message translates to:
  /// **'حسم على الفاتورة'**
  String get invoiceDiscountLabel;

  /// No description provided for @transportLabel.
  ///
  /// In ar, this message translates to:
  /// **'مصاريف نقل'**
  String get transportLabel;

  /// No description provided for @purchaseTotal.
  ///
  /// In ar, this message translates to:
  /// **'صافي الفاتورة'**
  String get purchaseTotal;

  /// No description provided for @payCash.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get payCash;

  /// No description provided for @payCredit.
  ///
  /// In ar, this message translates to:
  /// **'دين على الصيدلية'**
  String get payCredit;

  /// No description provided for @paidFromLabel.
  ///
  /// In ar, this message translates to:
  /// **'من وين الدفع؟'**
  String get paidFromLabel;

  /// No description provided for @fromDrawer.
  ///
  /// In ar, this message translates to:
  /// **'من الصندوق'**
  String get fromDrawer;

  /// No description provided for @fromOutside.
  ///
  /// In ar, this message translates to:
  /// **'من برّا الصندوق'**
  String get fromOutside;

  /// No description provided for @savePurchase.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الفاتورة'**
  String get savePurchase;

  /// No description provided for @purchaseSaved.
  ///
  /// In ar, this message translates to:
  /// **'انحفظت فاتورة الشراء'**
  String get purchaseSaved;

  /// No description provided for @errPurchaseEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما في أصناف بالفاتورة'**
  String get errPurchaseEmpty;

  /// No description provided for @errPurchaseLine.
  ///
  /// In ar, this message translates to:
  /// **'في سطر ناقص أو غلط'**
  String get errPurchaseLine;

  /// No description provided for @errPurchaseDiscount.
  ///
  /// In ar, this message translates to:
  /// **'الحسم أكبر من الفاتورة'**
  String get errPurchaseDiscount;

  /// No description provided for @errNeedSupplier.
  ///
  /// In ar, this message translates to:
  /// **'اختار المورد أول'**
  String get errNeedSupplier;

  /// No description provided for @balanceOwed.
  ///
  /// In ar, this message translates to:
  /// **'علينا للمورد'**
  String get balanceOwed;

  /// No description provided for @oldestDebt.
  ///
  /// In ar, this message translates to:
  /// **'أقدم دين'**
  String get oldestDebt;

  /// No description provided for @daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'من {days} يوم'**
  String daysAgo(String days);

  /// No description provided for @statement.
  ///
  /// In ar, this message translates to:
  /// **'كشف الحساب'**
  String get statement;

  /// No description provided for @paySupplier.
  ///
  /// In ar, this message translates to:
  /// **'دفعة للمورد'**
  String get paySupplier;

  /// No description provided for @returnToSupplier.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع للمستودع'**
  String get returnToSupplier;

  /// No description provided for @evPurchaseOnCredit.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة شراء (دين)'**
  String get evPurchaseOnCredit;

  /// No description provided for @evPaymentMade.
  ///
  /// In ar, this message translates to:
  /// **'دفعة'**
  String get evPaymentMade;

  /// No description provided for @evReturnCredited.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع'**
  String get evReturnCredited;

  /// No description provided for @colDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get colDate;

  /// No description provided for @colMovement.
  ///
  /// In ar, this message translates to:
  /// **'الحركة'**
  String get colMovement;

  /// No description provided for @colAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get colAmount;

  /// No description provided for @colBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get colBalance;

  /// No description provided for @batchLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدفعة'**
  String get batchLabel;

  /// No description provided for @piecesLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية (قطعة)'**
  String get piecesLabel;

  /// No description provided for @creditValueLabel.
  ///
  /// In ar, this message translates to:
  /// **'قيمة المرتجع ({symbol})'**
  String creditValueLabel(String symbol);

  /// No description provided for @refundCreditAccount.
  ///
  /// In ar, this message translates to:
  /// **'خصم من حساب المورد'**
  String get refundCreditAccount;

  /// No description provided for @refundCashFromSupplier.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع نقدي'**
  String get refundCashFromSupplier;

  /// No description provided for @returnSaved.
  ///
  /// In ar, this message translates to:
  /// **'انسجّل المرتجع للمستودع'**
  String get returnSaved;

  /// No description provided for @noBatches.
  ///
  /// In ar, this message translates to:
  /// **'ما في كمية بهالصنف'**
  String get noBatches;

  /// No description provided for @bestPrice.
  ///
  /// In ar, this message translates to:
  /// **'أرخص سعر: {price} من {supplier}'**
  String bestPrice(String price, String supplier);

  /// No description provided for @lastPrice.
  ///
  /// In ar, this message translates to:
  /// **'آخر سعر: {price}'**
  String lastPrice(String price);

  /// No description provided for @ownerOnlyAmounts.
  ///
  /// In ar, this message translates to:
  /// **'المبالغ والأرصدة للمالك بس'**
  String get ownerOnlyAmounts;

  /// No description provided for @dateFormatHint.
  ///
  /// In ar, this message translates to:
  /// **'1/6/28'**
  String get dateFormatHint;

  /// No description provided for @errDrawerClosed.
  ///
  /// In ar, this message translates to:
  /// **'الصندوق مسكّر، افتحه أول أو اختار الدفع من برّا الصندوق'**
  String get errDrawerClosed;

  /// No description provided for @purchaseBy.
  ///
  /// In ar, this message translates to:
  /// **'دخّلها {name}'**
  String purchaseBy(String name);

  /// No description provided for @navReports.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get navReports;

  /// No description provided for @reportsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح والتكلفة'**
  String get reportsTitle;

  /// No description provided for @netSales.
  ///
  /// In ar, this message translates to:
  /// **'صافي المبيعات'**
  String get netSales;

  /// No description provided for @costOfGoods.
  ///
  /// In ar, this message translates to:
  /// **'تكلفة البضاعة المباعة'**
  String get costOfGoods;

  /// No description provided for @grossProfit.
  ///
  /// In ar, this message translates to:
  /// **'الربح'**
  String get grossProfit;

  /// No description provided for @marginCaption.
  ///
  /// In ar, this message translates to:
  /// **'هامش الربح {pct}'**
  String marginCaption(String pct);

  /// No description provided for @stockValueAtCost.
  ///
  /// In ar, this message translates to:
  /// **'قيمة المخزون بالتكلفة'**
  String get stockValueAtCost;

  /// No description provided for @piecesWithoutCost.
  ///
  /// In ar, this message translates to:
  /// **'{pieces} قطعة بدون تكلفة'**
  String piecesWithoutCost(String pieces);

  /// No description provided for @unknownCostNotice.
  ///
  /// In ar, this message translates to:
  /// **'في {pieces} قطعة انباعت من بضاعة دخلت قبل فواتير الشراء، تكلفتها مو معروفة، فالربح الظاهر أعلى من الحقيقي. بيتصلّح لحالو لما تخلص هالبضاعة وتدخل بفواتير شراء.'**
  String unknownCostNotice(String pieces);

  /// No description provided for @byProduct.
  ///
  /// In ar, this message translates to:
  /// **'حسب الصنف'**
  String get byProduct;

  /// No description provided for @byEmployee.
  ///
  /// In ar, this message translates to:
  /// **'حسب الموظف'**
  String get byEmployee;

  /// No description provided for @byDay.
  ///
  /// In ar, this message translates to:
  /// **'حسب اليوم'**
  String get byDay;

  /// No description provided for @colRevenue.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get colRevenue;

  /// No description provided for @colCost.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة'**
  String get colCost;

  /// No description provided for @colProfit.
  ///
  /// In ar, this message translates to:
  /// **'الربح'**
  String get colProfit;

  /// No description provided for @colMargin.
  ///
  /// In ar, this message translates to:
  /// **'الهامش'**
  String get colMargin;

  /// No description provided for @noReportData.
  ///
  /// In ar, this message translates to:
  /// **'ما في مبيعات بهالفترة'**
  String get noReportData;

  /// No description provided for @statProfitToday.
  ///
  /// In ar, this message translates to:
  /// **'ربح اليوم'**
  String get statProfitToday;

  /// No description provided for @statSupplierDebts.
  ///
  /// In ar, this message translates to:
  /// **'علينا للموردين'**
  String get statSupplierDebts;

  /// No description provided for @suppliersOwedCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مورد'**
  String suppliersOwedCount(String count);

  /// No description provided for @costIncomplete.
  ///
  /// In ar, this message translates to:
  /// **'تكلفة ناقصة'**
  String get costIncomplete;

  /// No description provided for @tabShortages.
  ///
  /// In ar, this message translates to:
  /// **'النواقص'**
  String get tabShortages;

  /// No description provided for @tabOrders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبيات'**
  String get tabOrders;

  /// No description provided for @reasonOutOfStock.
  ///
  /// In ar, this message translates to:
  /// **'خالص'**
  String get reasonOutOfStock;

  /// No description provided for @reasonBelowMinimum.
  ///
  /// In ar, this message translates to:
  /// **'تحت الحد الأدنى'**
  String get reasonBelowMinimum;

  /// No description provided for @reasonSellingFast.
  ///
  /// In ar, this message translates to:
  /// **'عم يخلص بسرعة'**
  String get reasonSellingFast;

  /// No description provided for @runsOutIn.
  ///
  /// In ar, this message translates to:
  /// **'بيخلص خلال {days} يوم'**
  String runsOutIn(String days);

  /// No description provided for @orderQtyBoxes.
  ///
  /// In ar, this message translates to:
  /// **'الطلب (علبة)'**
  String get orderQtyBoxes;

  /// No description provided for @noShortages.
  ///
  /// In ar, this message translates to:
  /// **'ما في نواقص، كل شي متوفر'**
  String get noShortages;

  /// No description provided for @createOrders.
  ///
  /// In ar, this message translates to:
  /// **'اعمل الطلبيات ({count})'**
  String createOrders(String count);

  /// No description provided for @ordersCreated.
  ///
  /// In ar, this message translates to:
  /// **'انعملت {count} طلبية'**
  String ordersCreated(String count);

  /// No description provided for @errShortageNeedsSupplier.
  ///
  /// In ar, this message translates to:
  /// **'في أصناف بدون مورد: اختار المورد أو شيل التحديد عنها'**
  String get errShortageNeedsSupplier;

  /// No description provided for @noOrders.
  ///
  /// In ar, this message translates to:
  /// **'ما في طلبيات'**
  String get noOrders;

  /// No description provided for @orderDraft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get orderDraft;

  /// No description provided for @orderSent.
  ///
  /// In ar, this message translates to:
  /// **'انبعتت'**
  String get orderSent;

  /// No description provided for @orderReceived.
  ///
  /// In ar, this message translates to:
  /// **'استلمناها'**
  String get orderReceived;

  /// No description provided for @itemsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} صنف'**
  String itemsCount(String count);

  /// No description provided for @orderTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبية {supplier}'**
  String orderTitle(String supplier);

  /// No description provided for @copyOrder.
  ///
  /// In ar, this message translates to:
  /// **'انسخ الطلبية'**
  String get copyOrder;

  /// No description provided for @orderCopied.
  ///
  /// In ar, this message translates to:
  /// **'انسخت الطلبية: الصقها بواتساب أو تلغرام'**
  String get orderCopied;

  /// No description provided for @receiveOrder.
  ///
  /// In ar, this message translates to:
  /// **'وصلت: فاتورة شراء'**
  String get receiveOrder;

  /// No description provided for @deleteOrder.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteOrder;

  /// No description provided for @orderMessageHeader.
  ///
  /// In ar, this message translates to:
  /// **'طلبية من {pharmacy}'**
  String orderMessageHeader(String pharmacy);

  /// No description provided for @orderMessageDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ: {date}'**
  String orderMessageDate(String date);

  /// No description provided for @orderMessageThanks.
  ///
  /// In ar, this message translates to:
  /// **'ويعطيكن العافية'**
  String get orderMessageThanks;

  /// No description provided for @editSupplier.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المورد'**
  String get editSupplier;

  /// No description provided for @whatsappPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الواتساب'**
  String get whatsappPhoneLabel;

  /// No description provided for @whatsappPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'0944123456'**
  String get whatsappPhoneHint;

  /// No description provided for @invalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'الرقم مو صحيح'**
  String get invalidPhone;

  /// No description provided for @sendWhatsApp.
  ///
  /// In ar, this message translates to:
  /// **'ابعتها واتساب'**
  String get sendWhatsApp;

  /// No description provided for @openChat.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get openChat;

  /// No description provided for @errNoPhone.
  ///
  /// In ar, this message translates to:
  /// **'ما في رقم واتساب لهالمورد، ضيفه هون'**
  String get errNoPhone;

  /// No description provided for @whatsappFailed.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرنا نفتح واتساب: انسخت الطلبية، الصقها إنت'**
  String get whatsappFailed;

  /// No description provided for @stocktakeButton.
  ///
  /// In ar, this message translates to:
  /// **'جرد'**
  String get stocktakeButton;

  /// No description provided for @stocktakeTitle.
  ///
  /// In ar, this message translates to:
  /// **'الجرد'**
  String get stocktakeTitle;

  /// No description provided for @startStocktake.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ جرد'**
  String get startStocktake;

  /// No description provided for @stocktakeHelp.
  ///
  /// In ar, this message translates to:
  /// **'الجرد ما بيوقف البيع: بتعدّ كل صنف لحال، والبرنامج بيسجّل الكمية يلي كانت بالنظام لحظة العدّ. إذا عدّيت صنف مرتين، العدّة الأخيرة هي المعتمدة.'**
  String get stocktakeHelp;

  /// No description provided for @scopeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرف (اختياري، لجرد جزئي)'**
  String get scopeLabel;

  /// No description provided for @stocktakeOpen.
  ///
  /// In ar, this message translates to:
  /// **'جرد مفتوح من {date}'**
  String stocktakeOpen(String date);

  /// No description provided for @stocktakeScope.
  ///
  /// In ar, this message translates to:
  /// **'الرف: {shelf}'**
  String stocktakeScope(String shelf);

  /// No description provided for @countSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'امسح أو ابحث عن الصنف يلي عم تعدّه'**
  String get countSearchHint;

  /// No description provided for @countedBoxesLabel.
  ///
  /// In ar, this message translates to:
  /// **'العلب المعدودة'**
  String get countedBoxesLabel;

  /// No description provided for @countedStripsLabel.
  ///
  /// In ar, this message translates to:
  /// **'ظروف فرط'**
  String get countedStripsLabel;

  /// No description provided for @saveCount.
  ///
  /// In ar, this message translates to:
  /// **'سجّل'**
  String get saveCount;

  /// No description provided for @tabCounted.
  ///
  /// In ar, this message translates to:
  /// **'انعدّت ({count})'**
  String tabCounted(String count);

  /// No description provided for @tabNotCounted.
  ///
  /// In ar, this message translates to:
  /// **'لسا ({count})'**
  String tabNotCounted(String count);

  /// No description provided for @colCounted.
  ///
  /// In ar, this message translates to:
  /// **'المعدود'**
  String get colCounted;

  /// No description provided for @colSystem.
  ///
  /// In ar, this message translates to:
  /// **'بالنظام'**
  String get colSystem;

  /// No description provided for @colDifference.
  ///
  /// In ar, this message translates to:
  /// **'الفرق'**
  String get colDifference;

  /// No description provided for @shortageValue.
  ///
  /// In ar, this message translates to:
  /// **'قيمة النقص: {amount}'**
  String shortageValue(String amount);

  /// No description provided for @surplusValue.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الزيادة: {amount}'**
  String surplusValue(String amount);

  /// No description provided for @applyStocktake.
  ///
  /// In ar, this message translates to:
  /// **'طبّق الجرد'**
  String get applyStocktake;

  /// No description provided for @applyConfirm.
  ///
  /// In ar, this message translates to:
  /// **'رح ينعمل {count} تعديل على المخزون، وبيتسكّر الجرد. أكيد؟'**
  String applyConfirm(String count);

  /// No description provided for @stocktakeApplied.
  ///
  /// In ar, this message translates to:
  /// **'انطبّق الجرد: {count} تعديل'**
  String stocktakeApplied(String count);

  /// No description provided for @ownerAppliesNote.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق الجرد على المخزون للمالك بس'**
  String get ownerAppliesNote;

  /// No description provided for @pastStocktakes.
  ///
  /// In ar, this message translates to:
  /// **'جرودات سابقة'**
  String get pastStocktakes;

  /// No description provided for @noStocktakes.
  ///
  /// In ar, this message translates to:
  /// **'ما في جرودات سابقة'**
  String get noStocktakes;

  /// No description provided for @blindCountNote.
  ///
  /// In ar, this message translates to:
  /// **'ما منفرجيك الكمية يلي بالنظام قبل العدّ، منشان يكون العدّ دقيق.'**
  String get blindCountNote;

  /// No description provided for @syncTitle.
  ///
  /// In ar, this message translates to:
  /// **'السيرفر والمزامنة'**
  String get syncTitle;

  /// No description provided for @syncNotLinkedHelp.
  ///
  /// In ar, this message translates to:
  /// **'هالجهاز شغّال لحاله. اربطه بسيرفر الصيدلية (كمبيوتر الصيدلية) لتتشارك كل الأجهزة نفس البيانات. البيع بيضل شغّال حتى لو السيرفر طفي.'**
  String get syncNotLinkedHelp;

  /// No description provided for @findServer.
  ///
  /// In ar, this message translates to:
  /// **'دوّر على السيرفر'**
  String get findServer;

  /// No description provided for @searchingServer.
  ///
  /// In ar, this message translates to:
  /// **'عم دوّر على الشبكة'**
  String get searchingServer;

  /// No description provided for @noServerFound.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا سيرفر على هالشبكة. تأكد إنو كمبيوتر الصيدلية شغّال وعلى نفس الواي فاي، أو اكتب عنوانه.'**
  String get noServerFound;

  /// No description provided for @serverAddressLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان السيرفر'**
  String get serverAddressLabel;

  /// No description provided for @serverAddressHint.
  ///
  /// In ar, this message translates to:
  /// **'192.168.1.10'**
  String get serverAddressHint;

  /// No description provided for @useThisServer.
  ///
  /// In ar, this message translates to:
  /// **'اعتمد هالعنوان'**
  String get useThisServer;

  /// No description provided for @serverNotResponding.
  ///
  /// In ar, this message translates to:
  /// **'ما في سيرفر دوايا عم يرد على هالعنوان'**
  String get serverNotResponding;

  /// No description provided for @createOnServerTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الصيدلية على السيرفر'**
  String get createOnServerTitle;

  /// No description provided for @createOnServerHelp.
  ///
  /// In ar, this message translates to:
  /// **'السيرفر جديد: رح ننشئ الصيدلية عليه ونرفع كل بيانات هالجهاز. رقمك وكلمة السر رح تربط فيهن باقي الأجهزة.'**
  String get createOnServerHelp;

  /// No description provided for @linkTitle.
  ///
  /// In ar, this message translates to:
  /// **'ربط هالجهاز'**
  String get linkTitle;

  /// No description provided for @phoneAccountLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل'**
  String get phoneAccountLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة السر'**
  String get passwordLabel;

  /// No description provided for @passwordConfirmLabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة السر'**
  String get passwordConfirmLabel;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'6 أحرف على الأقل'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتين السر مو متطابقين'**
  String get passwordMismatch;

  /// No description provided for @linkButton.
  ///
  /// In ar, this message translates to:
  /// **'اربط'**
  String get linkButton;

  /// No description provided for @createAndLink.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ واربط'**
  String get createAndLink;

  /// No description provided for @linkedTo.
  ///
  /// In ar, this message translates to:
  /// **'مربوط بـ {pharmacy}'**
  String linkedTo(String pharmacy);

  /// No description provided for @signedInAs.
  ///
  /// In ar, this message translates to:
  /// **'الحساب: {name}'**
  String signedInAs(String name);

  /// No description provided for @lastSync.
  ///
  /// In ar, this message translates to:
  /// **'آخر مزامنة: {time}'**
  String lastSync(String time);

  /// No description provided for @neverSynced.
  ///
  /// In ar, this message translates to:
  /// **'لسا ما صار مزامنة'**
  String get neverSynced;

  /// No description provided for @pendingChanges.
  ///
  /// In ar, this message translates to:
  /// **'{count} حركة ناطرة'**
  String pendingChanges(String count);

  /// No description provided for @syncNowButton.
  ///
  /// In ar, this message translates to:
  /// **'زامن هلق'**
  String get syncNowButton;

  /// No description provided for @syncDownloading.
  ///
  /// In ar, this message translates to:
  /// **'عم ننزّل بيانات الصيدلية: {percent}%'**
  String syncDownloading(String percent);

  /// No description provided for @statusSyncing.
  ///
  /// In ar, this message translates to:
  /// **'عم يزامن'**
  String get statusSyncing;

  /// No description provided for @statusSynced.
  ///
  /// In ar, this message translates to:
  /// **'متزامن {time}'**
  String statusSynced(String time);

  /// No description provided for @statusServerMissing.
  ///
  /// In ar, this message translates to:
  /// **'السيرفر مو موجود'**
  String get statusServerMissing;

  /// No description provided for @statusUnlinked.
  ///
  /// In ar, this message translates to:
  /// **'الجهاز مفصول'**
  String get statusUnlinked;

  /// No description provided for @statusFailed.
  ///
  /// In ar, this message translates to:
  /// **'المزامنة وقفت'**
  String get statusFailed;

  /// No description provided for @unlinkedHelp.
  ///
  /// In ar, this message translates to:
  /// **'صاحب الصيدلية فصل هالجهاز عن السيرفر. البيع شغّال، بس ما رح يتزامن لحتى ينربط من جديد.'**
  String get unlinkedHelp;

  /// No description provided for @serverMissingHelp.
  ///
  /// In ar, this message translates to:
  /// **'ما عم نوصل للسيرفر. البيع شغّال عادي، والحركات ناطرة لحتى يرجع.'**
  String get serverMissingHelp;

  /// No description provided for @statusWrongServer.
  ///
  /// In ar, this message translates to:
  /// **'السيرفر تغيّر'**
  String get statusWrongServer;

  /// No description provided for @wrongServerHelp.
  ///
  /// In ar, this message translates to:
  /// **'يلي عم يرد على عنوان السيرفر مو نفس السيرفر يلي انربط عليه هالجهاز (رمزه مختلف)، فوقّفنا المزامنة منشان ما تطلع البيانات لجهاز غريب. البيع شغّال عادي. إذا انعاد تركيب السيرفر، اربط الجهاز من جديد.'**
  String get wrongServerHelp;

  /// No description provided for @errWrongServer.
  ///
  /// In ar, this message translates to:
  /// **'رمز السيرفر مو نفسه يلي انربط عليه الجهاز'**
  String get errWrongServer;

  /// No description provided for @relinkButton.
  ///
  /// In ar, this message translates to:
  /// **'اربط من جديد'**
  String get relinkButton;

  /// No description provided for @relinkConfirm.
  ///
  /// In ar, this message translates to:
  /// **'رح ينفك ربط هالجهاز بالسيرفر لتربطه من جديد. البيانات يلي عليه بتضل، وبترتفع كلها مع الربط الجديد. أكيد؟'**
  String get relinkConfirm;

  /// No description provided for @serverCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز السيرفر: {code}'**
  String serverCode(String code);

  /// No description provided for @serverCodeHelp.
  ///
  /// In ar, this message translates to:
  /// **'لازم يطابق الرمز يلي طلع وقت تركيب السيرفر.'**
  String get serverCodeHelp;

  /// No description provided for @devicesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأجهزة المربوطة'**
  String get devicesTitle;

  /// No description provided for @unlinkDevice.
  ///
  /// In ar, this message translates to:
  /// **'افصل'**
  String get unlinkDevice;

  /// No description provided for @unlinkConfirm.
  ///
  /// In ar, this message translates to:
  /// **'رح ينفصل الجهاز {name} عن السيرفر فوراً. أكيد؟'**
  String unlinkConfirm(String name);

  /// No description provided for @thisDeviceTag.
  ///
  /// In ar, this message translates to:
  /// **'هالجهاز'**
  String get thisDeviceTag;

  /// No description provided for @deviceUnlinkedTag.
  ///
  /// In ar, this message translates to:
  /// **'مفصول'**
  String get deviceUnlinkedTag;

  /// No description provided for @lastSeen.
  ///
  /// In ar, this message translates to:
  /// **'آخر ظهور {time}'**
  String lastSeen(String time);

  /// No description provided for @accountsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابات الموظفين'**
  String get accountsTitle;

  /// No description provided for @accountsHelp.
  ///
  /// In ar, this message translates to:
  /// **'كل موظف إلو رقم وكلمة سر، بيربط فيهن موبايله مرة وحدة وبيضل مسجّل.'**
  String get accountsHelp;

  /// No description provided for @addAccount.
  ///
  /// In ar, this message translates to:
  /// **'حساب لموظف'**
  String get addAccount;

  /// No description provided for @accountEmployeeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الموظف'**
  String get accountEmployeeLabel;

  /// No description provided for @accountDisabled.
  ///
  /// In ar, this message translates to:
  /// **'موقوف'**
  String get accountDisabled;

  /// No description provided for @errBadCredentials.
  ///
  /// In ar, this message translates to:
  /// **'الرقم أو كلمة السر غلط'**
  String get errBadCredentials;

  /// No description provided for @errPhoneTaken.
  ///
  /// In ar, this message translates to:
  /// **'هالرقم إلو حساب من قبل'**
  String get errPhoneTaken;

  /// No description provided for @errTooManyAttempts.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كتير غلط، جرّب بعد ربع ساعة'**
  String get errTooManyAttempts;

  /// No description provided for @errAlreadySetUp.
  ///
  /// In ar, this message translates to:
  /// **'هالسيرفر عليه صيدلية من قبل: اربط برقم وكلمة سر'**
  String get errAlreadySetUp;

  /// No description provided for @errDeviceOtherPharmacy.
  ///
  /// In ar, this message translates to:
  /// **'هالجهاز مربوط بصيدلية تانية'**
  String get errDeviceOtherPharmacy;

  /// No description provided for @errPharmacyInactive.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلية موقوفة على السيرفر'**
  String get errPharmacyInactive;

  /// No description provided for @errServer.
  ///
  /// In ar, this message translates to:
  /// **'صار خطأ بالسيرفر ({code})'**
  String errServer(String code);

  /// No description provided for @joinExisting.
  ///
  /// In ar, this message translates to:
  /// **'انضمام لصيدلية موجودة'**
  String get joinExisting;

  /// No description provided for @navMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get navMore;

  /// No description provided for @serverBackupLast.
  ///
  /// In ar, this message translates to:
  /// **'آخر نسخة احتياطية على السيرفر: {time}'**
  String serverBackupLast(String time);

  /// No description provided for @serverBackupNone.
  ///
  /// In ar, this message translates to:
  /// **'السيرفر لسا ما عمل نسخة احتياطية'**
  String get serverBackupNone;

  /// No description provided for @serverBackupError.
  ///
  /// In ar, this message translates to:
  /// **'في مشكلة بالنسخ الاحتياطي على السيرفر: شوف دليل التركيب'**
  String get serverBackupError;

  /// No description provided for @navInventoryShort.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get navInventoryShort;

  /// No description provided for @navDebtsShort.
  ///
  /// In ar, this message translates to:
  /// **'الديون'**
  String get navDebtsShort;

  /// No description provided for @newServer.
  ///
  /// In ar, this message translates to:
  /// **'سيرفر دوايا جديد (بلا صيدلية لسا)'**
  String get newServer;

  /// No description provided for @newPharmacy.
  ///
  /// In ar, this message translates to:
  /// **'صيدلية جديدة'**
  String get newPharmacy;

  /// No description provided for @joinHelp.
  ///
  /// In ar, this message translates to:
  /// **'للموبايلات والأجهزة الإضافية: بتربطها بسيرفر الصيدلية وبتنزل كل البيانات.'**
  String get joinHelp;

  /// No description provided for @joining.
  ///
  /// In ar, this message translates to:
  /// **'عم نربط وننزّل البيانات'**
  String get joining;

  /// No description provided for @joinNoEmployee.
  ///
  /// In ar, this message translates to:
  /// **'الحساب مو مربوط بموظف على هالصيدلية. اطلب من صاحب الصيدلية يربطه.'**
  String get joinNoEmployee;

  /// No description provided for @navExpenses.
  ///
  /// In ar, this message translates to:
  /// **'المصاريف'**
  String get navExpenses;

  /// No description provided for @expensesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المصاريف والأرباح والخسائر'**
  String get expensesTitle;

  /// No description provided for @addExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف'**
  String get addExpense;

  /// No description provided for @addExpenseTitle.
  ///
  /// In ar, this message translates to:
  /// **'مصروف جديد'**
  String get addExpenseTitle;

  /// No description provided for @expenseCategoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'شو نوع المصروف؟'**
  String get expenseCategoryLabel;

  /// No description provided for @expenseCustomLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المصروف'**
  String get expenseCustomLabel;

  /// No description provided for @expenseCategory.
  ///
  /// In ar, this message translates to:
  /// **'{key, select, rent{أجار} salaries{رواتب} electricity{كهربا} generator{أمبيرات} internet{إنترنت وموبايل} other{غير شي}}'**
  String expenseCategory(String key);

  /// No description provided for @tillDrawerPurchases.
  ///
  /// In ar, this message translates to:
  /// **'مشتريات من الصندوق'**
  String get tillDrawerPurchases;

  /// No description provided for @tillDrawerExpenses.
  ///
  /// In ar, this message translates to:
  /// **'مصاريف من الصندوق'**
  String get tillDrawerExpenses;

  /// No description provided for @tillSupplierRefunds.
  ///
  /// In ar, this message translates to:
  /// **'رجع من المستودعات نقداً'**
  String get tillSupplierRefunds;

  /// No description provided for @monthName.
  ///
  /// In ar, this message translates to:
  /// **'{month, select, 1{كانون التاني} 2{شباط} 3{آذار} 4{نيسان} 5{أيار} 6{حزيران} 7{تموز} 8{آب} 9{أيلول} 10{تشرين الأول} 11{تشرين التاني} 12{كانون الأول} other{{month}}}'**
  String monthName(String month);

  /// No description provided for @previousMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر يلي قبل'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر يلي بعد'**
  String get nextMonth;

  /// No description provided for @pnlTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح والخسائر'**
  String get pnlTitle;

  /// No description provided for @pnlSales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get pnlSales;

  /// No description provided for @pnlRefunds.
  ///
  /// In ar, this message translates to:
  /// **'مرتجعات الزباين'**
  String get pnlRefunds;

  /// No description provided for @pnlNetSales.
  ///
  /// In ar, this message translates to:
  /// **'صافي المبيعات'**
  String get pnlNetSales;

  /// No description provided for @pnlCostOfGoods.
  ///
  /// In ar, this message translates to:
  /// **'تكلفة البضاعة المباعة'**
  String get pnlCostOfGoods;

  /// No description provided for @pnlGrossProfit.
  ///
  /// In ar, this message translates to:
  /// **'ربح البضاعة'**
  String get pnlGrossProfit;

  /// No description provided for @pnlExpenses.
  ///
  /// In ar, this message translates to:
  /// **'المصاريف'**
  String get pnlExpenses;

  /// No description provided for @pnlNetProfit.
  ///
  /// In ar, this message translates to:
  /// **'صافي الربح'**
  String get pnlNetProfit;

  /// No description provided for @pnlNetLoss.
  ///
  /// In ar, this message translates to:
  /// **'صافي الخسارة'**
  String get pnlNetLoss;

  /// No description provided for @noExpenses.
  ///
  /// In ar, this message translates to:
  /// **'ما في مصاريف بهالشهر'**
  String get noExpenses;

  /// No description provided for @expensesListTitle.
  ///
  /// In ar, this message translates to:
  /// **'مصاريف الشهر'**
  String get expensesListTitle;

  /// No description provided for @expenseFromDrawerTag.
  ///
  /// In ar, this message translates to:
  /// **'من الصندوق'**
  String get expenseFromDrawerTag;

  /// No description provided for @expenseFromOutsideTag.
  ///
  /// In ar, this message translates to:
  /// **'من برّا'**
  String get expenseFromOutsideTag;

  /// No description provided for @expenseSaved.
  ///
  /// In ar, this message translates to:
  /// **'انسجّل المصروف'**
  String get expenseSaved;

  /// No description provided for @backupSection.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي على هالجهاز'**
  String get backupSection;

  /// No description provided for @backupHelp.
  ///
  /// In ar, this message translates to:
  /// **'كل يوم بتنعمل نسخة كاملة لحالها وبنخلّي آخر 30. الأحسن يكون المجلد على فلاشة، أو مجلد بينسخ لبرّا الكمبيوتر.'**
  String get backupHelp;

  /// No description provided for @backupFolderLabel.
  ///
  /// In ar, this message translates to:
  /// **'مجلد النسخ'**
  String get backupFolderLabel;

  /// No description provided for @saveFolder.
  ///
  /// In ar, this message translates to:
  /// **'اعتمد المجلد'**
  String get saveFolder;

  /// No description provided for @backupNow.
  ///
  /// In ar, this message translates to:
  /// **'خذ نسخة هلق'**
  String get backupNow;

  /// No description provided for @backingUp.
  ///
  /// In ar, this message translates to:
  /// **'عم ناخد نسخة'**
  String get backingUp;

  /// No description provided for @backupLast.
  ///
  /// In ar, this message translates to:
  /// **'آخر نسخة: {when}'**
  String backupLast(String when);

  /// No description provided for @backupNone.
  ///
  /// In ar, this message translates to:
  /// **'ما في نسخة لسا'**
  String get backupNone;

  /// No description provided for @backupFailed.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرنا ناخد النسخة (المجلد مو موجود أو الفلاشة مشلوحة؟). منرجع منجرّب لحالنا.'**
  String get backupFailed;

  /// No description provided for @backupDone.
  ///
  /// In ar, this message translates to:
  /// **'انعملت النسخة'**
  String get backupDone;

  /// No description provided for @restoreButton.
  ///
  /// In ar, this message translates to:
  /// **'استرجع'**
  String get restoreButton;

  /// No description provided for @restoreConfirm.
  ///
  /// In ar, this message translates to:
  /// **'رح ترجع بيانات هالجهاز متل ما كانت بتاريخ {when}، وكل شي صار بعدها على هالجهاز بيروح. البيانات الحالية بتنحفظ على جنب. أكيد؟'**
  String restoreConfirm(String when);

  /// No description provided for @restoreRestart.
  ///
  /// In ar, this message translates to:
  /// **'جاهز. سكّر البرنامج وافتحه من جديد، وبيفتح على النسخة يلي اخترتها.'**
  String get restoreRestart;

  /// No description provided for @restoreLinkedNote.
  ///
  /// In ar, this message translates to:
  /// **'هالجهاز مربوط بالسيرفر: إذا خرب، ركّبه من جديد واختار «انضمام لصيدلية موجودة» وبتنزل كل البيانات. الاسترجاع من نسخة هون للأجهزة يلي مو مربوطة.'**
  String get restoreLinkedNote;

  /// No description provided for @navCases.
  ///
  /// In ar, this message translates to:
  /// **'الحالات'**
  String get navCases;

  /// No description provided for @casesTitle.
  ///
  /// In ar, this message translates to:
  /// **'حالات المرضى وطلباتهم'**
  String get casesTitle;

  /// No description provided for @tabCases.
  ///
  /// In ar, this message translates to:
  /// **'الحالات'**
  String get tabCases;

  /// No description provided for @tabPatientOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الاستلام'**
  String get tabPatientOrders;

  /// No description provided for @inboxNotLinked.
  ///
  /// In ar, this message translates to:
  /// **'هالجهاز مو مربوط بسيرفر الصيدلية، فالحالات ما بتوصله.'**
  String get inboxNotLinked;

  /// No description provided for @inboxNotConnected.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلية مو مربوطة بدوايا أونلاين لسا. صاحب الصيدلية بيربطها من «السيرفر والمزامنة».'**
  String get inboxNotConnected;

  /// No description provided for @inboxOffline.
  ///
  /// In ar, this message translates to:
  /// **'ما في إنترنت هلق: الحالات والطلبات الجديدة بتوصل لما يرجع. البيع شغّال عادي.'**
  String get inboxOffline;

  /// No description provided for @noCases.
  ///
  /// In ar, this message translates to:
  /// **'ما في حالات هلق'**
  String get noCases;

  /// No description provided for @noPatientOrders.
  ///
  /// In ar, this message translates to:
  /// **'ما في طلبات هلق'**
  String get noPatientOrders;

  /// No description provided for @chooseCase.
  ///
  /// In ar, this message translates to:
  /// **'اختار من القائمة'**
  String get chooseCase;

  /// No description provided for @caseStatus.
  ///
  /// In ar, this message translates to:
  /// **'{status, select, sent{جديدة} preparing{عم تتحضّر} ready{جاهزة} picked_up{مستلمة} needs_doctor{بحاجة طبيب} emergency{طارئة} closed{مسكّرة} other{{status}}}'**
  String caseStatus(String status);

  /// No description provided for @orderStatus.
  ///
  /// In ar, this message translates to:
  /// **'{status, select, sent{جديد} preparing{عم يتحضّر} ready{جاهز} picked_up{مستلم} rejected{مرفوض} cancelled{ملغى} other{{status}}}'**
  String orderStatus(String status);

  /// No description provided for @patientAge.
  ///
  /// In ar, this message translates to:
  /// **'{age} سنة'**
  String patientAge(String age);

  /// No description provided for @sexMale.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get sexMale;

  /// No description provided for @sexFemale.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get sexFemale;

  /// No description provided for @urgentCase.
  ///
  /// In ar, this message translates to:
  /// **'حالة مستعجلة'**
  String get urgentCase;

  /// No description provided for @redFlag.
  ///
  /// In ar, this message translates to:
  /// **'{category, select, chest_pain{ألم بالصدر} breathing{صعوبة بالتنفس} stroke{علامات جلطة} bleeding{نزيف} infant_fever{حرارة عند رضيع} self_harm{خطر إيذاء النفس} poisoning{تسمم أو جرعة زايدة} seizure{اختلاج} unconscious{فقدان وعي} anaphylaxis{تحسس شديد} pregnancy_bleeding{نزيف مع حمل} severe_headache{صداع شديد أو تيبس رقبة} other{علامة خطر}}'**
  String redFlag(String category);

  /// No description provided for @urgentHelp.
  ///
  /// In ar, this message translates to:
  /// **'المساعد وقّف الاستشارة وطلب من المريض يتصل بالإسعاف. اتصل فيه لتطمّن عليه: {phone}'**
  String urgentHelp(String phone);

  /// No description provided for @newUrgentToast.
  ///
  /// In ar, this message translates to:
  /// **'وصلت حالة مستعجلة: {name}'**
  String newUrgentToast(String name);

  /// No description provided for @assistantSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص المساعد'**
  String get assistantSummary;

  /// No description provided for @sumSymptoms.
  ///
  /// In ar, this message translates to:
  /// **'الأعراض'**
  String get sumSymptoms;

  /// No description provided for @sumDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get sumDuration;

  /// No description provided for @sumAge.
  ///
  /// In ar, this message translates to:
  /// **'العمر'**
  String get sumAge;

  /// No description provided for @sumSex.
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get sumSex;

  /// No description provided for @sumPregnancy.
  ///
  /// In ar, this message translates to:
  /// **'حمل أو إرضاع'**
  String get sumPregnancy;

  /// No description provided for @sumAllergies.
  ///
  /// In ar, this message translates to:
  /// **'الحساسية'**
  String get sumAllergies;

  /// No description provided for @sumMedications.
  ///
  /// In ar, this message translates to:
  /// **'أدوية حالية'**
  String get sumMedications;

  /// No description provided for @sumConditions.
  ///
  /// In ar, this message translates to:
  /// **'أمراض مزمنة'**
  String get sumConditions;

  /// No description provided for @sumNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get sumNotes;

  /// No description provided for @sumDenied.
  ///
  /// In ar, this message translates to:
  /// **'نفى: {list}'**
  String sumDenied(String list);

  /// No description provided for @noSummary.
  ///
  /// In ar, this message translates to:
  /// **'ما في ملخص (المساعد ما كان متاح): اقرا المحادثة.'**
  String get noSummary;

  /// No description provided for @conversationTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحادثة'**
  String get conversationTitle;

  /// No description provided for @roleAssistant.
  ///
  /// In ar, this message translates to:
  /// **'المساعد'**
  String get roleAssistant;

  /// No description provided for @rolePatient.
  ///
  /// In ar, this message translates to:
  /// **'المريض'**
  String get rolePatient;

  /// No description provided for @roleSystem.
  ///
  /// In ar, this message translates to:
  /// **'دوايا'**
  String get roleSystem;

  /// No description provided for @correctAssistant.
  ///
  /// In ar, this message translates to:
  /// **'صحّح'**
  String get correctAssistant;

  /// No description provided for @correctionTitle.
  ///
  /// In ar, this message translates to:
  /// **'شو كان الصح؟'**
  String get correctionTitle;

  /// No description provided for @correctionHelp.
  ///
  /// In ar, this message translates to:
  /// **'بتنسجّل للمراجعة منشان نحسّن المساعد، وما بتنستعمل لتدريب تلقائي.'**
  String get correctionHelp;

  /// No description provided for @correctionSaved.
  ///
  /// In ar, this message translates to:
  /// **'انسجّل التصحيح، شكراً'**
  String get correctionSaved;

  /// No description provided for @customerHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجلّه عندك'**
  String get customerHistory;

  /// No description provided for @notACustomer.
  ///
  /// In ar, this message translates to:
  /// **'مو زبون مسجّل عندك'**
  String get notACustomer;

  /// No description provided for @customerDebt.
  ///
  /// In ar, this message translates to:
  /// **'عليه دين: {amount}'**
  String customerDebt(String amount);

  /// No description provided for @lastPurchases.
  ///
  /// In ar, this message translates to:
  /// **'آخر مشترياته'**
  String get lastPurchases;

  /// No description provided for @yourDecision.
  ///
  /// In ar, this message translates to:
  /// **'قرارك'**
  String get yourDecision;

  /// No description provided for @decisionHelp.
  ///
  /// In ar, this message translates to:
  /// **'القرار والجرعات دايماً عند الصيدلي'**
  String get decisionHelp;

  /// No description provided for @addMedicine.
  ///
  /// In ar, this message translates to:
  /// **'أضف دوا'**
  String get addMedicine;

  /// No description provided for @searchStock.
  ///
  /// In ar, this message translates to:
  /// **'دوّر بالمخزون'**
  String get searchStock;

  /// No description provided for @onHandShort.
  ///
  /// In ar, this message translates to:
  /// **'متوفر: {qty}'**
  String onHandShort(String qty);

  /// No description provided for @instructionsLabel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الاستعمال'**
  String get instructionsLabel;

  /// No description provided for @timesPerDayLabel.
  ///
  /// In ar, this message translates to:
  /// **'مرات باليوم'**
  String get timesPerDayLabel;

  /// No description provided for @daysLabel.
  ///
  /// In ar, this message translates to:
  /// **'كم يوم'**
  String get daysLabel;

  /// No description provided for @decisionNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة للمريض (اختياري)'**
  String get decisionNote;

  /// No description provided for @markReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهز، بلّغ المريض'**
  String get markReady;

  /// No description provided for @askPatient.
  ///
  /// In ar, this message translates to:
  /// **'اسأل المريض سؤال'**
  String get askPatient;

  /// No description provided for @needsDoctorButton.
  ///
  /// In ar, this message translates to:
  /// **'بحاجة طبيب'**
  String get needsDoctorButton;

  /// No description provided for @needsDoctorConfirm.
  ///
  /// In ar, this message translates to:
  /// **'رح نقول للمريض إنو حالته بدها طبيب يفحصه، وبتتسكّر الحالة. فيك تضيف كلمة إله:'**
  String get needsDoctorConfirm;

  /// No description provided for @closeCase.
  ///
  /// In ar, this message translates to:
  /// **'سكّر الحالة'**
  String get closeCase;

  /// No description provided for @startPreparing.
  ///
  /// In ar, this message translates to:
  /// **'بلّش التحضير'**
  String get startPreparing;

  /// No description provided for @instructionsRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب طريقة الاستعمال لكل دوا'**
  String get instructionsRequired;

  /// No description provided for @decisionSent.
  ///
  /// In ar, this message translates to:
  /// **'انبعت للمريض'**
  String get decisionSent;

  /// No description provided for @pickupAndSell.
  ///
  /// In ar, this message translates to:
  /// **'استلم وبيع'**
  String get pickupAndSell;

  /// No description provided for @pickupDone.
  ///
  /// In ar, this message translates to:
  /// **'انسجّل الاستلام'**
  String get pickupDone;

  /// No description provided for @handledBy.
  ///
  /// In ar, this message translates to:
  /// **'مسؤول: {name}'**
  String handledBy(String name);

  /// No description provided for @orderRequested.
  ///
  /// In ar, this message translates to:
  /// **'طلب {qty}'**
  String orderRequested(String qty);

  /// No description provided for @orderPatientNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة المريض: {note}'**
  String orderPatientNote(String note);

  /// No description provided for @pharmacistNoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة للمريض (اختياري)'**
  String get pharmacistNoteLabel;

  /// No description provided for @markOrderReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للاستلام'**
  String get markOrderReady;

  /// No description provided for @rejectOrder.
  ///
  /// In ar, this message translates to:
  /// **'ما في'**
  String get rejectOrder;

  /// No description provided for @orderTotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع: {amount}'**
  String orderTotal(String amount);

  /// No description provided for @orderLinesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} صنف'**
  String orderLinesCount(String count);

  /// No description provided for @pickupPartial.
  ///
  /// In ar, this message translates to:
  /// **'بعض الأصناف مو متوفرة بالمخزون، زبطها بشاشة البيع'**
  String get pickupPartial;

  /// No description provided for @centralSection.
  ///
  /// In ar, this message translates to:
  /// **'دوايا أونلاين'**
  String get centralSection;

  /// No description provided for @centralHelp.
  ///
  /// In ar, this message translates to:
  /// **'لما تربط الصيدلية، المرضى بيشوفوا رفوفها (السعر ومتوفر أو لأ بس)، وبيبعتوا حالات وطلبات للاستلام. البيع والحسابات بيضلوا عندك.'**
  String get centralHelp;

  /// No description provided for @centralUrlLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان دوايا أونلاين'**
  String get centralUrlLabel;

  /// No description provided for @centralKeyLabel.
  ///
  /// In ar, this message translates to:
  /// **'مفتاح الصيدلية'**
  String get centralKeyLabel;

  /// No description provided for @centralLink.
  ///
  /// In ar, this message translates to:
  /// **'اربط'**
  String get centralLink;

  /// No description provided for @centralUnlink.
  ///
  /// In ar, this message translates to:
  /// **'فك الربط'**
  String get centralUnlink;

  /// No description provided for @centralLinked.
  ///
  /// In ar, this message translates to:
  /// **'مربوطة بـ {url}'**
  String centralLinked(String url);

  /// No description provided for @centralNotLinked.
  ///
  /// In ar, this message translates to:
  /// **'مو مربوطة'**
  String get centralNotLinked;

  /// No description provided for @errBadPharmacyKey.
  ///
  /// In ar, this message translates to:
  /// **'المفتاح غلط'**
  String get errBadPharmacyKey;

  /// No description provided for @errCentralUnreachable.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرنا نوصل لدوايا أونلاين'**
  String get errCentralUnreachable;

  /// No description provided for @removeItem.
  ///
  /// In ar, this message translates to:
  /// **'شيل'**
  String get removeItem;

  /// No description provided for @centralUrlHint.
  ///
  /// In ar, this message translates to:
  /// **'https://…'**
  String get centralUrlHint;

  /// No description provided for @noSummaryUrgent.
  ///
  /// In ar, this message translates to:
  /// **'ما في ملخص: المساعد وقّف الاستشارة أول ما طلعت علامة الخطر. اقرا المحادثة.'**
  String get noSummaryUrgent;

  /// No description provided for @prescriptionPhoto.
  ///
  /// In ar, this message translates to:
  /// **'صورة الوصفة من المريض. اضغط لتكبّرها.'**
  String get prescriptionPhoto;

  /// No description provided for @printReceipt.
  ///
  /// In ar, this message translates to:
  /// **'اطبع الإيصال'**
  String get printReceipt;

  /// No description provided for @receiptSaleNo.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة'**
  String get receiptSaleNo;

  /// No description provided for @receiptCashier.
  ///
  /// In ar, this message translates to:
  /// **'البائع'**
  String get receiptCashier;

  /// No description provided for @receiptCustomer.
  ///
  /// In ar, this message translates to:
  /// **'الزبون'**
  String get receiptCustomer;

  /// No description provided for @receiptSubtotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع'**
  String get receiptSubtotal;

  /// No description provided for @receiptDiscount.
  ///
  /// In ar, this message translates to:
  /// **'الحسم'**
  String get receiptDiscount;

  /// No description provided for @receiptTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get receiptTotal;

  /// No description provided for @receiptPayment.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get receiptPayment;

  /// No description provided for @receiptTendered.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get receiptTendered;

  /// No description provided for @receiptChange.
  ///
  /// In ar, this message translates to:
  /// **'الباقي'**
  String get receiptChange;

  /// No description provided for @receiptThanks.
  ///
  /// In ar, this message translates to:
  /// **'سلامتك، ومنتمنالك الشفا'**
  String get receiptThanks;

  /// No description provided for @printFailed.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرنا نطبع. تأكد إنو الطابعة شغّالة.'**
  String get printFailed;

  /// No description provided for @lookTitle.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get lookTitle;

  /// No description provided for @lookSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ألوان ونمط التطبيق على هالجهاز'**
  String get lookSubtitle;

  /// No description provided for @lookStyle.
  ///
  /// In ar, this message translates to:
  /// **'النمط'**
  String get lookStyle;

  /// No description provided for @lookStyleGlass.
  ///
  /// In ar, this message translates to:
  /// **'زجاجي'**
  String get lookStyleGlass;

  /// No description provided for @lookStyleFlat.
  ///
  /// In ar, this message translates to:
  /// **'مسطّح'**
  String get lookStyleFlat;

  /// No description provided for @lookStyleSoft.
  ///
  /// In ar, this message translates to:
  /// **'ناعم'**
  String get lookStyleSoft;

  /// No description provided for @lookStyleOutline.
  ///
  /// In ar, this message translates to:
  /// **'خطوط'**
  String get lookStyleOutline;

  /// No description provided for @lookStyleContrast.
  ///
  /// In ar, this message translates to:
  /// **'تباين عالي'**
  String get lookStyleContrast;

  /// No description provided for @lookNoteGlass.
  ///
  /// In ar, this message translates to:
  /// **'شفاف ومغبّش'**
  String get lookNoteGlass;

  /// No description provided for @lookNoteFlat.
  ///
  /// In ar, this message translates to:
  /// **'ألوان صافية بدون ظلال'**
  String get lookNoteFlat;

  /// No description provided for @lookNoteSoft.
  ///
  /// In ar, this message translates to:
  /// **'حواف دايرية وظلال خفيفة'**
  String get lookNoteSoft;

  /// No description provided for @lookNoteOutline.
  ///
  /// In ar, this message translates to:
  /// **'بسيط، إطارات رفيعة'**
  String get lookNoteOutline;

  /// No description provided for @lookNoteContrast.
  ///
  /// In ar, this message translates to:
  /// **'للنظر الضعيف والشمس'**
  String get lookNoteContrast;

  /// No description provided for @lookMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع'**
  String get lookMode;

  /// No description provided for @lookModeDark.
  ///
  /// In ar, this message translates to:
  /// **'ليلي'**
  String get lookModeDark;

  /// No description provided for @lookModeLight.
  ///
  /// In ar, this message translates to:
  /// **'نهاري'**
  String get lookModeLight;

  /// No description provided for @lookModeBlack.
  ///
  /// In ar, this message translates to:
  /// **'أسود كامل'**
  String get lookModeBlack;

  /// No description provided for @lookModeAuto.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get lookModeAuto;

  /// No description provided for @lookColors.
  ///
  /// In ar, this message translates to:
  /// **'الألوان'**
  String get lookColors;

  /// No description provided for @lookPaletteGreen.
  ///
  /// In ar, this message translates to:
  /// **'أخضر دوايا'**
  String get lookPaletteGreen;

  /// No description provided for @lookPaletteNavy.
  ///
  /// In ar, this message translates to:
  /// **'كحلي'**
  String get lookPaletteNavy;

  /// No description provided for @lookPaletteWine.
  ///
  /// In ar, this message translates to:
  /// **'خمري'**
  String get lookPaletteWine;

  /// No description provided for @lookPaletteViolet.
  ///
  /// In ar, this message translates to:
  /// **'بنفسجي'**
  String get lookPaletteViolet;

  /// No description provided for @lookPaletteSky.
  ///
  /// In ar, this message translates to:
  /// **'سماوي'**
  String get lookPaletteSky;

  /// No description provided for @lookPaletteRose.
  ///
  /// In ar, this message translates to:
  /// **'زهري'**
  String get lookPaletteRose;

  /// No description provided for @lookPaletteAmber.
  ///
  /// In ar, this message translates to:
  /// **'عنبري'**
  String get lookPaletteAmber;

  /// No description provided for @lookPaletteOlive.
  ///
  /// In ar, this message translates to:
  /// **'زيتي'**
  String get lookPaletteOlive;

  /// No description provided for @lookPaletteMint.
  ///
  /// In ar, this message translates to:
  /// **'نعناعي'**
  String get lookPaletteMint;

  /// No description provided for @lookPaletteSand.
  ///
  /// In ar, this message translates to:
  /// **'رملي'**
  String get lookPaletteSand;

  /// No description provided for @lookPaletteChar.
  ///
  /// In ar, this message translates to:
  /// **'فحمي'**
  String get lookPaletteChar;

  /// No description provided for @lookCustom.
  ///
  /// In ar, this message translates to:
  /// **'تصميمي'**
  String get lookCustom;

  /// No description provided for @lookMain.
  ///
  /// In ar, this message translates to:
  /// **'اللون الأساسي'**
  String get lookMain;

  /// No description provided for @lookBackground.
  ///
  /// In ar, this message translates to:
  /// **'لون الخلفية'**
  String get lookBackground;

  /// No description provided for @lookHue.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get lookHue;

  /// No description provided for @lookLightness.
  ///
  /// In ar, this message translates to:
  /// **'الفتاحة'**
  String get lookLightness;

  /// No description provided for @lookDetails.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get lookDetails;

  /// No description provided for @lookCorners.
  ///
  /// In ar, this message translates to:
  /// **'الحواف'**
  String get lookCorners;

  /// No description provided for @lookBlur.
  ///
  /// In ar, this message translates to:
  /// **'التغبيش'**
  String get lookBlur;

  /// No description provided for @lookTextSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get lookTextSize;

  /// No description provided for @lookSizeSmall.
  ///
  /// In ar, this message translates to:
  /// **'صغير'**
  String get lookSizeSmall;

  /// No description provided for @lookSizeNormal.
  ///
  /// In ar, this message translates to:
  /// **'عادي'**
  String get lookSizeNormal;

  /// No description provided for @lookSizeLarge.
  ///
  /// In ar, this message translates to:
  /// **'كبير'**
  String get lookSizeLarge;

  /// No description provided for @lookSizeXLarge.
  ///
  /// In ar, this message translates to:
  /// **'كبير جداً'**
  String get lookSizeXLarge;

  /// No description provided for @lookSpacing.
  ///
  /// In ar, this message translates to:
  /// **'المسافات'**
  String get lookSpacing;

  /// No description provided for @lookSpacingComfy.
  ///
  /// In ar, this message translates to:
  /// **'مريحة'**
  String get lookSpacingComfy;

  /// No description provided for @lookSpacingCompact.
  ///
  /// In ar, this message translates to:
  /// **'مضغوطة'**
  String get lookSpacingCompact;

  /// No description provided for @lookHeadingFont.
  ///
  /// In ar, this message translates to:
  /// **'خط العناوين'**
  String get lookHeadingFont;

  /// No description provided for @lookFontAmiri.
  ///
  /// In ar, this message translates to:
  /// **'مزخرف'**
  String get lookFontAmiri;

  /// No description provided for @lookFontPlain.
  ///
  /// In ar, this message translates to:
  /// **'بسيط'**
  String get lookFontPlain;

  /// No description provided for @lookReadability.
  ///
  /// In ar, this message translates to:
  /// **'وضوح القراءة'**
  String get lookReadability;

  /// No description provided for @lookReadable.
  ///
  /// In ar, this message translates to:
  /// **'أي لون بيصعّب القراءة بيتعدّل لحاله. الأحمر للخطر والأصفر للتحذير ما بيتغيّروا.'**
  String get lookReadable;

  /// No description provided for @lookAdjusted.
  ///
  /// In ar, this message translates to:
  /// **'اتعدّل ليضل واضح'**
  String get lookAdjusted;

  /// No description provided for @lookSample.
  ///
  /// In ar, this message translates to:
  /// **'هيك بيطلع'**
  String get lookSample;

  /// No description provided for @lookSampleButton.
  ///
  /// In ar, this message translates to:
  /// **'زر'**
  String get lookSampleButton;

  /// No description provided for @lookSampleWarning.
  ///
  /// In ar, this message translates to:
  /// **'هيك بيطلع التحذير.'**
  String get lookSampleWarning;

  /// No description provided for @lookSampleDanger.
  ///
  /// In ar, this message translates to:
  /// **'وهيك بتطلع الحالة المستعجلة.'**
  String get lookSampleDanger;

  /// No description provided for @lookReset.
  ///
  /// In ar, this message translates to:
  /// **'رجّع للأصل'**
  String get lookReset;
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
