// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'دوايا';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get back => 'رجوع';

  @override
  String get search => 'بحث';

  @override
  String get optional => 'اختياري';

  @override
  String get required => 'مطلوب';

  @override
  String get invalidNumber => 'رقم غير صحيح';

  @override
  String units(String count) {
    return '$count علبة';
  }

  @override
  String get none => '—';

  @override
  String get offline => 'يعمل بدون إنترنت';

  @override
  String get signOut => 'تبديل الموظف';

  @override
  String get owner => 'مالك';

  @override
  String get employee => 'موظف';

  @override
  String get setupTitle => 'أهلين بدوايا';

  @override
  String get setupSubtitle =>
      'خلّينا نجهّز هالجهاز للصيدلية. كل شي بينحفظ على الجهاز وبيشتغل بدون إنترنت.';

  @override
  String get pharmacyNameLabel => 'اسم الصيدلية';

  @override
  String get deviceNameLabel => 'اسم هالجهاز';

  @override
  String get deviceNameHint => 'مثلاً: لابتوب الكاونتر';

  @override
  String get ownerNameLabel => 'اسمك (المالك)';

  @override
  String get pinLabel => 'رمز الدخول (٤ أرقام)';

  @override
  String get pinConfirmLabel => 'أعد الرمز';

  @override
  String get pinMismatch => 'الرمزين مو متطابقين';

  @override
  String get pinInvalid => 'الرمز لازم يكون ٤ أرقام';

  @override
  String get startButton => 'ابدأ';

  @override
  String get loginTitle => 'مين عم يشتغل هلق؟';

  @override
  String loginEnterPin(String name) {
    return 'أدخل رمز $name';
  }

  @override
  String get wrongPin => 'الرمز غلط';

  @override
  String get changeEmployee => 'غيّر الموظف';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navPos => 'البيع';

  @override
  String get navInventory => 'الأدوية والمخزون';

  @override
  String get navDebts => 'الزبائن والديون';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navSectionMain => 'الصيدلية';

  @override
  String get navSectionAdmin => 'الإدارة';

  @override
  String greeting(String name) {
    return 'أهلين $name';
  }

  @override
  String get newSale => 'بيع جديد';

  @override
  String get statSalesToday => 'مبيعات اليوم';

  @override
  String statSalesCount(String count) {
    return '$count عملية';
  }

  @override
  String get statOpenDebts => 'ديون مفتوحة';

  @override
  String statCustomersCount(String count) {
    return '$count زبون';
  }

  @override
  String get statNearExpiry => 'قرب تنتهي صلاحيته';

  @override
  String statWithinDays(String days) {
    return 'خلال $days يوم';
  }

  @override
  String get statLowStock => 'مخزون قليل';

  @override
  String statProductsCount(String count) {
    return '$count صنف';
  }

  @override
  String get recentSales => 'آخر المبيعات';

  @override
  String get noSalesYet => 'ما في مبيعات لسا';

  @override
  String get colTime => 'الوقت';

  @override
  String get colTotal => 'المبلغ';

  @override
  String get colPayment => 'الدفع';

  @override
  String get colEmployee => 'الموظف';

  @override
  String get colDevice => 'الجهاز';

  @override
  String get colCustomer => 'الزبون';

  @override
  String get paymentCash => 'نقدي';

  @override
  String get paymentDebt => 'دين';

  @override
  String get walkInCustomer => 'زبون عابر';

  @override
  String get nearExpiryAlerts => 'كميات قريبة الانتهاء';

  @override
  String nearExpiryAlertLine(String qty, String product, String date) {
    return '$qty من $product بتنتهي $date';
  }

  @override
  String get noNearExpiry => 'ما في شي قريب ينتهي';

  @override
  String get expiredLabel => 'منتهي';

  @override
  String get posTitle => 'بيع جديد';

  @override
  String get posSearchHint => 'ابحث بالاسم أو المادة الفعالة أو امسح الباركود';

  @override
  String get scannerReady => 'قارئ الباركود جاهز';

  @override
  String get addToCart => 'أضف';

  @override
  String inStock(String count) {
    return 'متوفر: $count';
  }

  @override
  String lowLeft(String count) {
    return 'باقي $count';
  }

  @override
  String get outOfStock => 'نفد';

  @override
  String get showAlternatives => 'اعرض البديل';

  @override
  String get alternativesTitle => 'بدائل بنفس المادة الفعالة';

  @override
  String get noAlternatives => 'ما في بديل متوفر';

  @override
  String alternativeHint(String name) {
    return 'بديل متوفر: $name';
  }

  @override
  String get invoice => 'الفاتورة';

  @override
  String get cartEmpty => 'امسح باركود أو ابحث لتضيف أصناف';

  @override
  String perUnit(String price) {
    return '$price للعلبة';
  }

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get discount => 'حسم';

  @override
  String get total => 'الإجمالي';

  @override
  String get completeSale => 'إتمام البيع';

  @override
  String get registeredCustomer => 'زبون مسجّل';

  @override
  String get chooseCustomer => 'اختار زبون';

  @override
  String get newCustomer => 'زبون جديد';

  @override
  String get customerNameLabel => 'اسم الزبون';

  @override
  String get phoneLabel => 'رقم الموبايل';

  @override
  String get notesLabel => 'ملاحظات';

  @override
  String get shortcuts => 'اختصارات:';

  @override
  String get shortcutSearch => 'بحث';

  @override
  String get shortcutDebt => 'دين';

  @override
  String get shortcutComplete => 'إتمام';

  @override
  String saleDone(String total) {
    return 'تمّ البيع: $total';
  }

  @override
  String barcodeNotFound(String code) {
    return 'ما لقينا صنف بهالباركود: $code';
  }

  @override
  String get errEmptyCart => 'الفاتورة فاضية';

  @override
  String get errDebtNeedsCustomer => 'البيع بالدين بدو زبون مسجّل';

  @override
  String get errDiscount => 'الحسم أكبر من المجموع';

  @override
  String get errStock => 'الكمية مو متوفرة بالمخزون';

  @override
  String get errBadQty => 'كمية غير صحيحة';

  @override
  String nearExpiryNudge(String qty, String date) {
    return 'في $qty بتنتهي $date، بيع منها أول';
  }

  @override
  String get prescriptionOnly => 'بوصفة';

  @override
  String get inventoryTitle => 'الأدوية والمخزون';

  @override
  String get addProduct => 'صنف جديد';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterLow => 'مخزون قليل';

  @override
  String get filterNearExpiry => 'قريب الانتهاء';

  @override
  String get filterOut => 'نفد';

  @override
  String get colProduct => 'الصنف';

  @override
  String get colIngredient => 'المادة الفعالة';

  @override
  String get colStock => 'المخزون';

  @override
  String get colPrice => 'السعر';

  @override
  String get colNearestExpiry => 'أقرب انتهاء';

  @override
  String get colShelf => 'الرف';

  @override
  String get noProducts => 'ما في أصناف لسا. ضيف أول صنف.';

  @override
  String get productFormNew => 'صنف جديد';

  @override
  String get productFormEdit => 'تعديل الصنف';

  @override
  String get tradeNameLabel => 'الاسم التجاري (لاتيني)';

  @override
  String get arabicNameLabel => 'الاسم بالعربي';

  @override
  String get ingredientLabel => 'المادة الفعالة';

  @override
  String get strengthLabel => 'التركيز';

  @override
  String get formLabel => 'الشكل';

  @override
  String get manufacturerLabel => 'الشركة المصنعة';

  @override
  String get shelfLabel => 'الرف';

  @override
  String priceLabel(String symbol) {
    return 'سعر البيع ($symbol)';
  }

  @override
  String get lowThresholdLabel => 'تنبيه المخزون القليل عند';

  @override
  String get barcodesLabel => 'الباركود (افصل بفاصلة)';

  @override
  String get prescriptionLabel => 'بحاجة وصفة';

  @override
  String duplicateBarcode(String code) {
    return 'الباركود $code مستعمل لصنف تاني';
  }

  @override
  String get productDetail => 'تفاصيل الصنف';

  @override
  String get batches => 'الدفعات';

  @override
  String batchReceived(String date) {
    return 'استلام $date';
  }

  @override
  String get noExpiry => 'بدون تاريخ';

  @override
  String expiresOn(String date) {
    return 'ينتهي $date';
  }

  @override
  String get receiveStock => 'استلام بضاعة';

  @override
  String get quantityLabel => 'الكمية';

  @override
  String get expiryLabel => 'تاريخ الانتهاء';

  @override
  String get expiryHint => 'اختياري · يوم/شهر/سنة';

  @override
  String get unitCostLabel => 'سعر الشراء للعلبة';

  @override
  String get adjustStock => 'تعديل جرد';

  @override
  String get adjustHelp => 'اكتب الكمية الفعلية الموجودة بالرف';

  @override
  String get actualQtyLabel => 'الكمية الفعلية';

  @override
  String get removeExpired => 'إزالة كمية منتهية';

  @override
  String removeExpiredConfirm(String qty) {
    return 'رح نشيل $qty من المخزون كمنتهية الصلاحية.';
  }

  @override
  String get invalidDate => 'تاريخ غير صحيح';

  @override
  String get history => 'الحركات';

  @override
  String get evReceived => 'استلام';

  @override
  String get evSold => 'بيع';

  @override
  String get evReturned => 'مرتجع';

  @override
  String get evAdjusted => 'تعديل جرد';

  @override
  String get evExpiredRemoved => 'إزالة منتهي';

  @override
  String get debtsTitle => 'الزبائن والديون';

  @override
  String get addCustomer => 'زبون جديد';

  @override
  String get balance => 'الرصيد';

  @override
  String owes(String amount) {
    return 'عليه $amount';
  }

  @override
  String get settled => 'مسدّد';

  @override
  String get recordPayment => 'تسجيل دفعة';

  @override
  String amountLabel(String symbol) {
    return 'المبلغ ($symbol)';
  }

  @override
  String get debtAdded => 'دين من بيع';

  @override
  String get paymentReceived => 'دفعة';

  @override
  String get noCustomers => 'ما في زبائن لسا';

  @override
  String get filterOwing => 'عليهم ديون';

  @override
  String get totalOpenDebts => 'مجموع الديون المفتوحة';

  @override
  String get paymentTooLarge => 'المبلغ أكبر من الدين';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get pharmacySection => 'الصيدلية';

  @override
  String get currencySection => 'العملة';

  @override
  String get currencyCodeLabel => 'رمز العملة (ISO)';

  @override
  String get currencySymbolLabel => 'الرمز الظاهر';

  @override
  String get currencyDecimalsLabel => 'عدد الخانات العشرية';

  @override
  String get currencyHelp => 'الافتراضي الليرة السورية الجديدة. غيّرها إذا بتسعّر بعملة تانية.';

  @override
  String get nearExpiryDaysLabel => 'نبّهني قبل الانتهاء بـ (يوم)';

  @override
  String get employeesSection => 'الموظفين';

  @override
  String get addEmployee => 'موظف جديد';

  @override
  String get employeeNameLabel => 'اسم الموظف';

  @override
  String get deactivate => 'إيقاف';

  @override
  String get activate => 'تفعيل';

  @override
  String get inactive => 'موقوف';

  @override
  String get thisDevice => 'هالجهاز';

  @override
  String get saved => 'انحفظ';

  @override
  String get ownerOnly => 'هالقسم للمالك بس';

  @override
  String get loadDemo => 'عبّي بيانات تجريبية';

  @override
  String get demoLoaded => 'انضافت بيانات تجريبية';
}
