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
}
