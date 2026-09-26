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
  String get tagline => 'استشارة صحية بلهجتك، وصيدليتك بتراجع كل حالة وبتحضّرلك الدوا.';

  @override
  String get createAccount => 'حساب جديد';

  @override
  String get haveAccount => 'عندي حساب';

  @override
  String get signIn => 'دخول';

  @override
  String get signUpTitle => 'حساب جديد';

  @override
  String get signInTitle => 'أهلين فيك من جديد';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get phoneLabel => 'رقم الموبايل';

  @override
  String get passwordLabel => 'كلمة السر';

  @override
  String get birthYearLabel => 'سنة الميلاد';

  @override
  String get sexLabel => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get cityLabel => 'المدينة';

  @override
  String get optional => 'اختياري';

  @override
  String get required => 'مطلوب';

  @override
  String get invalidPhone => 'رقم الموبايل مو مزبوط';

  @override
  String get passwordTooShort => 'كلمة السر 6 أحرف أو أكتر';

  @override
  String get invalidYear => 'سنة مو مزبوطة';

  @override
  String get signUpHelp => 'العمر والجنس بيساعدوا الصيدلي يختارلك الأنسب، وما بيشوفهن غير صيدليتك.';

  @override
  String get choosePharmacyTitle => 'اختار صيدليتك';

  @override
  String get choosePharmacyHelp => 'حالاتك وطلباتك بتروح لهالصيدلية. فيك تغيّرها بعدين.';

  @override
  String get pharmacyCodeLabel => 'رمز الصيدلية';

  @override
  String get pharmacyCodeHint => 'مكتوب عند الكاونتر، متل SH4F';

  @override
  String get findByCode => 'دوّر';

  @override
  String get orPickFromList => 'أو اختار من القائمة';

  @override
  String get noPharmacies => 'ما في صيدليات بهالمدينة لسا';

  @override
  String get chooseThis => 'اختار';

  @override
  String pharmacyHours(String hours) {
    return 'الدوام: $hours';
  }

  @override
  String get yourPharmacy => 'صيدليتك';

  @override
  String get change => 'غيّر';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navConsultations => 'استشاراتي';

  @override
  String get navAccount => 'حسابي';

  @override
  String get heroTitle => 'حاسس بشي؟\nاحكيلي';

  @override
  String get heroSubtitle => 'مساعد صحي، وصيدليتك بتراجع كل حالة.';

  @override
  String get startConsultation => 'ابدأ استشارة';

  @override
  String get recentConsultations => 'آخر استشاراتك';

  @override
  String get seeAll => 'الكل';

  @override
  String get noConsultations => 'ما عندك استشارات لسا';

  @override
  String get safetyLine => 'إذا صار عندك ضيق نفس أو ألم بالصدر، روح عالطوارئ فوراً.';

  @override
  String get assistantTitle => 'مساعد دوايا';

  @override
  String pharmacyFollowing(String name) {
    return '$name متابعة';
  }

  @override
  String get messageHint => 'اكتب رسالتك';

  @override
  String get send => 'ابعت';

  @override
  String get sendToPharmacyNow => 'ابعت المحادثة للصيدلي مباشرة';

  @override
  String get summaryTitle => 'ملخص حالتك';

  @override
  String get summaryHelp => 'راجعه، وصحّح أي شي قبل ما تبعته.';

  @override
  String get sendToPharmacy => 'ابعته للصيدلية';

  @override
  String get edit => 'عدّل';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get sumSymptoms => 'الأعراض';

  @override
  String get sumDuration => 'المدة';

  @override
  String get sumAge => 'العمر';

  @override
  String get sumSex => 'الجنس';

  @override
  String get sumPregnancy => 'حمل أو إرضاع';

  @override
  String get sumAllergies => 'الحساسية';

  @override
  String get sumMedications => 'أدوية عم تاخدها';

  @override
  String get sumConditions => 'أمراض مزمنة';

  @override
  String get sumDenied => 'نفيت';

  @override
  String get sumNotes => 'ملاحظات';

  @override
  String get listHint => 'افصل بفاصلة';

  @override
  String status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'chatting': 'مع المساعد',
      'summary': 'ناطر مراجعتك',
      'sent': 'وصلت للصيدلية',
      'preparing': 'الصيدلي عم يحضّر',
      'ready': 'جاهز للاستلام',
      'picked_up': 'استلمت',
      'needs_doctor': 'بحاجة طبيب',
      'emergency': 'حالة طارئة',
      'closed': 'مسكّرة',
      'other': '$status',
    });
    return '$_temp0';
  }

  @override
  String get stepSent => 'وصلت';

  @override
  String get stepPreparing => 'عم يتحضّر';

  @override
  String get stepReady => 'جاهز';

  @override
  String get stepPickedUp => 'استلمت';

  @override
  String get decisionTitle => 'حضّرلك الصيدلي';

  @override
  String decisionBy(String name) {
    return 'الصيدلي $name';
  }

  @override
  String pickupAt(String name) {
    return 'استلام من $name، الدفع عند الاستلام';
  }

  @override
  String get roleAssistant => 'المساعد';

  @override
  String get rolePharmacist => 'الصيدلي';

  @override
  String get emergencyTitle => 'اطلب مساعدة هلق';

  @override
  String callAmbulance(String number) {
    return 'الإسعاف $number';
  }

  @override
  String callEmergency(String number) {
    return 'الطوارئ $number';
  }

  @override
  String get emergencyStillWrite => 'فيك تكتب للصيدلية هون كمان.';

  @override
  String get consultationClosed => 'هالاستشارة خلصت. ابدأ وحدة جديدة إذا احتجت.';

  @override
  String get accountTitle => 'حسابي';

  @override
  String get logout => 'تسجيل خروج';

  @override
  String get logoutConfirm => 'بدك تطلع من حسابك على هالجهاز؟';

  @override
  String get confirm => 'تأكيد';

  @override
  String get errNetwork => 'ما في اتصال بالإنترنت. جرّب كمان شوي.';

  @override
  String get errPhoneTaken => 'في حساب بهالرقم. جرّب «عندي حساب».';

  @override
  String get errBadCredentials => 'الرقم أو كلمة السر غلط';

  @override
  String get errTooMany => 'محاولات كتير، استنى شوي وجرّب';

  @override
  String get errPharmacyNotFound => 'ما لقينا صيدلية بهالرمز';

  @override
  String errGeneric(String code) {
    return 'صار خطأ ($code)، جرّب كمان مرة';
  }

  @override
  String get thinking => 'عم يكتب…';

  @override
  String get retry => 'جرّب كمان مرة';

  @override
  String get navOrders => 'طلباتي';

  @override
  String get searchHint => 'دوّر على دوا أو منتج…';

  @override
  String get availableAtPharmacy => 'متوفر بصيدليتك';

  @override
  String get shelfTitle => 'رفوف صيدليتك';

  @override
  String get available => 'متوفر';

  @override
  String get unavailable => 'مو متوفر هلق';

  @override
  String get prescriptionOnly => 'بوصفة';

  @override
  String get noPrescription => 'بدون وصفة';

  @override
  String get rxHint => 'هالدوا بدو وصفة طبية: جيبها معك وقت الاستلام، والصيدلي بيقرر.';

  @override
  String get askPharmacistHint =>
      'اسأل صيدليتك عن الطريقة المناسبة إلك، خصوصاً إذا عم تاخد أدوية تانية.';

  @override
  String get ingredient => 'المادة الفعالة';

  @override
  String get strength => 'العيار';

  @override
  String get dosageForm => 'الشكل';

  @override
  String get noResults => 'ما لقينا شي بهالاسم';

  @override
  String get orderFromPharmacy => 'اطلب من صيدليتي';

  @override
  String get addedToCart => 'انضاف لطلبيتك';

  @override
  String inCart(String count) {
    return 'بطلبيتك: $count';
  }

  @override
  String get viewCart => 'شوف الطلبية';

  @override
  String get less => 'أقل';

  @override
  String get more => 'أكتر';

  @override
  String get cartTitle => 'طلبيتي';

  @override
  String get cartEmpty => 'طلبيتك فاضية. اختار من رفوف صيدليتك.';

  @override
  String get browseShelf => 'تصفّح الرفوف';

  @override
  String get noteToPharmacist => 'ملاحظة للصيدلي';

  @override
  String orderTotal(String amount) {
    return 'المجموع: $amount';
  }

  @override
  String pickupFrom(String name) {
    return 'استلام من $name';
  }

  @override
  String get sendOrder => 'أرسل الطلب للصيدلية';

  @override
  String get payAtPickup => 'الدفع عند الاستلام بالصيدلية';

  @override
  String get finalQuantitiesHint => 'الكميات النهائية بيحددها الصيدلي حسب الموجود.';

  @override
  String get orderSent => 'وصل طلبك للصيدلية';

  @override
  String get ordersTitle => 'طلباتي';

  @override
  String get noOrders => 'ما عندك طلبات لسا';

  @override
  String orderStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'sent': 'وصل للصيدلية',
      'preparing': 'عم يتحضّر',
      'ready': 'جاهز للاستلام',
      'picked_up': 'استلمته',
      'rejected': 'ما في هلق',
      'cancelled': 'ملغى',
      'other': '$status',
    });
    return '$_temp0';
  }

  @override
  String orderLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتج',
      few: '$count منتجات',
      two: 'منتجين',
      one: 'منتج واحد',
    );
    return '$_temp0';
  }

  @override
  String lineChanged(String requested, String quantity) {
    return 'طلبت $requested، الصيدلي حضّر $quantity';
  }

  @override
  String lineDropped(String requested) {
    return 'طلبت $requested، ما في هلق';
  }

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get cancelOrderConfirm => 'بدك تلغي هالطلب؟';

  @override
  String get keepOrder => 'لا، خليه';

  @override
  String orderTitle(String date) {
    return 'طلب $date';
  }

  @override
  String get errUnknownProduct => 'في منتج ما عاد موجود على الرف. حدّث الطلبية.';

  @override
  String get errAlreadyHandled => 'الصيدلي بلّش بالطلب، ما عاد فيك تلغيه.';

  @override
  String lineQtyPrice(String quantity, String price) {
    return '$quantity × $price';
  }

  @override
  String get noticeConsultationReady => 'حضّرلك الصيدلي دواك';

  @override
  String get noticeConsultationReadyBody => 'جاهز للاستلام من صيدليتك، والتعليمات بالمحادثة.';

  @override
  String get noticeNeedsDoctor => 'الصيدلي شايف لازم تشوف طبيب';

  @override
  String get noticeNeedsDoctorBody => 'افتح المحادثة لتقرا شو كتبلك.';

  @override
  String get noticePreparing => 'الصيدلي عم يحضّر حالتك';

  @override
  String get noticeOrderReady => 'طلبك جاهز للاستلام';

  @override
  String get noticeOrderRejected => 'ما قدرت الصيدلية تحضّر طلبك';

  @override
  String get noticeOrderBody => 'افتح «طلباتي» للتفاصيل.';

  @override
  String doseTitle(String name) {
    return 'وقت دوا $name';
  }

  @override
  String get navDoses => 'جرعاتي';

  @override
  String get dosesTitle => 'جرعاتي';

  @override
  String get noDoses =>
      'ما عندك تذكيرات. لما الصيدلي يحضّرلك دوا بعدد مرات باليوم، فيك تشغّل التذكير من المحادثة.';

  @override
  String get remindMe => 'ذكّرني بالجرعات';

  @override
  String get reminderOn => 'التذكير شغّال';

  @override
  String get reminderSaved => 'انحفظ التذكير';

  @override
  String get reminderTimes => 'المواعيد';

  @override
  String reminderDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'لـ $days يوم',
      few: 'لـ $days أيام',
      two: 'ليومين',
      one: 'ليوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get reminderOngoing => 'لحتى توقّفه';

  @override
  String get reminderFinished => 'خلص الكورس';

  @override
  String get reminderWebNote => 'التذكير بيوصلك كإشعار على تطبيق الموبايل. هون بتشوف المواعيد بس.';

  @override
  String get reminderTimesHelp => 'فيك تزيح المواعيد لتناسبك. عدد المرات من الصيدلي.';

  @override
  String get deleteReminder => 'احذف التذكير';

  @override
  String nextDose(String time) {
    return 'الجاية: $time';
  }

  @override
  String get notificationsOff =>
      'الإشعارات مسكّرة. شغّلها من إعدادات الموبايل منشان يوصلك التذكير.';

  @override
  String get earlier => 'أبكر نص ساعة';

  @override
  String get later => 'أبعد نص ساعة';

  @override
  String remindersAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'انضاف $count تذكير',
      few: 'انضاف $count تذكيرات',
      two: 'انضاف تذكيرين',
      one: 'انضاف تذكير واحد',
    );
    return '$_temp0';
  }

  @override
  String get remindersActive => 'التذكير شغّال لهالأدوية';
}
