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
  /// **'{name} متابعة'**
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

  /// No description provided for @navOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get navOrders;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'دوّر على دوا أو منتج…'**
  String get searchHint;

  /// No description provided for @availableAtPharmacy.
  ///
  /// In ar, this message translates to:
  /// **'متوفر بصيدليتك'**
  String get availableAtPharmacy;

  /// No description provided for @shelfTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفوف صيدليتك'**
  String get shelfTitle;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In ar, this message translates to:
  /// **'مو متوفر هلق'**
  String get unavailable;

  /// No description provided for @prescriptionOnly.
  ///
  /// In ar, this message translates to:
  /// **'بوصفة'**
  String get prescriptionOnly;

  /// No description provided for @noPrescription.
  ///
  /// In ar, this message translates to:
  /// **'بدون وصفة'**
  String get noPrescription;

  /// No description provided for @rxHint.
  ///
  /// In ar, this message translates to:
  /// **'هالدوا بدو وصفة طبية: جيبها معك وقت الاستلام، والصيدلي بيقرر.'**
  String get rxHint;

  /// No description provided for @askPharmacistHint.
  ///
  /// In ar, this message translates to:
  /// **'اسأل صيدليتك عن الطريقة المناسبة إلك، خصوصاً إذا عم تاخد أدوية تانية.'**
  String get askPharmacistHint;

  /// No description provided for @ingredient.
  ///
  /// In ar, this message translates to:
  /// **'المادة الفعالة'**
  String get ingredient;

  /// No description provided for @strength.
  ///
  /// In ar, this message translates to:
  /// **'العيار'**
  String get strength;

  /// No description provided for @dosageForm.
  ///
  /// In ar, this message translates to:
  /// **'الشكل'**
  String get dosageForm;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا شي بهالاسم'**
  String get noResults;

  /// No description provided for @orderFromPharmacy.
  ///
  /// In ar, this message translates to:
  /// **'اطلب من صيدليتي'**
  String get orderFromPharmacy;

  /// No description provided for @addedToCart.
  ///
  /// In ar, this message translates to:
  /// **'انضاف لطلبيتك'**
  String get addedToCart;

  /// No description provided for @inCart.
  ///
  /// In ar, this message translates to:
  /// **'بطلبيتك: {count}'**
  String inCart(String count);

  /// No description provided for @viewCart.
  ///
  /// In ar, this message translates to:
  /// **'شوف الطلبية'**
  String get viewCart;

  /// No description provided for @less.
  ///
  /// In ar, this message translates to:
  /// **'أقل'**
  String get less;

  /// No description provided for @more.
  ///
  /// In ar, this message translates to:
  /// **'أكتر'**
  String get more;

  /// No description provided for @cartTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبيتي'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In ar, this message translates to:
  /// **'طلبيتك فاضية. اختار من رفوف صيدليتك.'**
  String get cartEmpty;

  /// No description provided for @browseShelf.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح الرفوف'**
  String get browseShelf;

  /// No description provided for @noteToPharmacist.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة للصيدلي'**
  String get noteToPharmacist;

  /// No description provided for @orderTotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع: {amount}'**
  String orderTotal(String amount);

  /// No description provided for @pickupFrom.
  ///
  /// In ar, this message translates to:
  /// **'استلام من {name}'**
  String pickupFrom(String name);

  /// No description provided for @sendOrder.
  ///
  /// In ar, this message translates to:
  /// **'أرسل الطلب للصيدلية'**
  String get sendOrder;

  /// No description provided for @payAtPickup.
  ///
  /// In ar, this message translates to:
  /// **'الدفع عند الاستلام بالصيدلية'**
  String get payAtPickup;

  /// No description provided for @finalQuantitiesHint.
  ///
  /// In ar, this message translates to:
  /// **'الكميات النهائية بيحددها الصيدلي حسب الموجود.'**
  String get finalQuantitiesHint;

  /// No description provided for @orderSent.
  ///
  /// In ar, this message translates to:
  /// **'وصل طلبك للصيدلية'**
  String get orderSent;

  /// No description provided for @ordersTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get ordersTitle;

  /// No description provided for @noOrders.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك طلبات لسا'**
  String get noOrders;

  /// No description provided for @orderStatus.
  ///
  /// In ar, this message translates to:
  /// **'{status, select, sent{وصل للصيدلية} preparing{عم يتحضّر} ready{جاهز للاستلام} picked_up{استلمته} rejected{ما في هلق} cancelled{ملغى} other{{status}}}'**
  String orderStatus(String status);

  /// No description provided for @orderLines.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{منتج واحد} =2{منتجين} few{{count} منتجات} other{{count} منتج}}'**
  String orderLines(int count);

  /// No description provided for @lineChanged.
  ///
  /// In ar, this message translates to:
  /// **'طلبت {requested}، الصيدلي حضّر {quantity}'**
  String lineChanged(String requested, String quantity);

  /// No description provided for @lineDropped.
  ///
  /// In ar, this message translates to:
  /// **'طلبت {requested}، ما في هلق'**
  String lineDropped(String requested);

  /// No description provided for @cancelOrder.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In ar, this message translates to:
  /// **'بدك تلغي هالطلب؟'**
  String get cancelOrderConfirm;

  /// No description provided for @keepOrder.
  ///
  /// In ar, this message translates to:
  /// **'لا، خليه'**
  String get keepOrder;

  /// No description provided for @orderTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب {date}'**
  String orderTitle(String date);

  /// No description provided for @errUnknownProduct.
  ///
  /// In ar, this message translates to:
  /// **'في منتج ما عاد موجود على الرف. حدّث الطلبية.'**
  String get errUnknownProduct;

  /// No description provided for @errAlreadyHandled.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلي بلّش بالطلب، ما عاد فيك تلغيه.'**
  String get errAlreadyHandled;

  /// No description provided for @lineQtyPrice.
  ///
  /// In ar, this message translates to:
  /// **'{quantity} × {price}'**
  String lineQtyPrice(String quantity, String price);

  /// No description provided for @noticeConsultationReady.
  ///
  /// In ar, this message translates to:
  /// **'حضّرلك الصيدلي دواك'**
  String get noticeConsultationReady;

  /// No description provided for @noticeConsultationReadyBody.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للاستلام من صيدليتك، والتعليمات بالمحادثة.'**
  String get noticeConsultationReadyBody;

  /// No description provided for @noticeNeedsDoctor.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلي شايف لازم تشوف طبيب'**
  String get noticeNeedsDoctor;

  /// No description provided for @noticeNeedsDoctorBody.
  ///
  /// In ar, this message translates to:
  /// **'افتح المحادثة لتقرا شو كتبلك.'**
  String get noticeNeedsDoctorBody;

  /// No description provided for @noticePreparing.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلي عم يحضّر حالتك'**
  String get noticePreparing;

  /// No description provided for @noticeOrderReady.
  ///
  /// In ar, this message translates to:
  /// **'طلبك جاهز للاستلام'**
  String get noticeOrderReady;

  /// No description provided for @noticeOrderRejected.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرت الصيدلية تحضّر طلبك'**
  String get noticeOrderRejected;

  /// No description provided for @noticeOrderBody.
  ///
  /// In ar, this message translates to:
  /// **'افتح «طلباتي» للتفاصيل.'**
  String get noticeOrderBody;

  /// No description provided for @doseTitle.
  ///
  /// In ar, this message translates to:
  /// **'وقت دوا {name}'**
  String doseTitle(String name);

  /// No description provided for @navDoses.
  ///
  /// In ar, this message translates to:
  /// **'جرعاتي'**
  String get navDoses;

  /// No description provided for @dosesTitle.
  ///
  /// In ar, this message translates to:
  /// **'جرعاتي'**
  String get dosesTitle;

  /// No description provided for @noDoses.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك تذكيرات. لما الصيدلي يحضّرلك دوا بعدد مرات باليوم، فيك تشغّل التذكير من المحادثة.'**
  String get noDoses;

  /// No description provided for @remindMe.
  ///
  /// In ar, this message translates to:
  /// **'ذكّرني بالجرعات'**
  String get remindMe;

  /// No description provided for @reminderOn.
  ///
  /// In ar, this message translates to:
  /// **'التذكير شغّال'**
  String get reminderOn;

  /// No description provided for @reminderSaved.
  ///
  /// In ar, this message translates to:
  /// **'انحفظ التذكير'**
  String get reminderSaved;

  /// No description provided for @reminderTimes.
  ///
  /// In ar, this message translates to:
  /// **'المواعيد'**
  String get reminderTimes;

  /// No description provided for @reminderDays.
  ///
  /// In ar, this message translates to:
  /// **'{days, plural, =1{كورس يوم واحد} =2{كورس يومين} few{كورس {days} أيام} other{كورس {days} يوم}}'**
  String reminderDays(int days);

  /// No description provided for @reminderOngoing.
  ///
  /// In ar, this message translates to:
  /// **'لحتى توقّفه'**
  String get reminderOngoing;

  /// No description provided for @reminderFinished.
  ///
  /// In ar, this message translates to:
  /// **'خلص الكورس'**
  String get reminderFinished;

  /// No description provided for @reminderWebNote.
  ///
  /// In ar, this message translates to:
  /// **'التذكير بيوصلك كإشعار على تطبيق الموبايل. هون بتشوف المواعيد بس.'**
  String get reminderWebNote;

  /// No description provided for @reminderTimesHelp.
  ///
  /// In ar, this message translates to:
  /// **'فيك تزيح المواعيد لتناسبك. عدد المرات من الصيدلي.'**
  String get reminderTimesHelp;

  /// No description provided for @deleteReminder.
  ///
  /// In ar, this message translates to:
  /// **'احذف التذكير'**
  String get deleteReminder;

  /// No description provided for @nextDose.
  ///
  /// In ar, this message translates to:
  /// **'الجاية: {time}'**
  String nextDose(String time);

  /// No description provided for @notificationsOff.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات مسكّرة. شغّلها من إعدادات الموبايل منشان يوصلك التذكير.'**
  String get notificationsOff;

  /// No description provided for @earlier.
  ///
  /// In ar, this message translates to:
  /// **'أبكر نص ساعة'**
  String get earlier;

  /// No description provided for @later.
  ///
  /// In ar, this message translates to:
  /// **'أبعد نص ساعة'**
  String get later;

  /// No description provided for @remindersAdded.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{انضاف تذكير واحد} =2{انضاف تذكيرين} few{انضاف {count} تذكيرات} other{انضاف {count} تذكير}}'**
  String remindersAdded(int count);

  /// No description provided for @remindersActive.
  ///
  /// In ar, this message translates to:
  /// **'التذكير شغّال لهالأدوية'**
  String get remindersActive;

  /// No description provided for @attachPhoto.
  ///
  /// In ar, this message translates to:
  /// **'بعت صورة'**
  String get attachPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In ar, this message translates to:
  /// **'صوّر بالكاميرا'**
  String get takePhoto;

  /// No description provided for @fromGallery.
  ///
  /// In ar, this message translates to:
  /// **'اختار من الصور'**
  String get fromGallery;

  /// No description provided for @attachPrescription.
  ///
  /// In ar, this message translates to:
  /// **'أرفق صورة الوصفة'**
  String get attachPrescription;

  /// No description provided for @removePhoto.
  ///
  /// In ar, this message translates to:
  /// **'شيل الصورة'**
  String get removePhoto;

  /// No description provided for @prescriptionPhotoHint.
  ///
  /// In ar, this message translates to:
  /// **'صورة الوصفة بتوصل للصيدلي مع الطلب.'**
  String get prescriptionPhotoHint;

  /// No description provided for @photoSent.
  ///
  /// In ar, this message translates to:
  /// **'وصلت الصورة'**
  String get photoSent;

  /// No description provided for @errPhotoTooBig.
  ///
  /// In ar, this message translates to:
  /// **'الصورة كبيرة كتير، جرّب وحدة أصغر'**
  String get errPhotoTooBig;

  /// No description provided for @errNotAnImage.
  ///
  /// In ar, this message translates to:
  /// **'هاد مو ملف صورة'**
  String get errNotAnImage;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'سكّر'**
  String get close;
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
