// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Texi';

  @override
  String get driverAppTitle => 'Texi Driver';

  @override
  String get splashGettingLocation => 'Getting your location...';

  @override
  String get loginWelcome => 'Welcome';

  @override
  String get loginSubtitle => 'Enter your number to continue';

  @override
  String get loginCode => 'Code';

  @override
  String get loginPhone => 'Phone';

  @override
  String get loginContinue => 'Continue';

  @override
  String get loginErrorInvalidCredentials =>
      'Could not sign in. Check your number.';

  @override
  String get loginPhoneRequired => 'Enter your phone number';

  @override
  String get homeRequestRide => 'Request ride';

  @override
  String homeNearbyDrivers(int count) {
    return '$count nearby driver';
  }

  @override
  String get homeNearbyDriversNone => 'No nearby drivers at the moment';

  @override
  String homeUpdatesEvery(int seconds) {
    return 'Updates every $seconds seconds';
  }

  @override
  String get homeLocationError =>
      'Enable location to see the map and nearby drivers.';

  @override
  String get homeLocationErrorGps => 'Could not get your location. Check GPS.';

  @override
  String get homeRetry => 'Retry';

  @override
  String get tripOrigin => 'Origin';

  @override
  String get tripDestination => 'Destination';

  @override
  String get tripYourLocation => 'Your current location';

  @override
  String get tripWherePickup => 'Where should we pick you up?';

  @override
  String get tripUseMyLocation => 'Use my current location';

  @override
  String get tripSearchAddress => 'Search address';

  @override
  String get tripChooseOnMap => 'Choose on map';

  @override
  String get tripUseAsPickup => 'Use as pickup point';

  @override
  String get tripUseAsDestination => 'Use as destination';

  @override
  String get tripMoveMapSetPickup =>
      'Move the map and tap the button to set where you\'ll be picked up.';

  @override
  String get tripMoveMapSetDestination =>
      'Move the map and tap the button to set the destination.';

  @override
  String get tripTapMapDestination => 'Tap the map or choose an option below';

  @override
  String get tripSeePrices => 'See prices';

  @override
  String get tripSearchPlaceholder => 'Search address...';

  @override
  String get tripUseMapCenter => 'Use this location';

  @override
  String get tripWhereTo => 'Where to?';

  @override
  String get tripSearchError => 'Address not found';

  @override
  String get tripSearchingAddress => 'Searching...';

  @override
  String get tripNoCoverageInZone =>
      'We don\'t have service coverage in this area at the moment. Try another location or move to a service zone.';

  @override
  String get tripNoDriversAvailable =>
      'No drivers available at the moment. Please try again in a few moments.';

  @override
  String get tripNext => 'Next';

  @override
  String get quoteTitle => 'Choose your ride';

  @override
  String get quoteSubtitle => 'Select a service type';

  @override
  String get quotePerTrip => 'per trip';

  @override
  String get quoteConfirm => 'Confirm';

  @override
  String get confirmTitle => 'Confirm your ride';

  @override
  String get confirmFrom => 'From';

  @override
  String get confirmTo => 'To';

  @override
  String get confirmRequestRide => 'Request ride';

  @override
  String get searchingTitle => 'Looking for a driver';

  @override
  String get searchingSubtitle => 'We are finding the best option for you';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get driverLoginWelcome => 'Welcome, driver';

  @override
  String get driverLoginSubtitle =>
      'Sign in with your number and password to start receiving rides.';

  @override
  String get driverLoginPassword => 'Password';

  @override
  String get driverLoginButton => 'Sign in';

  @override
  String get driverLoginPhoneAndPasswordRequired =>
      'Enter your number and password';

  @override
  String get driverLoginErrorGeneric => 'Could not sign in';

  @override
  String get driverLoginRegisterHint =>
      'Don\'t have credentials? You can register as a driver.';

  @override
  String get driverLoginRegisterCta => 'Register';

  @override
  String get driverHomeTitle => 'Driver';

  @override
  String get driverHomeOnlineTitle => 'You are online';

  @override
  String get driverHomeOfflineTitle => 'You are offline';

  @override
  String get driverHomeOnlineSubtitle =>
      'Nearby passengers will see your vehicle and you can receive ride requests.';

  @override
  String get driverHomeOfflineSubtitle =>
      'Turn the switch on to start receiving rides.';

  @override
  String get driverHomeRequestsTitle => 'Ride requests';

  @override
  String get driverHomeRequestsEmpty =>
      'You will see passenger requests here\nwhen you are online.';

  @override
  String get driverHomeMiniStatusOnline => 'Online';

  @override
  String get driverHomeMiniStatusOffline => 'Offline';

  @override
  String get driverHomeMiniConnecting => 'Connecting…';

  @override
  String get driverHomeMiniVehicleEmpty => 'Vehicle not registered yet';

  @override
  String driverHomeMiniRating(String rating) {
    return '$rating ★';
  }

  @override
  String get driverLogout => 'Sign out';

  @override
  String get driverOnlineAuthTitle => 'Confirm your identity';

  @override
  String get driverOnlineAuthSubtitle =>
      'Next, you\'ll use your fingerprint, Face ID, or device PIN. This keeps your account safe when you go online.';

  @override
  String get driverOnlineAuthContinue => 'Continue';

  @override
  String get driverOnlineAuthCancel => 'Cancel';

  @override
  String get driverOnlineAuthReasonBiometric =>
      'Confirm your identity to go online as a driver';

  @override
  String get driverOnlineAuthReasonDeviceCredential =>
      'Confirm with your PIN or pattern to go online';

  @override
  String get driverOnlineAuthVerifyFailed => 'Could not verify device identity';

  @override
  String get driverProfileMenu => 'My profile';

  @override
  String get driverProfileTitle => 'My profile';

  @override
  String get driverProfileBack => 'Back to home';

  @override
  String get driverProfileRefreshTooltip => 'Refresh';

  @override
  String get driverProfileRetry => 'Try again';

  @override
  String get driverProfileErrorNoSession =>
      'Session unavailable. Please sign in again.';

  @override
  String get driverProfileErrorEmpty => 'Empty server response.';

  @override
  String get driverProfileErrorBadFormat => 'Could not read profile data.';

  @override
  String get driverProfileRoleSubtitle => 'TEXI driver';

  @override
  String get driverProfileBadgeActive => 'Active profile';

  @override
  String get driverProfileBadgeSecure => 'Secure account';

  @override
  String get driverProfileVerificationTitle => 'Account status: Under review';

  @override
  String get driverProfileVerificationBody =>
      'Your documents were received successfully. Our team is validating them so we can enable your service as soon as possible.';

  @override
  String get driverProfileSectionPersonal => 'Personal information';

  @override
  String get driverProfileSectionContact => 'Contact';

  @override
  String get driverProfileSectionLocation => 'Location';

  @override
  String get driverProfileReadOnlyFooter =>
      'These details are read-only for now. Editing from the app will be available soon.';

  @override
  String get driverProfileFieldName => 'Name';

  @override
  String get driverProfileFieldBirthDate => 'Date of birth';

  @override
  String get driverProfileFieldGender => 'Gender';

  @override
  String get driverProfileFieldPhone => 'Phone';

  @override
  String get driverProfileFieldEmail => 'Email';

  @override
  String get driverProfileFieldAddress => 'Address';

  @override
  String get driverProfileFieldLocality => 'City / locality';

  @override
  String get driverProfileGenderMale => 'Male';

  @override
  String get driverProfileGenderFemale => 'Female';

  @override
  String get driverProfileGenderOther => 'Other';

  @override
  String get driverProfileValueEmpty => '—';

  @override
  String get driverProfileDefaultName => 'TEXI driver';

  @override
  String get driverOnlineErrorNoInternet =>
      'No internet connection. Connect to go online.';

  @override
  String get driverOnlineErrorNoGps =>
      'Enable location permissions to share your position.';

  @override
  String get driverOnlineErrorNoToken =>
      'Invalid session. Please sign in again.';

  @override
  String get driverOnlineErrorSocket =>
      'Could not connect to the server. Please try again.';

  @override
  String get driverOnlineErrorUnknown =>
      'Could not go online. Please try again.';

  @override
  String get driverTripInProgressTitle => 'Trip in progress';

  @override
  String get driverTripStatusAccepted => 'Go to pickup';

  @override
  String get driverTripStatusArrived => 'At pickup point';

  @override
  String get driverTripStatusStarted => 'On the way';

  @override
  String get driverTripStatusCompleted => 'Trip completed';

  @override
  String get driverTripStatusCancelled => 'Trip cancelled';

  @override
  String get driverTripStatusInProgress => 'Trip in progress';

  @override
  String driverTripEstimatedPrice(String amount) {
    return 'Estimated price: $amount';
  }

  @override
  String get driverTripArrivedButton => 'I arrived at pickup';

  @override
  String get driverTripStartButton => 'Start trip';

  @override
  String get driverTripCompleteButton => 'Finish trip';

  @override
  String get driverTripOfferTitle => 'New ride request';

  @override
  String driverTripOfferPrice(String amount) {
    return 'Estimated price: $amount';
  }

  @override
  String driverTripOfferEta(int minutes) {
    return 'Estimated arrival: $minutes min';
  }

  @override
  String get driverTripReject => 'Reject';

  @override
  String get driverTripAccept => 'Accept';

  @override
  String get driverTripOfferPriceTbd => 'To be agreed';

  @override
  String get driverTripOfferBadgeNew => 'New';

  @override
  String driverTripOfferPickupEta(String minutes) {
    return '~$minutes min to pickup';
  }

  @override
  String driverTripOfferRouteEta(String minutes) {
    return '~$minutes min to destination';
  }

  @override
  String driverTripOfferRouteKm(String distance) {
    return '$distance trip';
  }

  @override
  String get driverOfferErrorNoConnection => 'No connection to server.';

  @override
  String get driverOfferErrorExpired => 'This offer is no longer available.';

  @override
  String get driverOfferErrorTaken => 'Trip already assigned or cancelled.';

  @override
  String get driverOfferErrorGeneric => 'Could not update the request.';

  @override
  String get driverTripNavigatePickup => 'Navigate to pickup';

  @override
  String get driverTripNavigateDestination => 'Navigate to destination';

  @override
  String get driverTripReactivate => 'Resume receiving rides';

  @override
  String driverTripSnackbarNavigationFailed(String label) {
    return 'Could not open navigation ($label)';
  }

  @override
  String get driverTripBackgroundPromptTitle => 'Keep service active?';

  @override
  String get driverTripBackgroundPromptDisconnect => 'Disconnect';

  @override
  String get driverTripBackgroundPromptKeep => 'Keep active';

  @override
  String driverTripBackgroundPromptBody(String seconds) {
    return 'You were out of the app for more than 15 minutes.\nIf you want to keep receiving requests, confirm now.\n\nAuto disconnect in ${seconds}s';
  }

  @override
  String get driverHomeBackgroundLocationTitle => 'Location in the background';

  @override
  String get driverHomeBackgroundLocationBody =>
      'So passengers can find you while the app is not open, allow \"Always\" (or \"Allow all the time\") location on the next step. It is only used while you are available as a driver. You can change this in system settings at any time.';

  @override
  String get driverHomeBackgroundLocationLater => 'Not now';

  @override
  String get driverHomeBackgroundLocationContinue => 'Continue';

  @override
  String get driverMapDriverPosition => 'Your position';

  @override
  String get driverMapPickupPoint => 'Pickup point';

  @override
  String get driverMapDestinationPoint => 'Destination';

  @override
  String get driverMapCalculatingRoute => 'Calculating route...';

  @override
  String get driverTripRatingHeaderTitle => 'Trip completed';

  @override
  String get driverTripRatingTitle => 'Rate your passenger';

  @override
  String get driverTripRatingSubtitle =>
      'Your feedback helps us keep the service great for everyone.';

  @override
  String get driverTripRatingSubmit => 'Send rating';

  @override
  String get driverTripRatingSkip => 'Skip for now';

  @override
  String get driverTripRatingSummaryLabel => 'Trip summary';

  @override
  String get driverTripRatingPassengerDefault => 'Passenger';

  @override
  String get driverTripRatingOriginDefault => 'Pickup';

  @override
  String get driverTripRatingDestinationDefault => 'Destination';

  @override
  String driverTripRatingDistanceKm(String distance) {
    return '$distance km';
  }

  @override
  String driverTripRatingEtaMinutes(String minutes) {
    return '~$minutes min';
  }

  @override
  String get driverTripRatingPriceLabel => 'Fare';

  @override
  String get driverTripRatingYourRating => 'Your rating';

  @override
  String driverTripRatingRouteHint(String origin, String destination) {
    return '$origin → $destination';
  }

  @override
  String get driverRegImageTakePhoto => 'Take photo';

  @override
  String get driverRegImageChooseGallery => 'Choose from gallery';

  @override
  String driverRegImageTooLarge(int maxKb) {
    return 'Image is too large (max $maxKb KB). Choose another one or reduce resolution.';
  }

  @override
  String get driverRegImageReadError => 'Could not read image.';

  @override
  String get driverRegStepData => 'Data';

  @override
  String get driverRegStepIdentity => 'Identity';

  @override
  String get driverRegStepLicense => 'License';

  @override
  String get driverRegStepAccess => 'Access';

  @override
  String get driverRegStepVehicle => 'Vehicle';

  @override
  String get driverRegStepPhotos => 'Photos';

  @override
  String get driverRegGenderOther => 'Other / prefer not to say';

  @override
  String get driverRegTitle => 'Driver registration';

  @override
  String driverRegStepCounter(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get driverRegSnackSelectCountryCoverage =>
      'Select a country with service coverage.';

  @override
  String get driverRegSnackSelectDepartmentLocality =>
      'Choose department and locality (province).';

  @override
  String get driverRegSnackPasswordsMismatch => 'Passwords do not match.';

  @override
  String get driverRegSnackIdentityIncomplete =>
      'Complete number, expiry date, and the three images.';

  @override
  String get driverRegSnackLicenseIncomplete =>
      'We need category, expiry date, and one photo for each side of the license.';

  @override
  String get driverRegSnackVehicleYearInvalid => 'Invalid vehicle year.';

  @override
  String get driverRegSnackVehiclePhotosIncomplete =>
      'We need all four views: front, rear, and both sides of the vehicle.';

  @override
  String get driverRegDoneTitle => 'Done!';

  @override
  String get driverRegDoneBody =>
      'Thanks for joining Texi. Your data and documents were registered and are now under review. We will activate your service soon so you can start taking trips. Now sign in with your credentials.';

  @override
  String get driverRegDoneGoLogin => 'Go to sign in';
}
