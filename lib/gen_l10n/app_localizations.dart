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

  /// No description provided for @driverLoginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in'**
  String get driverLoginErrorGeneric;

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

  /// No description provided for @driverOnlineErrorNoToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid session. Please sign in again.'**
  String get driverOnlineErrorNoToken;

  /// No description provided for @driverOnlineErrorSocket.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Please try again.'**
  String get driverOnlineErrorSocket;

  /// No description provided for @driverOnlineErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Could not go online. Please try again.'**
  String get driverOnlineErrorUnknown;

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
