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
  String get pinLabel => 'رمز الدخول (4 أرقام)';

  @override
  String get pinConfirmLabel => 'أعد الرمز';

  @override
  String get pinMismatch => 'الرمزين مو متطابقين';

  @override
  String get pinInvalid => 'الرمز لازم يكون 4 أرقام';

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

  @override
  String get navStaff => 'حسابات الموظفين';

  @override
  String get staffTitle => 'حسابات الموظفين';

  @override
  String get periodToday => 'اليوم';

  @override
  String get periodWeek => 'هالأسبوع';

  @override
  String get periodMonth => 'هالشهر';

  @override
  String get staffTotalSales => 'مجموع المبيعات';

  @override
  String get staffCashSales => 'نقدي';

  @override
  String get staffDebtSales => 'بالدين';

  @override
  String get staffPayments => 'دفعات ديون قبضها';

  @override
  String get staffCashToHandIn => 'المفروض يسلّم نقدي';

  @override
  String get staffDiscounts => 'حسومات';

  @override
  String get staffUnits => 'علب مباعة';

  @override
  String staffSalesCount(String count) {
    return '$count فاتورة';
  }

  @override
  String get staffNoActivity => 'ما في مبيعات بهالفترة';

  @override
  String get staffTopProducts => 'أكثر شي باعه';

  @override
  String get staffInvoices => 'فواتيره';

  @override
  String lineItem(String product, String qty) {
    return '$product × $qty';
  }

  @override
  String get staffCashHint => 'النقدي = المبيعات النقدية + دفعات الديون − المرتجع النقدي';

  @override
  String get unitBox => 'علبة';

  @override
  String get unitStrip => 'ظرف';

  @override
  String packsAndStrips(String packs, String strips) {
    return '$packs علبة + $strips ظرف';
  }

  @override
  String stripsOnly(String strips) {
    return '$strips ظرف';
  }

  @override
  String get unitsPerPackLabel => 'عدد الظروف بالعلبة';

  @override
  String get unitsPerPackHelp => '1 = بيع بالعلبة بس';

  @override
  String stripPriceLabel(String symbol) {
    return 'سعر الظرف ($symbol)';
  }

  @override
  String get unitsPerPackLocked => 'ما فيك تغيّر عدد الظروف بعد ما صار في حركة مخزون لهالصنف';

  @override
  String get receiveQtyBoxes => 'الكمية (علب)';

  @override
  String get looseStripsLabel => 'ظروف فرط';

  @override
  String get addBox => 'علبة';

  @override
  String get addStrip => 'ظرف';

  @override
  String get returnsButton => 'مرتجع';

  @override
  String get returnsTitle => 'مرتجع';

  @override
  String get returnFromInvoice => 'من فاتورة';

  @override
  String get returnFree => 'مرتجع حر';

  @override
  String get pickInvoice => 'اختار الفاتورة';

  @override
  String get noInvoices => 'ما في فواتير';

  @override
  String returnable(String qty) {
    return 'قابل للإرجاع: $qty';
  }

  @override
  String get refundMethod => 'طريقة الإرجاع';

  @override
  String get refundCash => 'نقدي من الصندوق';

  @override
  String get refundDebtCredit => 'خصم من دين الزبون';

  @override
  String get returnTotal => 'مبلغ المرتجع';

  @override
  String get confirmReturn => 'تأكيد المرتجع';

  @override
  String returnDone(String total) {
    return 'انسجّل المرتجع: $total';
  }

  @override
  String get errReturnEmpty => 'ما اخترت شي للإرجاع';

  @override
  String get errReturnTooMany => 'الكمية أكتر من يلي انباع';

  @override
  String get errReturnNeedsCustomer => 'الخصم من الدين بدو زبون';

  @override
  String get errReturnCreditTooBig => 'المبلغ أكبر من دين الزبون';

  @override
  String get errReturnUnknown => 'هالصنف ما إله مخزون سابق';

  @override
  String get unitPriceLabel => 'سعر الوحدة';

  @override
  String get debtCredited => 'مرتجع (خصم)';

  @override
  String get staffReturns => 'مرتجعات';

  @override
  String get staffCashRefunds => 'مرتجع نقدي';

  @override
  String perStrip(String price) {
    return '$price للظرف';
  }

  @override
  String get navTill => 'الصندوق';

  @override
  String get paymentTransfer => 'تحويل';

  @override
  String get paymentTransferHint => 'شام كاش أو أي تحويل إلكتروني (ما بيدخل الصندوق)';

  @override
  String discountLabel(String symbol) {
    return 'حسم ($symbol)';
  }

  @override
  String tenderedLabel(String symbol) {
    return 'المبلغ المقبوض ($symbol)';
  }

  @override
  String get changeDue => 'الباقي للزبون';

  @override
  String get errTendered => 'المبلغ المقبوض أقل من الإجمالي';

  @override
  String get tillClosedBanner => 'الصندوق مسكّر. افتحه لتبدأ البيع.';

  @override
  String get openTill => 'افتح الصندوق';

  @override
  String openingFloatLabel(String symbol) {
    return 'المبلغ الموجود بالصندوق هلق ($symbol)';
  }

  @override
  String get tillTitle => 'الصندوق';

  @override
  String tillOpenedAt(String time) {
    return 'مفتوح من $time';
  }

  @override
  String get tillFloat => 'رصيد الافتتاح';

  @override
  String get tillCashSales => 'مبيعات نقدية';

  @override
  String get tillDebtPayments => 'دفعات ديون';

  @override
  String get tillCashRefunds => 'مرتجع نقدي';

  @override
  String get tillCashIn => 'إضافة نقد';

  @override
  String get tillCashOut => 'سحب نقد';

  @override
  String get tillTransfers => 'تحويلات (خارج الصندوق)';

  @override
  String get tillExpected => 'المفروض بالصندوق';

  @override
  String get addCash => 'إضافة نقد';

  @override
  String get withdrawCash => 'سحب نقد';

  @override
  String get reasonLabel => 'السبب';

  @override
  String get closeTill => 'إغلاق الصندوق';

  @override
  String countedLabel(String symbol) {
    return 'العدّ الفعلي ($symbol)';
  }

  @override
  String get countHelp => 'عدّ المصاري يلي بالصندوق واكتب المبلغ';

  @override
  String shortage(String amount) {
    return 'عجز $amount';
  }

  @override
  String surplus(String amount) {
    return 'زيادة $amount';
  }

  @override
  String get balanced => 'مطابق';

  @override
  String get tillClosedResult => 'انسكّر الصندوق';

  @override
  String get tillIsClosed => 'الصندوق مسكّر';

  @override
  String get shiftsTitle => 'الورديات';

  @override
  String get noShifts => 'ما في ورديات بهالفترة';

  @override
  String get shiftOpenNow => 'مفتوح';

  @override
  String shiftLine(String from, String to) {
    return 'من $from لـ $to';
  }

  @override
  String get staffTransferSales => 'تحويلات';

  @override
  String get evReturnedToSupplier => 'مرتجع للمستودع';

  @override
  String get navPurchases => 'المشتريات';

  @override
  String get purchasesTitle => 'المشتريات';

  @override
  String get tabInvoices => 'فواتير الشراء';

  @override
  String get tabSuppliers => 'الموردين';

  @override
  String get newPurchase => 'فاتورة شراء';

  @override
  String get addSupplier => 'مورد جديد';

  @override
  String get supplierNameLabel => 'اسم المستودع / المورد';

  @override
  String get repNameLabel => 'اسم المندوب';

  @override
  String get noSuppliers => 'ما في موردين لسا';

  @override
  String get noPurchases => 'ما في فواتير شراء لسا';

  @override
  String get chooseSupplier => 'اختار المورد';

  @override
  String get supplierInvoiceNoLabel => 'رقم فاتورة المورد';

  @override
  String get colQty => 'الكمية';

  @override
  String get colBonus => 'بونص';

  @override
  String get colUnitPrice => 'سعر الشراء';

  @override
  String get colDiscountPct => 'حسم %';

  @override
  String get colExpiry => 'الانتهاء';

  @override
  String get colSalePrice => 'سعر المبيع';

  @override
  String get colLineTotal => 'المجموع';

  @override
  String get colSupplier => 'المورد';

  @override
  String get colInvoiceNo => 'رقم الفاتورة';

  @override
  String get purchaseSearchHint => 'امسح باركود أو ابحث عن صنف لتضيفه للفاتورة';

  @override
  String get gross => 'الإجمالي قبل الحسم';

  @override
  String get lineDiscounts => 'حسومات الأسطر';

  @override
  String get invoiceDiscountLabel => 'حسم على الفاتورة';

  @override
  String get transportLabel => 'مصاريف نقل';

  @override
  String get purchaseTotal => 'صافي الفاتورة';

  @override
  String get payCash => 'نقدي';

  @override
  String get payCredit => 'دين على الصيدلية';

  @override
  String get paidFromLabel => 'من وين الدفع؟';

  @override
  String get fromDrawer => 'من الصندوق';

  @override
  String get fromOutside => 'من برّا الصندوق';

  @override
  String get savePurchase => 'حفظ الفاتورة';

  @override
  String get purchaseSaved => 'انحفظت فاتورة الشراء';

  @override
  String get errPurchaseEmpty => 'ما في أصناف بالفاتورة';

  @override
  String get errPurchaseLine => 'في سطر ناقص أو غلط';

  @override
  String get errPurchaseDiscount => 'الحسم أكبر من الفاتورة';

  @override
  String get errNeedSupplier => 'اختار المورد أول';

  @override
  String get balanceOwed => 'علينا للمورد';

  @override
  String get oldestDebt => 'أقدم دين';

  @override
  String daysAgo(String days) {
    return 'من $days يوم';
  }

  @override
  String get statement => 'كشف الحساب';

  @override
  String get paySupplier => 'دفعة للمورد';

  @override
  String get returnToSupplier => 'مرتجع للمستودع';

  @override
  String get evPurchaseOnCredit => 'فاتورة شراء (دين)';

  @override
  String get evPaymentMade => 'دفعة';

  @override
  String get evReturnCredited => 'مرتجع';

  @override
  String get colDate => 'التاريخ';

  @override
  String get colMovement => 'الحركة';

  @override
  String get colAmount => 'المبلغ';

  @override
  String get colBalance => 'الرصيد';

  @override
  String get batchLabel => 'الدفعة';

  @override
  String get piecesLabel => 'الكمية (قطعة)';

  @override
  String creditValueLabel(String symbol) {
    return 'قيمة المرتجع ($symbol)';
  }

  @override
  String get refundCreditAccount => 'خصم من حساب المورد';

  @override
  String get refundCashFromSupplier => 'استرجاع نقدي';

  @override
  String get returnSaved => 'انسجّل المرتجع للمستودع';

  @override
  String get noBatches => 'ما في كمية بهالصنف';

  @override
  String bestPrice(String price, String supplier) {
    return 'أرخص سعر: $price من $supplier';
  }

  @override
  String lastPrice(String price) {
    return 'آخر سعر: $price';
  }

  @override
  String get ownerOnlyAmounts => 'المبالغ والأرصدة للمالك بس';

  @override
  String get dateFormatHint => '1/6/28';

  @override
  String get errDrawerClosed => 'الصندوق مسكّر، افتحه أول أو اختار الدفع من برّا الصندوق';

  @override
  String purchaseBy(String name) {
    return 'دخّلها $name';
  }

  @override
  String get navReports => 'الأرباح';

  @override
  String get reportsTitle => 'الأرباح والتكلفة';

  @override
  String get netSales => 'صافي المبيعات';

  @override
  String get costOfGoods => 'تكلفة البضاعة المباعة';

  @override
  String get grossProfit => 'الربح';

  @override
  String marginCaption(String pct) {
    return 'هامش الربح $pct';
  }

  @override
  String get stockValueAtCost => 'قيمة المخزون بالتكلفة';

  @override
  String piecesWithoutCost(String pieces) {
    return '$pieces قطعة بدون تكلفة';
  }

  @override
  String unknownCostNotice(String pieces) {
    return 'في $pieces قطعة انباعت من بضاعة دخلت قبل فواتير الشراء، تكلفتها مو معروفة، فالربح الظاهر أعلى من الحقيقي. بيتصلّح لحالو لما تخلص هالبضاعة وتدخل بفواتير شراء.';
  }

  @override
  String get byProduct => 'حسب الصنف';

  @override
  String get byEmployee => 'حسب الموظف';

  @override
  String get byDay => 'حسب اليوم';

  @override
  String get colRevenue => 'المبيعات';

  @override
  String get colCost => 'التكلفة';

  @override
  String get colProfit => 'الربح';

  @override
  String get colMargin => 'الهامش';

  @override
  String get noReportData => 'ما في مبيعات بهالفترة';

  @override
  String get statProfitToday => 'ربح اليوم';

  @override
  String get statSupplierDebts => 'علينا للموردين';

  @override
  String suppliersOwedCount(String count) {
    return '$count مورد';
  }

  @override
  String get costIncomplete => 'تكلفة ناقصة';

  @override
  String get tabShortages => 'النواقص';

  @override
  String get tabOrders => 'الطلبيات';

  @override
  String get reasonOutOfStock => 'خالص';

  @override
  String get reasonBelowMinimum => 'تحت الحد الأدنى';

  @override
  String get reasonSellingFast => 'عم يخلص بسرعة';

  @override
  String runsOutIn(String days) {
    return 'بيخلص خلال $days يوم';
  }

  @override
  String get orderQtyBoxes => 'الطلب (علبة)';

  @override
  String get noShortages => 'ما في نواقص، كل شي متوفر';

  @override
  String createOrders(String count) {
    return 'اعمل الطلبيات ($count)';
  }

  @override
  String ordersCreated(String count) {
    return 'انعملت $count طلبية';
  }

  @override
  String get errShortageNeedsSupplier => 'في أصناف بدون مورد: اختار المورد أو شيل التحديد عنها';

  @override
  String get noOrders => 'ما في طلبيات';

  @override
  String get orderDraft => 'مسودة';

  @override
  String get orderSent => 'انبعتت';

  @override
  String get orderReceived => 'استلمناها';

  @override
  String itemsCount(String count) {
    return '$count صنف';
  }

  @override
  String orderTitle(String supplier) {
    return 'طلبية $supplier';
  }

  @override
  String get copyOrder => 'انسخ الطلبية';

  @override
  String get orderCopied => 'انسخت الطلبية: الصقها بواتساب أو تلغرام';

  @override
  String get receiveOrder => 'وصلت: فاتورة شراء';

  @override
  String get deleteOrder => 'حذف';

  @override
  String orderMessageHeader(String pharmacy) {
    return 'طلبية من $pharmacy';
  }

  @override
  String orderMessageDate(String date) {
    return 'التاريخ: $date';
  }

  @override
  String get orderMessageThanks => 'ويعطيكن العافية';

  @override
  String get editSupplier => 'تعديل المورد';

  @override
  String get whatsappPhoneLabel => 'رقم الواتساب';

  @override
  String get whatsappPhoneHint => '0944123456';

  @override
  String get invalidPhone => 'الرقم مو صحيح';

  @override
  String get sendWhatsApp => 'ابعتها واتساب';

  @override
  String get openChat => 'واتساب';

  @override
  String get errNoPhone => 'ما في رقم واتساب لهالمورد، ضيفه هون';

  @override
  String get whatsappFailed => 'ما قدرنا نفتح واتساب: انسخت الطلبية، الصقها إنت';

  @override
  String get stocktakeButton => 'جرد';

  @override
  String get stocktakeTitle => 'الجرد';

  @override
  String get startStocktake => 'ابدأ جرد';

  @override
  String get stocktakeHelp =>
      'الجرد ما بيوقف البيع: بتعدّ كل صنف لحال، والبرنامج بيسجّل الكمية يلي كانت بالنظام لحظة العدّ. إذا عدّيت صنف مرتين، العدّة الأخيرة هي المعتمدة.';

  @override
  String get scopeLabel => 'الرف (اختياري، لجرد جزئي)';

  @override
  String stocktakeOpen(String date) {
    return 'جرد مفتوح من $date';
  }

  @override
  String stocktakeScope(String shelf) {
    return 'الرف: $shelf';
  }

  @override
  String get countSearchHint => 'امسح أو ابحث عن الصنف يلي عم تعدّه';

  @override
  String get countedBoxesLabel => 'العلب المعدودة';

  @override
  String get countedStripsLabel => 'ظروف فرط';

  @override
  String get saveCount => 'سجّل';

  @override
  String tabCounted(String count) {
    return 'انعدّت ($count)';
  }

  @override
  String tabNotCounted(String count) {
    return 'لسا ($count)';
  }

  @override
  String get colCounted => 'المعدود';

  @override
  String get colSystem => 'بالنظام';

  @override
  String get colDifference => 'الفرق';

  @override
  String shortageValue(String amount) {
    return 'قيمة النقص: $amount';
  }

  @override
  String surplusValue(String amount) {
    return 'قيمة الزيادة: $amount';
  }

  @override
  String get applyStocktake => 'طبّق الجرد';

  @override
  String applyConfirm(String count) {
    return 'رح ينعمل $count تعديل على المخزون، وبيتسكّر الجرد. أكيد؟';
  }

  @override
  String stocktakeApplied(String count) {
    return 'انطبّق الجرد: $count تعديل';
  }

  @override
  String get ownerAppliesNote => 'تطبيق الجرد على المخزون للمالك بس';

  @override
  String get pastStocktakes => 'جرودات سابقة';

  @override
  String get noStocktakes => 'ما في جرودات سابقة';

  @override
  String get blindCountNote => 'ما منفرجيك الكمية يلي بالنظام قبل العدّ، منشان يكون العدّ دقيق.';

  @override
  String get syncTitle => 'السيرفر والمزامنة';

  @override
  String get syncNotLinkedHelp =>
      'هالجهاز شغّال لحاله. اربطه بسيرفر الصيدلية (كمبيوتر الصيدلية) لتتشارك كل الأجهزة نفس البيانات. البيع بيضل شغّال حتى لو السيرفر طفي.';

  @override
  String get findServer => 'دوّر على السيرفر';

  @override
  String get searchingServer => 'عم دوّر على الشبكة';

  @override
  String get noServerFound =>
      'ما لقينا سيرفر على هالشبكة. تأكد إنو كمبيوتر الصيدلية شغّال وعلى نفس الواي فاي، أو اكتب عنوانه.';

  @override
  String get serverAddressLabel => 'عنوان السيرفر';

  @override
  String get serverAddressHint => '192.168.1.10';

  @override
  String get useThisServer => 'اعتمد هالعنوان';

  @override
  String get serverNotResponding => 'ما في سيرفر دوايا عم يرد على هالعنوان';

  @override
  String get createOnServerTitle => 'إنشاء الصيدلية على السيرفر';

  @override
  String get createOnServerHelp =>
      'السيرفر جديد: رح ننشئ الصيدلية عليه ونرفع كل بيانات هالجهاز. رقمك وكلمة السر رح تربط فيهن باقي الأجهزة.';

  @override
  String get linkTitle => 'ربط هالجهاز';

  @override
  String get phoneAccountLabel => 'رقم الموبايل';

  @override
  String get passwordLabel => 'كلمة السر';

  @override
  String get passwordConfirmLabel => 'تأكيد كلمة السر';

  @override
  String get passwordTooShort => '6 أحرف على الأقل';

  @override
  String get passwordMismatch => 'كلمتين السر مو متطابقين';

  @override
  String get linkButton => 'اربط';

  @override
  String get createAndLink => 'أنشئ واربط';

  @override
  String linkedTo(String pharmacy) {
    return 'مربوط بـ $pharmacy';
  }

  @override
  String signedInAs(String name) {
    return 'الحساب: $name';
  }

  @override
  String lastSync(String time) {
    return 'آخر مزامنة: $time';
  }

  @override
  String get neverSynced => 'لسا ما صار مزامنة';

  @override
  String pendingChanges(String count) {
    return '$count حركة ناطرة';
  }

  @override
  String get syncNowButton => 'زامن هلق';

  @override
  String syncDownloading(String percent) {
    return 'عم ننزّل بيانات الصيدلية: $percent%';
  }

  @override
  String get statusSyncing => 'عم يزامن';

  @override
  String statusSynced(String time) {
    return 'متزامن $time';
  }

  @override
  String get statusServerMissing => 'السيرفر مو موجود';

  @override
  String get statusUnlinked => 'الجهاز مفصول';

  @override
  String get statusFailed => 'المزامنة وقفت';

  @override
  String get unlinkedHelp =>
      'صاحب الصيدلية فصل هالجهاز عن السيرفر. البيع شغّال، بس ما رح يتزامن لحتى ينربط من جديد.';

  @override
  String get serverMissingHelp => 'ما عم نوصل للسيرفر. البيع شغّال عادي، والحركات ناطرة لحتى يرجع.';

  @override
  String get statusWrongServer => 'السيرفر تغيّر';

  @override
  String get wrongServerHelp =>
      'يلي عم يرد على عنوان السيرفر مو نفس السيرفر يلي انربط عليه هالجهاز (رمزه مختلف)، فوقّفنا المزامنة منشان ما تطلع البيانات لجهاز غريب. البيع شغّال عادي. إذا انعاد تركيب السيرفر، اربط الجهاز من جديد.';

  @override
  String get errWrongServer => 'رمز السيرفر مو نفسه يلي انربط عليه الجهاز';

  @override
  String get relinkButton => 'اربط من جديد';

  @override
  String get relinkConfirm =>
      'رح ينفك ربط هالجهاز بالسيرفر لتربطه من جديد. البيانات يلي عليه بتضل، وبترتفع كلها مع الربط الجديد. أكيد؟';

  @override
  String serverCode(String code) {
    return 'رمز السيرفر: $code';
  }

  @override
  String get serverCodeHelp => 'لازم يطابق الرمز يلي طلع وقت تركيب السيرفر.';

  @override
  String get devicesTitle => 'الأجهزة المربوطة';

  @override
  String get unlinkDevice => 'افصل';

  @override
  String unlinkConfirm(String name) {
    return 'رح ينفصل الجهاز $name عن السيرفر فوراً. أكيد؟';
  }

  @override
  String get thisDeviceTag => 'هالجهاز';

  @override
  String get deviceUnlinkedTag => 'مفصول';

  @override
  String lastSeen(String time) {
    return 'آخر ظهور $time';
  }

  @override
  String get accountsTitle => 'حسابات الموظفين';

  @override
  String get accountsHelp => 'كل موظف إلو رقم وكلمة سر، بيربط فيهن موبايله مرة وحدة وبيضل مسجّل.';

  @override
  String get addAccount => 'حساب لموظف';

  @override
  String get accountEmployeeLabel => 'الموظف';

  @override
  String get accountDisabled => 'موقوف';

  @override
  String get errBadCredentials => 'الرقم أو كلمة السر غلط';

  @override
  String get errPhoneTaken => 'هالرقم إلو حساب من قبل';

  @override
  String get errTooManyAttempts => 'محاولات كتير غلط، جرّب بعد ربع ساعة';

  @override
  String get errAlreadySetUp => 'هالسيرفر عليه صيدلية من قبل: اربط برقم وكلمة سر';

  @override
  String get errDeviceOtherPharmacy => 'هالجهاز مربوط بصيدلية تانية';

  @override
  String get errPharmacyInactive => 'الصيدلية موقوفة على السيرفر';

  @override
  String errServer(String code) {
    return 'صار خطأ بالسيرفر ($code)';
  }

  @override
  String get joinExisting => 'انضمام لصيدلية موجودة';

  @override
  String get navMore => 'المزيد';

  @override
  String serverBackupLast(String time) {
    return 'آخر نسخة احتياطية على السيرفر: $time';
  }

  @override
  String get serverBackupNone => 'السيرفر لسا ما عمل نسخة احتياطية';

  @override
  String get serverBackupError => 'في مشكلة بالنسخ الاحتياطي على السيرفر: شوف دليل التركيب';

  @override
  String get navInventoryShort => 'المخزون';

  @override
  String get navDebtsShort => 'الديون';

  @override
  String get newServer => 'سيرفر دوايا جديد (بلا صيدلية لسا)';

  @override
  String get newPharmacy => 'صيدلية جديدة';

  @override
  String get joinHelp =>
      'للموبايلات والأجهزة الإضافية: بتربطها بسيرفر الصيدلية وبتنزل كل البيانات.';

  @override
  String get joining => 'عم نربط وننزّل البيانات';

  @override
  String get joinNoEmployee => 'الحساب مو مربوط بموظف على هالصيدلية. اطلب من صاحب الصيدلية يربطه.';
}
