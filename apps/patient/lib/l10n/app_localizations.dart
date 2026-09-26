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

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'استشارة صحية بلهجتك، وصيدليتك بتراجع كل حالة وبتحضّرلك الدوا.'**
  String get tagline;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'حساب جديد'**
  String get createAccount;

  /// No description provided for @haveAccount.
  ///
  /// In ar, this message translates to:
  /// **'عندي حساب'**
  String get haveAccount;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get signIn;

  /// No description provided for @signUpTitle.
  ///
  /// In ar, this message translates to:
  /// **'حساب جديد'**
  String get signUpTitle;

  /// No description provided for @signInTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلين فيك من جديد'**
  String get signInTitle;

  /// No description provided for @nameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get nameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل'**
  String get phoneLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة السر'**
  String get passwordLabel;

  /// No description provided for @birthYearLabel.
  ///
  /// In ar, this message translates to:
  /// **'سنة الميلاد'**
  String get birthYearLabel;

  /// No description provided for @sexLabel.
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get sexLabel;

  /// No description provided for @male.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get male;

  /// No description provided for @female.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get female;

  /// No description provided for @cityLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get cityLabel;

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

  /// No description provided for @invalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل مو مزبوط'**
  String get invalidPhone;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة السر 6 أحرف أو أكتر'**
  String get passwordTooShort;

  /// No description provided for @invalidYear.
  ///
  /// In ar, this message translates to:
  /// **'سنة مو مزبوطة'**
  String get invalidYear;

  /// No description provided for @signUpHelp.
  ///
  /// In ar, this message translates to:
  /// **'العمر والجنس بيساعدوا الصيدلي يختارلك الأنسب، وما بيشوفهن غير صيدليتك.'**
  String get signUpHelp;

  /// No description provided for @choosePharmacyTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختار صيدليتك'**
  String get choosePharmacyTitle;

  /// No description provided for @choosePharmacyHelp.
  ///
  /// In ar, this message translates to:
  /// **'حالاتك وطلباتك بتروح لهالصيدلية. فيك تغيّرها بعدين.'**
  String get choosePharmacyHelp;

  /// No description provided for @pharmacyCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'رمز الصيدلية'**
  String get pharmacyCodeLabel;

  /// No description provided for @pharmacyCodeHint.
  ///
  /// In ar, this message translates to:
  /// **'مكتوب عند الكاونتر، متل SH4F'**
  String get pharmacyCodeHint;

  /// No description provided for @findByCode.
  ///
  /// In ar, this message translates to:
  /// **'دوّر'**
  String get findByCode;

  /// No description provided for @orPickFromList.
  ///
  /// In ar, this message translates to:
  /// **'أو اختار من القائمة'**
  String get orPickFromList;

  /// No description provided for @noPharmacies.
  ///
  /// In ar, this message translates to:
  /// **'ما في صيدليات بهالمدينة لسا'**
  String get noPharmacies;

  /// No description provided for @chooseThis.
  ///
  /// In ar, this message translates to:
  /// **'اختار'**
  String get chooseThis;

  /// No description provided for @pharmacyHours.
  ///
  /// In ar, this message translates to:
  /// **'الدوام: {hours}'**
  String pharmacyHours(String hours);

  /// No description provided for @yourPharmacy.
  ///
  /// In ar, this message translates to:
  /// **'صيدليتك'**
  String get yourPharmacy;

  /// No description provided for @change.
  ///
  /// In ar, this message translates to:
  /// **'غيّر'**
  String get change;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navConsultations.
  ///
  /// In ar, this message translates to:
  /// **'استشاراتي'**
  String get navConsultations;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// No description provided for @heroTitle.
  ///
  /// In ar, this message translates to:
  /// **'حاسس بشي؟\nاحكيلي'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مساعد صحي، وصيدليتك بتراجع كل حالة.'**
  String get heroSubtitle;

  /// No description provided for @startConsultation.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ استشارة'**
  String get startConsultation;

  /// No description provided for @recentConsultations.
  ///
  /// In ar, this message translates to:
  /// **'آخر استشاراتك'**
  String get recentConsultations;

  /// No description provided for @seeAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get seeAll;

  /// No description provided for @noConsultations.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك استشارات لسا'**
  String get noConsultations;

  /// No description provided for @safetyLine.
  ///
  /// In ar, this message translates to:
  /// **'إذا صار عندك ضيق نفس أو ألم بالصدر، روح عالطوارئ فوراً.'**
  String get safetyLine;

  /// No description provided for @assistantTitle.
  ///
  /// In ar, this message translates to:
  /// **'مساعد دوايا'**
  String get assistantTitle;

  /// No description provided for @pharmacyFollowing.
  ///
  /// In ar, this message translates to:
  /// **'صيدلية {name} متابعة'**
  String pharmacyFollowing(String name);

  /// No description provided for @messageHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالتك'**
  String get messageHint;

  /// No description provided for @send.
  ///
  /// In ar, this message translates to:
  /// **'ابعت'**
  String get send;

  /// No description provided for @sendToPharmacyNow.
  ///
  /// In ar, this message translates to:
  /// **'ابعت المحادثة للصيدلي مباشرة'**
  String get sendToPharmacyNow;

  /// No description provided for @summaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص حالتك'**
  String get summaryTitle;

  /// No description provided for @summaryHelp.
  ///
  /// In ar, this message translates to:
  /// **'راجعه، وصحّح أي شي قبل ما تبعته.'**
  String get summaryHelp;

  /// No description provided for @sendToPharmacy.
  ///
  /// In ar, this message translates to:
  /// **'ابعته للصيدلية'**
  String get sendToPharmacy;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'عدّل'**
  String get edit;

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
  /// **'أدوية عم تاخدها'**
  String get sumMedications;

  /// No description provided for @sumConditions.
  ///
  /// In ar, this message translates to:
  /// **'أمراض مزمنة'**
  String get sumConditions;

  /// No description provided for @sumDenied.
  ///
  /// In ar, this message translates to:
  /// **'نفيت'**
  String get sumDenied;

  /// No description provided for @sumNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get sumNotes;

  /// No description provided for @listHint.
  ///
  /// In ar, this message translates to:
  /// **'افصل بفاصلة'**
  String get listHint;

  /// No description provided for @status.
  ///
  /// In ar, this message translates to:
  /// **'{status, select, chatting{مع المساعد} summary{ناطر مراجعتك} sent{وصلت للصيدلية} preparing{الصيدلي عم يحضّر} ready{جاهز للاستلام} picked_up{استلمت} needs_doctor{بحاجة طبيب} emergency{حالة طارئة} closed{مسكّرة} other{{status}}}'**
  String status(String status);

  /// No description provided for @stepSent.
  ///
  /// In ar, this message translates to:
  /// **'وصلت'**
  String get stepSent;

  /// No description provided for @stepPreparing.
  ///
  /// In ar, this message translates to:
  /// **'عم يتحضّر'**
  String get stepPreparing;

  /// No description provided for @stepReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهز'**
  String get stepReady;

  /// No description provided for @stepPickedUp.
  ///
  /// In ar, this message translates to:
  /// **'استلمت'**
  String get stepPickedUp;

  /// No description provided for @decisionTitle.
  ///
  /// In ar, this message translates to:
  /// **'حضّرلك الصيدلي'**
  String get decisionTitle;

  /// No description provided for @decisionBy.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلي {name}'**
  String decisionBy(String name);

  /// No description provided for @pickupAt.
  ///
  /// In ar, this message translates to:
  /// **'استلام من {name}، الدفع عند الاستلام'**
  String pickupAt(String name);

  /// No description provided for @roleAssistant.
  ///
  /// In ar, this message translates to:
  /// **'المساعد'**
  String get roleAssistant;

  /// No description provided for @rolePharmacist.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلي'**
  String get rolePharmacist;

  /// No description provided for @emergencyTitle.
  ///
  /// In ar, this message translates to:
  /// **'اطلب مساعدة هلق'**
  String get emergencyTitle;

  /// No description provided for @callAmbulance.
  ///
  /// In ar, this message translates to:
  /// **'الإسعاف {number}'**
  String callAmbulance(String number);

  /// No description provided for @callEmergency.
  ///
  /// In ar, this message translates to:
  /// **'الطوارئ {number}'**
  String callEmergency(String number);

  /// No description provided for @emergencyStillWrite.
  ///
  /// In ar, this message translates to:
  /// **'فيك تكتب للصيدلية هون كمان.'**
  String get emergencyStillWrite;

  /// No description provided for @consultationClosed.
  ///
  /// In ar, this message translates to:
  /// **'هالاستشارة خلصت. ابدأ وحدة جديدة إذا احتجت.'**
  String get consultationClosed;

  /// No description provided for @accountTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get accountTitle;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل خروج'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'بدك تطلع من حسابك على هالجهاز؟'**
  String get logoutConfirm;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @errNetwork.
  ///
  /// In ar, this message translates to:
  /// **'ما في اتصال بالإنترنت. جرّب كمان شوي.'**
  String get errNetwork;

  /// No description provided for @errPhoneTaken.
  ///
  /// In ar, this message translates to:
  /// **'في حساب بهالرقم. جرّب «عندي حساب».'**
  String get errPhoneTaken;

  /// No description provided for @errBadCredentials.
  ///
  /// In ar, this message translates to:
  /// **'الرقم أو كلمة السر غلط'**
  String get errBadCredentials;

  /// No description provided for @errTooMany.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كتير، استنى شوي وجرّب'**
  String get errTooMany;

  /// No description provided for @errPharmacyNotFound.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا صيدلية بهالرمز'**
  String get errPharmacyNotFound;

  /// No description provided for @errGeneric.
  ///
  /// In ar, this message translates to:
  /// **'صار خطأ ({code})، جرّب كمان مرة'**
  String errGeneric(String code);

  /// No description provided for @thinking.
  ///
  /// In ar, this message translates to:
  /// **'عم يكتب…'**
  String get thinking;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كمان مرة'**
  String get retry;
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
