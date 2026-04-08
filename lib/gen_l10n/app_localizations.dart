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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Texi'**
  String get appName;

  /// No description provided for @driverAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Texi Driver'**
  String get driverAppTitle;

  /// No description provided for @splashGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get splashGettingLocation;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your number to continue'**
  String get loginSubtitle;

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

  /// No description provided for @loginContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get loginContinue;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Check your number.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get loginPhoneRequired;

  /// No description provided for @homeRequestRide.
  ///
  /// In en, this message translates to:
  /// **'Request ride'**
  String get homeRequestRide;

  /// No description provided for @homeNearbyDrivers.
  ///
  /// In en, this message translates to:
  /// **'{count} nearby driver'**
  String homeNearbyDrivers(int count);

  /// No description provided for @homeNearbyDriversNone.
  ///
  /// In en, this message translates to:
  /// **'No nearby drivers at the moment'**
  String get homeNearbyDriversNone;

  /// No description provided for @homeUpdatesEvery.
  ///
  /// In en, this message translates to:
  /// **'Updates every {seconds} seconds'**
  String homeUpdatesEvery(int seconds);

  /// No description provided for @homeLocationError.
  ///
  /// In en, this message translates to:
  /// **'Enable location to see the map and nearby drivers.'**
  String get homeLocationError;

  /// No description provided for @homeLocationErrorGps.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location. Check GPS.'**
  String get homeLocationErrorGps;

  /// No description provided for @homeRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get homeRetry;

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

  /// No description provided for @tripYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your current location'**
  String get tripYourLocation;

  /// No description provided for @tripWherePickup.
  ///
  /// In en, this message translates to:
  /// **'Where should we pick you up?'**
  String get tripWherePickup;

  /// No description provided for @tripUseMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get tripUseMyLocation;

  /// No description provided for @tripSearchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search address'**
  String get tripSearchAddress;

  /// No description provided for @tripChooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get tripChooseOnMap;

  /// No description provided for @tripUseAsPickup.
  ///
  /// In en, this message translates to:
  /// **'Use as pickup point'**
  String get tripUseAsPickup;

  /// No description provided for @tripUseAsDestination.
  ///
  /// In en, this message translates to:
  /// **'Use as destination'**
  String get tripUseAsDestination;

  /// No description provided for @tripMoveMapSetPickup.
  ///
  /// In en, this message translates to:
  /// **'Move the map and tap the button to set where you\'ll be picked up.'**
  String get tripMoveMapSetPickup;

  /// No description provided for @tripMoveMapSetDestination.
  ///
  /// In en, this message translates to:
  /// **'Move the map and tap the button to set the destination.'**
  String get tripMoveMapSetDestination;

  /// No description provided for @tripTapMapDestination.
  ///
  /// In en, this message translates to:
  /// **'Tap the map or choose an option below'**
  String get tripTapMapDestination;

  /// No description provided for @tripSeePrices.
  ///
  /// In en, this message translates to:
  /// **'See prices'**
  String get tripSeePrices;

  /// No description provided for @tripSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search address...'**
  String get tripSearchPlaceholder;

  /// No description provided for @tripUseMapCenter.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get tripUseMapCenter;

  /// No description provided for @tripWhereTo.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get tripWhereTo;

  /// No description provided for @tripSearchError.
  ///
  /// In en, this message translates to:
  /// **'Address not found'**
  String get tripSearchError;

  /// No description provided for @tripSearchingAddress.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get tripSearchingAddress;

  /// No description provided for @tripNoCoverageInZone.
  ///
  /// In en, this message translates to:
  /// **'We don\'t have service coverage in this area at the moment. Try another location or move to a service zone.'**
  String get tripNoCoverageInZone;

  /// No description provided for @tripNoDriversAvailable.
  ///
  /// In en, this message translates to:
  /// **'No drivers available at the moment. Please try again in a few moments.'**
  String get tripNoDriversAvailable;

  /// No description provided for @tripNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tripNext;

  /// No description provided for @quoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your ride'**
  String get quoteTitle;

  /// No description provided for @quoteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a service type'**
  String get quoteSubtitle;

  /// No description provided for @quotePerTrip.
  ///
  /// In en, this message translates to:
  /// **'per trip'**
  String get quotePerTrip;

  /// No description provided for @quoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get quoteConfirm;

  /// No description provided for @confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your ride'**
  String get confirmTitle;

  /// No description provided for @confirmFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get confirmFrom;

  /// No description provided for @confirmTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get confirmTo;

  /// No description provided for @confirmRequestRide.
  ///
  /// In en, this message translates to:
  /// **'Request ride'**
  String get confirmRequestRide;

  /// No description provided for @searchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Looking for a driver'**
  String get searchingTitle;

  /// No description provided for @searchingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are finding the best option for you'**
  String get searchingSubtitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

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
  /// **'Sign in with your number and password to start receiving rides.'**
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

  /// No description provided for @driverLoginRegisterHint.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have credentials? You can register as a driver.'**
  String get driverLoginRegisterHint;

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
  /// **'Create your account in minutes and start receiving trips with Texi.'**
  String get driverLoginRegisterBannerSubtitle;

  /// No description provided for @driverHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverHomeTitle;

  /// No description provided for @driverHomeOnlineTitle.
  ///
  /// In en, this message translates to:
  /// **'You are online'**
  String get driverHomeOnlineTitle;

  /// No description provided for @driverHomeOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get driverHomeOfflineTitle;

  /// No description provided for @driverHomeOnlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby passengers will see your vehicle and you can receive ride requests.'**
  String get driverHomeOnlineSubtitle;

  /// No description provided for @driverHomeOfflineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn the switch on to start receiving rides.'**
  String get driverHomeOfflineSubtitle;

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

  /// No description provided for @driverFcmOpenedTripOfferHint.
  ///
  /// In en, this message translates to:
  /// **'You opened a trip request alert. If you don\'t see the offer, go online; offers arrive over the live connection.'**
  String get driverFcmOpenedTripOfferHint;

  /// No description provided for @driverHomeMiniVehicleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Vehicle not registered yet'**
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

  /// No description provided for @driverHomeMenuAddVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add another vehicle'**
  String get driverHomeMenuAddVehicle;

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

  /// No description provided for @driverProfileFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get driverProfileFieldName;

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

  /// No description provided for @driverTripOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'New ride request'**
  String get driverTripOfferTitle;

  /// No description provided for @driverTripOfferPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated price: {amount}'**
  String driverTripOfferPrice(String amount);

  /// No description provided for @driverTripOfferEta.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival: {minutes} min'**
  String driverTripOfferEta(int minutes);

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

  /// No description provided for @driverTripOfferPickupEta.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min to pickup'**
  String driverTripOfferPickupEta(String minutes);

  /// No description provided for @driverTripOfferRouteEta.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min to destination'**
  String driverTripOfferRouteEta(String minutes);

  /// No description provided for @driverTripOfferRouteKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} trip'**
  String driverTripOfferRouteKm(String distance);

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

  /// No description provided for @driverOfferErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not update the request.'**
  String get driverOfferErrorGeneric;

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

  /// No description provided for @driverTripNavAssistedTitle.
  ///
  /// In en, this message translates to:
  /// **'Assisted navigation'**
  String get driverTripNavAssistedTitle;

  /// No description provided for @driverTripNavAssistedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Opens your maps or GPS app (Maps, Waze…)'**
  String get driverTripNavAssistedSubtitle;

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

  /// No description provided for @driverMapDriverPosition.
  ///
  /// In en, this message translates to:
  /// **'Your position'**
  String get driverMapDriverPosition;

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

  /// No description provided for @driverMapCalculatingRoute.
  ///
  /// In en, this message translates to:
  /// **'Calculating route...'**
  String get driverMapCalculatingRoute;

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

  /// No description provided for @driverTripRatingSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip summary'**
  String get driverTripRatingSummaryLabel;

  /// No description provided for @driverTripRatingPassengerDefault.
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get driverTripRatingPassengerDefault;

  /// No description provided for @driverTripRatingOriginDefault.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get driverTripRatingOriginDefault;

  /// No description provided for @driverTripRatingDestinationDefault.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get driverTripRatingDestinationDefault;

  /// No description provided for @driverTripRatingDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String driverTripRatingDistanceKm(String distance);

  /// No description provided for @driverTripRatingEtaMinutes.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String driverTripRatingEtaMinutes(String minutes);

  /// No description provided for @driverTripRatingPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get driverTripRatingPriceLabel;

  /// No description provided for @driverTripRatingYourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get driverTripRatingYourRating;

  /// No description provided for @driverTripRatingRouteHint.
  ///
  /// In en, this message translates to:
  /// **'{origin} → {destination}'**
  String driverTripRatingRouteHint(String origin, String destination);

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
  /// **'Invalid vehicle year.'**
  String get driverRegSnackVehicleYearInvalid;

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
  /// **'Thanks for joining Texi. Your data and documents were registered and are now under review. We will activate your service soon so you can start taking trips. Now sign in with your credentials.'**
  String get driverRegDoneBody;

  /// No description provided for @driverRegDoneGoLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in'**
  String get driverRegDoneGoLogin;

  /// No description provided for @driverRegAddVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
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

  /// No description provided for @driverRegValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get driverRegValidationRequired;

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

  /// No description provided for @driverRegFieldPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get driverRegFieldPhoneNumber;

  /// No description provided for @driverRegHintLocalDigitsOnly.
  ///
  /// In en, this message translates to:
  /// **'Local digits only'**
  String get driverRegHintLocalDigitsOnly;

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
  /// **'Activate your account'**
  String get driverRegSectionActivateAccount;

  /// No description provided for @driverRegSubtitleReviewBeforeContinue.
  ///
  /// In en, this message translates to:
  /// **'Review your data before continuing.'**
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
  /// **'Complete the data exactly as shown on your policy and plate; then upload photos of all four sides.'**
  String get driverRegIntroVehicle;

  /// No description provided for @driverRegSectionVehicleData.
  ///
  /// In en, this message translates to:
  /// **'Vehicle data'**
  String get driverRegSectionVehicleData;

  /// No description provided for @driverRegSubtitleVehicleData.
  ///
  /// In en, this message translates to:
  /// **'Brand, model, year and color (as in document or policy).'**
  String get driverRegSubtitleVehicleData;

  /// Section title: classification from GET /api/v2/vehicles/catalog.
  ///
  /// In en, this message translates to:
  /// **'Vehicle classification'**
  String get driverRegSectionVehicleClassification;

  /// Subtitle clarifying server catalog dependency.
  ///
  /// In en, this message translates to:
  /// **'Type, category and allowed services from the catalog (required by the server).'**
  String get driverRegSubtitleVehicleClassification;

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
  /// **'Brand & model (catalog)'**
  String get driverRegCatalogBrandModelTitle;

  /// No description provided for @driverRegCatalogTransportStepTitle.
  ///
  /// In en, this message translates to:
  /// **'1. What will you drive?'**
  String get driverRegCatalogTransportStepTitle;

  /// No description provided for @driverRegCatalogModelLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Brand and model (from catalog)'**
  String get driverRegCatalogModelLockedTitle;

  /// No description provided for @driverRegCatalogModelLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Taken from your selection above. Change brand or model in the catalog section if needed.'**
  String get driverRegCatalogModelLockedHint;

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

  /// No description provided for @driverRegCatalogSourceFallback.
  ///
  /// In en, this message translates to:
  /// **'Offline fallback data (run DB migrations for the full server catalog).'**
  String get driverRegCatalogSourceFallback;

  /// No description provided for @driverRegCatalogSourceDatabase.
  ///
  /// In en, this message translates to:
  /// **'Catalog from database'**
  String get driverRegCatalogSourceDatabase;

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
  /// **'Activate'**
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
