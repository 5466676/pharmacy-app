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
  String get panelName => 'لوحة المالك';

  @override
  String get navOverview => 'نظرة عامة';

  @override
  String get navPharmacies => 'الصيدليات';

  @override
  String get navPerformance => 'الأداء والمكافآت';

  @override
  String get navReview => 'مراجعة المحادثات';

  @override
  String get navKnowledge => 'قاعدة المعرفة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navPayments => 'المدفوعات: مطفية';

  @override
  String get signOut => 'تسجيل خروج';

  @override
  String get loading => 'لحظة...';

  @override
  String get retry => 'جرّب مرة تانية';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'سكّر';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'انتسخ';

  @override
  String get never => 'أبداً';

  @override
  String get none => 'ما في';

  @override
  String minutesShort(String n) {
    return '$n د';
  }

  @override
  String percent(String n) {
    return '$n%';
  }

  @override
  String agoMinutes(String n) {
    return 'من $n دقيقة';
  }

  @override
  String agoHours(String n) {
    return 'من $n ساعة';
  }

  @override
  String agoDays(String n) {
    return 'من $n يوم';
  }

  @override
  String get justNow => 'هلق';

  @override
  String get errNetwork => 'ما في اتصال مع سيرفر دوايا. تأكد من الإنترنت وجرّب مرة تانية.';

  @override
  String get errBadCredentials => 'الرقم أو كلمة السر غلط.';

  @override
  String get errTooMany => 'محاولات كتير غلط. استنى ربع ساعة وجرّب.';

  @override
  String get errReasonRequired => 'اكتب السبب (3 أحرف عالأقل).';

  @override
  String get errBadStatus => 'هالخطوة ما بتنفع بحالة الصيدلية الحالية.';

  @override
  String get errCodeTaken => 'هالرمز مستعمل لصيدلية تانية.';

  @override
  String get errBadCode => 'الرمز من 3 لـ 12 حرف إنكليزي أو رقم.';

  @override
  String get errNoteHasDose =>
      'الملاحظة فيها جرعة. المساعد ما بيعطي جرعات أبداً، شيلها واكتب شو لازم يسأل.';

  @override
  String errGeneric(String code) {
    return 'صار خطأ: $code';
  }

  @override
  String get signInTitle => 'لوحة مالك دوايا';

  @override
  String get signInSubtitle => 'للمالك بس. الحساب بيتعمل من سطر الأوامر على السيرفر.';

  @override
  String get phone => 'رقم الموبايل';

  @override
  String get password => 'كلمة السر';

  @override
  String get signIn => 'دخول';

  @override
  String get required => 'مطلوب';

  @override
  String overviewSubtitle(String days) {
    return 'آخر $days يوم';
  }

  @override
  String get rangeToday => 'اليوم';

  @override
  String get rangeWeek => '7 أيام';

  @override
  String get rangeMonth => '30 يوم';

  @override
  String get rangeQuarter => '90 يوم';

  @override
  String get kpiPharmacies => 'صيدليات فعّالة';

  @override
  String kpiPharmaciesCaption(String connected, String fresh) {
    return 'متصلة هلق: $connected، جديدة: $fresh';
  }

  @override
  String get kpiPatients => 'مرضى مسجلين';

  @override
  String kpiPatientsCaption(String active, String fresh) {
    return 'فعّالين: $active، جدد: $fresh';
  }

  @override
  String get kpiToday => 'استشارات اليوم';

  @override
  String kpiTodayCaption(String orders) {
    return 'طلبات: $orders';
  }

  @override
  String get kpiResponse => 'متوسط أول رد';

  @override
  String kpiResponseCaption(String target, String open) {
    return 'الهدف: $target د أو أقل، ما انجاوب: $open';
  }

  @override
  String get kpiUrgent => 'حالات خطرة اليوم';

  @override
  String kpiUrgentCaption(String open) {
    return 'ناطرة رد: $open';
  }

  @override
  String get chartTitle => 'سرعة أول رد';

  @override
  String get chartLegend => 'بالدقايق: الخط هو المتوسط، والشريط لحد أبطأ 10%، والمنقّط هو الهدف';

  @override
  String get chartEmpty => 'ما في حالات انجاوبت بهالفترة.';

  @override
  String get attentionTitle => 'بدها انتباه';

  @override
  String get attentionNone => 'كل الصيدليات ماشية تمام.';

  @override
  String attentionOffline(String ago) {
    return 'ما اتصلت $ago';
  }

  @override
  String get attentionNeverConnected => 'ما اتصلت ولا مرة';

  @override
  String get attentionHealth => 'الفحص الشهري فيه مشكلة';

  @override
  String attentionSlow(String m) {
    return 'رد بطيء: $m';
  }

  @override
  String reviewWaiting(String n) {
    return '$n محادثة ناطرة مراجعة';
  }

  @override
  String get openReview => 'افتح المراجعة';

  @override
  String get paymentsOff => 'الاشتراكات والمدفوعات مطفية بهالمرحلة (الدفع عند الاستلام).';

  @override
  String get searchPharmacies => 'دوّر بالاسم أو المدينة أو الرمز';

  @override
  String get addPharmacy => 'صيدلية جديدة';

  @override
  String get colName => 'الصيدلية';

  @override
  String get colCity => 'المدينة';

  @override
  String get colPatients => 'المرضى';

  @override
  String get colResponse => 'المتوسط';

  @override
  String get colConnection => 'الاتصال';

  @override
  String get colStatus => 'الحالة';

  @override
  String get statusActive => 'فعّالة';

  @override
  String get statusPending => 'ناطرة موافقة';

  @override
  String get statusSuspended => 'معلّقة';

  @override
  String get statusStopped => 'النظام موقّف';

  @override
  String get statusRemoved => 'ملغاة';

  @override
  String get connected => 'متصلة';

  @override
  String get hidden => 'مخفية عن المرضى';

  @override
  String get noPharmacies => 'ما في صيدليات لسا. ضيف أول وحدة من «صيدلية جديدة».';

  @override
  String get pickPharmacy => 'اختار صيدلية من القائمة لتشوف تفاصيلها.';

  @override
  String get factCode => 'الرمز';

  @override
  String get factLastContact => 'آخر اتصال';

  @override
  String get factLicence => 'الترخيص';

  @override
  String licenceDays(String n) {
    return '$n يوم بلا اتصال';
  }

  @override
  String get factDevices => 'الأجهزة';

  @override
  String get factBackup => 'آخر نسخة احتياطية';

  @override
  String get factVersion => 'نسخة السيرفر';

  @override
  String get factDisk => 'المساحة الفاضية';

  @override
  String diskMb(String n) {
    return '$n ميغا';
  }

  @override
  String get factKeys => 'مفاتيح فعّالة';

  @override
  String get healthTitle => 'الفحص الشهري';

  @override
  String healthAt(String date) {
    return 'آخر فحص: $date';
  }

  @override
  String get healthNever => 'ما صار فحص لسا. بيصير مع أول اتصال.';

  @override
  String get healthRequested => 'طلبت فحص، بيصير مع الاتصال الجاي.';

  @override
  String get healthPrivacy =>
      'الفحص بيصير على كمبيوتر الصيدلية، وبيوصلك بس النتيجة. ما بتوصلك أدويتهم ولا مبيعاتهم ولا أرباحهم.';

  @override
  String get checkBackup => 'النسخ الاحتياطي';

  @override
  String get checkDevices => 'كل الأجهزة عم تتزامن';

  @override
  String get checkStockBelowZero => 'مخزون تحت الصفر';

  @override
  String get checkExpiredOnSale => 'أدوية منتهية لسا معروضة';

  @override
  String get checkEvents => 'سجلات ناقصة';

  @override
  String get checkOpenShifts => 'ورديات مفتوحة أكتر من يوم';

  @override
  String get checkDisk => 'المساحة';

  @override
  String get levelOk => 'تمام';

  @override
  String get levelWarn => 'تنبيه';

  @override
  String get levelProblem => 'مشكلة';

  @override
  String countOf(String n) {
    return '($n)';
  }

  @override
  String get actionsTitle => 'التحكم';

  @override
  String get actApprove => 'موافقة';

  @override
  String get actSuspend => 'تعليق';

  @override
  String get actResume => 'إعادة تشغيل';

  @override
  String get actStop => 'إيقاف النظام';

  @override
  String get actRemove => 'إلغاء';

  @override
  String get actList => 'إظهار للمرضى';

  @override
  String get actUnlist => 'إخفاء عن المرضى';

  @override
  String get actNewKey => 'مفتاح جديد';

  @override
  String get actLicence => 'مدة الترخيص';

  @override
  String get actHealth => 'فحص هلق';

  @override
  String get actCreate => 'إضافة';

  @override
  String get explainSuspend =>
      'بيوقف دوايا أونلاين عنها فوراً: ما بتوصلها حالات ولا طلبات، وبتختفي عن المرضى. نظام البيع عندها بيضل شغال.';

  @override
  String get explainStop =>
      'أول ما يتصل سيرفرها، بيتسكّر البيع وتعديل المخزون عندها عند فتح البرنامج الجاي. الشوفة وتصدير بياناتها بيضلوا مفتوحين.';

  @override
  String get explainRemove =>
      'لما تشيل البرنامج من عندهم. مفتاحها بيبطل يشتغل وبتختفي عن المرضى، وما في رجعة.';

  @override
  String get explainNewKey => 'المفتاح القديم بيبطل فوراً. لازم تحط الجديد بسيرفر الصيدلية.';

  @override
  String get explainResume => 'بترجع الصيدلية فعّالة، وبيوصلها الخبر مع الاتصال الجاي.';

  @override
  String get reason => 'السبب';

  @override
  String get reasonHint => 'مثلاً: انتهى العقد';

  @override
  String get licencePrompt => 'قديش يوم بيضل النظام شغال بلا ما يتصل بدوايا؟';

  @override
  String get days => 'عدد الأيام';

  @override
  String get keyTitle => 'مفتاح سيرفر الصيدلية';

  @override
  String get keyOnce =>
      'انسخه هلق وحطه بسيرفر الصيدلية (شاشة «السيرفر والمزامنة» عند المالك). ما رح يبيّن مرة تانية.';

  @override
  String get logTitle => 'سجل الخطوات';

  @override
  String get logEmpty => 'ما في خطوات لسا.';

  @override
  String logBy(String who, String when) {
    return '$who، $when';
  }

  @override
  String get fieldName => 'اسم الصيدلية';

  @override
  String get fieldCity => 'المدينة';

  @override
  String get fieldCode => 'الرمز (بيشوفه المريض عالكاونتر)';

  @override
  String get fieldAddress => 'العنوان';

  @override
  String get fieldPhone => 'رقم الصيدلية';

  @override
  String get fieldHours => 'الدوام';

  @override
  String get perfTitle => 'الأداء والمكافآت';

  @override
  String perfSubtitle(String target, String min) {
    return 'الترتيب حسب نسبة الرد خلال $target دقايق، وبعدين نسبة الجواب والسرعة. الصيدلية يلي عندها أقل من $min حالة ما بتدخل الترتيب.';
  }

  @override
  String get perfMonth => 'الشهر';

  @override
  String get colRank => '#';

  @override
  String get colCases => 'حالات';

  @override
  String get colAnswered => 'انجاوب';

  @override
  String get colWithin => 'خلال الهدف';

  @override
  String get colP90 => 'أبطأ 10%';

  @override
  String get colUrgent => 'خطرة بوقتها';

  @override
  String get colOrders => 'طلبات جاهزة';

  @override
  String get colTier => 'الفئة';

  @override
  String get tierGold => 'ذهبي';

  @override
  String get tierSilver => 'فضي';

  @override
  String get tierFew => 'حالات قليلة';

  @override
  String get perfEmpty => 'ما في حالات بهالشهر.';

  @override
  String get rewardsNote => 'المكافآت نفسها بتقررها إنت برّا البرنامج.';

  @override
  String get reviewTitle => 'مراجعة المحادثات';

  @override
  String get reviewSubtitle => 'بلا اسم المريض ولا رقمه: العمر والجنس والصيدلية بس.';

  @override
  String get reviewWaitingTab => 'ناطرة';

  @override
  String get reviewDoneTab => 'خلصت';

  @override
  String get reviewEmpty => 'ما في شي ناطر مراجعة.';

  @override
  String get kindRedFlag => 'حالة خطرة';

  @override
  String get kindGuardBlock => 'رد انمنع';

  @override
  String get kindCorrection => 'تصحيح صيدلي';

  @override
  String get kindPatientEdit => 'المريض عدّل الملخص';

  @override
  String get kindLlmDown => 'النموذج وقف';

  @override
  String patientBrief(String sex, String age, String pharmacy) {
    return '$sex، $age سنة، $pharmacy';
  }

  @override
  String get sexM => 'رجل';

  @override
  String get sexF => 'امرأة';

  @override
  String get unknown => 'مو معروف';

  @override
  String get roleAssistant => 'المساعد';

  @override
  String get rolePatient => 'المريض';

  @override
  String get rolePharmacist => 'الصيدلي';

  @override
  String get roleSystem => 'النظام';

  @override
  String get photoMarker => 'صورة';

  @override
  String get detailTitle => 'التفاصيل';

  @override
  String get reviewNote => 'ملاحظتك';

  @override
  String get markReviewed => 'تمت المراجعة';

  @override
  String get toKnowledge => 'حوّلها لملاحظة بقاعدة المعرفة';

  @override
  String get pickItem => 'اختار محادثة من القائمة.';

  @override
  String get knowledgeTitle => 'قاعدة المعرفة';

  @override
  String get knowledgeSubtitle =>
      'ملاحظات قصيرة بتساعد المساعد يسأل أحسن. بتوصله الملاحظة لما يذكر المريض وحدة من كلماتها. ما في تدريب تلقائي أبداً.';

  @override
  String get addNote => 'ملاحظة جديدة';

  @override
  String get noteTitle => 'العنوان';

  @override
  String get noteText => 'الملاحظة';

  @override
  String get noteTags => 'الكلمات (افصل بينها بفاصلة)';

  @override
  String get noteTagsHint => 'طفل، رضيع، حرار';

  @override
  String get noteEnabled => 'شغّالة';

  @override
  String get noteDisabled => 'مطفية';

  @override
  String get notesEmpty => 'ما في ملاحظات لسا.';

  @override
  String get tryTitle => 'جرّب';

  @override
  String get tryHint => 'اكتب شي متل ما بيكتبه المريض';

  @override
  String tryResult(String titles) {
    return 'بيوصل للمساعد: $titles';
  }

  @override
  String get tryNothing => 'ولا ملاحظة.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get designTitle => 'شكل اللوحة';

  @override
  String get designConsole => 'غرفة القيادة';

  @override
  String get designConsoleNote => 'غامقة ودقيقة، أرقام كتير بمساحة قليلة.';

  @override
  String get designLedger => 'الدفتر';

  @override
  String get designLedgerNote => 'فاتحة ونظيفة، بتنقرى منيح بالنهار.';

  @override
  String get designFamily => 'من عيلة دوايا';

  @override
  String get designFamilyNote => 'أخضر دوايا وخط أميري.';

  @override
  String get serverTitle => 'السيرفر';

  @override
  String get serverNote => 'بتتغيّر من إعدادات السيرفر نفسه، مو من هون.';

  @override
  String get modelUrl => 'عنوان النموذج';

  @override
  String get modelName => 'النموذج';

  @override
  String get modelCheck => 'جرّب النموذج';

  @override
  String modelOk(String ms) {
    return 'عم يجاوب ($ms ملي ثانية)';
  }

  @override
  String modelDown(String error) {
    return 'ما عم يجاوب: $error';
  }

  @override
  String get emergencyNumbers => 'أرقام الطوارئ';

  @override
  String emergencyValue(String ambulance, String general) {
    return 'إسعاف $ambulance، طوارئ $general';
  }

  @override
  String get corsOrigins => 'عناوين الويب المسموحة';

  @override
  String get serverVersion => 'نسخة السيرفر';

  @override
  String get detailMatched => 'الكلام يلي طابق';

  @override
  String get detailCategory => 'النوع';

  @override
  String get detailCorrection => 'التصحيح';

  @override
  String get detailOriginal => 'قبل التصحيح';

  @override
  String get detailReply => 'رد المساعد';

  @override
  String get detailError => 'الخطأ';

  @override
  String get detailBy => 'الصيدلي';

  @override
  String get detailReason => 'السبب';
}
