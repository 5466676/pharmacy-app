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

  /// No description provided for @galleryTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكوّنات دوايا'**
  String get galleryTitle;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'صيدليتك بجيبتك'**
  String get tagline;

  /// No description provided for @splashBody.
  ///
  /// In ar, this message translates to:
  /// **'استشارة بإشراف صيدلي.\nدواك جاهز لما توصل.\nوصحتك بإيد أمينة.'**
  String get splashBody;

  /// No description provided for @modeGlass.
  ///
  /// In ar, this message translates to:
  /// **'زجاج'**
  String get modeGlass;

  /// No description provided for @modeSolid.
  ///
  /// In ar, this message translates to:
  /// **'صلب'**
  String get modeSolid;

  /// No description provided for @openDesktop.
  ///
  /// In ar, this message translates to:
  /// **'واجهة سطح المكتب'**
  String get openDesktop;

  /// No description provided for @compactSidebar.
  ///
  /// In ar, this message translates to:
  /// **'شريط مصغّر'**
  String get compactSidebar;

  /// No description provided for @fullSidebar.
  ///
  /// In ar, this message translates to:
  /// **'شريط كامل'**
  String get fullSidebar;

  /// No description provided for @sectionColors.
  ///
  /// In ar, this message translates to:
  /// **'الألوان'**
  String get sectionColors;

  /// No description provided for @sectionTypography.
  ///
  /// In ar, this message translates to:
  /// **'الخطوط'**
  String get sectionTypography;

  /// No description provided for @sectionLogo.
  ///
  /// In ar, this message translates to:
  /// **'الشعار'**
  String get sectionLogo;

  /// No description provided for @sectionButtons.
  ///
  /// In ar, this message translates to:
  /// **'الأزرار'**
  String get sectionButtons;

  /// No description provided for @sectionInputs.
  ///
  /// In ar, this message translates to:
  /// **'الحقول'**
  String get sectionInputs;

  /// No description provided for @sectionTiles.
  ///
  /// In ar, this message translates to:
  /// **'الأصناف'**
  String get sectionTiles;

  /// No description provided for @sectionProducts.
  ///
  /// In ar, this message translates to:
  /// **'متوفر بصيدليتك'**
  String get sectionProducts;

  /// No description provided for @sectionStats.
  ///
  /// In ar, this message translates to:
  /// **'بطاقات الأرقام'**
  String get sectionStats;

  /// No description provided for @sectionChips.
  ///
  /// In ar, this message translates to:
  /// **'الحالات'**
  String get sectionChips;

  /// No description provided for @sectionNotices.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get sectionNotices;

  /// No description provided for @sectionCases.
  ///
  /// In ar, this message translates to:
  /// **'حالات المساعد'**
  String get sectionCases;

  /// No description provided for @seeAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get seeAll;

  /// No description provided for @heroTitle.
  ///
  /// In ar, this message translates to:
  /// **'حاسس بشي؟\nاحكيلي'**
  String get heroTitle;

  /// No description provided for @heroBody.
  ///
  /// In ar, this message translates to:
  /// **'مساعد صحي، وصيدليتك بتراجع كل حالة.'**
  String get heroBody;

  /// No description provided for @startConsultation.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ استشارة'**
  String get startConsultation;

  /// No description provided for @typeDisplay.
  ///
  /// In ar, this message translates to:
  /// **'عنوان بخط أميري'**
  String get typeDisplay;

  /// No description provided for @typeBody.
  ///
  /// In ar, this message translates to:
  /// **'نص عادي بخط ريدكس برو، للمحتوى والشرح.'**
  String get typeBody;

  /// No description provided for @typeWeight.
  ///
  /// In ar, this message translates to:
  /// **'وزن {weight}'**
  String typeWeight(String weight);

  /// No description provided for @letsGo.
  ///
  /// In ar, this message translates to:
  /// **'يلا نبلش'**
  String get letsGo;

  /// No description provided for @orderFromMyPharmacy.
  ///
  /// In ar, this message translates to:
  /// **'اطلب من صيدليتي'**
  String get orderFromMyPharmacy;

  /// No description provided for @sendOrder.
  ///
  /// In ar, this message translates to:
  /// **'أرسل الطلب للصيدلية'**
  String get sendOrder;

  /// No description provided for @disabled.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح'**
  String get disabled;

  /// No description provided for @replyNothing.
  ///
  /// In ar, this message translates to:
  /// **'لا، ولا شي'**
  String get replyNothing;

  /// No description provided for @replyAllergy.
  ///
  /// In ar, this message translates to:
  /// **'عندي حساسية'**
  String get replyAllergy;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @favorite.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorite;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'فلترة'**
  String get filter;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'دوّر على دوا أو منتج...'**
  String get searchHint;

  /// No description provided for @posSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث أو امسح الباركود'**
  String get posSearchHint;

  /// No description provided for @catMedicine.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get catMedicine;

  /// No description provided for @catHealth.
  ///
  /// In ar, this message translates to:
  /// **'صحية'**
  String get catHealth;

  /// No description provided for @catCare.
  ///
  /// In ar, this message translates to:
  /// **'عناية'**
  String get catCare;

  /// No description provided for @catKids.
  ///
  /// In ar, this message translates to:
  /// **'أطفال'**
  String get catKids;

  /// No description provided for @catDevices.
  ///
  /// In ar, this message translates to:
  /// **'أجهزة'**
  String get catDevices;

  /// No description provided for @skinWash.
  ///
  /// In ar, this message translates to:
  /// **'غسول بشرة'**
  String get skinWash;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ل.س'**
  String price(String amount);

  /// No description provided for @statSalesToday.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات اليوم'**
  String get statSalesToday;

  /// No description provided for @statOpenDebts.
  ///
  /// In ar, this message translates to:
  /// **'ديون مفتوحة'**
  String get statOpenDebts;

  /// No description provided for @statNearExpiry.
  ///
  /// In ar, this message translates to:
  /// **'قرب تنتهي صلاحيته'**
  String get statNearExpiry;

  /// No description provided for @statAiCases.
  ///
  /// In ar, this message translates to:
  /// **'حالات المساعد'**
  String get statAiCases;

  /// No description provided for @statVsYesterday.
  ///
  /// In ar, this message translates to:
  /// **'{percent}٪ عن مبارح'**
  String statVsYesterday(String percent);

  /// No description provided for @statCustomers.
  ///
  /// In ar, this message translates to:
  /// **'{count} زبون'**
  String statCustomers(String count);

  /// No description provided for @statWithinDays.
  ///
  /// In ar, this message translates to:
  /// **'خلال {count} يوم'**
  String statWithinDays(String count);

  /// No description provided for @statWaiting.
  ///
  /// In ar, this message translates to:
  /// **'{count} بانتظارك'**
  String statWaiting(String count);

  /// No description provided for @chipReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهز'**
  String get chipReady;

  /// No description provided for @chipInStock.
  ///
  /// In ar, this message translates to:
  /// **'متوفر · {count}'**
  String chipInStock(String count);

  /// No description provided for @chipLeft.
  ///
  /// In ar, this message translates to:
  /// **'باقي {count}'**
  String chipLeft(String count);

  /// No description provided for @chipOut.
  ///
  /// In ar, this message translates to:
  /// **'نفد'**
  String get chipOut;

  /// No description provided for @chipSynced.
  ///
  /// In ar, this message translates to:
  /// **'متزامن'**
  String get chipSynced;

  /// No description provided for @chipCash.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get chipCash;

  /// No description provided for @chipUrgent.
  ///
  /// In ar, this message translates to:
  /// **'مستعجلة'**
  String get chipUrgent;

  /// No description provided for @chipDelivered.
  ///
  /// In ar, this message translates to:
  /// **'وصلت للصيدلية'**
  String get chipDelivered;

  /// No description provided for @noticeSafety.
  ///
  /// In ar, this message translates to:
  /// **'إذا صار عندك ضيق نفس أو ألم بالصدر، روح عالطوارئ فوراً.'**
  String get noticeSafety;

  /// No description provided for @noticeEmergency.
  ///
  /// In ar, this message translates to:
  /// **'الأعراض يلي ذكرتها ممكن تكون خطيرة. اتصل بالإسعاف أو روح لأقرب طوارئ هلق.'**
  String get noticeEmergency;

  /// No description provided for @callEmergency.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بالإسعاف'**
  String get callEmergency;

  /// No description provided for @case1Title.
  ///
  /// In ar, this message translates to:
  /// **'ألم صدر مع ضيق نفس'**
  String get case1Title;

  /// No description provided for @case1Sub.
  ///
  /// In ar, this message translates to:
  /// **'مستعجلة · من {minutes} دقيقة'**
  String case1Sub(String minutes);

  /// No description provided for @case2Title.
  ///
  /// In ar, this message translates to:
  /// **'صداع وحرارة خفيفة'**
  String get case2Title;

  /// No description provided for @case2Sub.
  ///
  /// In ar, this message translates to:
  /// **'من {minutes} دقايق'**
  String case2Sub(String minutes);

  /// No description provided for @case3Title.
  ///
  /// In ar, this message translates to:
  /// **'سعال ناشف عند طفل'**
  String get case3Title;

  /// No description provided for @case3Sub.
  ///
  /// In ar, this message translates to:
  /// **'من {minutes} دقيقة'**
  String case3Sub(String minutes);

  /// No description provided for @initials1.
  ///
  /// In ar, this message translates to:
  /// **'س.ح'**
  String get initials1;

  /// No description provided for @initials2.
  ///
  /// In ar, this message translates to:
  /// **'م.ع'**
  String get initials2;

  /// No description provided for @initials3.
  ///
  /// In ar, this message translates to:
  /// **'ر.خ'**
  String get initials3;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navConsult.
  ///
  /// In ar, this message translates to:
  /// **'استشارة'**
  String get navConsult;

  /// No description provided for @navDoses.
  ///
  /// In ar, this message translates to:
  /// **'جرعاتي'**
  String get navDoses;

  /// No description provided for @navOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get navOrders;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// No description provided for @sideMain.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get sideMain;

  /// No description provided for @sideOps.
  ///
  /// In ar, this message translates to:
  /// **'العمليات'**
  String get sideOps;

  /// No description provided for @sideAdmin.
  ///
  /// In ar, this message translates to:
  /// **'الإدارة'**
  String get sideAdmin;

  /// No description provided for @sideDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get sideDashboard;

  /// No description provided for @sideInventory.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية والمخزون'**
  String get sideInventory;

  /// No description provided for @sideCategories.
  ///
  /// In ar, this message translates to:
  /// **'الأصناف'**
  String get sideCategories;

  /// No description provided for @sideSale.
  ///
  /// In ar, this message translates to:
  /// **'البيع'**
  String get sideSale;

  /// No description provided for @sideDebts.
  ///
  /// In ar, this message translates to:
  /// **'الزبائن والديون'**
  String get sideDebts;

  /// No description provided for @sideCases.
  ///
  /// In ar, this message translates to:
  /// **'حالات المساعد'**
  String get sideCases;

  /// No description provided for @sideReports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get sideReports;

  /// No description provided for @sideSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get sideSettings;

  /// No description provided for @greeting.
  ///
  /// In ar, this message translates to:
  /// **'أهلين د. {name}'**
  String greeting(String name);

  /// No description provided for @newSale.
  ///
  /// In ar, this message translates to:
  /// **'بيع جديد'**
  String get newSale;

  /// No description provided for @pharmacistName.
  ///
  /// In ar, this message translates to:
  /// **'د. {name}'**
  String pharmacistName(String name);

  /// No description provided for @pharmacyName.
  ///
  /// In ar, this message translates to:
  /// **'صيدلية {name}'**
  String pharmacyName(String name);

  /// No description provided for @sampleDoctor.
  ///
  /// In ar, this message translates to:
  /// **'سامر'**
  String get sampleDoctor;

  /// No description provided for @samplePharmacy.
  ///
  /// In ar, this message translates to:
  /// **'الشفاء'**
  String get samplePharmacy;

  /// No description provided for @pharmacyResults.
  ///
  /// In ar, this message translates to:
  /// **'نتائج الصيدلية'**
  String get pharmacyResults;

  /// No description provided for @latestCases.
  ///
  /// In ar, this message translates to:
  /// **'آخر الحالات'**
  String get latestCases;
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
