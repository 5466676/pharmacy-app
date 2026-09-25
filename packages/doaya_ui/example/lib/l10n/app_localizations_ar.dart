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
  String get galleryTitle => 'مكوّنات دوايا';

  @override
  String get tagline => 'صيدليتك بجيبتك';

  @override
  String get splashBody => 'استشارة بإشراف صيدلي.\nدواك جاهز لما توصل.\nوصحتك بإيد أمينة.';

  @override
  String get modeGlass => 'زجاج';

  @override
  String get modeSolid => 'صلب';

  @override
  String get openDesktop => 'واجهة سطح المكتب';

  @override
  String get compactSidebar => 'شريط مصغّر';

  @override
  String get fullSidebar => 'شريط كامل';

  @override
  String get sectionColors => 'الألوان';

  @override
  String get sectionTypography => 'الخطوط';

  @override
  String get sectionLogo => 'الشعار';

  @override
  String get sectionButtons => 'الأزرار';

  @override
  String get sectionInputs => 'الحقول';

  @override
  String get sectionTiles => 'الأصناف';

  @override
  String get sectionProducts => 'متوفر بصيدليتك';

  @override
  String get sectionStats => 'بطاقات الأرقام';

  @override
  String get sectionChips => 'الحالات';

  @override
  String get sectionNotices => 'التنبيهات';

  @override
  String get sectionCases => 'حالات المساعد';

  @override
  String get seeAll => 'الكل';

  @override
  String get heroTitle => 'حاسس بشي؟\nاحكيلي';

  @override
  String get heroBody => 'مساعد صحي، وصيدليتك بتراجع كل حالة.';

  @override
  String get startConsultation => 'ابدأ استشارة';

  @override
  String get typeDisplay => 'عنوان بخط أميري';

  @override
  String get typeBody => 'نص عادي بخط ريدكس برو، للمحتوى والشرح.';

  @override
  String typeWeight(String weight) {
    return 'وزن $weight';
  }

  @override
  String get letsGo => 'يلا نبلش';

  @override
  String get orderFromMyPharmacy => 'اطلب من صيدليتي';

  @override
  String get sendOrder => 'أرسل الطلب للصيدلية';

  @override
  String get disabled => 'غير متاح';

  @override
  String get replyNothing => 'لا، ولا شي';

  @override
  String get replyAllergy => 'عندي حساسية';

  @override
  String get back => 'رجوع';

  @override
  String get favorite => 'المفضلة';

  @override
  String get share => 'مشاركة';

  @override
  String get filter => 'فلترة';

  @override
  String get searchHint => 'دوّر على دوا أو منتج...';

  @override
  String get posSearchHint => 'ابحث أو امسح الباركود';

  @override
  String get catMedicine => 'الأدوية';

  @override
  String get catHealth => 'صحية';

  @override
  String get catCare => 'عناية';

  @override
  String get catKids => 'أطفال';

  @override
  String get catDevices => 'أجهزة';

  @override
  String get skinWash => 'غسول بشرة';

  @override
  String price(String amount) {
    return '$amount ل.س';
  }

  @override
  String get statSalesToday => 'مبيعات اليوم';

  @override
  String get statOpenDebts => 'ديون مفتوحة';

  @override
  String get statNearExpiry => 'قرب تنتهي صلاحيته';

  @override
  String get statAiCases => 'حالات المساعد';

  @override
  String statVsYesterday(String percent) {
    return '$percent٪ عن مبارح';
  }

  @override
  String statCustomers(String count) {
    return '$count زبون';
  }

  @override
  String statWithinDays(String count) {
    return 'خلال $count يوم';
  }

  @override
  String statWaiting(String count) {
    return '$count بانتظارك';
  }

  @override
  String get chipReady => 'جاهز';

  @override
  String chipInStock(String count) {
    return 'متوفر · $count';
  }

  @override
  String chipLeft(String count) {
    return 'باقي $count';
  }

  @override
  String get chipOut => 'نفد';

  @override
  String get chipSynced => 'متزامن';

  @override
  String get chipCash => 'نقدي';

  @override
  String get chipUrgent => 'مستعجلة';

  @override
  String get chipDelivered => 'وصلت للصيدلية';

  @override
  String get noticeSafety => 'إذا صار عندك ضيق نفس أو ألم بالصدر، روح عالطوارئ فوراً.';

  @override
  String get noticeEmergency =>
      'الأعراض يلي ذكرتها ممكن تكون خطيرة. اتصل بالإسعاف أو روح لأقرب طوارئ هلق.';

  @override
  String get callEmergency => 'اتصل بالإسعاف';

  @override
  String get case1Title => 'ألم صدر مع ضيق نفس';

  @override
  String case1Sub(String minutes) {
    return 'مستعجلة · من $minutes دقيقة';
  }

  @override
  String get case2Title => 'صداع وحرارة خفيفة';

  @override
  String case2Sub(String minutes) {
    return 'من $minutes دقايق';
  }

  @override
  String get case3Title => 'سعال ناشف عند طفل';

  @override
  String case3Sub(String minutes) {
    return 'من $minutes دقيقة';
  }

  @override
  String get initials1 => 'س.ح';

  @override
  String get initials2 => 'م.ع';

  @override
  String get initials3 => 'ر.خ';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navConsult => 'استشارة';

  @override
  String get navDoses => 'جرعاتي';

  @override
  String get navOrders => 'طلباتي';

  @override
  String get navAccount => 'حسابي';

  @override
  String get sideMain => 'الرئيسية';

  @override
  String get sideOps => 'العمليات';

  @override
  String get sideAdmin => 'الإدارة';

  @override
  String get sideDashboard => 'لوحة التحكم';

  @override
  String get sideInventory => 'الأدوية والمخزون';

  @override
  String get sideCategories => 'الأصناف';

  @override
  String get sideSale => 'البيع';

  @override
  String get sideDebts => 'الزبائن والديون';

  @override
  String get sideCases => 'حالات المساعد';

  @override
  String get sideReports => 'التقارير';

  @override
  String get sideSettings => 'الإعدادات';

  @override
  String greeting(String name) {
    return 'أهلين د. $name';
  }

  @override
  String get newSale => 'بيع جديد';

  @override
  String pharmacistName(String name) {
    return 'د. $name';
  }

  @override
  String pharmacyName(String name) {
    return 'صيدلية $name';
  }

  @override
  String get sampleDoctor => 'سامر';

  @override
  String get samplePharmacy => 'الشفاء';

  @override
  String get pharmacyResults => 'نتائج الصيدلية';

  @override
  String get latestCases => 'آخر الحالات';
}
