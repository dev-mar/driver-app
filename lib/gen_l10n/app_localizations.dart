import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @driverAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Texi Driver'**
  String get driverAppTitle;

  /// No description provided for @loginCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get loginCode;

  /// No description provided for @loginPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get loginPhone;

  /// No description provided for @tripOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get tripOrigin;

  /// No description provided for @tripDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get tripDestination;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @driverLoginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, driver'**
  String get driverLoginWelcome;

  /// No description provided for @driverLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Or enter your number and password if you\'re already a Texi driver.'**
  String get driverLoginSubtitle;

  /// No description provided for @driverLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get driverLoginPassword;

  /// No description provided for @driverLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get driverLoginButton;

  /// No description provided for @driverLoginPhoneAndPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your number and password'**
  String get driverLoginPhoneAndPasswordRequired;

  /// No description provided for @driverLoginCountryCodeHint.
  ///
  /// In en, this message translates to:
  /// **'+591'**
  String get driverLoginCountryCodeHint;

  /// No description provided for @driverLoginPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'7 123 4567'**
  String get driverLoginPhoneHint;

  /// No description provided for @driverLoginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in'**
  String get driverLoginErrorGeneric;

  /// No description provided for @driverLoginErrorAccountBlocked.
  ///
  /// In en, this message translates to:
  /// **'Your account is blocked. Contact support to review your case.'**
  String get driverLoginErrorAccountBlocked;

  /// No description provided for @driverLoginErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Check your internet and try again.'**
  String get driverLoginErrorNetwork;

  /// No description provided for @driverLoginErrorConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. Check your network.'**
  String get driverLoginErrorConnection;

  /// No description provided for @driverLoginErrorInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid server response. Please try again.'**
  String get driverLoginErrorInvalidResponse;

  /// No description provided for @driverLoginErrorTokenMissing.
  ///
  /// In en, this message translates to:
  /// **'Session token was not received. Please try again.'**
  String get driverLoginErrorTokenMissing;

  /// No description provided for @driverLoginErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected sign-in error. Please try again.'**
  String get driverLoginErrorUnexpected;

  /// No description provided for @driverLoginErrorSessionSuperseded.
  ///
  /// In en, this message translates to:
  /// **'Your session was opened on another device.'**
  String get driverLoginErrorSessionSuperseded;

  /// No description provided for @driverLoginErrorTripOperationalLock.
  ///
  /// In en, this message translates to:
  /// **'Finish or cancel your current trip before signing in on another device.'**
  String get driverLoginErrorTripOperationalLock;

  /// No description provided for @driverLoginErrorDeviceBound.
  ///
  /// In en, this message translates to:
  /// **'This account is linked to another device. Contact support to change phones.'**
  String get driverLoginErrorDeviceBound;

  /// No description provided for @driverLoginRegisterCta.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get driverLoginRegisterCta;

  /// No description provided for @driverLoginRegisterBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'New driver?'**
  String get driverLoginRegisterBannerTitle;

  /// No description provided for @driverLoginRegisterBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account in minutes and start receiving trips with TEXIAPP.'**
  String get driverLoginRegisterBannerSubtitle;

  /// No description provided for @driverHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverHomeTitle;

  /// No description provided for @driverHomeRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride requests'**
  String get driverHomeRequestsTitle;

  /// No description provided for @driverHomeRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You will see passenger requests here\nwhen you are online.'**
  String get driverHomeRequestsEmpty;

  /// No description provided for @driverHomeMiniStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get driverHomeMiniStatusOnline;

  /// No description provided for @driverHomeMiniStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get driverHomeMiniStatusOffline;

  /// No description provided for @driverHomeMiniConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get driverHomeMiniConnecting;

  /// No description provided for @driverHomeMiniStatusRestoringConnection.
  ///
  /// In en, this message translates to:
  /// **'Restoring connection…'**
  String get driverHomeMiniStatusRestoringConnection;

  /// No description provided for @driverHomeVehicleRegistrationBanner.
  ///
  /// In en, this message translates to:
  /// **'You still need to register your vehicle. Without a vehicle you cannot receive trips.'**
  String get driverHomeVehicleRegistrationBanner;

  /// No description provided for @driverHomeVehicleRegistrationCta.
  ///
  /// In en, this message translates to:
  /// **'Complete vehicle registration'**
  String get driverHomeVehicleRegistrationCta;

  /// No description provided for @driverHomeCannotGoOnlineWithoutVehicle.
  ///
  /// In en, this message translates to:
  /// **'Register your vehicle before going online to receive trips.'**
  String get driverHomeCannotGoOnlineWithoutVehicle;

  /// No description provided for @driverHomeVehicleRequiredDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle required'**
  String get driverHomeVehicleRequiredDialogTitle;

  /// No description provided for @driverHomeCreditsLowWarning.
  ///
  /// In en, this message translates to:
  /// **'Your balance ({balance}) is close to the minimum ({min}) to stay online. Top up soon so you are not taken offline automatically.'**
  String driverHomeCreditsLowWarning(String balance, String min);

  /// No description provided for @driverFcmOpenedTripOfferHint.
  ///
  /// In en, this message translates to:
  /// **'We try to load the request from the alert into the list below. If it\'s missing, it may have expired or the connection failed—toggle online again.'**
  String get driverFcmOpenedTripOfferHint;

  /// No description provided for @driverFcmOpenedTripOfferOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Turn on availability to receive requests from alerts.'**
  String get driverFcmOpenedTripOfferOfflineHint;

  /// No description provided for @driverHomeMiniVehicleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get driverHomeMiniVehicleEmpty;

  /// No description provided for @driverHomeMiniRating.
  ///
  /// In en, this message translates to:
  /// **'{rating} ★'**
  String driverHomeMiniRating(String rating);

  /// No description provided for @driverLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get driverLogout;

  /// No description provided for @driverHomeMenuSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get driverHomeMenuSectionAccount;

  /// No description provided for @driverHomeMenuSectionActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get driverHomeMenuSectionActivity;

  /// No description provided for @driverHomeMenuSectionSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get driverHomeMenuSectionSession;

  /// No description provided for @driverHomeMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get driverHomeMenuTitle;

  /// No description provided for @driverEarningsCreditsMenu.
  ///
  /// In en, this message translates to:
  /// **'Earnings & credits'**
  String get driverEarningsCreditsMenu;

  /// No description provided for @driverClubMenu.
  ///
  /// In en, this message translates to:
  /// **'Driver Club'**
  String get driverClubMenu;

  /// No description provided for @driverClubTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Club'**
  String get driverClubTitle;

  /// No description provided for @driverClubHeroBadge.
  ///
  /// In en, this message translates to:
  /// **'EXCLUSIVE'**
  String get driverClubHeroBadge;

  /// No description provided for @driverClubHeroHello.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get driverClubHeroHello;

  /// No description provided for @driverClubHeroHelloName.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String driverClubHeroHelloName(String name);

  /// No description provided for @driverClubHeroTagline.
  ///
  /// In en, this message translates to:
  /// **'Benefits for drivers who already operate.'**
  String get driverClubHeroTagline;

  /// No description provided for @driverClubHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'What is the Texi Driver Club'**
  String get driverClubHowItWorks;

  /// No description provided for @driverClubLearnOnWeb.
  ///
  /// In en, this message translates to:
  /// **'Learn more about this benefit'**
  String get driverClubLearnOnWeb;

  /// No description provided for @driverClubWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Club credit'**
  String get driverClubWalletTitle;

  /// No description provided for @driverClubExpiresOn.
  ///
  /// In en, this message translates to:
  /// **'Active until {date}'**
  String driverClubExpiresOn(String date);

  /// No description provided for @driverClubWalletEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No Club credit yet.'**
  String get driverClubWalletEmptyHint;

  /// No description provided for @driverClubWalletLiveHint.
  ///
  /// In en, this message translates to:
  /// **'Used when trips complete.'**
  String get driverClubWalletLiveHint;

  /// No description provided for @driverClubInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite and earn'**
  String get driverClubInviteTitle;

  /// No description provided for @driverClubInviteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your code. Grow your network.'**
  String get driverClubInviteSubtitle;

  /// No description provided for @driverClubYourCode.
  ///
  /// In en, this message translates to:
  /// **'Your code'**
  String get driverClubYourCode;

  /// No description provided for @driverClubCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get driverClubCopyCode;

  /// No description provided for @driverClubCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get driverClubCodeCopied;

  /// No description provided for @driverClubShareWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get driverClubShareWhatsapp;

  /// No description provided for @driverClubWhatsappShare.
  ///
  /// In en, this message translates to:
  /// **'Join as a TEXIAPP driver with my code {code}'**
  String driverClubWhatsappShare(String code);

  /// No description provided for @driverClubEnterCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Were you invited? Enter their code'**
  String get driverClubEnterCodeHint;

  /// No description provided for @driverClubClaimCta.
  ///
  /// In en, this message translates to:
  /// **'Register code'**
  String get driverClubClaimCta;

  /// No description provided for @driverClubClaimOk.
  ///
  /// In en, this message translates to:
  /// **'Code registered'**
  String get driverClubClaimOk;

  /// No description provided for @driverClubInviteesTitle.
  ///
  /// In en, this message translates to:
  /// **'My guests'**
  String get driverClubInviteesTitle;

  /// No description provided for @driverClubInviteesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No guests yet.'**
  String get driverClubInviteesEmpty;

  /// No description provided for @driverClubStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get driverClubStatusPending;

  /// No description provided for @driverClubStatusProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get driverClubStatusProgress;

  /// No description provided for @driverClubStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get driverClubStatusDone;

  /// No description provided for @driverClubBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'More benefits'**
  String get driverClubBenefitsTitle;

  /// No description provided for @driverClubLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get driverClubLevelsTitle;

  /// No description provided for @driverClubLevelsHint.
  ///
  /// In en, this message translates to:
  /// **'Your category is confirmed by the team. These numbers are this month\'s reference.'**
  String get driverClubLevelsHint;

  /// No description provided for @driverClubMonthTripsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} trips this month'**
  String driverClubMonthTripsValue(int count);

  /// No description provided for @driverClubMonthRatingValue.
  ///
  /// In en, this message translates to:
  /// **'{rating} stars this month'**
  String driverClubMonthRatingValue(String rating);

  /// No description provided for @driverClubMonthRatingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No ratings this month yet'**
  String get driverClubMonthRatingEmpty;

  /// No description provided for @driverClubTripsRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} trips'**
  String driverClubTripsRange(int min, int max);

  /// No description provided for @driverClubTripsFrom.
  ///
  /// In en, this message translates to:
  /// **'From {min} trips'**
  String driverClubTripsFrom(int min);

  /// No description provided for @driverClubRatingFrom.
  ///
  /// In en, this message translates to:
  /// **'From {rating} stars'**
  String driverClubRatingFrom(String rating);

  /// No description provided for @driverClubRatingNone.
  ///
  /// In en, this message translates to:
  /// **'No star minimum'**
  String get driverClubRatingNone;

  /// No description provided for @driverClubChallengesTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get driverClubChallengesTitle;

  /// No description provided for @driverClubChallengesBlurb.
  ///
  /// In en, this message translates to:
  /// **'Short quests, when they go live.'**
  String get driverClubChallengesBlurb;

  /// No description provided for @driverClubAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle ads'**
  String get driverClubAdsTitle;

  /// No description provided for @driverClubAdsBlurb.
  ///
  /// In en, this message translates to:
  /// **'Apply when the call opens.'**
  String get driverClubAdsBlurb;

  /// No description provided for @driverRegFieldReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral code (optional)'**
  String get driverRegFieldReferralCode;

  /// No description provided for @driverRegFieldReferralCodeHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. CARLOS-782'**
  String get driverRegFieldReferralCodeHint;

  /// No description provided for @driverEarningsCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Earnings & credits'**
  String get driverEarningsCreditsTitle;

  /// No description provided for @driverEarningsCreditsFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Filter by period. Totals and lists match the selected range.'**
  String get driverEarningsCreditsFilterHint;

  /// No description provided for @driverEarningsCreditsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load data. Pull to refresh.'**
  String get driverEarningsCreditsLoadError;

  /// No description provided for @driverEarningsCreditsStatTrips.
  ///
  /// In en, this message translates to:
  /// **'Completed trips'**
  String get driverEarningsCreditsStatTrips;

  /// No description provided for @driverEarningsCreditsStatTripsHint.
  ///
  /// In en, this message translates to:
  /// **'In the selected period'**
  String get driverEarningsCreditsStatTripsHint;

  /// No description provided for @driverEarningsCreditsStatGross.
  ///
  /// In en, this message translates to:
  /// **'Trip total'**
  String get driverEarningsCreditsStatGross;

  /// No description provided for @driverEarningsCreditsStatGrossHint.
  ///
  /// In en, this message translates to:
  /// **'Sum of completed trip fares'**
  String get driverEarningsCreditsStatGrossHint;

  /// No description provided for @driverEarningsCreditsStatBalance.
  ///
  /// In en, this message translates to:
  /// **'Credit balance'**
  String get driverEarningsCreditsStatBalance;

  /// No description provided for @driverEarningsCreditsStatCommission.
  ///
  /// In en, this message translates to:
  /// **'Credit commission'**
  String get driverEarningsCreditsStatCommission;

  /// No description provided for @driverEarningsCreditsStatCommissionHint.
  ///
  /// In en, this message translates to:
  /// **'Deducted from balance in period'**
  String get driverEarningsCreditsStatCommissionHint;

  /// No description provided for @driverEarningsCreditsLedgerSection.
  ///
  /// In en, this message translates to:
  /// **'Credit activity'**
  String get driverEarningsCreditsLedgerSection;

  /// No description provided for @driverEarningsCreditsLedgerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No movements in this period.'**
  String get driverEarningsCreditsLedgerEmpty;

  /// No description provided for @driverEarningsCreditsLedgerGrant.
  ///
  /// In en, this message translates to:
  /// **'Top-up'**
  String get driverEarningsCreditsLedgerGrant;

  /// No description provided for @driverEarningsCreditsLedgerCommission.
  ///
  /// In en, this message translates to:
  /// **'Trip commission'**
  String get driverEarningsCreditsLedgerCommission;

  /// No description provided for @driverEarningsCreditsTripsSection.
  ///
  /// In en, this message translates to:
  /// **'Trips in period'**
  String get driverEarningsCreditsTripsSection;

  /// No description provided for @driverEarningsCreditsTripsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed trips in this period.'**
  String get driverEarningsCreditsTripsEmpty;

  /// No description provided for @driverEarningsCreditsTripIdShort.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get driverEarningsCreditsTripIdShort;

  /// No description provided for @driverTripHistoryMenu.
  ///
  /// In en, this message translates to:
  /// **'Trip history'**
  String get driverTripHistoryMenu;

  /// No description provided for @driverTripHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip history'**
  String get driverTripHistoryTitle;

  /// No description provided for @driverTripHistoryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get driverTripHistoryFilterAll;

  /// No description provided for @driverTripHistoryFilterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get driverTripHistoryFilterCompleted;

  /// No description provided for @driverTripHistoryFilterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get driverTripHistoryFilterCancelled;

  /// No description provided for @driverTripHistoryFilterInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get driverTripHistoryFilterInProgress;

  /// No description provided for @driverTripHistoryDateAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get driverTripHistoryDateAll;

  /// No description provided for @driverTripHistoryDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get driverTripHistoryDateToday;

  /// No description provided for @driverTripHistoryDate7d.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get driverTripHistoryDate7d;

  /// No description provided for @driverTripHistoryDate30d.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get driverTripHistoryDate30d;

  /// No description provided for @driverTripHistoryStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get driverTripHistoryStatusLabel;

  /// No description provided for @driverTripHistoryStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get driverTripHistoryStatusCompleted;

  /// No description provided for @driverTripHistoryStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get driverTripHistoryStatusCancelled;

  /// No description provided for @driverTripHistoryStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get driverTripHistoryStatusInProgress;

  /// No description provided for @driverTripHistoryDateCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get driverTripHistoryDateCustom;

  /// No description provided for @driverTripHistoryActiveFilters.
  ///
  /// In en, this message translates to:
  /// **'Active filters'**
  String get driverTripHistoryActiveFilters;

  /// No description provided for @driverTripHistoryCustomRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected range'**
  String get driverTripHistoryCustomRangeLabel;

  /// No description provided for @driverTripHistorySectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get driverTripHistorySectionToday;

  /// No description provided for @driverTripHistorySectionYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get driverTripHistorySectionYesterday;

  /// No description provided for @driverTripHistorySectionOlder.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get driverTripHistorySectionOlder;

  /// No description provided for @driverTripHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No trips yet for this filter.'**
  String get driverTripHistoryEmpty;

  /// No description provided for @driverTripHistoryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load trip history. Please try again.'**
  String get driverTripHistoryLoadError;

  /// No description provided for @driverTripHistoryNoSession.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get driverTripHistoryNoSession;

  /// No description provided for @driverTripHistoryPrevPage.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get driverTripHistoryPrevPage;

  /// No description provided for @driverTripHistoryNextPage.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get driverTripHistoryNextPage;

  /// No description provided for @driverTripHistoryPricePending.
  ///
  /// In en, this message translates to:
  /// **'No amount'**
  String get driverTripHistoryPricePending;

  /// No description provided for @driverHomeMenuAddVehicle.
  ///
  /// In en, this message translates to:
  /// **'My vehicles'**
  String get driverHomeMenuAddVehicle;

  /// No description provided for @driverMyVehiclesTitle.
  ///
  /// In en, this message translates to:
  /// **'My vehicles'**
  String get driverMyVehiclesTitle;

  /// No description provided for @driverMyVehiclesRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh list'**
  String get driverMyVehiclesRefreshTooltip;

  /// No description provided for @driverMyVehiclesAddFab.
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get driverMyVehiclesAddFab;

  /// No description provided for @driverMyVehiclesAddLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not available yet'**
  String get driverMyVehiclesAddLockedTitle;

  /// No description provided for @driverMyVehiclesAddLockedBody.
  ///
  /// In en, this message translates to:
  /// **'For now you can only have one registered vehicle. Adding another is a benefit unlocked based on your seniority and driver evaluation. If you think it should already apply, contact support.'**
  String get driverMyVehiclesAddLockedBody;

  /// No description provided for @driverMyVehiclesAddLockedCta.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get driverMyVehiclesAddLockedCta;

  /// No description provided for @driverMyVehiclesEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have no registered vehicles yet. Add one to offer service.'**
  String get driverMyVehiclesEmpty;

  /// No description provided for @driverMyVehiclesRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get driverMyVehiclesRetry;

  /// No description provided for @driverMyVehiclesPhotosPendingBadge.
  ///
  /// In en, this message translates to:
  /// **'Gallery incomplete: {uploaded} of {required} required photos'**
  String driverMyVehiclesPhotosPendingBadge(int uploaded, int required);

  /// No description provided for @driverMyVehiclesCompletePhotosCta.
  ///
  /// In en, this message translates to:
  /// **'Complete photos'**
  String get driverMyVehiclesCompletePhotosCta;

  /// No description provided for @driverMyVehiclesCompletePhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle photos'**
  String get driverMyVehiclesCompletePhotosTitle;

  /// No description provided for @driverMyVehiclesPhotosSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Photos saved successfully'**
  String get driverMyVehiclesPhotosSavedSnackbar;

  /// No description provided for @driverOnlineAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity'**
  String get driverOnlineAuthTitle;

  /// No description provided for @driverOnlineAuthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Next, you\'ll use your fingerprint, Face ID, or device PIN. This keeps your account safe when you go online.'**
  String get driverOnlineAuthSubtitle;

  /// No description provided for @driverOnlineAuthContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get driverOnlineAuthContinue;

  /// No description provided for @driverOnlineAuthCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get driverOnlineAuthCancel;

  /// No description provided for @driverOnlineAuthReasonBiometric.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity to go online as a driver'**
  String get driverOnlineAuthReasonBiometric;

  /// No description provided for @driverOnlineAuthReasonDeviceCredential.
  ///
  /// In en, this message translates to:
  /// **'Confirm with your PIN or pattern to go online'**
  String get driverOnlineAuthReasonDeviceCredential;

  /// No description provided for @driverOnlineAuthVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify device identity'**
  String get driverOnlineAuthVerifyFailed;

  /// No description provided for @driverProfileMenu.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get driverProfileMenu;

  /// No description provided for @driverProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get driverProfileTitle;

  /// No description provided for @driverProfileBack.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get driverProfileBack;

  /// No description provided for @driverProfileRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get driverProfileRefreshTooltip;

  /// No description provided for @driverProfileRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get driverProfileRetry;

  /// No description provided for @driverProfileErrorNoSession.
  ///
  /// In en, this message translates to:
  /// **'Session unavailable. Please sign in again.'**
  String get driverProfileErrorNoSession;

  /// No description provided for @driverProfileErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty server response.'**
  String get driverProfileErrorEmpty;

  /// No description provided for @driverProfileErrorBadFormat.
  ///
  /// In en, this message translates to:
  /// **'Could not read profile data.'**
  String get driverProfileErrorBadFormat;

  /// No description provided for @driverProfileRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'TEXI driver'**
  String get driverProfileRoleSubtitle;

  /// No description provided for @driverProfileBadgeActive.
  ///
  /// In en, this message translates to:
  /// **'Active profile'**
  String get driverProfileBadgeActive;

  /// No description provided for @driverProfileBadgeSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure account'**
  String get driverProfileBadgeSecure;

  /// No description provided for @driverProfileVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Account status: Under review'**
  String get driverProfileVerificationTitle;

  /// No description provided for @driverProfileVerificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your documents were received successfully. Our team is validating them so we can enable your service as soon as possible.'**
  String get driverProfileVerificationBody;

  /// No description provided for @driverProfileOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Uploads and checks'**
  String get driverProfileOnboardingTitle;

  /// No description provided for @driverProfileOnboardingBody.
  ///
  /// In en, this message translates to:
  /// **'Review each block\'s status. CI, license, and vehicle photos can be changed until the block shows as Verified. A verified block cannot be opened; the summary is below.'**
  String get driverProfileOnboardingBody;

  /// No description provided for @driverProfileSectionOnboardingPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get driverProfileSectionOnboardingPersonal;

  /// No description provided for @driverProfileSectionOnboardingIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity document'**
  String get driverProfileSectionOnboardingIdentity;

  /// No description provided for @driverProfileSectionOnboardingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver license'**
  String get driverProfileSectionOnboardingLicense;

  /// No description provided for @driverProfileSectionOnboardingVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle and photos'**
  String get driverProfileSectionOnboardingVehicle;

  /// No description provided for @driverProfileOnboardingStatusIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get driverProfileOnboardingStatusIncomplete;

  /// No description provided for @driverProfileOnboardingStatusPending.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get driverProfileOnboardingStatusPending;

  /// No description provided for @driverProfileOnboardingStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get driverProfileOnboardingStatusVerified;

  /// No description provided for @driverProfileOnboardingStatusAction.
  ///
  /// In en, this message translates to:
  /// **'Update requested'**
  String get driverProfileOnboardingStatusAction;

  /// No description provided for @driverProfileOnboardingTapToContinue.
  ///
  /// In en, this message translates to:
  /// **'Tap to open or update'**
  String get driverProfileOnboardingTapToContinue;

  /// No description provided for @driverProfileOnboardingTapEditable.
  ///
  /// In en, this message translates to:
  /// **'Tap to complete or fix'**
  String get driverProfileOnboardingTapEditable;

  /// No description provided for @driverProfileOnboardingTapEditPhotos.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photos (until approved)'**
  String get driverProfileOnboardingTapEditPhotos;

  /// No description provided for @driverProfileOnboardingTapViewOnly.
  ///
  /// In en, this message translates to:
  /// **'Tap to view (in review)'**
  String get driverProfileOnboardingTapViewOnly;

  /// No description provided for @driverProfileOnboardingTapLocked.
  ///
  /// In en, this message translates to:
  /// **'Verified. The summary is below.'**
  String get driverProfileOnboardingTapLocked;

  /// No description provided for @driverRegProfileSectionReadOnlyBanner.
  ///
  /// In en, this message translates to:
  /// **'This block is under review. You can view the information but cannot save changes until our team processes it.'**
  String get driverRegProfileSectionReadOnlyBanner;

  /// No description provided for @driverRegProfileSectionPhotosEditableBanner.
  ///
  /// In en, this message translates to:
  /// **'You can change the photos until this block is approved. Other details stay locked.'**
  String get driverRegProfileSectionPhotosEditableBanner;

  /// No description provided for @driverRegActionSavePhotos.
  ///
  /// In en, this message translates to:
  /// **'Save photos'**
  String get driverRegActionSavePhotos;

  /// No description provided for @driverRegSnackChangeAtLeastOnePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change at least one photo to save.'**
  String get driverRegSnackChangeAtLeastOnePhoto;

  /// No description provided for @driverRegProfileSectionLockedBanner.
  ///
  /// In en, this message translates to:
  /// **'This block is verified and cannot be changed from the app.'**
  String get driverRegProfileSectionLockedBanner;

  /// No description provided for @driverRegErrorSectionNotEditable.
  ///
  /// In en, this message translates to:
  /// **'This section cannot be changed in its current status.'**
  String get driverRegErrorSectionNotEditable;

  /// No description provided for @driverRegErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests in a short time. Wait a moment and try again.'**
  String get driverRegErrorRateLimited;

  /// No description provided for @driverRegErrorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your signal and try again.'**
  String get driverRegErrorNoConnection;

  /// No description provided for @driverRegPassengerUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'You already have a passenger account'**
  String get driverRegPassengerUpgradeTitle;

  /// No description provided for @driverRegPassengerUpgradeBody.
  ///
  /// In en, this message translates to:
  /// **'This number is already registered as a passenger. Open WhatsApp and send the message to confirm it is yours.'**
  String get driverRegPassengerUpgradeBody;

  /// No description provided for @driverRegPassengerUpgradeBodyCode.
  ///
  /// In en, this message translates to:
  /// **'This number is already registered as a passenger. Enter the verification code to confirm it is yours.'**
  String get driverRegPassengerUpgradeBodyCode;

  /// No description provided for @driverRegPassengerUpgradeOpenWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp'**
  String get driverRegPassengerUpgradeOpenWhatsApp;

  /// No description provided for @driverRegPassengerUpgradeWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your WhatsApp message…'**
  String get driverRegPassengerUpgradeWaiting;

  /// No description provided for @driverRegPassengerUpgradeExpired.
  ///
  /// In en, this message translates to:
  /// **'The message expired. Try again.'**
  String get driverRegPassengerUpgradeExpired;

  /// No description provided for @driverRegPassengerUpgradeCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get driverRegPassengerUpgradeCodeHint;

  /// No description provided for @driverRegPassengerUpgradeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get driverRegPassengerUpgradeConfirm;

  /// No description provided for @driverRegErrorPassengerUpgradeRequired.
  ///
  /// In en, this message translates to:
  /// **'This number already belongs to a passenger. Confirm it on WhatsApp to register as a driver.'**
  String get driverRegErrorPassengerUpgradeRequired;

  /// No description provided for @driverRegErrorDuplicatePhoneDriver.
  ///
  /// In en, this message translates to:
  /// **'This number is already registered as a driver. Sign in or recover your access.'**
  String get driverRegErrorDuplicatePhoneDriver;

  /// No description provided for @driverRegErrorUpgradeOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'The code is invalid or expired. Request a new one and try again.'**
  String get driverRegErrorUpgradeOtpInvalid;

  /// No description provided for @driverRegErrorUpgradeOtpNotFound.
  ///
  /// In en, this message translates to:
  /// **'There is no passenger account with this number. Complete registration as a new driver.'**
  String get driverRegErrorUpgradeOtpNotFound;

  /// No description provided for @driverRegErrorAccountDeletionPending.
  ///
  /// In en, this message translates to:
  /// **'This account is pending deletion. Cancel that request in the passenger app before registering as a driver.'**
  String get driverRegErrorAccountDeletionPending;

  /// No description provided for @driverRegErrorUpgradeWhatsAppSend.
  ///
  /// In en, this message translates to:
  /// **'We could not send the WhatsApp code. Try again in a few minutes.'**
  String get driverRegErrorUpgradeWhatsAppSend;

  /// No description provided for @driverProfileSectionPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get driverProfileSectionPersonal;

  /// No description provided for @driverProfileSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get driverProfileSectionContact;

  /// No description provided for @driverProfileSectionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get driverProfileSectionLocation;

  /// No description provided for @driverProfileReadOnlyFooter.
  ///
  /// In en, this message translates to:
  /// **'These details are read-only for now. Editing from the app will be available soon.'**
  String get driverProfileReadOnlyFooter;

  /// No description provided for @driverAppCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage credits'**
  String get driverAppCreditsTitle;

  /// No description provided for @driverAppCreditsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not load balance. Pull to refresh.'**
  String get driverAppCreditsUnavailable;

  /// No description provided for @driverAppCreditsBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance: {balance}'**
  String driverAppCreditsBalance(String balance);

  /// No description provided for @driverAppCreditsProgramOn.
  ///
  /// In en, this message translates to:
  /// **'Per-trip commission active'**
  String get driverAppCreditsProgramOn;

  /// No description provided for @driverAppCreditsProgramOff.
  ///
  /// In en, this message translates to:
  /// **'No automatic per-trip commission'**
  String get driverAppCreditsProgramOff;

  /// No description provided for @driverAppCreditsDetailPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of trip fare'**
  String driverAppCreditsDetailPercent(String percent);

  /// No description provided for @driverAppCreditsDetailFixed.
  ///
  /// In en, this message translates to:
  /// **'{amount} per completed trip'**
  String driverAppCreditsDetailFixed(String amount);

  /// No description provided for @driverProfileFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get driverProfileFieldName;

  /// No description provided for @driverProfileFieldReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral code'**
  String get driverProfileFieldReferralCode;

  /// No description provided for @driverProfileCopyReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Copy referral code'**
  String get driverProfileCopyReferralCode;

  /// No description provided for @driverProfileReferralCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get driverProfileReferralCopied;

  /// No description provided for @driverProfileFieldBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get driverProfileFieldBirthDate;

  /// No description provided for @driverProfileFieldGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get driverProfileFieldGender;

  /// No description provided for @driverProfileFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get driverProfileFieldPhone;

  /// No description provided for @driverProfileFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get driverProfileFieldEmail;

  /// No description provided for @driverProfileFieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get driverProfileFieldAddress;

  /// No description provided for @driverProfileFieldLocality.
  ///
  /// In en, this message translates to:
  /// **'City / locality'**
  String get driverProfileFieldLocality;

  /// No description provided for @driverProfileGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get driverProfileGenderMale;

  /// No description provided for @driverProfileGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get driverProfileGenderFemale;

  /// No description provided for @driverProfileGenderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get driverProfileGenderOther;

  /// No description provided for @driverProfileValueEmpty.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get driverProfileValueEmpty;

  /// No description provided for @driverProfileDefaultName.
  ///
  /// In en, this message translates to:
  /// **'TEXI driver'**
  String get driverProfileDefaultName;

  /// No description provided for @driverOnlineErrorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Connect to go online.'**
  String get driverOnlineErrorNoInternet;

  /// No description provided for @driverOnlineErrorNoGps.
  ///
  /// In en, this message translates to:
  /// **'Enable location permissions to share your position.'**
  String get driverOnlineErrorNoGps;

  /// No description provided for @driverOnlineErrorGpsServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on device location services to go online and receive trip offers.'**
  String get driverOnlineErrorGpsServiceOff;

  /// No description provided for @driverOnlineErrorNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications for this app. Without them you may miss trip offers when the app is in the background.'**
  String get driverOnlineErrorNoNotifications;

  /// No description provided for @driverOnlineErrorNoToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid session. Please sign in again.'**
  String get driverOnlineErrorNoToken;

  /// No description provided for @driverOnlineErrorSessionExpiredReLogin.
  ///
  /// In en, this message translates to:
  /// **'Your session expired or is no longer valid. Please sign in again.'**
  String get driverOnlineErrorSessionExpiredReLogin;

  /// No description provided for @driverOnlineErrorSocket.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Please try again.'**
  String get driverOnlineErrorSocket;

  /// No description provided for @driverOnlineErrorVehicleRequired.
  ///
  /// In en, this message translates to:
  /// **'You need a registered vehicle to connect. Complete vehicle registration or use “Add another vehicle” in the menu.'**
  String get driverOnlineErrorVehicleRequired;

  /// No description provided for @driverOnlineErrorGoOnlineBlocked.
  ///
  /// In en, this message translates to:
  /// **'Your account cannot go available for trips from the app. Contact support if you think this is a mistake.'**
  String get driverOnlineErrorGoOnlineBlocked;

  /// No description provided for @driverOnlineErrorCreditsBelowMin.
  ///
  /// In en, this message translates to:
  /// **'Insufficient credits to enable online mode. Minimum required: {minCredits}; current balance: {balance}.'**
  String driverOnlineErrorCreditsBelowMin(Object minCredits, Object balance);

  /// No description provided for @driverOnlineErrorAccountBlocked.
  ///
  /// In en, this message translates to:
  /// **'Your driver account is blocked. Your session was closed for safety.'**
  String get driverOnlineErrorAccountBlocked;

  /// No description provided for @driverOnlineErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Could not go online. Please try again.'**
  String get driverOnlineErrorUnknown;

  /// No description provided for @driverOnlineErrorActiveTripCantGoOffline.
  ///
  /// In en, this message translates to:
  /// **'You can’t go offline while you have an active trip or a rating pending. Finish or cancel the trip first.'**
  String get driverOnlineErrorActiveTripCantGoOffline;

  /// No description provided for @driverOnlineErrorReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Connection lost. Reconnecting…'**
  String get driverOnlineErrorReconnecting;

  /// No description provided for @driverOnlineErrorRbacForbidden.
  ///
  /// In en, this message translates to:
  /// **'Your account doesn’t have permission for this action. If it keeps happening, sign out and sign back in or contact support.'**
  String get driverOnlineErrorRbacForbidden;

  /// No description provided for @driverOnlineErrorRbacSession.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t validate your session to go online. Sign out and sign in again.'**
  String get driverOnlineErrorRbacSession;

  /// No description provided for @driverOnlineErrorRbacTechnical.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t verify permissions. Please try again in a few seconds.'**
  String get driverOnlineErrorRbacTechnical;

  /// No description provided for @driverHomeOnlineRequirementsHint.
  ///
  /// In en, this message translates to:
  /// **'Only needed to receive trips: the server must see you online, with location on, and be able to notify you. Other screens (like your profile) don’t need this.'**
  String get driverHomeOnlineRequirementsHint;

  /// No description provided for @driverHomeOpenSystemLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open location (GPS) settings'**
  String get driverHomeOpenSystemLocationSettings;

  /// No description provided for @driverHomeOpenAppPermissionSettings.
  ///
  /// In en, this message translates to:
  /// **'Open app permission settings'**
  String get driverHomeOpenAppPermissionSettings;

  /// No description provided for @driverTripInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip in progress'**
  String get driverTripInProgressTitle;

  /// No description provided for @driverTripStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Go to pickup'**
  String get driverTripStatusAccepted;

  /// No description provided for @driverTripStatusArrived.
  ///
  /// In en, this message translates to:
  /// **'At pickup point'**
  String get driverTripStatusArrived;

  /// No description provided for @driverTripStatusStarted.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get driverTripStatusStarted;

  /// No description provided for @driverTripStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get driverTripStatusCompleted;

  /// No description provided for @driverTripStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Trip cancelled'**
  String get driverTripStatusCancelled;

  /// No description provided for @driverTripStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip in progress'**
  String get driverTripStatusInProgress;

  /// No description provided for @driverTripEstimatedPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated price: {amount}'**
  String driverTripEstimatedPrice(String amount);

  /// No description provided for @driverTripArrivedButton.
  ///
  /// In en, this message translates to:
  /// **'I arrived at pickup'**
  String get driverTripArrivedButton;

  /// No description provided for @driverTripStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start trip'**
  String get driverTripStartButton;

  /// No description provided for @driverTripCompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Finish trip'**
  String get driverTripCompleteButton;

  /// No description provided for @driverTripOfferPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated price: {amount}'**
  String driverTripOfferPrice(String amount);

  /// No description provided for @driverTripReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get driverTripReject;

  /// No description provided for @driverTripAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get driverTripAccept;

  /// No description provided for @driverTripOfferPriceTbd.
  ///
  /// In en, this message translates to:
  /// **'To be agreed'**
  String get driverTripOfferPriceTbd;

  /// No description provided for @driverTripOfferBadgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get driverTripOfferBadgeNew;

  /// No description provided for @driverTripPaymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get driverTripPaymentCash;

  /// No description provided for @driverTripPaymentQr.
  ///
  /// In en, this message translates to:
  /// **'QR'**
  String get driverTripPaymentQr;

  /// No description provided for @driverTripExtrasTitle.
  ///
  /// In en, this message translates to:
  /// **'Passenger notes'**
  String get driverTripExtrasTitle;

  /// No description provided for @driverTripExtrasHint.
  ///
  /// In en, this message translates to:
  /// **'Informational. Close to return to the request list.'**
  String get driverTripExtrasHint;

  /// No description provided for @driverTripAddonsHint.
  ///
  /// In en, this message translates to:
  /// **'Review preferences and requirements. Close to return to the list.'**
  String get driverTripAddonsHint;

  /// No description provided for @driverTripExtrasClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get driverTripExtrasClose;

  /// No description provided for @driverTripExtraPet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get driverTripExtraPet;

  /// No description provided for @driverTripExtraPetAlert.
  ///
  /// In en, this message translates to:
  /// **'Pet on board.'**
  String get driverTripExtraPetAlert;

  /// No description provided for @driverTripExtraPetDetail.
  ///
  /// In en, this message translates to:
  /// **'The passenger is traveling with a pet.'**
  String get driverTripExtraPetDetail;

  /// No description provided for @driverTripExtraChildSeat.
  ///
  /// In en, this message translates to:
  /// **'Child seat'**
  String get driverTripExtraChildSeat;

  /// No description provided for @driverTripExtraWheelchair.
  ///
  /// In en, this message translates to:
  /// **'Wheelchair'**
  String get driverTripExtraWheelchair;

  /// No description provided for @driverTripExtraWheelchairAlert.
  ///
  /// In en, this message translates to:
  /// **'Passenger with a wheelchair.'**
  String get driverTripExtraWheelchairAlert;

  /// No description provided for @driverTripExtraWheelchairDetail.
  ///
  /// In en, this message translates to:
  /// **'Needs trunk space for a folding wheelchair. Please assist if needed.'**
  String get driverTripExtraWheelchairDetail;

  /// No description provided for @driverTripExtraOver4.
  ///
  /// In en, this message translates to:
  /// **'More than 4 people'**
  String get driverTripExtraOver4;

  /// No description provided for @driverTripExtraLuggageAlert.
  ///
  /// In en, this message translates to:
  /// **'With luggage.'**
  String get driverTripExtraLuggageAlert;

  /// No description provided for @driverTripExtraLuggageDetail.
  ///
  /// In en, this message translates to:
  /// **'The passenger has bags. Keep the trunk empty for luggage.'**
  String get driverTripExtraLuggageDetail;

  /// No description provided for @driverTripExtraAcAlert.
  ///
  /// In en, this message translates to:
  /// **'Air conditioning.'**
  String get driverTripExtraAcAlert;

  /// No description provided for @driverTripExtraAcDetail.
  ///
  /// In en, this message translates to:
  /// **'The passenger asked to travel with A/C.'**
  String get driverTripExtraAcDetail;

  /// No description provided for @driverTripSpecialSeats6Alert.
  ///
  /// In en, this message translates to:
  /// **'Large group (up to 6 passengers)'**
  String get driverTripSpecialSeats6Alert;

  /// No description provided for @driverTripSpecialSeats6Detail.
  ///
  /// In en, this message translates to:
  /// **'Needs a roomy vehicle confirmed for 6 passengers.'**
  String get driverTripSpecialSeats6Detail;

  /// No description provided for @driverTripSpecialRoofRackAlert.
  ///
  /// In en, this message translates to:
  /// **'Roof rack required'**
  String get driverTripSpecialRoofRackAlert;

  /// No description provided for @driverTripSpecialRoofRackDetail.
  ///
  /// In en, this message translates to:
  /// **'The passenger will carry roof cargo. Have straps/bungees ready.'**
  String get driverTripSpecialRoofRackDetail;

  /// No description provided for @driverTripSpecialCargoAlert.
  ///
  /// In en, this message translates to:
  /// **'Cargo / merchandise trip'**
  String get driverTripSpecialCargoAlert;

  /// No description provided for @driverTripSpecialCargoDetail.
  ///
  /// In en, this message translates to:
  /// **'Cargo space occupied. Includes extra time for loading and unloading.'**
  String get driverTripSpecialCargoDetail;

  /// No description provided for @driverRegFieldSixSeats.
  ///
  /// In en, this message translates to:
  /// **'Vehicle with 6 seats'**
  String get driverRegFieldSixSeats;

  /// No description provided for @driverRegHintSixSeats.
  ///
  /// In en, this message translates to:
  /// **'Check if your car can carry up to 6 passengers. Used for large-group trips.'**
  String get driverRegHintSixSeats;

  /// No description provided for @driverTripOfferBadgeOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get driverTripOfferBadgeOperations;

  /// No description provided for @driverTripOfferOperationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assigned from the operations portal'**
  String get driverTripOfferOperationsSubtitle;

  /// No description provided for @driverFcmOpenedTripOfferOperationsHint.
  ///
  /// In en, this message translates to:
  /// **'Operations trip request loaded. Check the list below.'**
  String get driverFcmOpenedTripOfferOperationsHint;

  /// No description provided for @driverOfferErrorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection to server.'**
  String get driverOfferErrorNoConnection;

  /// No description provided for @driverOfferErrorExpired.
  ///
  /// In en, this message translates to:
  /// **'This offer is no longer available.'**
  String get driverOfferErrorExpired;

  /// No description provided for @driverOfferErrorTaken.
  ///
  /// In en, this message translates to:
  /// **'Trip already assigned or cancelled.'**
  String get driverOfferErrorTaken;

  /// No description provided for @driverTripErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not update trip status.'**
  String get driverTripErrorGeneric;

  /// No description provided for @driverTripNavigatePickup.
  ///
  /// In en, this message translates to:
  /// **'Navigate to pickup'**
  String get driverTripNavigatePickup;

  /// No description provided for @driverTripNavigateDestination.
  ///
  /// In en, this message translates to:
  /// **'Navigate to destination'**
  String get driverTripNavigateDestination;

  /// No description provided for @driverRegisteredImagesMenu.
  ///
  /// In en, this message translates to:
  /// **'Registered images'**
  String get driverRegisteredImagesMenu;

  /// No description provided for @driverTripChatOpenCta.
  ///
  /// In en, this message translates to:
  /// **'Secure chat'**
  String get driverTripChatOpenCta;

  /// No description provided for @driverTripChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip chat'**
  String get driverTripChatTitle;

  /// No description provided for @driverTripChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live conversation with the passenger in real time.'**
  String get driverTripChatSubtitle;

  /// No description provided for @driverTripChatOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get driverTripChatOnline;

  /// No description provided for @driverTripChatOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get driverTripChatOffline;

  /// No description provided for @driverTripChatTemplateArrived.
  ///
  /// In en, this message translates to:
  /// **'I arrived at the pickup point'**
  String get driverTripChatTemplateArrived;

  /// No description provided for @driverTripChatTemplateCannotFind.
  ///
  /// In en, this message translates to:
  /// **'I can\'t find you'**
  String get driverTripChatTemplateCannotFind;

  /// No description provided for @driverTripChatTemplateConfirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your location'**
  String get driverTripChatTemplateConfirmLocation;

  /// No description provided for @driverTripChatNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get driverTripChatNow;

  /// No description provided for @driverTripChatErrorStorage.
  ///
  /// In en, this message translates to:
  /// **'Chat unavailable: server configuration is missing. Contact support.'**
  String get driverTripChatErrorStorage;

  /// No description provided for @driverTripChatErrorPhase.
  ///
  /// In en, this message translates to:
  /// **'Chat is only available before the trip starts.'**
  String get driverTripChatErrorPhase;

  /// No description provided for @driverTripChatErrorSendReceive.
  ///
  /// In en, this message translates to:
  /// **'Could not send/receive chat ({code}). Check your connection.'**
  String driverTripChatErrorSendReceive(String code);

  /// No description provided for @driverTripChatEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.\nSend one to start the conversation.'**
  String get driverTripChatEmptyState;

  /// No description provided for @driverTripChatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get driverTripChatMessageHint;

  /// No description provided for @driverTripReactivate.
  ///
  /// In en, this message translates to:
  /// **'Resume receiving rides'**
  String get driverTripReactivate;

  /// No description provided for @driverTripSnackbarNavigationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open navigation ({label})'**
  String driverTripSnackbarNavigationFailed(String label);

  /// No description provided for @driverTripBackgroundPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep service active?'**
  String get driverTripBackgroundPromptTitle;

  /// No description provided for @driverTripBackgroundPromptDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get driverTripBackgroundPromptDisconnect;

  /// No description provided for @driverTripBackgroundPromptKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep active'**
  String get driverTripBackgroundPromptKeep;

  /// No description provided for @driverTripBackgroundPromptBody.
  ///
  /// In en, this message translates to:
  /// **'You were out of the app for more than 15 minutes.\nIf you want to keep receiving requests, confirm now.\n\nAuto disconnect in {seconds}s'**
  String driverTripBackgroundPromptBody(String seconds);

  /// No description provided for @driverHomeBackgroundLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location in the background'**
  String get driverHomeBackgroundLocationTitle;

  /// No description provided for @driverHomeBackgroundLocationBody.
  ///
  /// In en, this message translates to:
  /// **'So passengers can find you while the app is not open, allow \"Always\" (or \"Allow all the time\") location on the next step. It is only used while you are available as a driver. You can change this in system settings at any time.'**
  String get driverHomeBackgroundLocationBody;

  /// No description provided for @driverHomeBackgroundLocationLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get driverHomeBackgroundLocationLater;

  /// No description provided for @driverHomeBackgroundLocationContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get driverHomeBackgroundLocationContinue;

  /// No description provided for @driverForegroundNotifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Texi · Driver mode'**
  String get driverForegroundNotifyTitle;

  /// No description provided for @driverForegroundNotifyBodySearching.
  ///
  /// In en, this message translates to:
  /// **'Waiting for ride requests. GPS stays on for dispatch.'**
  String get driverForegroundNotifyBodySearching;

  /// No description provided for @driverForegroundNotifyBodyTrip.
  ///
  /// In en, this message translates to:
  /// **'On a trip · location shared with passengers.'**
  String get driverForegroundNotifyBodyTrip;

  /// Foreground service body when there are pending trip offers
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 pending request — open Texi to respond} other{{count} pending requests — open Texi}}'**
  String driverForegroundNotifyBodyOffers(num count);

  /// No description provided for @driverNotifyChatTitle.
  ///
  /// In en, this message translates to:
  /// **'New chat message'**
  String get driverNotifyChatTitle;

  /// Local notification body for in-trip chat messages
  ///
  /// In en, this message translates to:
  /// **'{sender}: {message}'**
  String driverNotifyChatBody(String sender, String message);

  /// No description provided for @driverNotifyChatSenderPassenger.
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get driverNotifyChatSenderPassenger;

  /// No description provided for @driverNotifyChatSenderDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverNotifyChatSenderDriver;

  /// No description provided for @driverMapPickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Pickup point'**
  String get driverMapPickupPoint;

  /// No description provided for @driverMapDestinationPoint.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get driverMapDestinationPoint;

  /// No description provided for @driverDirectionsTollOnRoute.
  ///
  /// In en, this message translates to:
  /// **'Toll on route'**
  String get driverDirectionsTollOnRoute;

  /// No description provided for @driverDirectionsTollSnippet.
  ///
  /// In en, this message translates to:
  /// **'Adjust speed and lane in advance.'**
  String get driverDirectionsTollSnippet;

  /// No description provided for @driverDirectionsRelevantIntersection.
  ///
  /// In en, this message translates to:
  /// **'Relevant intersection'**
  String get driverDirectionsRelevantIntersection;

  /// No description provided for @driverTripRatingHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get driverTripRatingHeaderTitle;

  /// No description provided for @driverTripRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate your passenger'**
  String get driverTripRatingTitle;

  /// No description provided for @driverTripRatingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us keep the service great for everyone.'**
  String get driverTripRatingSubtitle;

  /// No description provided for @driverTripRatingSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send rating'**
  String get driverTripRatingSubmit;

  /// No description provided for @driverTripRatingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get driverTripRatingSkip;

  /// No description provided for @driverTripRatingPassengerDefault.
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get driverTripRatingPassengerDefault;

  /// No description provided for @driverTripRatingYourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get driverTripRatingYourRating;

  /// No description provided for @driverTripRatingFeedbackPromptLow.
  ///
  /// In en, this message translates to:
  /// **'What affected the trip? (multiple)'**
  String get driverTripRatingFeedbackPromptLow;

  /// No description provided for @driverTripRatingFeedbackPromptHigh.
  ///
  /// In en, this message translates to:
  /// **'What stood out about the passenger? (multiple)'**
  String get driverTripRatingFeedbackPromptHigh;

  /// No description provided for @driverRatingFallbackDelay.
  ///
  /// In en, this message translates to:
  /// **'Too long waiting'**
  String get driverRatingFallbackDelay;

  /// No description provided for @driverRatingFallbackLocation.
  ///
  /// In en, this message translates to:
  /// **'Hard to find each other'**
  String get driverRatingFallbackLocation;

  /// No description provided for @driverRatingFallbackRespect.
  ///
  /// In en, this message translates to:
  /// **'Lack of respect'**
  String get driverRatingFallbackRespect;

  /// No description provided for @driverRatingFallbackPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment issue'**
  String get driverRatingFallbackPayment;

  /// No description provided for @driverRatingFallbackOther.
  ///
  /// In en, this message translates to:
  /// **'Other issue'**
  String get driverRatingFallbackOther;

  /// No description provided for @driverRatingFallbackPunctual.
  ///
  /// In en, this message translates to:
  /// **'Punctual and ready to go'**
  String get driverRatingFallbackPunctual;

  /// No description provided for @driverRatingFallbackRespectful.
  ///
  /// In en, this message translates to:
  /// **'Respectful attitude'**
  String get driverRatingFallbackRespectful;

  /// No description provided for @driverRatingFallbackClearPickup.
  ///
  /// In en, this message translates to:
  /// **'Clear and quick pickup'**
  String get driverRatingFallbackClearPickup;

  /// No description provided for @driverRatingFallbackRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended passenger'**
  String get driverRatingFallbackRecommended;

  /// No description provided for @driverRatingFallbackExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent experience'**
  String get driverRatingFallbackExcellent;

  /// No description provided for @driverRegImageTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get driverRegImageTakePhoto;

  /// No description provided for @driverRegImageChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get driverRegImageChooseGallery;

  /// No description provided for @driverRegImageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image is too large (max {maxKb} KB). Choose another one or reduce resolution.'**
  String driverRegImageTooLarge(int maxKb);

  /// No description provided for @driverRegImageReadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read image.'**
  String get driverRegImageReadError;

  /// No description provided for @driverRegImageCompatibleCaptureUsed.
  ///
  /// In en, this message translates to:
  /// **'Optimized camera capture was used to reduce file size.'**
  String get driverRegImageCompatibleCaptureUsed;

  /// No description provided for @driverRegImageLongPressLightHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press a slot to retake with optimized capture (lower initial resolution).'**
  String get driverRegImageLongPressLightHint;

  /// No description provided for @driverRegCropSelfieTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust selfie'**
  String get driverRegCropSelfieTitle;

  /// No description provided for @driverRegCropDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust document'**
  String get driverRegCropDocumentTitle;

  /// No description provided for @driverRegCropVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Frame the vehicle'**
  String get driverRegCropVehicleTitle;

  /// No description provided for @driverRegPhotoReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your photo'**
  String get driverRegPhotoReviewTitle;

  /// No description provided for @driverRegPhotoReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can confirm it, take another one, or crop before continuing.'**
  String get driverRegPhotoReviewSubtitle;

  /// No description provided for @driverRegPhotoReviewUse.
  ///
  /// In en, this message translates to:
  /// **'Use this photo'**
  String get driverRegPhotoReviewUse;

  /// No description provided for @driverRegPhotoReviewChange.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get driverRegPhotoReviewChange;

  /// No description provided for @driverRegPhotoReviewEdit.
  ///
  /// In en, this message translates to:
  /// **'Crop or adjust'**
  String get driverRegPhotoReviewEdit;

  /// No description provided for @driverRegPhotoReviewCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get driverRegPhotoReviewCancel;

  /// No description provided for @driverRegStepData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get driverRegStepData;

  /// No description provided for @driverRegStepIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get driverRegStepIdentity;

  /// No description provided for @driverRegStepLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get driverRegStepLicense;

  /// No description provided for @driverRegStepAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get driverRegStepAccess;

  /// No description provided for @driverRegStepVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get driverRegStepVehicle;

  /// No description provided for @driverRegStepPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get driverRegStepPhotos;

  /// No description provided for @driverRegGenderOther.
  ///
  /// In en, this message translates to:
  /// **'Other / prefer not to say'**
  String get driverRegGenderOther;

  /// No description provided for @driverRegTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver registration'**
  String get driverRegTitle;

  /// No description provided for @driverRegStepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String driverRegStepCounter(String current, String total);

  /// No description provided for @driverRegSnackSelectCountryCoverage.
  ///
  /// In en, this message translates to:
  /// **'Select a country with service coverage.'**
  String get driverRegSnackSelectCountryCoverage;

  /// No description provided for @driverRegSnackSelectDepartmentLocality.
  ///
  /// In en, this message translates to:
  /// **'Choose department and locality (province).'**
  String get driverRegSnackSelectDepartmentLocality;

  /// No description provided for @driverRegSnackPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get driverRegSnackPasswordsMismatch;

  /// No description provided for @driverRegSnackIdentityIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Complete number, expiry date, and the three images.'**
  String get driverRegSnackIdentityIncomplete;

  /// No description provided for @driverRegSnackLicenseIncomplete.
  ///
  /// In en, this message translates to:
  /// **'We need category, expiry date, and one photo for each side of the license.'**
  String get driverRegSnackLicenseIncomplete;

  /// No description provided for @driverRegSnackVehicleYearInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a 4-digit year.'**
  String get driverRegSnackVehicleYearInvalid;

  /// No description provided for @driverRegSnackSelectCatalogBrandModel.
  ///
  /// In en, this message translates to:
  /// **'Select make and model from the lists before continuing.'**
  String get driverRegSnackSelectCatalogBrandModel;

  /// No description provided for @driverSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get driverSettingsTitle;

  /// No description provided for @driverRegSnackVehiclePhotosIncomplete.
  ///
  /// In en, this message translates to:
  /// **'We need all four views: front, rear, and both sides of the vehicle.'**
  String get driverRegSnackVehiclePhotosIncomplete;

  /// No description provided for @driverRegDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get driverRegDoneTitle;

  /// No description provided for @driverRegDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks for joining TEXIAPP. Your data and documents were registered and are now under review. We will contact you shortly to continue your registration. Now sign in with your credentials.'**
  String get driverRegDoneBody;

  /// No description provided for @driverRegDoneGoLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in'**
  String get driverRegDoneGoLogin;

  /// No description provided for @driverRegAddVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Register service vehicle'**
  String get driverRegAddVehicleTitle;

  /// No description provided for @driverRegAddVehicleDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registered'**
  String get driverRegAddVehicleDoneTitle;

  /// No description provided for @driverRegAddVehicleDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle details were saved. You can keep using the app as usual.'**
  String get driverRegAddVehicleDoneBody;

  /// No description provided for @driverRegAddVehicleDoneCta.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get driverRegAddVehicleDoneCta;

  /// No description provided for @driverRegResumeDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration complete'**
  String get driverRegResumeDoneTitle;

  /// No description provided for @driverRegResumeDoneBody.
  ///
  /// In en, this message translates to:
  /// **'You’re all set. You can now use the driver service.'**
  String get driverRegResumeDoneBody;

  /// No description provided for @driverRegResumeDoneCta.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get driverRegResumeDoneCta;

  /// No description provided for @driverRegOnboardingDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully!'**
  String get driverRegOnboardingDoneTitle;

  /// No description provided for @driverRegOnboardingDoneBody.
  ///
  /// In en, this message translates to:
  /// **'We\'re already reviewing your details and will contact you very soon. Tap Enter the app to sign in, register your vehicle, or contact support if you need help. You\'re almost there!'**
  String get driverRegOnboardingDoneBody;

  /// No description provided for @driverRegOnboardingDoneCta.
  ///
  /// In en, this message translates to:
  /// **'Enter the app'**
  String get driverRegOnboardingDoneCta;

  /// No description provided for @driverRegRetryLoadCountries.
  ///
  /// In en, this message translates to:
  /// **'Retry loading countries'**
  String get driverRegRetryLoadCountries;

  /// No description provided for @driverRegSectionOperationRegion.
  ///
  /// In en, this message translates to:
  /// **'Operation region'**
  String get driverRegSectionOperationRegion;

  /// No description provided for @driverRegFieldCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get driverRegFieldCountry;

  /// No description provided for @driverRegValidationSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get driverRegValidationSelectCountry;

  /// No description provided for @driverRegFieldDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get driverRegFieldDepartment;

  /// No description provided for @driverRegNoCoverageInCountry.
  ///
  /// In en, this message translates to:
  /// **'No coverage in this country'**
  String get driverRegNoCoverageInCountry;

  /// No description provided for @driverRegValidationSelectDepartment.
  ///
  /// In en, this message translates to:
  /// **'Select department'**
  String get driverRegValidationSelectDepartment;

  /// No description provided for @driverRegFieldLocality.
  ///
  /// In en, this message translates to:
  /// **'Locality (province)'**
  String get driverRegFieldLocality;

  /// No description provided for @driverRegChooseDepartmentFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a department'**
  String get driverRegChooseDepartmentFirst;

  /// No description provided for @driverRegValidationSelectLocality.
  ///
  /// In en, this message translates to:
  /// **'Select locality'**
  String get driverRegValidationSelectLocality;

  /// No description provided for @driverRegSectionPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get driverRegSectionPersonalData;

  /// No description provided for @driverRegFieldFirstName.
  ///
  /// In en, this message translates to:
  /// **'First names'**
  String get driverRegFieldFirstName;

  /// No description provided for @driverRegFieldLastName.
  ///
  /// In en, this message translates to:
  /// **'Last names'**
  String get driverRegFieldLastName;

  /// No description provided for @driverRegFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get driverRegFieldEmail;

  /// No description provided for @driverRegHintOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get driverRegHintOptional;

  /// No description provided for @driverRegEmailHelper.
  ///
  /// In en, this message translates to:
  /// **'Choose the email on this phone or type a different one.'**
  String get driverRegEmailHelper;

  /// No description provided for @driverRegEmailPickFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Use email from this phone'**
  String get driverRegEmailPickFromDevice;

  /// No description provided for @driverRegValidationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get driverRegValidationEmailInvalid;

  /// No description provided for @driverRegValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get driverRegValidationRequired;

  /// No description provided for @driverRegValidationMinAge18.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old to register as a driver.'**
  String get driverRegValidationMinAge18;

  /// No description provided for @driverRegAgeRequirementHint.
  ///
  /// In en, this message translates to:
  /// **'Driver registration and use of the driver app are reserved for persons over 18 years of age.'**
  String get driverRegAgeRequirementHint;

  /// No description provided for @driverRegAgeRequirementFieldHelper.
  ///
  /// In en, this message translates to:
  /// **'18+ only. The calendar only allows valid dates.'**
  String get driverRegAgeRequirementFieldHelper;

  /// No description provided for @driverRegAgeRequirementDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Age of majority required'**
  String get driverRegAgeRequirementDialogTitle;

  /// No description provided for @driverRegAgeRequirementDialogBody.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old to register as a driver. Correct your date of birth to continue.'**
  String get driverRegAgeRequirementDialogBody;

  /// No description provided for @driverRegValidationSelectOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get driverRegValidationSelectOption;

  /// No description provided for @driverRegSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get driverRegSectionContact;

  /// No description provided for @driverRegSectionContactAddress.
  ///
  /// In en, this message translates to:
  /// **'Contact and address'**
  String get driverRegSectionContactAddress;

  /// No description provided for @driverRegFieldPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get driverRegFieldPhoneNumber;

  /// No description provided for @driverRegHintLocalDigitsOnly.
  ///
  /// In en, this message translates to:
  /// **'E.g. 12345678'**
  String get driverRegHintLocalDigitsOnly;

  /// No description provided for @driverRegHintBoliviaLocalPhone.
  ///
  /// In en, this message translates to:
  /// **'E.g. 70000000'**
  String get driverRegHintBoliviaLocalPhone;

  /// No description provided for @driverRegChooseCountryFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose country first'**
  String get driverRegChooseCountryFirst;

  /// No description provided for @driverRegValidationIncompleteNumber.
  ///
  /// In en, this message translates to:
  /// **'Incomplete number'**
  String get driverRegValidationIncompleteNumber;

  /// No description provided for @driverRegValidationBoliviaPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get driverRegValidationBoliviaPhoneInvalid;

  /// No description provided for @driverRegSectionAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get driverRegSectionAddress;

  /// No description provided for @driverRegFieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Home address'**
  String get driverRegFieldAddress;

  /// No description provided for @driverRegHintAddressReference.
  ///
  /// In en, this message translates to:
  /// **'Street, area or reference'**
  String get driverRegHintAddressReference;

  /// No description provided for @driverRegSectionPassword.
  ///
  /// In en, this message translates to:
  /// **'Access password'**
  String get driverRegSectionPassword;

  /// No description provided for @driverRegSectionPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password to sign in to the app.'**
  String get driverRegSectionPasswordHint;

  /// No description provided for @driverRegHintMin8Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get driverRegHintMin8Chars;

  /// No description provided for @driverRegValidationMin8Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get driverRegValidationMin8Chars;

  /// No description provided for @driverRegFieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get driverRegFieldConfirmPassword;

  /// No description provided for @driverRegIntroPersonal.
  ///
  /// In en, this message translates to:
  /// **'Provide real data aligned with your documents.'**
  String get driverRegIntroPersonal;

  /// No description provided for @driverRegIntroIdentity.
  ///
  /// In en, this message translates to:
  /// **'Readable document and profile photo where you can be clearly identified: full face, no cap or dark glasses, no mask, no heavy shadows.'**
  String get driverRegIntroIdentity;

  /// No description provided for @driverRegSectionIdentityDocument.
  ///
  /// In en, this message translates to:
  /// **'Identity document'**
  String get driverRegSectionIdentityDocument;

  /// No description provided for @driverRegSubtitleIdentityDocument.
  ///
  /// In en, this message translates to:
  /// **'Number and expiration according to the document.'**
  String get driverRegSubtitleIdentityDocument;

  /// No description provided for @driverRegFieldDocumentNumber.
  ///
  /// In en, this message translates to:
  /// **'Document number'**
  String get driverRegFieldDocumentNumber;

  /// No description provided for @driverRegFieldDocumentExpiry.
  ///
  /// In en, this message translates to:
  /// **'Document expiration'**
  String get driverRegFieldDocumentExpiry;

  /// No description provided for @driverRegSectionFrontBack.
  ///
  /// In en, this message translates to:
  /// **'Front and back'**
  String get driverRegSectionFrontBack;

  /// No description provided for @driverRegSubtitleOneImagePerSide.
  ///
  /// In en, this message translates to:
  /// **'One image for each side.'**
  String get driverRegSubtitleOneImagePerSide;

  /// No description provided for @driverRegSectionProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get driverRegSectionProfilePhoto;

  /// No description provided for @driverRegSubtitleProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'To validate your identity: uncovered face, no cap, no glasses covering your eyes, good lighting.'**
  String get driverRegSubtitleProfilePhoto;

  /// No description provided for @driverRegIntroLicense.
  ///
  /// In en, this message translates to:
  /// **'Category, expiration, and clear photos of both sides of the license.'**
  String get driverRegIntroLicense;

  /// No description provided for @driverRegSectionCategoryValidity.
  ///
  /// In en, this message translates to:
  /// **'Category and validity'**
  String get driverRegSectionCategoryValidity;

  /// No description provided for @driverRegSubtitleCategoryValidity.
  ///
  /// In en, this message translates to:
  /// **'License category and expiration date (YYYY-MM-DD format).'**
  String get driverRegSubtitleCategoryValidity;

  /// No description provided for @driverRegFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get driverRegFieldCategory;

  /// No description provided for @driverRegHintCategoryExample.
  ///
  /// In en, this message translates to:
  /// **'Ex. B'**
  String get driverRegHintCategoryExample;

  /// No description provided for @driverRegValidationChooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get driverRegValidationChooseCategory;

  /// No description provided for @driverRegFieldExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiration'**
  String get driverRegFieldExpiry;

  /// No description provided for @driverRegHintLicenseExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Date when your license expires'**
  String get driverRegHintLicenseExpiryDate;

  /// No description provided for @driverRegValidationIndicateExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Provide expiration date'**
  String get driverRegValidationIndicateExpiryDate;

  /// No description provided for @driverRegSectionLicenseFrontBack.
  ///
  /// In en, this message translates to:
  /// **'License — front and back'**
  String get driverRegSectionLicenseFrontBack;

  /// No description provided for @driverRegSectionActivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Submit your registration'**
  String get driverRegSectionActivateAccount;

  /// No description provided for @driverRegSubtitleReviewBeforeContinue.
  ///
  /// In en, this message translates to:
  /// **'Review your details and send them for review.'**
  String get driverRegSubtitleReviewBeforeContinue;

  /// No description provided for @driverRegSectionYourSummary.
  ///
  /// In en, this message translates to:
  /// **'Your summary'**
  String get driverRegSectionYourSummary;

  /// No description provided for @driverRegSubtitleProfileWorkZone.
  ///
  /// In en, this message translates to:
  /// **'Profile and work area.'**
  String get driverRegSubtitleProfileWorkZone;

  /// No description provided for @driverRegFieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get driverRegFieldFullName;

  /// No description provided for @driverRegFieldServiceArea.
  ///
  /// In en, this message translates to:
  /// **'Service area'**
  String get driverRegFieldServiceArea;

  /// No description provided for @driverRegIdentityLicenseRegistered.
  ///
  /// In en, this message translates to:
  /// **'Identity and license documents registered.'**
  String get driverRegIdentityLicenseRegistered;

  /// No description provided for @driverRegIntroVehicle.
  ///
  /// In en, this message translates to:
  /// **'Enter the details as on the plate. Then you will upload four photos of the vehicle.'**
  String get driverRegIntroVehicle;

  /// No description provided for @driverRegSectionVehicleData.
  ///
  /// In en, this message translates to:
  /// **'Vehicle data'**
  String get driverRegSectionVehicleData;

  /// Section title: classification from GET /api/v2/vehicles/catalog.
  ///
  /// In en, this message translates to:
  /// **'Vehicle classification'**
  String get driverRegSectionVehicleClassification;

  /// Vehicle type dropdown label (fleet.vehicle_types).
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get driverRegFieldVehicleType;

  /// Category dropdown label (fleet.vehicle_categories).
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get driverRegFieldVehicleCategory;

  /// Heading for multi-select service type chips.
  ///
  /// In en, this message translates to:
  /// **'Enabled services'**
  String get driverRegFieldServiceTypes;

  /// Single service dropdown label in compatibility_mode.
  ///
  /// In en, this message translates to:
  /// **'Service type'**
  String get driverRegFieldServiceType;

  /// Button after catalog load error.
  ///
  /// In en, this message translates to:
  /// **'Retry catalog'**
  String get driverRegCatalogRetry;

  /// No description provided for @driverRegCatalogBrandModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Make and model'**
  String get driverRegCatalogBrandModelTitle;

  /// No description provided for @driverRegCatalogTransportStepTitle.
  ///
  /// In en, this message translates to:
  /// **'1. What will you drive?'**
  String get driverRegCatalogTransportStepTitle;

  /// No description provided for @serviceTypeNameStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get serviceTypeNameStandard;

  /// No description provided for @driverRegCatalogTransportCar.
  ///
  /// In en, this message translates to:
  /// **'Car / utility'**
  String get driverRegCatalogTransportCar;

  /// No description provided for @driverRegCatalogTransportMoto.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get driverRegCatalogTransportMoto;

  /// No description provided for @driverRegCatalogPickBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get driverRegCatalogPickBrand;

  /// No description provided for @driverRegCatalogPickModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get driverRegCatalogPickModel;

  /// No description provided for @driverRegCatalogPickBrandFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a brand first'**
  String get driverRegCatalogPickBrandFirst;

  /// No description provided for @driverRegCatalogCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle details'**
  String get driverRegCatalogCustomTitle;

  /// No description provided for @driverRegCatalogCustomHint.
  ///
  /// In en, this message translates to:
  /// **'It will be sent for review.'**
  String get driverRegCatalogCustomHint;

  /// No description provided for @driverRegCatalogCustomManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get driverRegCatalogCustomManufacturer;

  /// No description provided for @driverRegCatalogCustomModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get driverRegCatalogCustomModel;

  /// No description provided for @driverRegCatalogCustomYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get driverRegCatalogCustomYear;

  /// No description provided for @driverRegCatalogCustomSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get driverRegCatalogCustomSave;

  /// No description provided for @driverRegCatalogCustomSummary.
  ///
  /// In en, this message translates to:
  /// **'For review: {brand} · {model} ({year})'**
  String driverRegCatalogCustomSummary(String brand, String model, String year);

  /// No description provided for @driverRegSnackCatalogCustomRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter brand, model, and year for the Other option.'**
  String get driverRegSnackCatalogCustomRequired;

  /// No description provided for @driverRegCatalogTechnicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Technical catalogs (reference)'**
  String get driverRegCatalogTechnicalTitle;

  /// No description provided for @driverRegCatalogEmissionNorms.
  ///
  /// In en, this message translates to:
  /// **'Emission standards'**
  String get driverRegCatalogEmissionNorms;

  /// No description provided for @driverRegCatalogAxles.
  ///
  /// In en, this message translates to:
  /// **'Axle configurations'**
  String get driverRegCatalogAxles;

  /// No description provided for @driverRegCatalogBodyTypes.
  ///
  /// In en, this message translates to:
  /// **'Body types'**
  String get driverRegCatalogBodyTypes;

  /// No description provided for @driverRegCatalogUnits.
  ///
  /// In en, this message translates to:
  /// **'Measurement units'**
  String get driverRegCatalogUnits;

  /// Button when catalog not loaded yet.
  ///
  /// In en, this message translates to:
  /// **'Load catalog'**
  String get driverRegCatalogLoad;

  /// Info if type has no categories from API.
  ///
  /// In en, this message translates to:
  /// **'This type has no categories in the catalog. Try another type or contact support.'**
  String get driverRegVehicleTypeNoCategories;

  /// Info if category has no service_type_ids.
  ///
  /// In en, this message translates to:
  /// **'This category has no linked services in the catalog.'**
  String get driverRegCategoryNoServices;

  /// Prefix if name missing from service_types list.
  ///
  /// In en, this message translates to:
  /// **'Service '**
  String get driverRegServiceTypeFallbackPrefix;

  /// SnackBar when continuing before catalog ready.
  ///
  /// In en, this message translates to:
  /// **'Wait for the vehicle catalog to load or tap retry.'**
  String get driverRegSnackVehicleCatalogNotReady;

  /// Empty state when compatibility_mode has no rows.
  ///
  /// In en, this message translates to:
  /// **'No service types available. Try again later or contact support.'**
  String get driverRegCatalogNoServiceTypes;

  /// No description provided for @driverRegErrorVehicleServiceBridgeMissing.
  ///
  /// In en, this message translates to:
  /// **'We could not sync driver services in this environment. Please try again in a few seconds.'**
  String get driverRegErrorVehicleServiceBridgeMissing;

  /// No description provided for @driverRegErrorMissingUserId.
  ///
  /// In en, this message translates to:
  /// **'Driver identifier is missing. Return to the beginning of registration.'**
  String get driverRegErrorMissingUserId;

  /// No description provided for @driverRegErrorVehicleCatalogLoading.
  ///
  /// In en, this message translates to:
  /// **'Wait for the vehicle catalog to load, then try again.'**
  String get driverRegErrorVehicleCatalogLoading;

  /// No description provided for @driverRegErrorVehicleCatalogIncomplete.
  ///
  /// In en, this message translates to:
  /// **'The server catalog does not include vehicle type or category. Contact support.'**
  String get driverRegErrorVehicleCatalogIncomplete;

  /// No description provided for @driverRegErrorVehicleTypeCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Complete vehicle type and category.'**
  String get driverRegErrorVehicleTypeCategoryRequired;

  /// No description provided for @driverRegErrorVehicleCategoryInvalid.
  ///
  /// In en, this message translates to:
  /// **'The selected category is invalid. Choose another one.'**
  String get driverRegErrorVehicleCategoryInvalid;

  /// No description provided for @driverRegErrorVehicleNoServicesConfigured.
  ///
  /// In en, this message translates to:
  /// **'No services are configured for this category. Choose another one or contact support.'**
  String get driverRegErrorVehicleNoServicesConfigured;

  /// No description provided for @driverRegErrorVehicleServiceNotAllowedForCategory.
  ///
  /// In en, this message translates to:
  /// **'A selected service does not apply to this category.'**
  String get driverRegErrorVehicleServiceNotAllowedForCategory;

  /// No description provided for @driverRegErrorVehicleServiceCodeMissing.
  ///
  /// In en, this message translates to:
  /// **'The catalog is missing a service code for the current selection. Retry or update the app.'**
  String get driverRegErrorVehicleServiceCodeMissing;

  /// No description provided for @driverRegErrorSessionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Session unavailable. Please sign in again.'**
  String get driverRegErrorSessionUnavailable;

  /// No description provided for @driverRegErrorSecureStorage.
  ///
  /// In en, this message translates to:
  /// **'Could not read local data on this device. Close the app and try again. If it persists, clear the app data in Settings.'**
  String get driverRegErrorSecureStorage;

  /// No description provided for @driverRegCatalogCompatEmptyUsesDefault.
  ///
  /// In en, this message translates to:
  /// **'The server returned an empty service list. You can continue: the default service type will be used. To fix the list, check public.service_types in the database or tap retry.'**
  String get driverRegCatalogCompatEmptyUsesDefault;

  /// Notice when catalog_source=fallback on GET /api/v2/vehicles/catalog.
  ///
  /// In en, this message translates to:
  /// **'Fallback catalog: technical lists may not match production. This notice disappears when the database is fully seeded.'**
  String get driverRegCatalogFallbackBanner;

  /// No description provided for @driverRegFieldBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get driverRegFieldBrand;

  /// No description provided for @driverRegHintBrandExample.
  ///
  /// In en, this message translates to:
  /// **'Ex. Toyota'**
  String get driverRegHintBrandExample;

  /// No description provided for @driverRegFieldModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get driverRegFieldModel;

  /// No description provided for @driverRegHintModelExample.
  ///
  /// In en, this message translates to:
  /// **'Ex. Corolla'**
  String get driverRegHintModelExample;

  /// No description provided for @driverRegFieldYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get driverRegFieldYear;

  /// No description provided for @driverRegFieldColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get driverRegFieldColor;

  /// No description provided for @driverRegHintTypeOrPickColor.
  ///
  /// In en, this message translates to:
  /// **'Type or pick below'**
  String get driverRegHintTypeOrPickColor;

  /// No description provided for @driverRegSectionPlateVin.
  ///
  /// In en, this message translates to:
  /// **'Plate and chassis number (VIN)'**
  String get driverRegSectionPlateVin;

  /// No description provided for @driverRegSubtitlePlateUppercase.
  ///
  /// In en, this message translates to:
  /// **'Plate is saved in uppercase.'**
  String get driverRegSubtitlePlateUppercase;

  /// No description provided for @driverRegFieldPlate.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get driverRegFieldPlate;

  /// No description provided for @driverRegHintPlateExample.
  ///
  /// In en, this message translates to:
  /// **'Ex. ABC1231'**
  String get driverRegHintPlateExample;

  /// No description provided for @driverRegHelperUppercaseSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved in UPPERCASE'**
  String get driverRegHelperUppercaseSaved;

  /// No description provided for @driverRegFieldVinChassis.
  ///
  /// In en, this message translates to:
  /// **'VIN / chassis'**
  String get driverRegFieldVinChassis;

  /// No description provided for @driverRegHintVin17Chars.
  ///
  /// In en, this message translates to:
  /// **'17 alphanumeric characters'**
  String get driverRegHintVin17Chars;

  /// No description provided for @driverRegHelperVehicleDocumentReference.
  ///
  /// In en, this message translates to:
  /// **'As shown in vehicle card or document'**
  String get driverRegHelperVehicleDocumentReference;

  /// No description provided for @driverRegSectionInsuranceOwnership.
  ///
  /// In en, this message translates to:
  /// **'Insurance and ownership'**
  String get driverRegSectionInsuranceOwnership;

  /// No description provided for @driverRegSubtitleInsuranceOwnership.
  ///
  /// In en, this message translates to:
  /// **'Policy number and ownership title details or equivalent document.'**
  String get driverRegSubtitleInsuranceOwnership;

  /// No description provided for @driverRegFieldInsurancePolicyNumber.
  ///
  /// In en, this message translates to:
  /// **'Insurance policy number'**
  String get driverRegFieldInsurancePolicyNumber;

  /// No description provided for @driverRegHintAsPolicy.
  ///
  /// In en, this message translates to:
  /// **'As shown on active policy'**
  String get driverRegHintAsPolicy;

  /// No description provided for @driverRegFieldTitleDocData.
  ///
  /// In en, this message translates to:
  /// **'Ownership title / document details'**
  String get driverRegFieldTitleDocData;

  /// No description provided for @driverRegHintReferenceFromDocument.
  ///
  /// In en, this message translates to:
  /// **'Reference from your document'**
  String get driverRegHintReferenceFromDocument;

  /// No description provided for @driverRegIntroVehiclePhotos.
  ///
  /// In en, this message translates to:
  /// **'One photo for each side of the car: front, rear, left side and right side. Good lighting and full vehicle in frame.'**
  String get driverRegIntroVehiclePhotos;

  /// No description provided for @driverRegSectionVehicleViews.
  ///
  /// In en, this message translates to:
  /// **'Vehicle views'**
  String get driverRegSectionVehicleViews;

  /// No description provided for @driverRegSubtitleVehicleViews.
  ///
  /// In en, this message translates to:
  /// **'Tap each card to take or change photo; you\'ll see a preview once uploaded.'**
  String get driverRegSubtitleVehicleViews;

  /// No description provided for @driverRegPhotoFrontTitle.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get driverRegPhotoFrontTitle;

  /// No description provided for @driverRegPhotoFrontHint.
  ///
  /// In en, this message translates to:
  /// **'Frame the front; show the plate when possible.'**
  String get driverRegPhotoFrontHint;

  /// No description provided for @driverRegPhotoRearTitle.
  ///
  /// In en, this message translates to:
  /// **'Rear'**
  String get driverRegPhotoRearTitle;

  /// No description provided for @driverRegPhotoRearHint.
  ///
  /// In en, this message translates to:
  /// **'Entire rear side of the vehicle.'**
  String get driverRegPhotoRearHint;

  /// No description provided for @driverRegPhotoLeftTitle.
  ///
  /// In en, this message translates to:
  /// **'Left side'**
  String get driverRegPhotoLeftTitle;

  /// No description provided for @driverRegPhotoLeftHint.
  ///
  /// In en, this message translates to:
  /// **'Side view, full left side.'**
  String get driverRegPhotoLeftHint;

  /// No description provided for @driverRegPhotoRightTitle.
  ///
  /// In en, this message translates to:
  /// **'Right side'**
  String get driverRegPhotoRightTitle;

  /// No description provided for @driverRegPhotoRightHint.
  ///
  /// In en, this message translates to:
  /// **'Side view, full right side.'**
  String get driverRegPhotoRightHint;

  /// No description provided for @driverRegActionActivate.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get driverRegActionActivate;

  /// No description provided for @driverRegActionFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get driverRegActionFinish;

  /// No description provided for @driverRegActionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get driverRegActionContinue;

  /// No description provided for @driverRegActionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get driverRegActionBack;

  /// No description provided for @driverRegActionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get driverRegActionSave;

  /// No description provided for @driverRegCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel registration'**
  String get driverRegCancelTitle;

  /// No description provided for @driverRegCancelBodyUser.
  ///
  /// In en, this message translates to:
  /// **'For security, data entered so far will not be kept and this registration progress will be removed. You can start again whenever you want.'**
  String get driverRegCancelBodyUser;

  /// No description provided for @driverRegCancelBodyVehicle.
  ///
  /// In en, this message translates to:
  /// **'For security, the vehicle you are registering will not be saved. Your account and other vehicles stay unchanged.'**
  String get driverRegCancelBodyVehicle;

  /// No description provided for @driverRegCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get driverRegCancelConfirm;

  /// No description provided for @driverRegCancelKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get driverRegCancelKeepGoing;

  /// No description provided for @driverRegTitleProfileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Complete registration'**
  String get driverRegTitleProfileCompletion;

  /// No description provided for @driverRegProfileStepSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved.'**
  String get driverRegProfileStepSaved;

  /// No description provided for @driverRegProfileRedirectSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Based on your registration status, we opened «{stepTo}» instead of «{stepFrom}».'**
  String driverRegProfileRedirectSnackbar(String stepFrom, String stepTo);

  /// No description provided for @driverRegImageReady.
  ///
  /// In en, this message translates to:
  /// **'Image ready'**
  String get driverRegImageReady;

  /// No description provided for @driverRegTapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload'**
  String get driverRegTapToUpload;

  /// No description provided for @driverRegDocFrontTitle.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get driverRegDocFrontTitle;

  /// No description provided for @driverRegDocFrontHint.
  ///
  /// In en, this message translates to:
  /// **'Photo and main data.'**
  String get driverRegDocFrontHint;

  /// No description provided for @driverRegDocBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get driverRegDocBackTitle;

  /// No description provided for @driverRegDocBackHint.
  ///
  /// In en, this message translates to:
  /// **'Code, signature, or additional data.'**
  String get driverRegDocBackHint;

  /// No description provided for @driverRegLicenseFrontTitle.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get driverRegLicenseFrontTitle;

  /// No description provided for @driverRegLicenseFrontHint.
  ///
  /// In en, this message translates to:
  /// **'Photo and categories.'**
  String get driverRegLicenseFrontHint;

  /// No description provided for @driverRegLicenseBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get driverRegLicenseBackTitle;

  /// No description provided for @driverRegLicenseBackHint.
  ///
  /// In en, this message translates to:
  /// **'Restrictions or notes.'**
  String get driverRegLicenseBackHint;

  /// No description provided for @driverRegProfilePhotoReadyHint.
  ///
  /// In en, this message translates to:
  /// **'Photo ready. Tap the circle to change it.'**
  String get driverRegProfilePhotoReadyHint;

  /// No description provided for @driverRegProfilePhotoGuideHint.
  ///
  /// In en, this message translates to:
  /// **'Make sure your face is centered and well lit.'**
  String get driverRegProfilePhotoGuideHint;

  /// No description provided for @driverRegTapCardToReplacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap the card to replace this photo.'**
  String get driverRegTapCardToReplacePhoto;

  /// No description provided for @driverRegChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get driverRegChangePhoto;

  /// No description provided for @driverRegTakeOrChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take or choose photo'**
  String get driverRegTakeOrChoosePhoto;

  /// No description provided for @driverRegColorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get driverRegColorBlack;

  /// No description provided for @driverRegColorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get driverRegColorWhite;

  /// No description provided for @driverRegColorGray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get driverRegColorGray;

  /// No description provided for @driverRegColorSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get driverRegColorSilver;

  /// No description provided for @driverRegColorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get driverRegColorRed;

  /// No description provided for @driverRegColorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get driverRegColorBlue;

  /// No description provided for @driverRegColorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get driverRegColorGreen;

  /// No description provided for @driverRegColorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get driverRegColorYellow;

  /// No description provided for @driverRegColorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get driverRegColorOrange;

  /// No description provided for @driverRegColorViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get driverRegColorViolet;

  /// No description provided for @driverRegColorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get driverRegColorBrown;

  /// No description provided for @driverRegColorBeige.
  ///
  /// In en, this message translates to:
  /// **'Beige'**
  String get driverRegColorBeige;

  /// No description provided for @driverRegColorGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get driverRegColorGold;

  /// No description provided for @driverLegalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal & privacy'**
  String get driverLegalSectionTitle;

  /// No description provided for @driverLegalSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the documents that apply to your account and manage your data.'**
  String get driverLegalSectionSubtitle;

  /// No description provided for @driverLegalPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get driverLegalPrivacyPolicy;

  /// No description provided for @driverLegalTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get driverLegalTermsOfService;

  /// No description provided for @driverLegalDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get driverLegalDeleteAccountTitle;

  /// No description provided for @driverLegalDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Your account will enter a scheduled deletion period for {graceDays} days. After you confirm, your session will close and you cannot use the app. To recover it, sign in with your credentials and cancel the request before the deadline.'**
  String driverLegalDeleteAccountBody(int graceDays);

  /// No description provided for @driverLegalDeleteAccountAction.
  ///
  /// In en, this message translates to:
  /// **'How to request'**
  String get driverLegalDeleteAccountAction;

  /// No description provided for @driverLegalDeleteAccountConfirmSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule deletion'**
  String get driverLegalDeleteAccountConfirmSchedule;

  /// No description provided for @driverLegalDeleteAccountScheduling.
  ///
  /// In en, this message translates to:
  /// **'Scheduling deletion…'**
  String get driverLegalDeleteAccountScheduling;

  /// No description provided for @driverLegalDeleteAccountScheduledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deletion scheduled. Your session was closed; sign in to recover your account before the deadline.'**
  String get driverLegalDeleteAccountScheduledSuccess;

  /// No description provided for @driverLoginAccountDeletionPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Deletion scheduled'**
  String get driverLoginAccountDeletionPendingTitle;

  /// No description provided for @driverLoginAccountDeletionPendingBody.
  ///
  /// In en, this message translates to:
  /// **'This account is scheduled for deletion on {effectiveDate}. You cannot use the app until you recover it.'**
  String driverLoginAccountDeletionPendingBody(String effectiveDate);

  /// No description provided for @driverLoginAccountDeletionPendingDateFallback.
  ///
  /// In en, this message translates to:
  /// **'the scheduled date'**
  String get driverLoginAccountDeletionPendingDateFallback;

  /// No description provided for @driverLoginAccountDeletionRecover.
  ///
  /// In en, this message translates to:
  /// **'Recover account'**
  String get driverLoginAccountDeletionRecover;

  /// No description provided for @driverLoginAccountDeletionDismiss.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get driverLoginAccountDeletionDismiss;

  /// No description provided for @driverLoginAccountDeletionRecovering.
  ///
  /// In en, this message translates to:
  /// **'Recovering account…'**
  String get driverLoginAccountDeletionRecovering;

  /// No description provided for @driverLoginAccountDeletionRecoverSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account recovered. Welcome back.'**
  String get driverLoginAccountDeletionRecoverSuccess;

  /// No description provided for @driverLegalDeleteAccountPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Deletion scheduled'**
  String get driverLegalDeleteAccountPendingTitle;

  /// No description provided for @driverLegalDeleteAccountPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your account will be deleted on {effectiveDate}. You have {daysRemaining} days left to cancel and restore access.'**
  String driverLegalDeleteAccountPendingBody(
    String effectiveDate,
    int daysRemaining,
  );

  /// No description provided for @driverLegalDeleteAccountPendingDateFallback.
  ///
  /// In en, this message translates to:
  /// **'the scheduled date'**
  String get driverLegalDeleteAccountPendingDateFallback;

  /// No description provided for @driverLegalDeleteAccountCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel deletion'**
  String get driverLegalDeleteAccountCancelAction;

  /// No description provided for @driverLegalDeleteAccountCancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling deletion…'**
  String get driverLegalDeleteAccountCancelling;

  /// No description provided for @driverLegalDeleteAccountCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deletion cancelled. Your account is still active.'**
  String get driverLegalDeleteAccountCancelSuccess;

  /// No description provided for @driverPlayNotificationDisclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip notifications'**
  String get driverPlayNotificationDisclosureTitle;

  /// No description provided for @driverPlayNotificationDisclosureBody.
  ///
  /// In en, this message translates to:
  /// **'TEXIAPP needs to send you notifications when trip requests arrive, trip status changes, or the passenger sends a message while you are online as a driver.'**
  String get driverPlayNotificationDisclosureBody;

  /// No description provided for @driverPlayLocationDisclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'Location to receive trips'**
  String get driverPlayLocationDisclosureTitle;

  /// No description provided for @driverPlayLocationDisclosureBody.
  ///
  /// In en, this message translates to:
  /// **'TEXIAPP uses your location to show you on the map, match nearby trip requests, and share your position with the passenger during an active trip.'**
  String get driverPlayLocationDisclosureBody;

  /// No description provided for @driverPlayDisclosureContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get driverPlayDisclosureContinue;

  /// No description provided for @driverLegalLoginHint.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our usage policies and terms of service.'**
  String get driverLegalLoginHint;

  /// No description provided for @driverLegalLoginPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get driverLegalLoginPrefix;

  /// No description provided for @driverLegalLoginConjunction.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get driverLegalLoginConjunction;

  /// No description provided for @driverLegalActivatePrefix.
  ///
  /// In en, this message translates to:
  /// **'By submitting you accept our '**
  String get driverLegalActivatePrefix;

  /// No description provided for @driverLegalUsagePolicies.
  ///
  /// In en, this message translates to:
  /// **'usage policies'**
  String get driverLegalUsagePolicies;

  /// No description provided for @driverLegalRegistrationHint.
  ///
  /// In en, this message translates to:
  /// **'By activating you accept our usage policies.'**
  String get driverLegalRegistrationHint;

  /// No description provided for @driverPlayCameraDisclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access'**
  String get driverPlayCameraDisclosureTitle;

  /// No description provided for @driverPlayCameraDisclosureBody.
  ///
  /// In en, this message translates to:
  /// **'TEXIAPP uses the camera to capture identity documents, your license, and vehicle photos during registration. Images are sent securely for verification.'**
  String get driverPlayCameraDisclosureBody;

  /// No description provided for @driverPlayGalleryDisclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo library access'**
  String get driverPlayGalleryDisclosureTitle;

  /// No description provided for @driverPlayGalleryDisclosureBody.
  ///
  /// In en, this message translates to:
  /// **'TEXIAPP accesses photos you choose from your library for driver registration. Only the image you select is uploaded.'**
  String get driverPlayGalleryDisclosureBody;

  /// No description provided for @driverAppUpdateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get driverAppUpdateRequiredTitle;

  /// No description provided for @driverAppUpdateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of Texi Driver is available. Update the app to continue.'**
  String get driverAppUpdateRequiredMessage;

  /// No description provided for @driverAppUpdateOptionalTitle.
  ///
  /// In en, this message translates to:
  /// **'New version available'**
  String get driverAppUpdateOptionalTitle;

  /// No description provided for @driverAppUpdateOptionalMessage.
  ///
  /// In en, this message translates to:
  /// **'An update is available on the Play Store. We recommend installing it for the best experience.'**
  String get driverAppUpdateOptionalMessage;

  /// No description provided for @driverAppUpdateOpenStore.
  ///
  /// In en, this message translates to:
  /// **'Go to Play Store'**
  String get driverAppUpdateOpenStore;

  /// No description provided for @driverAppUpdateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get driverAppUpdateLater;

  /// No description provided for @driverPasswordResetForgotLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get driverPasswordResetForgotLink;

  /// No description provided for @driverPasswordResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get driverPasswordResetTitle;

  /// No description provided for @driverPasswordResetLead.
  ///
  /// In en, this message translates to:
  /// **'Confirm your number. The fastest option is to send the TEXIAPP WhatsApp verification message. Or we can email you a code.'**
  String get driverPasswordResetLead;

  /// No description provided for @driverPasswordResetWhatsAppCta.
  ///
  /// In en, this message translates to:
  /// **'Verify with WhatsApp'**
  String get driverPasswordResetWhatsAppCta;

  /// No description provided for @driverPasswordResetEmailCta.
  ///
  /// In en, this message translates to:
  /// **'Send code to email'**
  String get driverPasswordResetEmailCta;

  /// No description provided for @driverPasswordResetWaTitle.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp verification'**
  String get driverPasswordResetWaTitle;

  /// No description provided for @driverPasswordResetWaBody.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp and send the prescribed message. When we receive it, return to TEXIAPP to create your new password.'**
  String get driverPasswordResetWaBody;

  /// No description provided for @driverPasswordResetWaWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the WhatsApp message…'**
  String get driverPasswordResetWaWaiting;

  /// No description provided for @driverPasswordResetEmailMissingBody.
  ///
  /// In en, this message translates to:
  /// **'We did not find an email on your account. Enter one to receive the code. We will save it when you reset the password.'**
  String get driverPasswordResetEmailMissingBody;

  /// No description provided for @driverPasswordResetEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get driverPasswordResetEmailLabel;

  /// No description provided for @driverPasswordResetSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get driverPasswordResetSendCode;

  /// No description provided for @driverPasswordResetEmailCodeBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent to {email} and create your new password.'**
  String driverPasswordResetEmailCodeBody(String email);

  /// No description provided for @driverPasswordResetEmailFallback.
  ///
  /// In en, this message translates to:
  /// **'your email'**
  String get driverPasswordResetEmailFallback;

  /// No description provided for @driverPasswordResetCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get driverPasswordResetCodeLabel;

  /// No description provided for @driverPasswordResetNewPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Number confirmed. Create a new password (at least 8 characters).'**
  String get driverPasswordResetNewPasswordBody;

  /// No description provided for @driverPasswordResetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get driverPasswordResetNewPassword;

  /// No description provided for @driverPasswordResetConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get driverPasswordResetConfirmPassword;

  /// No description provided for @driverPasswordResetSave.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get driverPasswordResetSave;

  /// No description provided for @driverPasswordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Sign in with your new password.'**
  String get driverPasswordResetSuccess;

  /// No description provided for @driverPasswordResetErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'There is no driver account with that number.'**
  String get driverPasswordResetErrorNotFound;

  /// No description provided for @driverPasswordResetErrorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an email to receive the code.'**
  String get driverPasswordResetErrorEmailRequired;

  /// No description provided for @driverPasswordResetErrorOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Incorrect or expired code.'**
  String get driverPasswordResetErrorOtpInvalid;

  /// No description provided for @driverPasswordResetErrorNotVerified.
  ///
  /// In en, this message translates to:
  /// **'We have not confirmed the WhatsApp message yet. Send it and try again.'**
  String get driverPasswordResetErrorNotVerified;

  /// No description provided for @driverPasswordResetErrorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a few minutes.'**
  String get driverPasswordResetErrorRateLimit;

  /// No description provided for @driverPasswordResetErrorWaUnavailable.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is unavailable right now. Try email.'**
  String get driverPasswordResetErrorWaUnavailable;

  /// No description provided for @driverPasswordResetErrorEmailConflict.
  ///
  /// In en, this message translates to:
  /// **'That email is already used by another account.'**
  String get driverPasswordResetErrorEmailConflict;

  /// No description provided for @driverPasswordResetErrorMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get driverPasswordResetErrorMismatch;

  /// No description provided for @driverPasswordResetErrorExpired.
  ///
  /// In en, this message translates to:
  /// **'The WhatsApp message expired. Try again.'**
  String get driverPasswordResetErrorExpired;

  /// No description provided for @driverChangePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your password'**
  String get driverChangePasswordTitle;

  /// No description provided for @driverChangePasswordLead.
  ///
  /// In en, this message translates to:
  /// **'Support gave you a temporary password to sign in. For security, create your own password now. This screen only appears after a support reset, not when you recover the password from the app.'**
  String get driverChangePasswordLead;

  /// No description provided for @driverChangePasswordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Temporary password'**
  String get driverChangePasswordCurrent;

  /// No description provided for @driverChangePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get driverChangePasswordNew;

  /// No description provided for @driverChangePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get driverChangePasswordConfirm;

  /// No description provided for @driverChangePasswordSave.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get driverChangePasswordSave;

  /// No description provided for @driverChangePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get driverChangePasswordSuccess;

  /// No description provided for @driverChangePasswordLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get driverChangePasswordLogout;

  /// No description provided for @driverChangePasswordErrorCurrent.
  ///
  /// In en, this message translates to:
  /// **'The temporary password is incorrect.'**
  String get driverChangePasswordErrorCurrent;

  /// No description provided for @driverChangePasswordErrorSame.
  ///
  /// In en, this message translates to:
  /// **'The new password must be different from the temporary one.'**
  String get driverChangePasswordErrorSame;

  /// No description provided for @driverChangePasswordErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not update the password.'**
  String get driverChangePasswordErrorGeneric;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
