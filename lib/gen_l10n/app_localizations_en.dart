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
  String get driverLoginCountryCodeHint => '+591';

  @override
  String get driverLoginPhoneHint => '7 123 4567';

  @override
  String get driverLoginErrorGeneric => 'Could not sign in';

  @override
  String get driverLoginErrorNetwork =>
      'Could not connect. Check your internet and try again.';

  @override
  String get driverLoginErrorConnection =>
      'No connection to the server. Check your network.';

  @override
  String get driverLoginErrorInvalidResponse =>
      'Invalid server response. Please try again.';

  @override
  String get driverLoginErrorTokenMissing =>
      'Session token was not received. Please try again.';

  @override
  String get driverLoginErrorUnexpected =>
      'Unexpected sign-in error. Please try again.';

  @override
  String get driverLoginRegisterHint =>
      'Don\'t have credentials? You can register as a driver.';

  @override
  String get driverLoginRegisterCta => 'Register';

  @override
  String get driverLoginRegisterBannerTitle => 'New driver?';

  @override
  String get driverLoginRegisterBannerSubtitle =>
      'Create your account in minutes and start receiving trips with Texi.';

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
  String get driverHomeMiniStatusRestoringConnection => 'Restoring connection…';

  @override
  String get driverHomeVehicleRegistrationBanner =>
      'You still need to register your vehicle. Without a vehicle you cannot receive trips.';

  @override
  String get driverHomeVehicleRegistrationCta =>
      'Complete vehicle registration';

  @override
  String get driverHomeCannotGoOnlineWithoutVehicle =>
      'Register your vehicle before going online to receive trips.';

  @override
  String get driverFcmOpenedTripOfferHint =>
      'You opened a trip request alert. If you don\'t see the offer, go online; offers arrive over the live connection.';

  @override
  String get driverHomeMiniVehicleEmpty => 'Vehicle not registered yet';

  @override
  String driverHomeMiniRating(String rating) {
    return '$rating ★';
  }

  @override
  String get driverLogout => 'Sign out';

  @override
  String get driverHomeMenuAddVehicle => 'Add another vehicle';

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
  String get driverOnlineErrorGpsServiceOff =>
      'Turn on device location services to go online and receive trip offers.';

  @override
  String get driverOnlineErrorNoNotifications =>
      'Enable notifications for this app. Without them you may miss trip offers when the app is in the background.';

  @override
  String get driverOnlineErrorNoToken =>
      'Invalid session. Please sign in again.';

  @override
  String get driverOnlineErrorSessionExpiredReLogin =>
      'Your session expired or is no longer valid. Please sign in again.';

  @override
  String get driverOnlineErrorSocket =>
      'Could not connect to the server. Please try again.';

  @override
  String get driverOnlineErrorVehicleRequired =>
      'You need a registered vehicle to connect. Complete vehicle registration or use “Add another vehicle” in the menu.';

  @override
  String get driverOnlineErrorUnknown =>
      'Could not go online. Please try again.';

  @override
  String get driverOnlineErrorActiveTripCantGoOffline =>
      'You can’t go offline while you have an active trip or a rating pending. Finish or cancel the trip first.';

  @override
  String get driverOnlineErrorReconnecting => 'Connection lost. Reconnecting…';

  @override
  String get driverOnlineErrorRbacForbidden =>
      'Your account doesn’t have permission for this action. If it keeps happening, sign out and sign back in or contact support.';

  @override
  String get driverOnlineErrorRbacSession =>
      'We couldn’t validate your session to go online. Sign out and sign in again.';

  @override
  String get driverOnlineErrorRbacTechnical =>
      'We couldn’t verify permissions. Please try again in a few seconds.';

  @override
  String get driverHomeOnlineRequirementsHint =>
      'Only needed to receive trips: the server must see you online, with location on, and be able to notify you. Other screens (like your profile) don’t need this.';

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
  String get driverTripErrorGeneric => 'Could not update trip status.';

  @override
  String get driverTripNavigatePickup => 'Navigate to pickup';

  @override
  String get driverTripNavigateDestination => 'Navigate to destination';

  @override
  String get driverTripNavAssistedTitle => 'Assisted navigation';

  @override
  String get driverTripNavAssistedSubtitle =>
      'Opens your maps or GPS app (Maps, Waze…)';

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

  @override
  String get driverRegAddVehicleTitle => 'Add vehicle';

  @override
  String get driverRegAddVehicleDoneTitle => 'Vehicle registered';

  @override
  String get driverRegAddVehicleDoneBody =>
      'Your vehicle details were saved. You can keep using the app as usual.';

  @override
  String get driverRegAddVehicleDoneCta => 'Back to home';

  @override
  String get driverRegResumeDoneTitle => 'Registration complete';

  @override
  String get driverRegResumeDoneBody =>
      'You’re all set. You can now use the driver service.';

  @override
  String get driverRegResumeDoneCta => 'Go to home';

  @override
  String get driverRegRetryLoadCountries => 'Retry loading countries';

  @override
  String get driverRegSectionOperationRegion => 'Operation region';

  @override
  String get driverRegFieldCountry => 'Country';

  @override
  String get driverRegValidationSelectCountry => 'Select country';

  @override
  String get driverRegFieldDepartment => 'Department';

  @override
  String get driverRegNoCoverageInCountry => 'No coverage in this country';

  @override
  String get driverRegValidationSelectDepartment => 'Select department';

  @override
  String get driverRegFieldLocality => 'Locality (province)';

  @override
  String get driverRegChooseDepartmentFirst => 'Choose a department';

  @override
  String get driverRegValidationSelectLocality => 'Select locality';

  @override
  String get driverRegSectionPersonalData => 'Personal data';

  @override
  String get driverRegFieldFirstName => 'First names';

  @override
  String get driverRegFieldLastName => 'Last names';

  @override
  String get driverRegFieldEmail => 'Email';

  @override
  String get driverRegHintOptional => 'Optional';

  @override
  String get driverRegValidationRequired => 'Required';

  @override
  String get driverRegValidationSelectOption => 'Select an option';

  @override
  String get driverRegSectionContact => 'Contact';

  @override
  String get driverRegFieldPhoneNumber => 'Phone number';

  @override
  String get driverRegHintLocalDigitsOnly => 'Local digits only';

  @override
  String get driverRegChooseCountryFirst => 'Choose country first';

  @override
  String get driverRegValidationIncompleteNumber => 'Incomplete number';

  @override
  String get driverRegSectionAddress => 'Address';

  @override
  String get driverRegFieldAddress => 'Home address';

  @override
  String get driverRegHintAddressReference => 'Street, area or reference';

  @override
  String get driverRegSectionPassword => 'Access password';

  @override
  String get driverRegHintMin8Chars => 'At least 8 characters';

  @override
  String get driverRegValidationMin8Chars => 'At least 8 characters';

  @override
  String get driverRegFieldConfirmPassword => 'Confirm password';

  @override
  String get driverRegIntroPersonal =>
      'Provide real data aligned with your documents.';

  @override
  String get driverRegIntroIdentity =>
      'Readable document and profile photo where you can be clearly identified: full face, no cap or dark glasses, no mask, no heavy shadows.';

  @override
  String get driverRegSectionIdentityDocument => 'Identity document';

  @override
  String get driverRegSubtitleIdentityDocument =>
      'Number and expiration according to the document.';

  @override
  String get driverRegFieldDocumentNumber => 'Document number';

  @override
  String get driverRegFieldDocumentExpiry => 'Document expiration';

  @override
  String get driverRegSectionFrontBack => 'Front and back';

  @override
  String get driverRegSubtitleOneImagePerSide => 'One image for each side.';

  @override
  String get driverRegSectionProfilePhoto => 'Profile photo';

  @override
  String get driverRegSubtitleProfilePhoto =>
      'To validate your identity: uncovered face, no cap, no glasses covering your eyes, good lighting.';

  @override
  String get driverRegIntroLicense =>
      'Category, expiration, and clear photos of both sides of the license.';

  @override
  String get driverRegSectionCategoryValidity => 'Category and validity';

  @override
  String get driverRegSubtitleCategoryValidity =>
      'License category and expiration date (YYYY-MM-DD format).';

  @override
  String get driverRegFieldCategory => 'Category';

  @override
  String get driverRegHintCategoryExample => 'Ex. B';

  @override
  String get driverRegValidationChooseCategory => 'Choose a category';

  @override
  String get driverRegFieldExpiry => 'Expiration';

  @override
  String get driverRegHintLicenseExpiryDate => 'Date when your license expires';

  @override
  String get driverRegValidationIndicateExpiryDate => 'Provide expiration date';

  @override
  String get driverRegSectionLicenseFrontBack => 'License — front and back';

  @override
  String get driverRegSectionActivateAccount => 'Activate your account';

  @override
  String get driverRegSubtitleReviewBeforeContinue =>
      'Review your data before continuing.';

  @override
  String get driverRegSectionYourSummary => 'Your summary';

  @override
  String get driverRegSubtitleProfileWorkZone => 'Profile and work area.';

  @override
  String get driverRegFieldFullName => 'Full name';

  @override
  String get driverRegFieldServiceArea => 'Service area';

  @override
  String get driverRegIdentityLicenseRegistered =>
      'Identity and license documents registered.';

  @override
  String get driverRegIntroVehicle =>
      'Complete the data exactly as shown on your policy and plate; then upload photos of all four sides.';

  @override
  String get driverRegSectionVehicleData => 'Vehicle data';

  @override
  String get driverRegSubtitleVehicleData =>
      'Brand, model, year and color (as in document or policy).';

  @override
  String get driverRegSectionVehicleClassification => 'Vehicle classification';

  @override
  String get driverRegSubtitleVehicleClassification =>
      'Type, category and allowed services from the catalog (required by the server).';

  @override
  String get driverRegFieldVehicleType => 'Vehicle type';

  @override
  String get driverRegFieldVehicleCategory => 'Category';

  @override
  String get driverRegFieldServiceTypes => 'Enabled services';

  @override
  String get driverRegFieldServiceType => 'Service type';

  @override
  String get driverRegCatalogRetry => 'Retry catalog';

  @override
  String get driverRegCatalogBrandModelTitle => 'Brand & model (catalog)';

  @override
  String get driverRegCatalogTransportStepTitle => '1. What will you drive?';

  @override
  String get driverRegCatalogModelLockedTitle =>
      'Brand and model (from catalog)';

  @override
  String get driverRegCatalogModelLockedHint =>
      'Taken from your selection above. Change brand or model in the catalog section if needed.';

  @override
  String get serviceTypeNameStandard => 'Standard';

  @override
  String get driverRegCatalogTransportCar => 'Car / utility';

  @override
  String get driverRegCatalogTransportMoto => 'Motorcycle';

  @override
  String get driverRegCatalogPickBrand => 'Brand';

  @override
  String get driverRegCatalogPickModel => 'Model';

  @override
  String get driverRegCatalogPickBrandFirst => 'Choose a brand first';

  @override
  String get driverRegCatalogTechnicalTitle => 'Technical catalogs (reference)';

  @override
  String get driverRegCatalogEmissionNorms => 'Emission standards';

  @override
  String get driverRegCatalogAxles => 'Axle configurations';

  @override
  String get driverRegCatalogBodyTypes => 'Body types';

  @override
  String get driverRegCatalogUnits => 'Measurement units';

  @override
  String get driverRegCatalogSourceFallback =>
      'Offline fallback data (run DB migrations for the full server catalog).';

  @override
  String get driverRegCatalogSourceDatabase => 'Catalog from database';

  @override
  String get driverRegCatalogLoad => 'Load catalog';

  @override
  String get driverRegVehicleTypeNoCategories =>
      'This type has no categories in the catalog. Try another type or contact support.';

  @override
  String get driverRegCategoryNoServices =>
      'This category has no linked services in the catalog.';

  @override
  String get driverRegServiceTypeFallbackPrefix => 'Service ';

  @override
  String get driverRegSnackVehicleCatalogNotReady =>
      'Wait for the vehicle catalog to load or tap retry.';

  @override
  String get driverRegCatalogNoServiceTypes =>
      'No service types available. Try again later or contact support.';

  @override
  String get driverRegErrorVehicleServiceBridgeMissing =>
      'We could not sync driver services in this environment. Please try again in a few seconds.';

  @override
  String get driverRegErrorMissingUserId =>
      'Driver identifier is missing. Return to the beginning of registration.';

  @override
  String get driverRegErrorVehicleCatalogLoading =>
      'Wait for the vehicle catalog to load, then try again.';

  @override
  String get driverRegErrorVehicleCatalogIncomplete =>
      'The server catalog does not include vehicle type or category. Contact support.';

  @override
  String get driverRegErrorVehicleTypeCategoryRequired =>
      'Complete vehicle type and category.';

  @override
  String get driverRegErrorVehicleCategoryInvalid =>
      'The selected category is invalid. Choose another one.';

  @override
  String get driverRegErrorVehicleNoServicesConfigured =>
      'No services are configured for this category. Choose another one or contact support.';

  @override
  String get driverRegErrorVehicleServiceNotAllowedForCategory =>
      'A selected service does not apply to this category.';

  @override
  String get driverRegErrorVehicleServiceCodeMissing =>
      'The catalog is missing a service code for the current selection. Retry or update the app.';

  @override
  String get driverRegErrorSessionUnavailable =>
      'Session unavailable. Please sign in again.';

  @override
  String get driverRegCatalogCompatEmptyUsesDefault =>
      'The server returned an empty service list. You can continue: the default service type will be used. To fix the list, check public.service_types in the database or tap retry.';

  @override
  String get driverRegCatalogFallbackBanner =>
      'Fallback catalog: technical lists may not match production. This notice disappears when the database is fully seeded.';

  @override
  String get driverRegFieldBrand => 'Brand';

  @override
  String get driverRegHintBrandExample => 'Ex. Toyota';

  @override
  String get driverRegFieldModel => 'Model';

  @override
  String get driverRegHintModelExample => 'Ex. Corolla';

  @override
  String get driverRegFieldYear => 'Year';

  @override
  String get driverRegFieldColor => 'Color';

  @override
  String get driverRegHintTypeOrPickColor => 'Type or pick below';

  @override
  String get driverRegSectionPlateVin => 'Plate and chassis number (VIN)';

  @override
  String get driverRegSubtitlePlateUppercase => 'Plate is saved in uppercase.';

  @override
  String get driverRegFieldPlate => 'Plate';

  @override
  String get driverRegHintPlateExample => 'Ex. ABC1231';

  @override
  String get driverRegHelperUppercaseSaved => 'Saved in UPPERCASE';

  @override
  String get driverRegFieldVinChassis => 'VIN / chassis';

  @override
  String get driverRegHintVin17Chars => '17 alphanumeric characters';

  @override
  String get driverRegHelperVehicleDocumentReference =>
      'As shown in vehicle card or document';

  @override
  String get driverRegSectionInsuranceOwnership => 'Insurance and ownership';

  @override
  String get driverRegSubtitleInsuranceOwnership =>
      'Policy number and ownership title details or equivalent document.';

  @override
  String get driverRegFieldInsurancePolicyNumber => 'Insurance policy number';

  @override
  String get driverRegHintAsPolicy => 'As shown on active policy';

  @override
  String get driverRegFieldTitleDocData => 'Ownership title / document details';

  @override
  String get driverRegHintReferenceFromDocument =>
      'Reference from your document';

  @override
  String get driverRegIntroVehiclePhotos =>
      'One photo for each side of the car: front, rear, left side and right side. Good lighting and full vehicle in frame.';

  @override
  String get driverRegSectionVehicleViews => 'Vehicle views';

  @override
  String get driverRegSubtitleVehicleViews =>
      'Tap each card to take or change photo; you\'ll see a preview once uploaded.';

  @override
  String get driverRegPhotoFrontTitle => 'Front';

  @override
  String get driverRegPhotoFrontHint =>
      'Frame the front; show the plate when possible.';

  @override
  String get driverRegPhotoRearTitle => 'Rear';

  @override
  String get driverRegPhotoRearHint => 'Entire rear side of the vehicle.';

  @override
  String get driverRegPhotoLeftTitle => 'Left side';

  @override
  String get driverRegPhotoLeftHint => 'Side view, full left side.';

  @override
  String get driverRegPhotoRightTitle => 'Right side';

  @override
  String get driverRegPhotoRightHint => 'Side view, full right side.';

  @override
  String get driverRegActionActivate => 'Activate';

  @override
  String get driverRegActionFinish => 'Finish';

  @override
  String get driverRegActionContinue => 'Continue';

  @override
  String get driverRegActionBack => 'Back';

  @override
  String get driverRegImageReady => 'Image ready';

  @override
  String get driverRegTapToUpload => 'Tap to upload';

  @override
  String get driverRegDocFrontTitle => 'Front';

  @override
  String get driverRegDocFrontHint => 'Photo and main data.';

  @override
  String get driverRegDocBackTitle => 'Back';

  @override
  String get driverRegDocBackHint => 'Code, signature, or additional data.';

  @override
  String get driverRegLicenseFrontTitle => 'Front';

  @override
  String get driverRegLicenseFrontHint => 'Photo and categories.';

  @override
  String get driverRegLicenseBackTitle => 'Back';

  @override
  String get driverRegLicenseBackHint => 'Restrictions or notes.';

  @override
  String get driverRegProfilePhotoReadyHint =>
      'Photo ready. Tap the circle to change it.';

  @override
  String get driverRegProfilePhotoGuideHint =>
      'Make sure your face is centered and well lit.';

  @override
  String get driverRegTapCardToReplacePhoto =>
      'Tap the card to replace this photo.';

  @override
  String get driverRegChangePhoto => 'Change photo';

  @override
  String get driverRegTakeOrChoosePhoto => 'Take or choose photo';

  @override
  String get driverRegColorBlack => 'Black';

  @override
  String get driverRegColorWhite => 'White';

  @override
  String get driverRegColorGray => 'Gray';

  @override
  String get driverRegColorSilver => 'Silver';

  @override
  String get driverRegColorRed => 'Red';

  @override
  String get driverRegColorBlue => 'Blue';

  @override
  String get driverRegColorGreen => 'Green';

  @override
  String get driverRegColorYellow => 'Yellow';

  @override
  String get driverRegColorOrange => 'Orange';

  @override
  String get driverRegColorViolet => 'Violet';

  @override
  String get driverRegColorBrown => 'Brown';

  @override
  String get driverRegColorBeige => 'Beige';

  @override
  String get driverRegColorGold => 'Gold';
}
