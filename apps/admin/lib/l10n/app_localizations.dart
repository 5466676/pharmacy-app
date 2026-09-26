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

  /// No description provided for @panelName.
  ///
  /// In ar, this message translates to:
  /// **'لوحة المالك'**
  String get panelName;

  /// No description provided for @navOverview.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة'**
  String get navOverview;

  /// No description provided for @navPharmacies.
  ///
  /// In ar, this message translates to:
  /// **'الصيدليات'**
  String get navPharmacies;

  /// No description provided for @navPerformance.
  ///
  /// In ar, this message translates to:
  /// **'الأداء والمكافآت'**
  String get navPerformance;

  /// No description provided for @navReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة المحادثات'**
  String get navReview;

  /// No description provided for @navKnowledge.
  ///
  /// In ar, this message translates to:
  /// **'قاعدة المعرفة'**
  String get navKnowledge;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @navPayments.
  ///
  /// In ar, this message translates to:
  /// **'المدفوعات: مطفية'**
  String get navPayments;

  /// No description provided for @signOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل خروج'**
  String get signOut;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'لحظة...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'جرّب مرة تانية'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'سكّر'**
  String get close;

  /// No description provided for @copy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In ar, this message translates to:
  /// **'انتسخ'**
  String get copied;

  /// No description provided for @never.
  ///
  /// In ar, this message translates to:
  /// **'أبداً'**
  String get never;

  /// No description provided for @none.
  ///
  /// In ar, this message translates to:
  /// **'ما في'**
  String get none;

  /// No description provided for @minutesShort.
  ///
  /// In ar, this message translates to:
  /// **'{n} د'**
  String minutesShort(String n);

  /// No description provided for @percent.
  ///
  /// In ar, this message translates to:
  /// **'{n}%'**
  String percent(String n);

  /// No description provided for @agoMinutes.
  ///
  /// In ar, this message translates to:
  /// **'من {n} دقيقة'**
  String agoMinutes(String n);

  /// No description provided for @agoHours.
  ///
  /// In ar, this message translates to:
  /// **'من {n} ساعة'**
  String agoHours(String n);

  /// No description provided for @agoDays.
  ///
  /// In ar, this message translates to:
  /// **'من {n} يوم'**
  String agoDays(String n);

  /// No description provided for @justNow.
  ///
  /// In ar, this message translates to:
  /// **'هلق'**
  String get justNow;

  /// No description provided for @errNetwork.
  ///
  /// In ar, this message translates to:
  /// **'ما في اتصال مع سيرفر دوايا. تأكد من الإنترنت وجرّب مرة تانية.'**
  String get errNetwork;

  /// No description provided for @errBadCredentials.
  ///
  /// In ar, this message translates to:
  /// **'الرقم أو كلمة السر غلط.'**
  String get errBadCredentials;

  /// No description provided for @errTooMany.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كتير غلط. استنى ربع ساعة وجرّب.'**
  String get errTooMany;

  /// No description provided for @errReasonRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب السبب (3 أحرف عالأقل).'**
  String get errReasonRequired;

  /// No description provided for @errBadStatus.
  ///
  /// In ar, this message translates to:
  /// **'هالخطوة ما بتنفع بحالة الصيدلية الحالية.'**
  String get errBadStatus;

  /// No description provided for @errCodeTaken.
  ///
  /// In ar, this message translates to:
  /// **'هالرمز مستعمل لصيدلية تانية.'**
  String get errCodeTaken;

  /// No description provided for @errBadCode.
  ///
  /// In ar, this message translates to:
  /// **'الرمز من 3 لـ 12 حرف إنكليزي أو رقم.'**
  String get errBadCode;

  /// No description provided for @errNoteHasDose.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظة فيها جرعة. المساعد ما بيعطي جرعات أبداً، شيلها واكتب شو لازم يسأل.'**
  String get errNoteHasDose;

  /// No description provided for @errGeneric.
  ///
  /// In ar, this message translates to:
  /// **'صار خطأ: {code}'**
  String errGeneric(String code);

  /// No description provided for @signInTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة مالك دوايا'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'للمالك بس. الحساب بيتعمل من سطر الأوامر على السيرفر.'**
  String get signInSubtitle;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة السر'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get signIn;

  /// No description provided for @required.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get required;

  /// No description provided for @overviewSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'آخر {days} يوم'**
  String overviewSubtitle(String days);

  /// No description provided for @rangeToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get rangeToday;

  /// No description provided for @rangeWeek.
  ///
  /// In ar, this message translates to:
  /// **'7 أيام'**
  String get rangeWeek;

  /// No description provided for @rangeMonth.
  ///
  /// In ar, this message translates to:
  /// **'30 يوم'**
  String get rangeMonth;

  /// No description provided for @rangeQuarter.
  ///
  /// In ar, this message translates to:
  /// **'90 يوم'**
  String get rangeQuarter;

  /// No description provided for @kpiPharmacies.
  ///
  /// In ar, this message translates to:
  /// **'صيدليات فعّالة'**
  String get kpiPharmacies;

  /// No description provided for @kpiPharmaciesCaption.
  ///
  /// In ar, this message translates to:
  /// **'متصلة هلق: {connected}، جديدة: {fresh}'**
  String kpiPharmaciesCaption(String connected, String fresh);

  /// No description provided for @kpiPatients.
  ///
  /// In ar, this message translates to:
  /// **'مرضى مسجلين'**
  String get kpiPatients;

  /// No description provided for @kpiPatientsCaption.
  ///
  /// In ar, this message translates to:
  /// **'فعّالين: {active}، جدد: {fresh}'**
  String kpiPatientsCaption(String active, String fresh);

  /// No description provided for @kpiToday.
  ///
  /// In ar, this message translates to:
  /// **'استشارات اليوم'**
  String get kpiToday;

  /// No description provided for @kpiTodayCaption.
  ///
  /// In ar, this message translates to:
  /// **'طلبات: {orders}'**
  String kpiTodayCaption(String orders);

  /// No description provided for @kpiResponse.
  ///
  /// In ar, this message translates to:
  /// **'متوسط أول رد'**
  String get kpiResponse;

  /// No description provided for @kpiResponseCaption.
  ///
  /// In ar, this message translates to:
  /// **'الهدف: {target} د أو أقل، ما انجاوب: {open}'**
  String kpiResponseCaption(String target, String open);

  /// No description provided for @kpiUrgent.
  ///
  /// In ar, this message translates to:
  /// **'حالات خطرة اليوم'**
  String get kpiUrgent;

  /// No description provided for @kpiUrgentCaption.
  ///
  /// In ar, this message translates to:
  /// **'ناطرة رد: {open}'**
  String kpiUrgentCaption(String open);

  /// No description provided for @chartTitle.
  ///
  /// In ar, this message translates to:
  /// **'سرعة أول رد'**
  String get chartTitle;

  /// No description provided for @chartLegend.
  ///
  /// In ar, this message translates to:
  /// **'بالدقايق: الخط هو المتوسط، والشريط لحد أبطأ 10%، والمنقّط هو الهدف'**
  String get chartLegend;

  /// No description provided for @chartEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما في حالات انجاوبت بهالفترة.'**
  String get chartEmpty;

  /// No description provided for @attentionTitle.
  ///
  /// In ar, this message translates to:
  /// **'بدها انتباه'**
  String get attentionTitle;

  /// No description provided for @attentionNone.
  ///
  /// In ar, this message translates to:
  /// **'كل الصيدليات ماشية تمام.'**
  String get attentionNone;

  /// No description provided for @attentionOffline.
  ///
  /// In ar, this message translates to:
  /// **'ما اتصلت {ago}'**
  String attentionOffline(String ago);

  /// No description provided for @attentionNeverConnected.
  ///
  /// In ar, this message translates to:
  /// **'ما اتصلت ولا مرة'**
  String get attentionNeverConnected;

  /// No description provided for @attentionHealth.
  ///
  /// In ar, this message translates to:
  /// **'الفحص الشهري فيه مشكلة'**
  String get attentionHealth;

  /// No description provided for @attentionSlow.
  ///
  /// In ar, this message translates to:
  /// **'رد بطيء: {m}'**
  String attentionSlow(String m);

  /// No description provided for @reviewWaiting.
  ///
  /// In ar, this message translates to:
  /// **'{n} محادثة ناطرة مراجعة'**
  String reviewWaiting(String n);

  /// No description provided for @openReview.
  ///
  /// In ar, this message translates to:
  /// **'افتح المراجعة'**
  String get openReview;

  /// No description provided for @paymentsOff.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات والمدفوعات مطفية بهالمرحلة (الدفع عند الاستلام).'**
  String get paymentsOff;

  /// No description provided for @searchPharmacies.
  ///
  /// In ar, this message translates to:
  /// **'دوّر بالاسم أو المدينة أو الرمز'**
  String get searchPharmacies;

  /// No description provided for @addPharmacy.
  ///
  /// In ar, this message translates to:
  /// **'صيدلية جديدة'**
  String get addPharmacy;

  /// No description provided for @colName.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلية'**
  String get colName;

  /// No description provided for @colCity.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get colCity;

  /// No description provided for @colPatients.
  ///
  /// In ar, this message translates to:
  /// **'المرضى'**
  String get colPatients;

  /// No description provided for @colResponse.
  ///
  /// In ar, this message translates to:
  /// **'المتوسط'**
  String get colResponse;

  /// No description provided for @colConnection.
  ///
  /// In ar, this message translates to:
  /// **'الاتصال'**
  String get colConnection;

  /// No description provided for @colStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get colStatus;

  /// No description provided for @statusActive.
  ///
  /// In ar, this message translates to:
  /// **'مستعملة'**
  String get statusActive;

  /// No description provided for @statusPending.
  ///
  /// In ar, this message translates to:
  /// **'ناطرة موافقة'**
  String get statusPending;

  /// No description provided for @statusSuspended.
  ///
  /// In ar, this message translates to:
  /// **'معلّقة'**
  String get statusSuspended;

  /// No description provided for @statusStopped.
  ///
  /// In ar, this message translates to:
  /// **'النظام موقّف'**
  String get statusStopped;

  /// No description provided for @statusRemoved.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get statusRemoved;

  /// No description provided for @connected.
  ///
  /// In ar, this message translates to:
  /// **'متصلة'**
  String get connected;

  /// No description provided for @hidden.
  ///
  /// In ar, this message translates to:
  /// **'مخفية عن المرضى'**
  String get hidden;

  /// No description provided for @noPharmacies.
  ///
  /// In ar, this message translates to:
  /// **'ما في صيدليات لسا. ضيف أول وحدة من «صيدلية جديدة».'**
  String get noPharmacies;

  /// No description provided for @pickPharmacy.
  ///
  /// In ar, this message translates to:
  /// **'اختار صيدلية من القائمة لتشوف تفاصيلها.'**
  String get pickPharmacy;

  /// No description provided for @factCode.
  ///
  /// In ar, this message translates to:
  /// **'الرمز'**
  String get factCode;

  /// No description provided for @factLastContact.
  ///
  /// In ar, this message translates to:
  /// **'آخر اتصال'**
  String get factLastContact;

  /// No description provided for @factLicence.
  ///
  /// In ar, this message translates to:
  /// **'الترخيص'**
  String get factLicence;

  /// No description provided for @licenceDays.
  ///
  /// In ar, this message translates to:
  /// **'{n} يوم بلا اتصال'**
  String licenceDays(String n);

  /// No description provided for @factDevices.
  ///
  /// In ar, this message translates to:
  /// **'الأجهزة'**
  String get factDevices;

  /// No description provided for @factBackup.
  ///
  /// In ar, this message translates to:
  /// **'آخر نسخة احتياطية'**
  String get factBackup;

  /// No description provided for @factVersion.
  ///
  /// In ar, this message translates to:
  /// **'نسخة السيرفر'**
  String get factVersion;

  /// No description provided for @factDisk.
  ///
  /// In ar, this message translates to:
  /// **'المساحة الفاضية'**
  String get factDisk;

  /// No description provided for @diskMb.
  ///
  /// In ar, this message translates to:
  /// **'{n} ميغا'**
  String diskMb(String n);

  /// No description provided for @factKeys.
  ///
  /// In ar, this message translates to:
  /// **'مفاتيح فعّالة'**
  String get factKeys;

  /// No description provided for @healthTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفحص الشهري'**
  String get healthTitle;

  /// No description provided for @healthAt.
  ///
  /// In ar, this message translates to:
  /// **'آخر فحص: {date}'**
  String healthAt(String date);

  /// No description provided for @healthNever.
  ///
  /// In ar, this message translates to:
  /// **'ما صار فحص لسا. بيصير مع أول اتصال.'**
  String get healthNever;

  /// No description provided for @healthRequested.
  ///
  /// In ar, this message translates to:
  /// **'طلبت فحص، بيصير مع الاتصال الجاي.'**
  String get healthRequested;

  /// No description provided for @healthPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'الفحص بيصير على كمبيوتر الصيدلية، وبيوصلك بس النتيجة. ما بتوصلك أدويتهم ولا مبيعاتهم ولا أرباحهم.'**
  String get healthPrivacy;

  /// No description provided for @checkBackup.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي'**
  String get checkBackup;

  /// No description provided for @checkDevices.
  ///
  /// In ar, this message translates to:
  /// **'كل الأجهزة عم تتزامن'**
  String get checkDevices;

  /// No description provided for @checkStockBelowZero.
  ///
  /// In ar, this message translates to:
  /// **'مخزون تحت الصفر'**
  String get checkStockBelowZero;

  /// No description provided for @checkExpiredOnSale.
  ///
  /// In ar, this message translates to:
  /// **'أدوية منتهية لسا معروضة'**
  String get checkExpiredOnSale;

  /// No description provided for @checkEvents.
  ///
  /// In ar, this message translates to:
  /// **'سجلات ناقصة'**
  String get checkEvents;

  /// No description provided for @checkOpenShifts.
  ///
  /// In ar, this message translates to:
  /// **'ورديات مفتوحة أكتر من يوم'**
  String get checkOpenShifts;

  /// No description provided for @checkDisk.
  ///
  /// In ar, this message translates to:
  /// **'المساحة'**
  String get checkDisk;

  /// No description provided for @levelOk.
  ///
  /// In ar, this message translates to:
  /// **'تمام'**
  String get levelOk;

  /// No description provided for @levelWarn.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه'**
  String get levelWarn;

  /// No description provided for @levelProblem.
  ///
  /// In ar, this message translates to:
  /// **'مشكلة'**
  String get levelProblem;

  /// No description provided for @countOf.
  ///
  /// In ar, this message translates to:
  /// **'({n})'**
  String countOf(String n);

  /// No description provided for @actionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحكم'**
  String get actionsTitle;

  /// No description provided for @actApprove.
  ///
  /// In ar, this message translates to:
  /// **'موافقة'**
  String get actApprove;

  /// No description provided for @actSuspend.
  ///
  /// In ar, this message translates to:
  /// **'تعليق'**
  String get actSuspend;

  /// No description provided for @actResume.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تشغيل'**
  String get actResume;

  /// No description provided for @actStop.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف النظام'**
  String get actStop;

  /// No description provided for @actRemove.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get actRemove;

  /// No description provided for @actList.
  ///
  /// In ar, this message translates to:
  /// **'إظهار للمرضى'**
  String get actList;

  /// No description provided for @actUnlist.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء عن المرضى'**
  String get actUnlist;

  /// No description provided for @actNewKey.
  ///
  /// In ar, this message translates to:
  /// **'مفتاح جديد'**
  String get actNewKey;

  /// No description provided for @actLicence.
  ///
  /// In ar, this message translates to:
  /// **'مدة الترخيص'**
  String get actLicence;

  /// No description provided for @actHealth.
  ///
  /// In ar, this message translates to:
  /// **'فحص هلق'**
  String get actHealth;

  /// No description provided for @actCreate.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get actCreate;

  /// No description provided for @explainSuspend.
  ///
  /// In ar, this message translates to:
  /// **'بيوقف دوايا أونلاين عنها فوراً: ما بتوصلها حالات ولا طلبات، وبتختفي عن المرضى. نظام البيع عندها بيضل شغال.'**
  String get explainSuspend;

  /// No description provided for @explainStop.
  ///
  /// In ar, this message translates to:
  /// **'أول ما يتصل سيرفرها، بيتسكّر البيع وتعديل المخزون عندها عند فتح البرنامج الجاي. الشوفة وتصدير بياناتها بيضلوا مفتوحين.'**
  String get explainStop;

  /// No description provided for @explainRemove.
  ///
  /// In ar, this message translates to:
  /// **'لما تشيل البرنامج من عندهم. مفتاحها بيبطل يشتغل وبتختفي عن المرضى، وما في رجعة.'**
  String get explainRemove;

  /// No description provided for @explainNewKey.
  ///
  /// In ar, this message translates to:
  /// **'المفتاح القديم بيبطل فوراً. لازم تحط الجديد بسيرفر الصيدلية.'**
  String get explainNewKey;

  /// No description provided for @explainResume.
  ///
  /// In ar, this message translates to:
  /// **'بترجع الصيدلية فعّالة، وبيوصلها الخبر مع الاتصال الجاي.'**
  String get explainResume;

  /// No description provided for @reason.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get reason;

  /// No description provided for @reasonHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: انتهى العقد'**
  String get reasonHint;

  /// No description provided for @licencePrompt.
  ///
  /// In ar, this message translates to:
  /// **'قديش يوم بيضل النظام شغال بلا ما يتصل بدوايا؟'**
  String get licencePrompt;

  /// No description provided for @days.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأيام'**
  String get days;

  /// No description provided for @keyTitle.
  ///
  /// In ar, this message translates to:
  /// **'مفتاح سيرفر الصيدلية'**
  String get keyTitle;

  /// No description provided for @keyOnce.
  ///
  /// In ar, this message translates to:
  /// **'انسخه هلق وحطه بسيرفر الصيدلية (شاشة «السيرفر والمزامنة» عند المالك). ما رح يبيّن مرة تانية.'**
  String get keyOnce;

  /// No description provided for @logTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل الخطوات'**
  String get logTitle;

  /// No description provided for @logEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما في خطوات لسا.'**
  String get logEmpty;

  /// No description provided for @logBy.
  ///
  /// In ar, this message translates to:
  /// **'{who}، {when}'**
  String logBy(String who, String when);

  /// No description provided for @fieldName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الصيدلية'**
  String get fieldName;

  /// No description provided for @fieldCity.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get fieldCity;

  /// No description provided for @fieldCode.
  ///
  /// In ar, this message translates to:
  /// **'الرمز (بيشوفه المريض عالكاونتر)'**
  String get fieldCode;

  /// No description provided for @fieldAddress.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get fieldAddress;

  /// No description provided for @fieldPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الصيدلية'**
  String get fieldPhone;

  /// No description provided for @fieldHours.
  ///
  /// In ar, this message translates to:
  /// **'الدوام'**
  String get fieldHours;

  /// No description provided for @perfTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأداء والمكافآت'**
  String get perfTitle;

  /// No description provided for @perfSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الترتيب حسب نسبة الرد خلال {target} دقايق، وبعدين نسبة الجواب والسرعة. الصيدلية يلي عندها أقل من {min} حالة ما بتدخل الترتيب.'**
  String perfSubtitle(String target, String min);

  /// No description provided for @perfMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر'**
  String get perfMonth;

  /// No description provided for @colRank.
  ///
  /// In ar, this message translates to:
  /// **'#'**
  String get colRank;

  /// No description provided for @colCases.
  ///
  /// In ar, this message translates to:
  /// **'حالات'**
  String get colCases;

  /// No description provided for @colAnswered.
  ///
  /// In ar, this message translates to:
  /// **'انجاوب'**
  String get colAnswered;

  /// No description provided for @colWithin.
  ///
  /// In ar, this message translates to:
  /// **'خلال الهدف'**
  String get colWithin;

  /// No description provided for @colP90.
  ///
  /// In ar, this message translates to:
  /// **'أبطأ 10%'**
  String get colP90;

  /// No description provided for @colUrgent.
  ///
  /// In ar, this message translates to:
  /// **'خطرة بوقتها'**
  String get colUrgent;

  /// No description provided for @colOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات جاهزة'**
  String get colOrders;

  /// No description provided for @colTier.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get colTier;

  /// No description provided for @tierGold.
  ///
  /// In ar, this message translates to:
  /// **'ذهبي'**
  String get tierGold;

  /// No description provided for @tierSilver.
  ///
  /// In ar, this message translates to:
  /// **'فضي'**
  String get tierSilver;

  /// No description provided for @tierFew.
  ///
  /// In ar, this message translates to:
  /// **'حالات قليلة'**
  String get tierFew;

  /// No description provided for @perfEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما في حالات بهالشهر.'**
  String get perfEmpty;

  /// No description provided for @rewardsNote.
  ///
  /// In ar, this message translates to:
  /// **'المكافآت نفسها بتقررها إنت برّا البرنامج.'**
  String get rewardsNote;

  /// No description provided for @reviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة المحادثات'**
  String get reviewTitle;

  /// No description provided for @reviewSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'بلا اسم المريض ولا رقمه: العمر والجنس والصيدلية بس.'**
  String get reviewSubtitle;

  /// No description provided for @reviewWaitingTab.
  ///
  /// In ar, this message translates to:
  /// **'ناطرة'**
  String get reviewWaitingTab;

  /// No description provided for @reviewDoneTab.
  ///
  /// In ar, this message translates to:
  /// **'خلصت'**
  String get reviewDoneTab;

  /// No description provided for @reviewEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما في شي ناطر مراجعة.'**
  String get reviewEmpty;

  /// No description provided for @kindRedFlag.
  ///
  /// In ar, this message translates to:
  /// **'حالة خطرة'**
  String get kindRedFlag;

  /// No description provided for @kindGuardBlock.
  ///
  /// In ar, this message translates to:
  /// **'رد انمنع'**
  String get kindGuardBlock;

  /// No description provided for @kindCorrection.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح صيدلي'**
  String get kindCorrection;

  /// No description provided for @kindPatientEdit.
  ///
  /// In ar, this message translates to:
  /// **'المريض عدّل الملخص'**
  String get kindPatientEdit;

  /// No description provided for @kindLlmDown.
  ///
  /// In ar, this message translates to:
  /// **'النموذج وقف'**
  String get kindLlmDown;

  /// No description provided for @patientBrief.
  ///
  /// In ar, this message translates to:
  /// **'{sex}، {age} سنة، {pharmacy}'**
  String patientBrief(String sex, String age, String pharmacy);

  /// No description provided for @sexM.
  ///
  /// In ar, this message translates to:
  /// **'رجل'**
  String get sexM;

  /// No description provided for @sexF.
  ///
  /// In ar, this message translates to:
  /// **'امرأة'**
  String get sexF;

  /// No description provided for @unknown.
  ///
  /// In ar, this message translates to:
  /// **'مو معروف'**
  String get unknown;

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

  /// No description provided for @rolePharmacist.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلي'**
  String get rolePharmacist;

  /// No description provided for @roleSystem.
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get roleSystem;

  /// No description provided for @photoMarker.
  ///
  /// In ar, this message translates to:
  /// **'صورة'**
  String get photoMarker;

  /// No description provided for @detailTitle.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get detailTitle;

  /// No description provided for @reviewNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظتك'**
  String get reviewNote;

  /// No description provided for @markReviewed.
  ///
  /// In ar, this message translates to:
  /// **'تمت المراجعة'**
  String get markReviewed;

  /// No description provided for @toKnowledge.
  ///
  /// In ar, this message translates to:
  /// **'حوّلها لملاحظة بقاعدة المعرفة'**
  String get toKnowledge;

  /// No description provided for @pickItem.
  ///
  /// In ar, this message translates to:
  /// **'اختار محادثة من القائمة.'**
  String get pickItem;

  /// No description provided for @knowledgeTitle.
  ///
  /// In ar, this message translates to:
  /// **'قاعدة المعرفة'**
  String get knowledgeTitle;

  /// No description provided for @knowledgeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات قصيرة بتساعد المساعد يسأل أحسن. بتوصله الملاحظة لما يذكر المريض وحدة من كلماتها. ما في تدريب تلقائي أبداً.'**
  String get knowledgeSubtitle;

  /// No description provided for @addNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة جديدة'**
  String get addNote;

  /// No description provided for @noteTitle.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get noteTitle;

  /// No description provided for @noteText.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظة'**
  String get noteText;

  /// No description provided for @noteTags.
  ///
  /// In ar, this message translates to:
  /// **'الكلمات (افصل بينها بفاصلة)'**
  String get noteTags;

  /// No description provided for @noteTagsHint.
  ///
  /// In ar, this message translates to:
  /// **'طفل، رضيع، حرار'**
  String get noteTagsHint;

  /// No description provided for @noteEnabled.
  ///
  /// In ar, this message translates to:
  /// **'شغّالة'**
  String get noteEnabled;

  /// No description provided for @noteDisabled.
  ///
  /// In ar, this message translates to:
  /// **'مطفية'**
  String get noteDisabled;

  /// No description provided for @notesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما في ملاحظات لسا.'**
  String get notesEmpty;

  /// No description provided for @tryTitle.
  ///
  /// In ar, this message translates to:
  /// **'جرّب'**
  String get tryTitle;

  /// No description provided for @tryHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب شي متل ما بيكتبه المريض'**
  String get tryHint;

  /// No description provided for @tryResult.
  ///
  /// In ar, this message translates to:
  /// **'بيوصل للمساعد: {titles}'**
  String tryResult(String titles);

  /// No description provided for @tryNothing.
  ///
  /// In ar, this message translates to:
  /// **'ولا ملاحظة.'**
  String get tryNothing;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @designTitle.
  ///
  /// In ar, this message translates to:
  /// **'شكل اللوحة'**
  String get designTitle;

  /// No description provided for @designConsole.
  ///
  /// In ar, this message translates to:
  /// **'غرفة القيادة'**
  String get designConsole;

  /// No description provided for @designConsoleNote.
  ///
  /// In ar, this message translates to:
  /// **'غامقة ودقيقة، أرقام كتير بمساحة قليلة.'**
  String get designConsoleNote;

  /// No description provided for @designLedger.
  ///
  /// In ar, this message translates to:
  /// **'الدفتر'**
  String get designLedger;

  /// No description provided for @designLedgerNote.
  ///
  /// In ar, this message translates to:
  /// **'فاتحة ونظيفة، بتنقرى منيح بالنهار.'**
  String get designLedgerNote;

  /// No description provided for @designFamily.
  ///
  /// In ar, this message translates to:
  /// **'من عيلة دوايا'**
  String get designFamily;

  /// No description provided for @designFamilyNote.
  ///
  /// In ar, this message translates to:
  /// **'أخضر دوايا وخط أميري.'**
  String get designFamilyNote;

  /// No description provided for @serverTitle.
  ///
  /// In ar, this message translates to:
  /// **'السيرفر'**
  String get serverTitle;

  /// No description provided for @serverNote.
  ///
  /// In ar, this message translates to:
  /// **'بتتغيّر من إعدادات السيرفر نفسه، مو من هون.'**
  String get serverNote;

  /// No description provided for @modelUrl.
  ///
  /// In ar, this message translates to:
  /// **'عنوان النموذج'**
  String get modelUrl;

  /// No description provided for @modelName.
  ///
  /// In ar, this message translates to:
  /// **'النموذج'**
  String get modelName;

  /// No description provided for @modelCheck.
  ///
  /// In ar, this message translates to:
  /// **'جرّب النموذج'**
  String get modelCheck;

  /// No description provided for @modelOk.
  ///
  /// In ar, this message translates to:
  /// **'عم يجاوب ({ms} ملي ثانية)'**
  String modelOk(String ms);

  /// No description provided for @modelDown.
  ///
  /// In ar, this message translates to:
  /// **'ما عم يجاوب: {error}'**
  String modelDown(String error);

  /// No description provided for @emergencyNumbers.
  ///
  /// In ar, this message translates to:
  /// **'أرقام الطوارئ'**
  String get emergencyNumbers;

  /// No description provided for @emergencyValue.
  ///
  /// In ar, this message translates to:
  /// **'إسعاف {ambulance}، طوارئ {general}'**
  String emergencyValue(String ambulance, String general);

  /// No description provided for @corsOrigins.
  ///
  /// In ar, this message translates to:
  /// **'عناوين الويب المسموحة'**
  String get corsOrigins;

  /// No description provided for @serverVersion.
  ///
  /// In ar, this message translates to:
  /// **'نسخة السيرفر'**
  String get serverVersion;

  /// No description provided for @detailMatched.
  ///
  /// In ar, this message translates to:
  /// **'الكلام يلي طابق'**
  String get detailMatched;

  /// No description provided for @detailCategory.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get detailCategory;

  /// No description provided for @detailCorrection.
  ///
  /// In ar, this message translates to:
  /// **'التصحيح'**
  String get detailCorrection;

  /// No description provided for @detailOriginal.
  ///
  /// In ar, this message translates to:
  /// **'قبل التصحيح'**
  String get detailOriginal;

  /// No description provided for @detailReply.
  ///
  /// In ar, this message translates to:
  /// **'رد المساعد'**
  String get detailReply;

  /// No description provided for @detailError.
  ///
  /// In ar, this message translates to:
  /// **'الخطأ'**
  String get detailError;

  /// No description provided for @detailBy.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلي'**
  String get detailBy;

  /// No description provided for @detailReason.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get detailReason;

  /// No description provided for @navAssistant.
  ///
  /// In ar, this message translates to:
  /// **'المساعد'**
  String get navAssistant;

  /// No description provided for @asTitle.
  ///
  /// In ar, this message translates to:
  /// **'المساعد'**
  String get asTitle;

  /// No description provided for @asSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'النموذج، التعليمات، أمثلة السلامة، وجرّب قبل ما تعتمد. قواعد السلامة الأساسية ثابتة بالكود وما بتتغيّر من هون.'**
  String get asSubtitle;

  /// No description provided for @tabState.
  ///
  /// In ar, this message translates to:
  /// **'الحالة والنموذج'**
  String get tabState;

  /// No description provided for @tabPrompts.
  ///
  /// In ar, this message translates to:
  /// **'التعليمات'**
  String get tabPrompts;

  /// No description provided for @tabExamples.
  ///
  /// In ar, this message translates to:
  /// **'أمثلة السلامة'**
  String get tabExamples;

  /// No description provided for @tabSandbox.
  ///
  /// In ar, this message translates to:
  /// **'جرّب'**
  String get tabSandbox;

  /// No description provided for @last24h.
  ///
  /// In ar, this message translates to:
  /// **'آخر 24 ساعة'**
  String get last24h;

  /// No description provided for @stReplies.
  ///
  /// In ar, this message translates to:
  /// **'ردود'**
  String get stReplies;

  /// No description provided for @stDown.
  ///
  /// In ar, this message translates to:
  /// **'مرات الوقوف'**
  String get stDown;

  /// No description provided for @stMedian.
  ///
  /// In ar, this message translates to:
  /// **'متوسط زمن الرد'**
  String get stMedian;

  /// No description provided for @stSlowest.
  ///
  /// In ar, this message translates to:
  /// **'أبطأ رد: {ms}'**
  String stSlowest(String ms);

  /// No description provided for @msValue.
  ///
  /// In ar, this message translates to:
  /// **'{n} ملي ثانية'**
  String msValue(String n);

  /// No description provided for @stGuard.
  ///
  /// In ar, this message translates to:
  /// **'ردود انمنعت'**
  String get stGuard;

  /// No description provided for @stFlags.
  ///
  /// In ar, this message translates to:
  /// **'حالات خطرة'**
  String get stFlags;

  /// No description provided for @stFlagsCaption.
  ///
  /// In ar, this message translates to:
  /// **'من القواعد: {rules}، من النموذج: {model}'**
  String stFlagsCaption(String rules, String model);

  /// No description provided for @stDoctor.
  ///
  /// In ar, this message translates to:
  /// **'نصيحة بطبيب'**
  String get stDoctor;

  /// No description provided for @lastDown.
  ///
  /// In ar, this message translates to:
  /// **'آخر وقوف: {ago}'**
  String lastDown(String ago);

  /// No description provided for @assistantDownBanner.
  ///
  /// In ar, this message translates to:
  /// **'المساعد وقف {ago}. المرضى عم يبعتوا للصيدلي مباشرة لحد ما يرجع.'**
  String assistantDownBanner(String ago);

  /// No description provided for @modelTitle.
  ///
  /// In ar, this message translates to:
  /// **'النموذج'**
  String get modelTitle;

  /// No description provided for @modelSourcePanel.
  ///
  /// In ar, this message translates to:
  /// **'مختار من اللوحة'**
  String get modelSourcePanel;

  /// No description provided for @modelSourceSettings.
  ///
  /// In ar, this message translates to:
  /// **'من إعدادات السيرفر (ما اخترت من اللوحة لسا)'**
  String get modelSourceSettings;

  /// No description provided for @modelKeySet.
  ///
  /// In ar, this message translates to:
  /// **'في مفتاح محفوظ'**
  String get modelKeySet;

  /// No description provided for @modelNoKey.
  ///
  /// In ar, this message translates to:
  /// **'بلا مفتاح'**
  String get modelNoKey;

  /// No description provided for @changeModel.
  ///
  /// In ar, this message translates to:
  /// **'غيّر النموذج'**
  String get changeModel;

  /// No description provided for @chooseServer.
  ///
  /// In ar, this message translates to:
  /// **'اختر المخدم'**
  String get chooseServer;

  /// No description provided for @providerLmStudio.
  ///
  /// In ar, this message translates to:
  /// **'LM Studio'**
  String get providerLmStudio;

  /// No description provided for @providerOllama.
  ///
  /// In ar, this message translates to:
  /// **'Ollama'**
  String get providerOllama;

  /// No description provided for @providerHosted.
  ///
  /// In ar, this message translates to:
  /// **'خدمة أونلاين'**
  String get providerHosted;

  /// No description provided for @serverUrl.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المخدم'**
  String get serverUrl;

  /// No description provided for @apiKey.
  ///
  /// In ar, this message translates to:
  /// **'مفتاح API'**
  String get apiKey;

  /// No description provided for @apiKeyKeep.
  ///
  /// In ar, this message translates to:
  /// **'اتركه فاضي لتضل على المفتاح المحفوظ'**
  String get apiKeyKeep;

  /// No description provided for @removeKey.
  ///
  /// In ar, this message translates to:
  /// **'شيل المفتاح'**
  String get removeKey;

  /// No description provided for @fetchModels.
  ///
  /// In ar, this message translates to:
  /// **'جيب النماذج'**
  String get fetchModels;

  /// No description provided for @chooseModel.
  ///
  /// In ar, this message translates to:
  /// **'اختر النموذج'**
  String get chooseModel;

  /// No description provided for @modelNameManual.
  ///
  /// In ar, this message translates to:
  /// **'أو اكتب اسم النموذج'**
  String get modelNameManual;

  /// No description provided for @noModels.
  ///
  /// In ar, this message translates to:
  /// **'المخدم ما رجّع ولا نموذج.'**
  String get noModels;

  /// No description provided for @timeoutSeconds.
  ///
  /// In ar, this message translates to:
  /// **'مهلة الرد (ثانية)'**
  String get timeoutSeconds;

  /// No description provided for @switchModel.
  ///
  /// In ar, this message translates to:
  /// **'جرّب وبدّل'**
  String get switchModel;

  /// No description provided for @switched.
  ///
  /// In ar, this message translates to:
  /// **'تبدّل النموذج، جاوب بـ {ms}'**
  String switched(String ms);

  /// No description provided for @errServerUnreachable.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرت وصل للمخدم. تأكد من العنوان وإنو شغّال.'**
  String get errServerUnreachable;

  /// No description provided for @errModelNotAnswering.
  ///
  /// In ar, this message translates to:
  /// **'النموذج ما جاوب، فما بدّلت. تأكد من الاسم والمفتاح.'**
  String get errModelNotAnswering;

  /// No description provided for @errTestNotPassed.
  ///
  /// In ar, this message translates to:
  /// **'لازم تمتحن المسودة وتنجح بعد آخر تعديل قبل ما تعتمدها.'**
  String get errTestNotPassed;

  /// No description provided for @errNotADraft.
  ///
  /// In ar, this message translates to:
  /// **'هالنسخة مو مسودة.'**
  String get errNotADraft;

  /// No description provided for @errAlreadyDefault.
  ///
  /// In ar, this message translates to:
  /// **'هي أصلاً النسخة الأساسية.'**
  String get errAlreadyDefault;

  /// No description provided for @kindAssistant.
  ///
  /// In ar, this message translates to:
  /// **'أسئلة المساعد'**
  String get kindAssistant;

  /// No description provided for @kindSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الصيدلي'**
  String get kindSummary;

  /// No description provided for @kindClassifier.
  ///
  /// In ar, this message translates to:
  /// **'فاحص الخطر'**
  String get kindClassifier;

  /// No description provided for @kindAssistantNote.
  ///
  /// In ar, this message translates to:
  /// **'كيف بيحكي المساعد مع المريض وشو بيسأل.'**
  String get kindAssistantNote;

  /// No description provided for @kindSummaryNote.
  ///
  /// In ar, this message translates to:
  /// **'كيف بينكتب الملخص يلي بيوصل للصيدلي.'**
  String get kindSummaryNote;

  /// No description provided for @kindClassifierNote.
  ///
  /// In ar, this message translates to:
  /// **'شو بيعتبر إسعاف، وشو بيعتبر لازم دكتور. أمثلة السلامة بتنضاف عليه.'**
  String get kindClassifierNote;

  /// No description provided for @inUse.
  ///
  /// In ar, this message translates to:
  /// **'المستعمل هلق'**
  String get inUse;

  /// No description provided for @builtIn.
  ///
  /// In ar, this message translates to:
  /// **'النسخة الأساسية'**
  String get builtIn;

  /// No description provided for @versionN.
  ///
  /// In ar, this message translates to:
  /// **'نسخة {n}'**
  String versionN(String n);

  /// No description provided for @statusDraft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get statusDraft;

  /// No description provided for @statusRetired.
  ///
  /// In ar, this message translates to:
  /// **'قديمة'**
  String get statusRetired;

  /// No description provided for @lockedTitle.
  ///
  /// In ar, this message translates to:
  /// **'ثابت بالكود (بينضاف دايماً)'**
  String get lockedTitle;

  /// No description provided for @newDraft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة جديدة'**
  String get newDraft;

  /// No description provided for @editDraft.
  ///
  /// In ar, this message translates to:
  /// **'عدّل'**
  String get editDraft;

  /// No description provided for @runTest.
  ///
  /// In ar, this message translates to:
  /// **'امتحن'**
  String get runTest;

  /// No description provided for @activateDraft.
  ///
  /// In ar, this message translates to:
  /// **'اعتمد'**
  String get activateDraft;

  /// No description provided for @rollbackStep.
  ///
  /// In ar, this message translates to:
  /// **'رجوع خطوة'**
  String get rollbackStep;

  /// No description provided for @rollbackConfirm.
  ///
  /// In ar, this message translates to:
  /// **'ترجع للنسخة يلي قبلها؟'**
  String get rollbackConfirm;

  /// No description provided for @draftText.
  ///
  /// In ar, this message translates to:
  /// **'النص'**
  String get draftText;

  /// No description provided for @draftNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة (شو غيّرت)'**
  String get draftNote;

  /// No description provided for @testPassed.
  ///
  /// In ar, this message translates to:
  /// **'نجحت: ما فوّتت ولا حالة'**
  String get testPassed;

  /// No description provided for @testFailed.
  ///
  /// In ar, this message translates to:
  /// **'ما نجحت: فوّتت {missed}'**
  String testFailed(String missed);

  /// No description provided for @testFalseAlarms.
  ///
  /// In ar, this message translates to:
  /// **'إنذارات زيادة: {n}'**
  String testFalseAlarms(String n);

  /// No description provided for @testSummaryBad.
  ///
  /// In ar, this message translates to:
  /// **'الملخص ما اشتغل'**
  String get testSummaryBad;

  /// No description provided for @testRunning.
  ///
  /// In ar, this message translates to:
  /// **'عم امتحن... ممكن ياخد دقيقة مع نموذج محلي.'**
  String get testRunning;

  /// No description provided for @expected.
  ///
  /// In ar, this message translates to:
  /// **'المتوقع'**
  String get expected;

  /// No description provided for @got.
  ///
  /// In ar, this message translates to:
  /// **'صار'**
  String get got;

  /// No description provided for @labelEmergency.
  ///
  /// In ar, this message translates to:
  /// **'إسعاف'**
  String get labelEmergency;

  /// No description provided for @labelDoctor.
  ///
  /// In ar, this message translates to:
  /// **'لازم دكتور'**
  String get labelDoctor;

  /// No description provided for @labelNormal.
  ///
  /// In ar, this message translates to:
  /// **'عادي'**
  String get labelNormal;

  /// No description provided for @bySource.
  ///
  /// In ar, this message translates to:
  /// **'({source})'**
  String bySource(String source);

  /// No description provided for @sourceRules.
  ///
  /// In ar, this message translates to:
  /// **'القواعد'**
  String get sourceRules;

  /// No description provided for @sourceModel.
  ///
  /// In ar, this message translates to:
  /// **'النموذج'**
  String get sourceModel;

  /// No description provided for @guardBlockedCase.
  ///
  /// In ar, this message translates to:
  /// **'انمنع رد فيه دوا أو جرعة'**
  String get guardBlockedCase;

  /// No description provided for @modelDownCase.
  ///
  /// In ar, this message translates to:
  /// **'النموذج ما جاوب'**
  String get modelDownCase;

  /// No description provided for @examplesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حط مواقف لازم فيها المساعد ينذر المريض: إسعاف أو يروح لدكتور، ومواقف عادية كمان. بتنضاف لفاحص الخطر كأمثلة، وبتصير جزء من الامتحان. ما في تدريب تلقائي.'**
  String get examplesSubtitle;

  /// No description provided for @addExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال جديد'**
  String get addExample;

  /// No description provided for @exampleText.
  ///
  /// In ar, this message translates to:
  /// **'شو كتب المريض'**
  String get exampleText;

  /// No description provided for @exampleLabel.
  ///
  /// In ar, this message translates to:
  /// **'لازم يصير'**
  String get exampleLabel;

  /// No description provided for @exampleNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get exampleNote;

  /// No description provided for @examplesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما في أمثلة لسا.'**
  String get examplesEmpty;

  /// No description provided for @testCurrent.
  ///
  /// In ar, this message translates to:
  /// **'امتحن المستعمل هلق'**
  String get testCurrent;

  /// No description provided for @exampleEnabled.
  ///
  /// In ar, this message translates to:
  /// **'مستعمل'**
  String get exampleEnabled;

  /// No description provided for @sandboxSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'احكي كأنك مريض. ما في مريض حقيقي وما بينحفظ شي. فيك تجرب المسودات قبل ما تعتمدها.'**
  String get sandboxSubtitle;

  /// No description provided for @useDrafts.
  ///
  /// In ar, this message translates to:
  /// **'جرّب مع المسودات:'**
  String get useDrafts;

  /// No description provided for @noDrafts.
  ///
  /// In ar, this message translates to:
  /// **'ما في مسودات، عم جرّب المستعمل هلق.'**
  String get noDrafts;

  /// No description provided for @sandboxHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالة المريض'**
  String get sandboxHint;

  /// No description provided for @send.
  ///
  /// In ar, this message translates to:
  /// **'ابعت'**
  String get send;

  /// No description provided for @restart.
  ///
  /// In ar, this message translates to:
  /// **'من الأول'**
  String get restart;

  /// No description provided for @turnReply.
  ///
  /// In ar, this message translates to:
  /// **'رد'**
  String get turnReply;

  /// No description provided for @turnEmergency.
  ///
  /// In ar, this message translates to:
  /// **'إسعاف'**
  String get turnEmergency;

  /// No description provided for @turnDoctor.
  ///
  /// In ar, this message translates to:
  /// **'لازم دكتور'**
  String get turnDoctor;

  /// No description provided for @turnSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص'**
  String get turnSummary;

  /// No description provided for @turnFallback.
  ///
  /// In ar, this message translates to:
  /// **'النموذج وقف'**
  String get turnFallback;

  /// No description provided for @guardBlockedTurn.
  ///
  /// In ar, this message translates to:
  /// **'الحارس منع رد وحط بداله'**
  String get guardBlockedTurn;
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
