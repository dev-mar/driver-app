// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get driverAppTitle => 'Texi Driver';

  @override
  String get loginCode => 'Code';

  @override
  String get loginPhone => 'Phone';

  @override
  String get tripOrigin => 'Origin';

  @override
  String get tripDestination => 'Destination';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

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
      'Or enter your number and password if you\'re already a Texi driver.';

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
  String get driverLoginPhoneHint => 'E.g.: 70000000';

  @override
  String get driverLoginErrorGeneric => 'Could not sign in';

  @override
  String get driverLoginErrorAccountBlocked =>
      'Your account is blocked. Contact support to review your case.';

  @override
  String get driverLoginErrorNetwork =>
      'Could not connect. Check your internet and try again.';

  @override
  String get driverLoginErrorConnection =>
      'No connection to the server. Check your network.';

  @override
  String get driverLoginErrorInvalidResponse =>
      'We could not sign in. Please try again.';

  @override
  String get driverLoginErrorTokenMissing =>
      'We could not sign in. Please try again.';

  @override
  String get driverLoginErrorUnexpected =>
      'Unexpected sign-in error. Please try again.';

  @override
  String get driverLoginErrorSessionSuperseded =>
      'Your session was opened on another device.';

  @override
  String get driverLoginErrorTripOperationalLock =>
      'Finish or cancel your current trip before signing in on another device.';

  @override
  String get driverLoginErrorDeviceBound =>
      'This account is linked to another device. Contact support to change phones.';

  @override
  String get driverLoginRegisterCta => 'Register';

  @override
  String get driverLoginRegisterBannerTitle => 'New driver?';

  @override
  String get driverLoginRegisterBannerSubtitle =>
      'Create your account in minutes and start receiving trips with TEXIAPP.';

  @override
  String get driverHomeTitle => 'Driver';

  @override
  String get driverHomeRequestsTitle => 'Ride requests';

  @override
  String get driverHomeRequestsEmpty => 'You will see passenger requests here.';

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
  String get driverHomeVehicleRequiredDialogTitle => 'Vehicle required';

  @override
  String driverHomeCreditsLowWarning(String balance, String min) {
    return 'You have $balance left. You\'re near the required credit minimum ($min) to take trips.';
  }

  @override
  String get driverCreditsNoticeCta => 'Top up';

  @override
  String get driverCreditsNoticeWarningTitle => 'Low balance';

  @override
  String driverCreditsNoticeWarningBody(String min) {
    return 'You\'re near the required credit minimum ($min) to take trips.';
  }

  @override
  String get driverCreditsNoticeBlockedTitle => 'Top up to receive trips';

  @override
  String get driverCreditsNoticeBlockedBody =>
      'Go to Top-ups to go back online.';

  @override
  String get driverCreditsNoticeAfterTripWarningTitle =>
      'Balance near the minimum';

  @override
  String get driverCreditsNoticeAfterTripWarningBody =>
      'Go to Top-ups so you stay available.';

  @override
  String get driverCreditsNoticeAfterTripBlockedTitle =>
      'Trip done. Top up to continue';

  @override
  String driverCreditsNoticeAfterTripBlockedBody(String min) {
    return 'Trip saved. You reached the required credit minimum ($min) to take trips.';
  }

  @override
  String get driverFcmOpenedTripOfferHint =>
      'We just loaded the request from the alert; check the list below. If it\'s missing, it may have expired or the connection failed—toggle online again.';

  @override
  String get driverFcmOpenedTripOfferOfflineHint =>
      'You\'re offline. Turn on availability to receive requests from alerts.';

  @override
  String get driverHomeMiniVehicleEmpty => 'Vehicle';

  @override
  String driverHomeMiniRating(String rating) {
    return '$rating ★';
  }

  @override
  String get driverLogout => 'Sign out';

  @override
  String get driverHomeMenuSectionAccount => 'Account';

  @override
  String get driverHomeMenuSectionActivity => 'Activity';

  @override
  String get driverHomeMenuSectionSession => 'Session';

  @override
  String get driverHomeMenuTitle => 'Menu';

  @override
  String get driverEarningsCreditsMenu => 'Earnings & credits';

  @override
  String get driverClubMenu => 'Driver Club';

  @override
  String get driverClubTitle => 'Driver Club';

  @override
  String get driverClubHeroBadge => 'EXCLUSIVE';

  @override
  String get driverClubHeroHello => 'Hi';

  @override
  String driverClubHeroHelloName(String name) {
    return 'Hi, $name';
  }

  @override
  String get driverClubHeroTagline =>
      'Benefits for drivers who already operate.';

  @override
  String get driverClubHowItWorks => 'What is the Texi Driver Club';

  @override
  String get driverClubLearnOnWeb => 'Learn more about this benefit';

  @override
  String get driverClubWalletTitle => 'Club credit';

  @override
  String driverClubExpiresOn(String date) {
    return 'Active until $date';
  }

  @override
  String get driverClubWalletEmptyHint => 'No Club credit yet.';

  @override
  String get driverClubWalletLiveHint => 'Used when trips complete.';

  @override
  String get driverClubInviteTitle => 'Invite and earn';

  @override
  String get driverClubInviteSubtitle => 'Share your code. Grow your network.';

  @override
  String get driverClubYourCode => 'Your code';

  @override
  String get driverClubCopyCode => 'Copy';

  @override
  String get driverClubCodeCopied => 'Code copied';

  @override
  String get driverClubShareWhatsapp => 'WhatsApp';

  @override
  String driverClubWhatsappShare(String code) {
    return 'Join as a TEXIAPP driver with my code $code';
  }

  @override
  String get driverClubEnterCodeHint => 'Were you invited? Enter their code';

  @override
  String get driverClubClaimCta => 'Register code';

  @override
  String get driverClubClaimOk => 'Code registered';

  @override
  String get driverClubInviteesTitle => 'My guests';

  @override
  String get driverClubInviteesEmpty => 'No guests yet.';

  @override
  String get driverClubStatusPending => 'Pending';

  @override
  String get driverClubStatusProgress => 'In progress';

  @override
  String get driverClubStatusDone => 'Done';

  @override
  String get driverClubBenefitsTitle => 'More benefits';

  @override
  String get driverClubLevelsTitle => 'Levels';

  @override
  String get driverClubLevelsHint =>
      'Your category is confirmed by our team. These numbers are this month\'s reference.';

  @override
  String driverClubMonthTripsValue(int count) {
    return '$count trips this month';
  }

  @override
  String driverClubMonthRatingValue(String rating) {
    return '$rating stars this month';
  }

  @override
  String get driverClubMonthRatingEmpty => 'No ratings this month yet';

  @override
  String driverClubTripsRange(int min, int max) {
    return '$min–$max trips';
  }

  @override
  String driverClubTripsFrom(int min) {
    return 'From $min trips';
  }

  @override
  String driverClubRatingFrom(String rating) {
    return 'From $rating stars';
  }

  @override
  String get driverClubRatingNone => 'No star minimum';

  @override
  String get driverClubChallengesTitle => 'Challenges';

  @override
  String get driverClubChallengesBlurb => 'Short quests, when they go live.';

  @override
  String get driverClubAdsTitle => 'Vehicle ads';

  @override
  String get driverClubAdsBlurb => 'Apply when the call opens.';

  @override
  String get driverRegFieldReferralCode => 'Referral code (optional)';

  @override
  String get driverRegFieldReferralCodeHint => 'E.g. CARLOS-782';

  @override
  String get driverEarningsCreditsTitle => 'Earnings & credits';

  @override
  String get driverEarningsCreditsFilterHint =>
      'Filter by period. Totals and lists match the selected range.';

  @override
  String get driverEarningsCreditsLoadError =>
      'Could not load data. Pull to refresh.';

  @override
  String get driverEarningsCreditsStatTrips => 'Completed trips';

  @override
  String get driverEarningsCreditsStatTripsHint => 'In the selected period';

  @override
  String get driverEarningsCreditsStatGross => 'Trip total';

  @override
  String get driverEarningsCreditsStatGrossHint =>
      'Sum of completed trip fares';

  @override
  String get driverEarningsCreditsStatBalance => 'Credit balance';

  @override
  String get driverEarningsCreditsStatCommission => 'Credit commission';

  @override
  String get driverEarningsCreditsStatCommissionHint =>
      'Deducted from balance in period';

  @override
  String get driverEarningsCreditsLedgerSection => 'Credit activity';

  @override
  String get driverEarningsCreditsLedgerEmpty => 'No movements in this period.';

  @override
  String get driverEarningsCreditsLedgerGrant => 'Top-up';

  @override
  String get driverEarningsCreditsLedgerCommission => 'Trip commission';

  @override
  String get driverEarningsCreditsTripsSection => 'Trips in period';

  @override
  String get driverEarningsCreditsTripsEmpty =>
      'No completed trips in this period.';

  @override
  String get driverEarningsCreditsTripIdShort => 'Trip';

  @override
  String get driverTopupSectionTitle => 'Top up credits';

  @override
  String get driverTopupScreenTitle => 'Top up credits';

  @override
  String get driverTopupMenu => 'Top-ups';

  @override
  String get driverTopupOpenFromEarnings => 'Top up credits';

  @override
  String get driverTopupOpenFromEarningsHint =>
      'Pay a QR and send the receipt. Balance is credited when our team confirms it.';

  @override
  String get driverTopupStepAmount => 'Choose the amount';

  @override
  String get driverTopupStepPay => 'Pay this QR';

  @override
  String get driverTopupStepProof => 'Send the receipt';

  @override
  String get driverTopupUnavailableTitle => 'Top-ups unavailable';

  @override
  String get driverTopupUnavailableBody =>
      'There are no top-up packages in your country yet. Try again later.';

  @override
  String get driverTopupHistoryEmpty => 'You have no top-ups yet.';

  @override
  String get driverTopupHistoryRetry => 'Try again';

  @override
  String get driverTopupSectionHint =>
      'Pay the QR and upload the receipt. Balance is credited when our team confirms it — not instantly.';

  @override
  String get driverTopupShareQr => 'Share QR';

  @override
  String get driverTopupSaveQr => 'Save QR';

  @override
  String get driverTopupShareFailed => 'Could not share the QR.';

  @override
  String get driverTopupSaveFailed => 'Could not save the QR.';

  @override
  String get driverTopupSaveOk =>
      'QR saved to your photos. You can open it from Gallery or Files.';

  @override
  String get driverTopupSavePermissionDenied =>
      'Allow adding photos to save the QR.';

  @override
  String get driverTopupReceiptTitle => 'I already paid';

  @override
  String get driverTopupReceiptHint =>
      'Select the receipt from gallery or files to upload it.';

  @override
  String get driverTopupPendingTitle => 'Top-up in review';

  @override
  String get driverTopupPendingHint =>
      'You have a top-up in review. You cannot send another until it is credited or rejected.';

  @override
  String driverTopupDailyLimitHint(int max) {
    return 'You reached today\'s limit of $max top-ups.';
  }

  @override
  String get driverTopupPickReceipt => 'Choose from gallery or files';

  @override
  String get driverTopupReceiptPicked => 'Image ready · change';

  @override
  String get driverTopupSubmit => 'Send top-up';

  @override
  String get driverTopupSubmitted => 'Sent. We\'ll credit it after review.';

  @override
  String get driverTopupSubmitFailed => 'Could not send the top-up.';

  @override
  String get driverTopupUploadFailed =>
      'Could not upload the image. Try again.';

  @override
  String get driverTopupGalleryDisclosureTitle => 'Choose receipt';

  @override
  String get driverTopupGalleryDisclosureBody =>
      'This device\'s photo or file picker will open for this top-up only. We do not keep that access.';

  @override
  String get driverTopupGalleryDisclosureContinue => 'Continue';

  @override
  String get driverTopupReceiptInvalidType =>
      'Use a JPG or PNG of the receipt. If it won\'t load, send the transfer details instead.';

  @override
  String get driverTopupReceiptTooLarge =>
      'That image is too large. Pick another or send the transfer details.';

  @override
  String get driverTopupReceiptCompressFailed =>
      'We couldn\'t read that image. Try another or send the transfer details.';

  @override
  String get driverTopupTransferTitle => 'Transfer details';

  @override
  String get driverTopupTransferHint => 'Mobile number and a transaction note.';

  @override
  String get driverTopupOrDivider => 'OR';

  @override
  String get driverTopupOriginAccountLabel => 'Mobile number';

  @override
  String get driverTopupOriginAccountHint => 'E.g.: 70000000';

  @override
  String get driverTopupTransactionRefLabel => 'Transaction details';

  @override
  String get driverTopupTransactionRefHint =>
      'Bank that credited, time, or amount';

  @override
  String get driverTopupNeedEvidence =>
      'Choose the receipt image, or send the transaction details (mobile number and notes).';

  @override
  String get driverTopupHistoryTitle => 'Your top-ups';

  @override
  String get driverTopupStatusPending => 'In review';

  @override
  String get driverTopupStatusCredited => 'Credited';

  @override
  String get driverTopupStatusRejected => 'Rejected';

  @override
  String get driverTripHistoryMenu => 'Trip history';

  @override
  String get driverTripHistoryTitle => 'Trip history';

  @override
  String get driverTripHistoryFilterAll => 'All';

  @override
  String get driverTripHistoryFilterCompleted => 'Completed';

  @override
  String get driverTripHistoryFilterCancelled => 'Cancelled';

  @override
  String get driverTripHistoryFilterInProgress => 'In progress';

  @override
  String get driverTripHistoryDateAll => 'All time';

  @override
  String get driverTripHistoryDateToday => 'Today';

  @override
  String get driverTripHistoryDate7d => 'Last 7 days';

  @override
  String get driverTripHistoryDate30d => 'Last 30 days';

  @override
  String get driverTripHistoryStatusLabel => 'Status';

  @override
  String get driverTripHistoryStatusCompleted => 'Completed';

  @override
  String get driverTripHistoryStatusCancelled => 'Cancelled';

  @override
  String get driverTripHistoryStatusInProgress => 'In progress';

  @override
  String get driverTripHistoryDateCustom => 'Custom';

  @override
  String get driverTripHistoryActiveFilters => 'Active filters';

  @override
  String get driverTripHistoryCustomRangeLabel => 'Selected range';

  @override
  String get driverTripHistorySectionToday => 'Today';

  @override
  String get driverTripHistorySectionYesterday => 'Yesterday';

  @override
  String get driverTripHistorySectionOlder => 'Older';

  @override
  String get driverTripHistoryEmpty => 'No trips yet for this filter.';

  @override
  String get driverTripHistoryLoadError =>
      'Could not load trip history. Please try again.';

  @override
  String get driverTripHistoryNoSession =>
      'Your session expired. Please sign in again.';

  @override
  String get driverTripHistoryPrevPage => 'Previous';

  @override
  String get driverTripHistoryNextPage => 'Next';

  @override
  String get driverTripHistoryPricePending => 'No amount';

  @override
  String get driverHomeMenuAddVehicle => 'My vehicles';

  @override
  String get driverMyVehiclesTitle => 'My vehicles';

  @override
  String get driverMyVehiclesRefreshTooltip => 'Refresh list';

  @override
  String get driverMyVehiclesAddFab => 'Add vehicle';

  @override
  String get driverMyVehiclesAddLockedTitle => 'Not available yet';

  @override
  String get driverMyVehiclesAddLockedBody =>
      'For now you can only have one registered vehicle. Adding another is a benefit unlocked based on your seniority and driver evaluation. If you think it should already apply, contact support.';

  @override
  String get driverMyVehiclesAddLockedCta => 'Got it';

  @override
  String get driverMyVehiclesEmpty =>
      'You have no registered vehicles yet. Add one to offer service.';

  @override
  String get driverMyVehiclesRetry => 'Try again';

  @override
  String driverMyVehiclesPhotosPendingBadge(int uploaded, int required) {
    return 'Gallery incomplete: $uploaded of $required required photos';
  }

  @override
  String get driverMyVehiclesCompletePhotosCta => 'Complete photos';

  @override
  String get driverMyVehiclesCompletePhotosTitle => 'Vehicle photos';

  @override
  String get driverMyVehiclesPhotosSavedSnackbar => 'Photos saved successfully';

  @override
  String get driverOnlineAuthTitle => 'Confirm your identity';

  @override
  String get driverOnlineAuthSubtitle =>
      'We ask for fingerprint, face, or PIN so only you can go online. TexiApp doesn’t store or collect that data.';

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
  String get driverProfileErrorEmpty =>
      'We could not load your profile. Try again.';

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
  String get driverProfileOnboardingTitle => 'Documents and validation';

  @override
  String get driverProfileOnboardingBody =>
      'Review each block\'s status. CI, license, and vehicle photos can be changed until the block shows as Verified. A verified block cannot be opened; the summary is below.';

  @override
  String get driverProfileSectionOnboardingPersonal => 'Personal information';

  @override
  String get driverProfileSectionOnboardingIdentity => 'Identity document';

  @override
  String get driverProfileSectionOnboardingLicense => 'Driver license';

  @override
  String get driverProfileSectionOnboardingVehicle => 'Vehicle and photos';

  @override
  String get driverProfileOnboardingStatusIncomplete => 'Pending';

  @override
  String get driverProfileOnboardingStatusPending => 'In review';

  @override
  String get driverProfileOnboardingStatusVerified => 'Verified';

  @override
  String get driverProfileOnboardingStatusAction => 'Update requested';

  @override
  String get driverProfileOnboardingTapToContinue => 'Tap to open or update';

  @override
  String get driverProfileOnboardingTapEditable => 'Tap to complete or fix';

  @override
  String get driverProfileOnboardingTapEditPhotos =>
      'Tap to change photos (until approved)';

  @override
  String get driverProfileOnboardingTapViewOnly => 'Tap to view (in review)';

  @override
  String get driverProfileOnboardingTapLocked =>
      'Verified. The summary is below.';

  @override
  String get driverRegProfileSectionReadOnlyBanner =>
      'This block is under review. You can view the information but cannot save changes until our team processes it.';

  @override
  String get driverRegProfileSectionPhotosEditableBanner =>
      'You can change the photos until this block is approved. Other details stay locked.';

  @override
  String get driverRegActionSavePhotos => 'Save photos';

  @override
  String get driverRegSnackChangeAtLeastOnePhoto =>
      'Change at least one photo to save.';

  @override
  String get driverRegProfileSectionLockedBanner =>
      'This block is verified and cannot be changed from the app.';

  @override
  String get driverRegErrorSectionNotEditable =>
      'This section cannot be changed in its current status.';

  @override
  String get driverRegErrorRateLimited =>
      'Too many requests in a short time. Wait a moment and try again.';

  @override
  String get driverRegErrorNoConnection =>
      'No internet connection. Check your signal and try again.';

  @override
  String get driverRegPassengerUpgradeTitle =>
      'You already have a passenger account';

  @override
  String get driverRegPassengerUpgradeBody =>
      'This number is already registered as a passenger. Open WhatsApp and send the message to confirm it is yours.';

  @override
  String get driverRegPassengerUpgradeBodyCode =>
      'This number is already registered as a passenger. Enter the verification code to confirm it is yours.';

  @override
  String get driverRegPassengerUpgradeOpenWhatsApp => 'Open WhatsApp';

  @override
  String get driverRegPassengerUpgradeWaiting =>
      'Waiting for your WhatsApp message…';

  @override
  String get driverRegPassengerUpgradeExpired =>
      'The message expired. Try again.';

  @override
  String get driverRegPassengerUpgradeCodeHint => 'Verification code';

  @override
  String get driverRegPassengerUpgradeConfirm => 'Continue';

  @override
  String get driverRegErrorPassengerUpgradeRequired =>
      'This number already belongs to a passenger. Confirm it on WhatsApp to register as a driver.';

  @override
  String get driverRegErrorDuplicatePhoneDriver =>
      'This number is already registered as a driver. Sign in or recover your access.';

  @override
  String get driverRegErrorUpgradeOtpInvalid =>
      'The code is invalid or expired. Request a new one and try again.';

  @override
  String get driverRegErrorUpgradeOtpNotFound =>
      'There is no passenger account with this number. Complete registration as a new driver.';

  @override
  String get driverRegErrorAccountDeletionPending =>
      'This account is pending deletion. Cancel that request in the passenger app before registering as a driver.';

  @override
  String get driverRegErrorUpgradeWhatsAppSend =>
      'We could not send the WhatsApp code. Try again in a few minutes.';

  @override
  String get driverProfileSectionPersonal => 'Personal information';

  @override
  String get driverProfileSectionContact => 'Contact';

  @override
  String get driverProfileSectionLocation => 'Location';

  @override
  String get driverProfileReadOnlyFooter => 'These details are read-only.';

  @override
  String get driverAppCreditsTitle => 'Usage credits';

  @override
  String get driverAppCreditsUnavailable =>
      'Could not load balance. Pull to refresh.';

  @override
  String driverAppCreditsBalance(String balance) {
    return 'Balance: $balance';
  }

  @override
  String get driverAppCreditsProgramOn => 'Per-trip commission active';

  @override
  String get driverAppCreditsProgramOff => 'No automatic per-trip commission';

  @override
  String driverAppCreditsDetailPercent(String percent) {
    return '$percent% of trip fare';
  }

  @override
  String driverAppCreditsDetailFixed(String amount) {
    return '$amount per completed trip';
  }

  @override
  String get driverProfileFieldName => 'Name';

  @override
  String get driverProfileFieldReferralCode => 'Referral code';

  @override
  String get driverProfileCopyReferralCode => 'Copy referral code';

  @override
  String get driverProfileReferralCopied => 'Code copied';

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
  String get driverOnlineErrorGoOnlineBlocked =>
      'Your account cannot go available for trips from the app. Contact support if you think this is a mistake.';

  @override
  String driverOnlineErrorCreditsBelowMin(Object minCredits, Object balance) {
    return 'You\'ve reached the required credit minimum ($minCredits) to take trips. Balance: $balance. Go to Top-ups to go online.';
  }

  @override
  String get driverOnlineErrorAccountBlocked =>
      'Your driver account is blocked. Your session was closed for safety.';

  @override
  String get driverOnlineErrorRegistrationIncomplete =>
      'Complete your registration (identity, license and vehicle) to go online and receive trips.';

  @override
  String get driverOnlineErrorRegistrationNotVerified =>
      'Our team has not verified your identity, license or vehicle yet. You will receive trip offers after each stage is approved.';

  @override
  String get driverOnlineErrorAccountNotActive =>
      'Your driver account is not active. Contact support.';

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
  String get driverHomeOpenSystemLocationSettings =>
      'Open location (GPS) settings';

  @override
  String get driverHomeOpenAppPermissionSettings =>
      'Open app permission settings';

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
  String driverTripOfferPrice(String amount) {
    return 'Estimated price: $amount';
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
  String get driverTripPaymentCash => 'Cash';

  @override
  String get driverTripPaymentQr => 'QR';

  @override
  String get driverTripExtrasTitle => 'Passenger notes';

  @override
  String get driverTripExtrasHint =>
      'Informational. Close to return to the request list.';

  @override
  String get driverTripAddonsHint =>
      'Review preferences and requirements. Close to return to the list.';

  @override
  String get driverTripExtrasClose => 'Close';

  @override
  String get driverTripExtraPet => 'Pet';

  @override
  String get driverTripExtraPetAlert => 'Pet on board.';

  @override
  String get driverTripExtraPetDetail =>
      'The passenger is traveling with a pet.';

  @override
  String get driverTripExtraChildSeat => 'Child seat';

  @override
  String get driverTripExtraWheelchair => 'Wheelchair';

  @override
  String get driverTripExtraWheelchairAlert => 'Passenger with a wheelchair.';

  @override
  String get driverTripExtraWheelchairDetail =>
      'Needs trunk space for a folding wheelchair. Please assist if needed.';

  @override
  String get driverTripExtraOver4 => 'More than 4 people';

  @override
  String get driverTripExtraLuggageAlert => 'With luggage.';

  @override
  String get driverTripExtraLuggageDetail =>
      'The passenger has bags. Keep the trunk empty for luggage.';

  @override
  String get driverTripExtraAcAlert => 'Air conditioning.';

  @override
  String get driverTripExtraAcDetail =>
      'The passenger asked to travel with A/C.';

  @override
  String get driverTripSpecialSeats6Alert => 'Large group (up to 6 passengers)';

  @override
  String get driverTripSpecialSeats6Detail =>
      'Needs a roomy vehicle confirmed for 6 passengers.';

  @override
  String get driverTripSpecialRoofRackAlert => 'Roof rack required';

  @override
  String get driverTripSpecialRoofRackDetail =>
      'The passenger will carry roof cargo. Have straps/bungees ready.';

  @override
  String get driverTripSpecialCargoAlert => 'Cargo / merchandise trip';

  @override
  String get driverTripSpecialCargoDetail =>
      'Cargo space occupied. Includes extra time for loading and unloading.';

  @override
  String get driverRegFieldSixSeats => 'Vehicle with 6 seats';

  @override
  String get driverRegHintSixSeats =>
      'Check if your car can carry up to 6 passengers. Used for large-group trips.';

  @override
  String get driverTripOfferBadgeOperations => 'Operations';

  @override
  String get driverTripOfferOperationsSubtitle =>
      'Assigned from the operations portal';

  @override
  String get driverFcmOpenedTripOfferOperationsHint =>
      'Operations trip request loaded. Check the list below.';

  @override
  String get driverOfferErrorNoConnection => 'No connection to server.';

  @override
  String get driverOfferErrorExpired => 'This offer is no longer available.';

  @override
  String get driverOfferErrorTaken => 'Trip already assigned or cancelled.';

  @override
  String get driverTripErrorGeneric => 'Could not update trip status.';

  @override
  String get driverTripNavigatePickup => 'Navigate to pickup';

  @override
  String get driverTripNavigateDestination => 'Navigate to destination';

  @override
  String get driverRegisteredImagesMenu => 'Registered images';

  @override
  String get driverTripChatOpenCta => 'Secure chat';

  @override
  String get driverTripChatTitle => 'Trip chat';

  @override
  String get driverTripChatSubtitle =>
      'Live conversation with the passenger in real time.';

  @override
  String get driverTripChatOnline => 'Online';

  @override
  String get driverTripChatOffline => 'Offline';

  @override
  String get driverTripChatTemplateArrived => 'I arrived at the pickup point';

  @override
  String get driverTripChatTemplateCannotFind => 'I can\'t find you';

  @override
  String get driverTripChatTemplateConfirmLocation =>
      'Please confirm your location';

  @override
  String get driverTripChatNow => 'Now';

  @override
  String get driverTripChatErrorStorage =>
      'Chat unavailable: server configuration is missing. Contact support.';

  @override
  String get driverTripChatErrorPhase =>
      'Chat is only available before the trip starts.';

  @override
  String get driverTripChatErrorSendReceive =>
      'Could not send or receive the message. Check your connection.';

  @override
  String get driverTripChatEmptyState =>
      'No messages yet.\nSend one to start the conversation.';

  @override
  String get driverTripChatMessageHint => 'Write a message';

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
  String get driverForegroundNotifyTitle => 'Texi · Driver mode';

  @override
  String get driverForegroundNotifyBodySearching =>
      'Waiting for ride requests. GPS stays on for dispatch.';

  @override
  String get driverForegroundNotifyBodyTrip =>
      'On a trip · location shared with passengers.';

  @override
  String driverForegroundNotifyBodyOffers(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending requests — open Texi',
      one: '1 pending request — open Texi to respond',
    );
    return '$_temp0';
  }

  @override
  String get driverNotifyChatTitle => 'New chat message';

  @override
  String driverNotifyChatBody(String sender, String message) {
    return '$sender: $message';
  }

  @override
  String get driverNotifyChatSenderPassenger => 'Passenger';

  @override
  String get driverNotifyChatSenderDriver => 'Driver';

  @override
  String get driverMapPickupPoint => 'Pickup point';

  @override
  String get driverMapDestinationPoint => 'Destination';

  @override
  String get driverDirectionsTollOnRoute => 'Toll on route';

  @override
  String get driverDirectionsTollSnippet => 'Adjust speed and lane in advance.';

  @override
  String get driverDirectionsRelevantIntersection => 'Relevant intersection';

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
  String get driverTripRatingPassengerDefault => 'Passenger';

  @override
  String get driverTripRatingYourRating => 'Your rating';

  @override
  String get driverTripRatingFeedbackPromptLow =>
      'What affected the trip? (multiple)';

  @override
  String get driverTripRatingFeedbackPromptHigh =>
      'What stood out about the passenger? (multiple)';

  @override
  String get driverRatingFallbackDelay => 'Too long waiting';

  @override
  String get driverRatingFallbackLocation => 'Hard to find each other';

  @override
  String get driverRatingFallbackRespect => 'Lack of respect';

  @override
  String get driverRatingFallbackPayment => 'Payment issue';

  @override
  String get driverRatingFallbackOther => 'Other issue';

  @override
  String get driverRatingFallbackPunctual => 'Punctual and ready to go';

  @override
  String get driverRatingFallbackRespectful => 'Respectful attitude';

  @override
  String get driverRatingFallbackClearPickup => 'Clear and quick trip';

  @override
  String get driverRatingFallbackRecommended => 'Recommended passenger';

  @override
  String get driverRatingFallbackExcellent => 'Excellent experience';

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
  String get driverRegImageCompatibleCaptureUsed =>
      'Optimized camera capture was used to reduce file size.';

  @override
  String get driverRegImageLongPressLightHint =>
      'Long-press a slot to retake with optimized capture (lower initial resolution).';

  @override
  String get driverRegCropSelfieTitle => 'Adjust selfie';

  @override
  String get driverRegCropDocumentTitle => 'Adjust document';

  @override
  String get driverRegCropVehicleTitle => 'Frame the vehicle';

  @override
  String get driverRegPhotoReviewTitle => 'Review your photo';

  @override
  String get driverRegPhotoReviewSubtitle =>
      'You can confirm it, take another one, or crop before continuing.';

  @override
  String get driverRegPhotoReviewUse => 'Use this photo';

  @override
  String get driverRegPhotoReviewChange => 'Change photo';

  @override
  String get driverRegPhotoReviewEdit => 'Crop or adjust';

  @override
  String get driverRegPhotoReviewCancel => 'Cancel';

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
  String get driverRegSnackVehicleYearInvalid => 'Enter a 4-digit year.';

  @override
  String get driverRegSnackSelectCatalogBrandModel =>
      'Select make and model from the lists before continuing.';

  @override
  String get driverSettingsTitle => 'Settings';

  @override
  String get driverRegSnackVehiclePhotosIncomplete =>
      'We need all four views: front, rear, and both sides of the vehicle.';

  @override
  String get driverRegDoneTitle => 'Done!';

  @override
  String get driverRegDoneBody =>
      'Thanks for joining TEXIAPP. Your data and documents were registered and are now under review. We will contact you shortly to continue your registration. Now sign in with your credentials.';

  @override
  String get driverRegDoneGoLogin => 'Go to sign in';

  @override
  String get driverRegAddVehicleTitle => 'Register service vehicle';

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
  String get driverRegOnboardingDoneTitle => 'Details sent for review';

  @override
  String get driverRegOnboardingDoneBody =>
      'Your details were sent for review. Now enter the app to register your vehicle.';

  @override
  String get driverRegOnboardingDoneCta => 'Enter the app';

  @override
  String get driverRegAccessHeroTitle => 'Check your details';

  @override
  String get driverRegAccessHeroSubtitle =>
      'When you continue, your details go to review. After that you’ll register your vehicle.';

  @override
  String get driverHomeOpeningVehicleForm => 'Opening the vehicle form…';

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
  String get driverRegEmailHelper =>
      'Choose the email on this phone or type a different one.';

  @override
  String get driverRegEmailPickFromDevice => 'Use email from this phone';

  @override
  String get driverRegValidationEmailInvalid => 'Enter a valid email.';

  @override
  String get driverRegValidationRequired => 'Required';

  @override
  String get driverRegValidationMinAge18 =>
      'You must be at least 18 years old to register as a driver.';

  @override
  String get driverRegAgeRequirementHint =>
      'Driver registration and use of the driver app are reserved for persons over 18 years of age.';

  @override
  String get driverRegAgeRequirementFieldHelper =>
      '18+ only. The calendar only allows valid dates.';

  @override
  String get driverRegAgeRequirementDialogTitle => 'Age of majority required';

  @override
  String get driverRegAgeRequirementDialogBody =>
      'You must be at least 18 years old to register as a driver. Correct your date of birth to continue.';

  @override
  String get driverRegValidationSelectOption => 'Select an option';

  @override
  String get driverRegSectionContact => 'Contact';

  @override
  String get driverRegSectionContactAddress => 'Contact and address';

  @override
  String get driverRegFieldPhoneNumber => 'Phone number';

  @override
  String get driverRegHintLocalDigitsOnly => 'E.g. 12345678';

  @override
  String get driverRegHintBoliviaLocalPhone => 'E.g.: 70000000';

  @override
  String get driverRegChooseCountryFirst => 'Choose country first';

  @override
  String get driverRegValidationIncompleteNumber => 'Incomplete number';

  @override
  String get driverRegValidationBoliviaPhoneInvalid => 'Invalid number';

  @override
  String get driverRegSectionAddress => 'Address';

  @override
  String get driverRegFieldAddress => 'Home address';

  @override
  String get driverRegHintAddressReference => 'Street, area or reference';

  @override
  String get driverRegSectionPassword => 'Access password';

  @override
  String get driverRegSectionPasswordHint =>
      'Create a password to sign in to the app.';

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
  String get driverRegSectionActivateAccount => 'Submit your registration';

  @override
  String get driverRegSubtitleReviewBeforeContinue =>
      'Review your details and send them for review.';

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
      'Enter the details as on the plate. Then you will upload four photos of the vehicle.';

  @override
  String get driverRegSectionVehicleData => 'Vehicle data';

  @override
  String get driverRegSectionVehicleClassification => 'Vehicle classification';

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
  String get driverRegCatalogBrandModelTitle => 'Make and model';

  @override
  String get driverRegCatalogTransportStepTitle => '1. What will you drive?';

  @override
  String get serviceTypeNameStandard => 'Standard';

  @override
  String get serviceTypeNameMoto => 'Moto';

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
  String get driverRegCatalogCustomTitle => 'Your vehicle details';

  @override
  String get driverRegCatalogCustomHint => 'It will be sent for review.';

  @override
  String get driverRegCatalogCustomManufacturer => 'Brand';

  @override
  String get driverRegCatalogCustomModel => 'Model';

  @override
  String get driverRegCatalogCustomYear => 'Year';

  @override
  String get driverRegCatalogCustomSave => 'Save';

  @override
  String driverRegCatalogCustomSummary(
    String brand,
    String model,
    String year,
  ) {
    return 'For review: $brand · $model ($year)';
  }

  @override
  String get driverRegSnackCatalogCustomRequired =>
      'Enter brand, model, and year for the Other option.';

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
      'We could not save the services. Please try again in a few seconds.';

  @override
  String get driverRegErrorMissingUserId =>
      'We could not continue registration. Go back to the start and try again.';

  @override
  String get driverRegErrorVehicleCatalogLoading =>
      'Wait for the vehicle catalog to load, then try again.';

  @override
  String get driverRegErrorVehicleCatalogIncomplete =>
      'We could not load the vehicle type or category. Contact support.';

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
  String get driverRegErrorSecureStorage =>
      'Could not read local data on this device. Close the app and try again. If it persists, clear the app data in Settings.';

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
  String get driverRegActionActivate => 'Continue';

  @override
  String get driverRegActionFinish => 'Finish';

  @override
  String get driverRegActionContinue => 'Continue';

  @override
  String get driverRegActionBack => 'Back';

  @override
  String get driverRegActionSave => 'Save';

  @override
  String get driverRegCancelTitle => 'Cancel registration';

  @override
  String get driverRegCancelBodyUser =>
      'For security, data entered so far will not be kept and this registration progress will be removed. You can start again whenever you want.';

  @override
  String get driverRegCancelBodyVehicle =>
      'For security, the vehicle you are registering will not be saved. Your account and other vehicles stay unchanged.';

  @override
  String get driverRegCancelConfirm => 'Yes, cancel';

  @override
  String get driverRegCancelKeepGoing => 'Keep going';

  @override
  String get driverRegTitleProfileCompletion => 'Complete registration';

  @override
  String get driverRegProfileStepSaved => 'Changes saved.';

  @override
  String driverRegProfileRedirectSnackbar(String stepFrom, String stepTo) {
    return 'Based on your registration status, we opened «$stepTo» instead of «$stepFrom».';
  }

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

  @override
  String get driverLegalSectionTitle => 'Legal & privacy';

  @override
  String get driverLegalSectionSubtitle =>
      'Review the documents that apply to your account and manage your data.';

  @override
  String get driverLegalPrivacyPolicy => 'Privacy policy';

  @override
  String get driverLegalTermsOfService => 'Terms of service';

  @override
  String get driverLegalDeleteAccountTitle => 'Delete account';

  @override
  String driverLegalDeleteAccountBody(int graceDays) {
    return 'Your account will enter a scheduled deletion period for $graceDays days. After you confirm, your session will close and you cannot use the app. To recover it, sign in with your credentials and cancel the request before the deadline.';
  }

  @override
  String get driverLegalDeleteAccountAction => 'How to request';

  @override
  String get driverLegalDeleteAccountConfirmSchedule => 'Schedule deletion';

  @override
  String get driverLegalDeleteAccountScheduling => 'Scheduling deletion…';

  @override
  String get driverLegalDeleteAccountScheduledSuccess =>
      'Deletion scheduled. Your session was closed; sign in to recover your account before the deadline.';

  @override
  String get driverLoginAccountDeletionPendingTitle => 'Deletion scheduled';

  @override
  String driverLoginAccountDeletionPendingBody(String effectiveDate) {
    return 'This account is scheduled for deletion on $effectiveDate. You cannot use the app until you recover it.';
  }

  @override
  String get driverLoginAccountDeletionPendingDateFallback =>
      'the scheduled date';

  @override
  String get driverLoginAccountDeletionRecover => 'Recover account';

  @override
  String get driverLoginAccountDeletionDismiss => 'OK';

  @override
  String get driverLoginAccountDeletionRecovering => 'Recovering account…';

  @override
  String get driverLoginAccountDeletionRecoverSuccess =>
      'Account recovered. Welcome back.';

  @override
  String get driverLegalDeleteAccountPendingTitle => 'Deletion scheduled';

  @override
  String driverLegalDeleteAccountPendingBody(
    String effectiveDate,
    int daysRemaining,
  ) {
    return 'Your account will be deleted on $effectiveDate. You have $daysRemaining days left to cancel and restore access.';
  }

  @override
  String get driverLegalDeleteAccountPendingDateFallback =>
      'the scheduled date';

  @override
  String get driverLegalDeleteAccountCancelAction => 'Cancel deletion';

  @override
  String get driverLegalDeleteAccountCancelling => 'Cancelling deletion…';

  @override
  String get driverLegalDeleteAccountCancelSuccess =>
      'Deletion cancelled. Your account is still active.';

  @override
  String get driverPlayNotificationDisclosureTitle => 'Trip notifications';

  @override
  String get driverPlayNotificationDisclosureBody =>
      'TEXIAPP needs to send you notifications when trip requests arrive, trip status changes, or the passenger sends a message while you are online as a driver.';

  @override
  String get driverPlayLocationDisclosureTitle => 'Location to receive trips';

  @override
  String get driverPlayLocationDisclosureBody =>
      'TEXIAPP uses your location to show you on the map, match nearby trip requests, and share your position with the passenger during an active trip.';

  @override
  String get driverPlayDisclosureContinue => 'Continue';

  @override
  String get driverLegalLoginHint =>
      'By continuing, you agree to our usage policies and terms of service.';

  @override
  String get driverLegalLoginPrefix => 'By continuing, you agree to our ';

  @override
  String get driverLegalLoginConjunction => ' and ';

  @override
  String get driverLegalActivatePrefix => 'By continuing you accept our ';

  @override
  String get driverLegalUsagePolicies => 'usage policies';

  @override
  String get driverLegalRegistrationHint =>
      'By continuing you accept our usage policies.';

  @override
  String get driverPlayCameraDisclosureTitle => 'Camera access';

  @override
  String get driverPlayCameraDisclosureBody =>
      'TEXIAPP uses the camera to capture identity documents, your license, and vehicle photos during registration. Images are sent securely for verification.';

  @override
  String get driverPlayGalleryDisclosureTitle => 'Photo library access';

  @override
  String get driverPlayGalleryDisclosureBody =>
      'TEXIAPP accesses photos you choose from your library for driver registration. Only the image you select is uploaded.';

  @override
  String get driverAppUpdateRequiredTitle => 'Update required';

  @override
  String get driverAppUpdateRequiredMessage =>
      'A new version of Texi Driver is available. Update the app to continue.';

  @override
  String get driverAppUpdateOptionalTitle => 'New version available';

  @override
  String get driverAppUpdateOptionalMessage =>
      'An update is available on the Play Store. We recommend installing it for the best experience.';

  @override
  String get driverAppUpdateOpenStore => 'Go to Play Store';

  @override
  String get driverAppUpdateLater => 'Later';

  @override
  String get driverPasswordResetForgotLink => 'Forgot your password?';

  @override
  String get driverPasswordResetTitle => 'Reset password';

  @override
  String get driverPasswordResetLead =>
      'Confirm your number. The fastest option is to send a WhatsApp message. Or we can email you a code.';

  @override
  String get driverPasswordResetWhatsAppCta => 'Verify with WhatsApp';

  @override
  String get driverPasswordResetEmailCta => 'Send code to email';

  @override
  String get driverPasswordResetWaTitle => 'WhatsApp verification';

  @override
  String get driverPasswordResetWaBody =>
      'Open WhatsApp and send the message. When we receive it, return to the app to create your new password.';

  @override
  String get driverPasswordResetWaWaiting =>
      'Waiting for the WhatsApp message…';

  @override
  String get driverPasswordResetEmailMissingBody =>
      'We did not find an email on your account. Enter one to receive the code. We will save it when you reset the password.';

  @override
  String get driverPasswordResetEmailLabel => 'Email';

  @override
  String get driverPasswordResetSendCode => 'Send code';

  @override
  String driverPasswordResetEmailCodeBody(String email) {
    return 'Enter the code we sent to $email and create your new password.';
  }

  @override
  String get driverPasswordResetEmailFallback => 'your email';

  @override
  String get driverPasswordResetCodeLabel => 'Code';

  @override
  String get driverPasswordResetNewPasswordBody =>
      'Number confirmed. Create a new password (at least 8 characters).';

  @override
  String get driverPasswordResetNewPassword => 'New password';

  @override
  String get driverPasswordResetConfirmPassword => 'Repeat password';

  @override
  String get driverPasswordResetSave => 'Save password';

  @override
  String get driverPasswordResetSuccess =>
      'Password updated. Sign in with your new password.';

  @override
  String get driverPasswordResetErrorNotFound =>
      'There is no driver account with that number.';

  @override
  String get driverPasswordResetErrorEmailRequired =>
      'Enter an email to receive the code.';

  @override
  String get driverPasswordResetErrorOtpInvalid => 'Incorrect or expired code.';

  @override
  String get driverPasswordResetErrorNotVerified =>
      'We have not confirmed the WhatsApp message yet. Send it and try again.';

  @override
  String get driverPasswordResetErrorRateLimit =>
      'Too many attempts. Wait a few minutes.';

  @override
  String get driverPasswordResetErrorWaUnavailable =>
      'WhatsApp is unavailable right now. Try email.';

  @override
  String get driverPasswordResetErrorEmailConflict =>
      'That email is already used by another account.';

  @override
  String get driverPasswordResetErrorMismatch => 'Passwords do not match.';

  @override
  String get driverPasswordResetErrorExpired =>
      'The WhatsApp message expired. Try again.';

  @override
  String get driverChangePasswordTitle => 'Create your password';

  @override
  String get driverChangePasswordLead =>
      'Support gave you a temporary password to sign in. For security, create your own password now.';

  @override
  String get driverChangePasswordCurrent => 'Temporary password';

  @override
  String get driverChangePasswordNew => 'New password';

  @override
  String get driverChangePasswordConfirm => 'Repeat new password';

  @override
  String get driverChangePasswordSave => 'Save and continue';

  @override
  String get driverChangePasswordSuccess => 'Password updated.';

  @override
  String get driverChangePasswordLogout => 'Sign out';

  @override
  String get driverChangePasswordErrorCurrent =>
      'The temporary password is incorrect.';

  @override
  String get driverChangePasswordErrorSame =>
      'The new password must be different from the temporary one.';

  @override
  String get driverChangePasswordErrorGeneric =>
      'Could not update the password.';
}
