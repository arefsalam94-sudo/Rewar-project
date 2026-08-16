import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../models/booking.dart';
import '../models/help_topic.dart';
import '../models/nature_detail.dart';
import '../models/nature_filters.dart';
import '../models/policy_topic.dart';

/// App localization for English, Kurdish (Sorani) and Arabic.
///
/// Hand-written (rather than generated) so it stays robust across Flutter
/// versions and gives full control over the Kurdish locale, which Flutter's
/// built-in localizations don't cover (handled via the fallback delegates
/// below — Kurdish reuses Arabic's Material/RTL localizations).
///
/// Access with `AppLocalizations.of(context)`.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ku'), // Kurdish (Sorani)
    Locale('ar'),
  ];

  /// The full delegate list for [MaterialApp] (and tests). Kurdish fallback
  /// delegates come first so they win for `ku`; everything else is handled by
  /// the standard global delegates.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        _KurdishMaterialDelegate(),
        _KurdishCupertinoDelegate(),
        _KurdishWidgetsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static const Map<String, Map<String, String>>
  _values = <String, Map<String, String>>{
    'en': <String, String>{
      'chooseYourLanguage': 'Choose Your Language',
      'selectLanguageToContinue': 'Select a language to continue',
      'logIn': 'Log In',
      'email': 'Email',
      'password': 'Password',
      'forgetPassword': 'Forget Password',
      'orLabel': 'Or',
      'dontHaveAccount': "Don't have an account? ",
      'registerNow': 'Register Now',
      'continueAsGuest': 'Continue as Guest',
      'emailRequired': 'Please enter your email',
      'emailInvalid': 'Enter a valid email address',
      'passwordRequired': 'Please enter your password',
      'forgetPasswordSubtitle':
          'Please select your contact details and we will send a '
          'verification code to reset your password.',
      'phoneNumber': 'Phone number',
      'emailAddress': 'Email address',
      'sendCode': 'Send Code',
      'selectContactMethod': 'Choose phone or email first',
      'verificationCode': 'Verification Code',
      // {dest} is replaced with the masked phone/email, rendered in bold.
      'verificationSubtitle':
          'Enter the 6-digit code we just sent to {dest} to reset your '
          'password.',
      'didntReceiveCode': "Didn't receive the code? ",
      'resendNow': 'Resend now',
      'resendIn': 'Resend in {seconds}s',
      'verify': 'Verify',
      'codeIncomplete': 'Enter all 6 digits of the code',
      'codeIncorrect': 'That code is not correct. Please try again.',
      'codeExpired': 'This code has expired. Request a new one.',
      'tooManyAttempts': 'Too many attempts. Please wait before trying again.',
      'codeResentPhone': 'A new code has been sent by SMS',
      'codeResentEmail': 'A new code has been sent to your email',
      'sendCodeFailed': "We couldn't send the code. Please try again.",
      'networkError': 'No connection. Check your network and try again.',
      'resetPassword': 'Reset Password',
      'resetPasswordSubtitle':
          'At least 8 characters, with uppercase, lowercase and special '
          'character.',
      'newPassword': 'New Password',
      'confirmPassword': 'Confirm Password',
      'updatePassword': 'Update Password',
      'passwordTooShort': 'Use at least 8 characters',
      'passwordNeedsUppercase': 'Add at least one uppercase letter',
      'passwordNeedsLowercase': 'Add at least one lowercase letter',
      'passwordNeedsSpecial': 'Add at least one special character',
      'confirmPasswordRequired': 'Please re-enter the new password',
      'passwordsDontMatch': 'The two passwords do not match',
      'passwordUpdated': 'Password updated. Please log in.',
      'passwordUpdateFailed':
          "We couldn't update your password. Please try again.",
      'passwordTooWeak': 'Please choose a stronger password',
      'sessionExpired': 'Your session expired. Please start again.',
      // --- Register screen ---
      'register': 'Register',
      'fullName': 'Full Name',
      'age': 'Age',
      'gender': 'Gender',
      'genderMale': 'Male',
      'genderFemale': 'Female',
      'genderOther': 'Other',
      'genderOptional': 'Gender (optional)',
      'alreadyHaveAccount': 'Already have an Account? ',
      'logInHere': 'Log In here',
      'passwordHint':
          'At least 8 characters, with uppercase, lowercase and special '
          'character.',
      'acceptTerms': 'I agree to the Terms of Service and Privacy Policy',
      'termsRequired': 'Please accept the Terms and Privacy Policy',
      'fullNameRequired': 'Please enter your full name',
      'fullNameTooShort': 'Please enter your full name',
      'dateOfBirthRequired': 'Please choose your date of birth',
      'mustBe18': 'You must be at least 18 to create an account',
      'phoneRequired': 'Please enter your phone number',
      'phoneInvalid': 'Enter a valid phone number',
      'selectCountryCode': 'Country code',
      'accountCreated': 'Account created. Please log in.',
      'registerFailed': "We couldn't create your account. Please try again.",
      'emailInUse': 'An account already exists with this email',
      'phoneInUse': 'An account already exists with this phone number',
      'verifyNumberSubtitle':
          'Enter the 6-digit code we just sent to {dest} to verify your '
          'number.',
      'verifyEmailTitle': 'Verify your email',
      'verifyEmailSubtitle':
          'Enter the 6-digit code we just sent to {dest} to confirm your '
          'email address.',
      'emailVerified': 'Your email is verified.',
      // --- Terms of Service screen ---
      'termsOfService': 'Terms of Service',
      'termsAgreeCheckbox':
          'I have read and agree to the Terms of Service and Privacy Policy.',
      'continueLabel': 'Continue',
      'lastUpdated': 'Last updated: {date}',
      'termsLoadFailed': "We couldn't load the Terms. Please try again.",
      'tryAgain': 'Try again',
      'termsNotReviewed':
          'Draft wording — pending legal review. Not for release.',
      // --- Account Setup screen ---
      'accountSetup': 'Account Setup',
      'accountSetupSubtitle':
          'Finish your account setup by uploading profile picture and set '
          'your username.',
      'username': 'Username',
      'createAccount': 'Create Account',
      'chooseFromGallery': 'Choose from gallery',
      'takePhoto': 'Take a photo',
      'removePhoto': 'Remove photo',
      'usernameRequired': 'Please enter a username',
      'usernameTooShort': 'Use at least 2 characters',
      'imageTooLarge': 'That picture is too large. Choose one under 5 MB.',
      'imagePickFailed': "We couldn't open that picture. Please try again.",
      'profileSaveFailed': "We couldn't save your profile. Please try again.",
      'cameraPermissionDenied':
          'Camera access is off. Turn it on in Settings to take a photo.',
      'galleryPermissionDenied':
          'Photo access is off. Turn it on in Settings to choose a picture.',
      // --- Register Complete screen ---
      'registerComplete': 'Register Complete!',
      'registerCompleteSubtitle':
          'You have successfully created your account. Welcome!',
      'explore': 'Explore',
      // --- Onboarding (3-slide intro) ---
      // The title is two separate lines because each uses a different font:
      // line 1 Corbel Regular, line 2 Unbounded Medium.
      'onboardingTitleLine1': 'Discover',
      'onboardingTitleLine2': 'Kurdistan',
      // The only hard line break is before the closing sentence; the rest is
      // left to wrap naturally so longer translations don't break the layout.
      'onboardingBody1':
          'Explore beautiful valleys, rivers, and mountain trails that few '
          'travelers ever reach.\nAll in one app.',
      // Slide 2. One sentence with no hard break — it wraps to two lines on
      // its own, as the reference shows.
      'onboardingTitle2Line1': 'Fly to',
      'onboardingTitle2Line2': 'Kurdistan',
      'onboardingBody2':
          'Compare flights, pick your dates and book your ticket in minutes.',
      // Slide 3.
      'onboardingTitle3Line1': 'Your Ride',
      'onboardingTitle3Line2': 'Is Ready !',
      'onboardingBody3':
          'Rent a car and reach every corner of Kurdistan on your own '
          'schedule.',
      'onboardingNext': 'Next',
      // --- Home screen ---
      'goodMorning': 'Good morning',
      'goodAfternoon': 'Good afternoon',
      'goodEvening': 'Good evening',
      'dearUser': 'Dear User',
      'whereWouldYouLikeToGo': 'Where would you like to go?',
      'planYourJourney': 'Plan your journey',
      'exploreNature': 'Explore Nature',
      'exploreNatureHint': 'Trails, lakes & breathtaking parks.',
      'whereToStay': 'Where to Stay',
      'whereToStayHint': 'Hotels, cabins & unique stays',
      'bestPrice': 'Best Price',
      'carRental': 'Car Rental',
      'carRentalHint': 'Find the perfect car for your adventure',
      'findACar': 'Find a Car',
      'flightTicketing': 'Flight Ticketing',
      'flightTicketingHint': 'Cheap flights, easy booking, secure payments',
      'findFlight': 'Find Flight',
      'exploreToursTitle': 'Explore Tours',
      'exploreToursHint': 'Local experiences, hidden gems & expert guides',
      'findTours': 'Find Tours',
      'placesCount': '{count}+ places',
      'navHome': 'Home',
      'navTrips': 'Trips',
      'navMap': 'Map',
      'navSaved': 'Saved',
      'featuredLoadFailed': "Couldn't load featured destinations",
      'featuredEmpty': 'Nothing is featured yet',
      'signInToSave': 'Sign in to save favourites',
      'signInToSaveBody':
          'Create an account or log in to keep your favourite places.',
      'notNow': 'Not now',
      'addedToFavorites': 'Added to your favourites',
      'removedFromFavorites': 'Removed from your favourites',
      'favoriteFailed': "Couldn't update your favourites",
      'comingSoon': 'Coming soon',
      'mapOpenFailed': "Couldn't open the maps app",
      'menu': 'Menu',
      'changeLanguage': 'Change language',
      // --- Home screen side drawer ---
      'close': 'Close',
      'services': 'Services',
      'myBookings': 'My Bookings',
      'billingPayments': 'Billing/Payments',
      'billingPaymentTitle': 'Billing & Payments',
      'currentPaymentMethod': 'Current Payment Method',
      'addPaymentMethod': 'Add a payment method',
      'addPaymentMethodDescription':
          'Save your debit or credit card to pay for hotels, flights, car rentals, and tours.',
      'paymentInformationEncrypted':
          'Your payment information is securely encrypted.',
      'addCard': 'Add Card',
      'debitOrCreditCard': 'Debit or Credit Card',
      'secureCheckout': 'Secure checkout',
      'secureCardSetupUnavailable': 'Secure card setup is coming soon.',
      'paymentMethodAlreadyAdded':
          'A payment method is already linked to your account.',
      'newCard': 'New Card',
      'newCardDescription':
          'Add a card for faster checkout on future bookings.',
      'cardDetails': 'Card Details',
      'cardholderName': 'Cardholder Name',
      'cardNumber': 'Card Number',
      'expiryDate': 'Expiry Date',
      'expiryHint': 'MM/YY',
      'cvv': 'CVV',
      'country': 'Country',
      'yourCountry': 'Your country',
      'zipCode': 'ZIP Code',
      'optional': 'Optional',
      'saveCardForFutureBookings': 'Save this card for future bookings',
      'editPaymentMethodLater':
          'You can edit or remove this payment method later from Billing & Payment.',
      'requiredField': 'This field is required.',
      'invalidCardNumber': 'Enter a valid card number.',
      'invalidExpiryDate': 'Enter a valid future date.',
      'invalidCvv': 'Enter a valid CVV.',
      'editProfile': 'Edit Profile',
      'editProfileSubtitle': 'Update your photo and full name.',
      'firstAndLastName': 'First and last name',
      'firstName': 'First name',
      'lastName': 'Last name',
      'firstAndLastNameRequired': 'Enter both your first and last name.',
      'saveChanges': 'Save Changes',
      'profileUpdated': 'Your profile was updated.',
      'settingsUpdateFailed': 'Could not update this setting. Try again.',
      'changeEmail': 'Change Email',
      'changeEmailSubtitle':
          'Confirm your password, then verify the new email address.',
      'confirmEmailIdentitySubtitle':
          'Enter your current account email and app password to confirm your identity.',
      'currentEmail': 'Current email',
      'newEmail': 'New email',
      'newEmailVerificationSubtitle':
          'Enter the new email and the 6-digit verification code we send there.',
      'emailUpdated': 'Your email was updated.',
      'currentPassword': 'Current password',
      'enterValidEmail': 'Enter a valid email address.',
      'sendVerificationLink': 'Send Verification Link',
      'emailVerificationSent':
          'Verification sent. Your email changes after you approve the link.',
      'reauthenticationFailed': 'Your current password could not be verified.',
      'changePhoneNumber': 'Change Phone Number',
      'changePhoneSubtitle': 'We will send an SMS code to verify this number.',
      'newPhoneNumber': 'New phone number',
      'phoneInternationalFormat': 'Use international format, such as +964…',
      'verificationCodeSent': 'Verification code sent.',
      // 'verificationCode' and 'sendCode' already exist earlier in this map.
      'verifyAndSave': 'Verify & Save',
      'invalidVerificationCode': 'The verification code is invalid.',
      'passwordChangeRules':
          'Use at least 8 characters, one uppercase letter, and one symbol.',
      'kilometers': 'Kilometers (km)',
      'miles': 'Miles (mi)',
      'milesShort': 'mi',
      'defaultPayment': 'Default',
      'debitCard': 'Debit Card',
      'creditCard': 'Credit Card',
      'kurdistanInternationalBank': 'Kurdistan International Bank',
      'firstIraqiBank': 'First Iraqi Bank',
      'newlyAddedCard': 'Newly added card',
      'savedCard': 'Saved card',
      'add': 'Add',
      'change': 'Change',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'setDefaultCard': 'Set default card',
      'setDefaultCardBody': 'This card will be used for new bookings.',
      'defaultCardUpdated': 'Default card updated',
      'deleteCardTitle': 'Delete this card?',
      'deleteCardBody':
          'The card ending {last4} will be removed from your saved payment '
          'methods. You can add it again at any time.',
      'cardDeleted': 'Card removed',
      'cardAdded': 'Card added',
      'billingSignInTitle': 'Sign in to manage payment',
      'billingSignInBody':
          'Your saved cards are tied to your account, so we need you signed in '
          'to show them.',
      'photoSignInTitle': 'Sign in to add a photo',
      'photoSignInBody':
          'Your profile picture is saved to your account, so we need you '
          'signed in to change it.',
      'paymentHistory': 'Payment History',
      'paid': 'Paid',
      'pending': 'Pending',
      'viewReceipt': 'View Receipt',
      'hotel': 'Hotel',
      'flight': 'Flight',
      'car': 'Car',
      'tour': 'Tour',
      'mountainViewResort': 'Mountain View Resort',
      'erbilToIstanbul': 'Erbil → Istanbul',
      'suvRental': 'SUV Rental',
      'rawanduzCanyonAdventure': 'Rawanduz Canyon Adventure',
      'paymentDateMay24': 'May 24, 2025',
      'paymentDateMay23': 'May 23, 2025',
      'paymentDateMay25': 'May 25, 2025',
      'paymentDateMay26': 'May 26, 2025',
      'settings': 'Settings',
      'settingsAccount': 'Account',
      'settingsChangePassword': 'Change password',
      'settingsPreferences': 'Preferences',
      'settingsNotifications': 'Notifications',
      'settingsTheme': 'Theme',
      'settingsLanguage': 'Language',
      'settingsUnits': 'Units',
      'settingsSecurityLegal': 'Security & legal',
      'settingsSecurityPrivacy': 'Security & privacy',
      'settingsDeleteAccount': 'Delete account',
      'notificationsPermissionDenied':
          'Notification permission was not granted.',
      'notificationsUpdateFailed':
          "We couldn't update notifications. Please try again.",
      'languageEnglish': 'English',
      'languageKurdish': 'Kurdish',
      'languageArabic': 'Arabic',
      'kilometersShort': 'Km',
      'currency': 'Currency',
      'policy': 'Policy',
      'helpSupport': 'Help/Support',
      'aboutUs': 'About Us',
      'contactWay': 'Contact Way',
      'logOut': 'Log Out',
      'guestUser': 'Guest',
      'guestDrawerPrompt': 'Sign in to see your profile',
      'signInRequired': 'Please sign in first',
      'selectCurrency': 'Select Currency',
      'currencyUSD': 'US Dollar (USD)',
      'currencyIQD': 'Iraqi Dinar (IQD)',
      'currencyEUR': 'Euro (EUR)',
      'currencyUpdated': 'Currency updated',
      'currencyUpdateFailed':
          "We couldn't update your currency. Please try again.",
      'logOutFailed': "We couldn't log you out. Please try again.",
      'profilePhotoUpdated': 'Profile photo updated',
      // --- Explore Nature screen ---
      'filterHiking': 'Hiking',
      'filterBeach': 'Beach',
      'filterSunsetView': 'Sunset View',
      'filterCustomize': 'Customize',
      'locationLabel': 'Location:',
      'distanceLabel': 'Distance:',
      'distanceFromCurrentLocation': '{distance} from current location',
      'natureSpotsLoadFailed': "Couldn't load places. Please try again.",
      'natureSpotsEmpty': 'No places match these filters yet',
      'highlightedEmpty': 'Nothing is highlighted yet',
      'clearFilters': 'Clear filters',
      'aboutThisPlace': 'About this place',
      'placeNameLabel': 'Name:',
      'placeDistanceLabel': 'Distance:',
      'suggestedStaysNearby': 'Suggested stays nearby',
      'stayDistanceAway': '{distance} km away',
      'weather': 'Weather',
      'weatherUnavailable': 'Weather is unavailable right now',
      'sunny': 'Sunny',
      'partlyCloudy': 'Partly cloudy',
      'cloudy': 'Cloudy',
      'rainy': 'Rainy',
      'snowy': 'Snowy',
      'ratingsAndReviews': 'Ratings & Reviews',
      'basedOnReviews': 'Based on {count} reviews',
      'writeReviewPrompt': 'Visited this place?',
      'writeReviewHint': 'Tap here to rate your visit and write a comment',
      'reviewsLoadFailed': "Couldn't load visitor reviews",
      'noReviewsYet': 'No reviews yet. Be the first to share your visit.',
      'seeAllReviews': 'See all reviews',
      'openPlaceMap': 'Open place map',
      'reviewsCount': '{count} reviews',
      // --- Reviews & Ratings screen ---
      'reviewsAndRatings': 'Reviews & Ratings',
      'averageRating': 'Average Rating',
      'outOfTen': '/ 10',
      'allReviews': 'All Reviews',
      'sortMostRecent': 'Most Recent',
      'sortHighestRated': 'Highest Rated',
      'sortLowestRated': 'Lowest Rated',
      'sortMostHelpful': 'Most Helpful',
      'sortReviewsBy': 'Sort reviews by',
      'oneReview': '1 review',
      'noRatingsYet': 'Not rated yet',
      'addYourReview': 'Add your review',
      'yourRating': 'Your rating',
      'reviewCommentHint': 'Tell others about your experience…',
      'postReview': 'Post Review',
      'updateReview': 'Update Review',
      'reviewPosted': 'Thanks — your review is live',
      'reviewUpdated': 'Your review has been updated',
      'reviewPostFailed': "We couldn't post your review. Please try again.",
      'reviewRatingRequired': 'Choose a star rating first',
      'reviewCommentTooShort': 'Write at least 3 characters',
      'reviewCommentTooLong': 'Keep your review under 1000 characters',
      'reviewSignInTitle': 'Sign in to write a review',
      'reviewSignInBody':
          'Reviews are tied to your account, so everyone can see who visited.',
      'yourReviewLabel': 'Your review',
      'editYourReview': 'Edit your review',
      'helpfulVote': 'Mark this review as helpful',
      'helpfulVoteRemove': 'Remove your helpful vote',
      'helpfulSignInBody': 'Sign in to tell others a review was helpful.',
      'helpfulFailed': "We couldn't save your vote. Please try again.",
      'loadMoreReviews': 'Show more reviews',
      'reviewJustNow': 'Just now',
      'reviewHoursAgo': '{count} hours ago',
      'reviewOneHourAgo': '1 hour ago',
      'reviewDaysAgo': '{count} days ago',
      'reviewOneDayAgo': '1 day ago',
      'reviewWeeksAgo': '{count} weeks ago',
      'reviewOneWeekAgo': '1 week ago',
      'reviewMonthsAgo': '{count} months ago',
      'reviewOneMonthAgo': '1 month ago',
      'reviewYearsAgo': '{count} years ago',
      'reviewOneYearAgo': '1 year ago',
      // --- Customize Filters screen ---
      'customizeFilters': 'Customize Filters',
      'customizeFiltersSubtitle': 'Find places that match your trip',
      'filtersSelected': '{count} Filters selected',
      'oneFilterSelected': '1 Filter selected',
      'noFiltersSelected': 'No filters selected',
      'resetAll': 'Reset All',
      'placeType': 'Place Type',
      'facilitiesAmenities': 'Facilities & Amenities',
      'showPlaces': 'Show {count} Places',
      'showOnePlace': 'Show 1 Place',
      'showNoPlaces': 'No places match',
      'placeTypeForest': 'Forest',
      'placeTypeMountain': 'Mountain',
      'placeTypeCanyon': 'Canyon',
      'placeTypePark': 'Park',
      'placeTypeLake': 'Lake',
      'placeTypeWaterfall': 'Waterfall',
      'placeTypeRiver': 'River',
      'placeTypeMuseum': 'Museum',
      'amenityParking': 'Parking',
      'amenityRestrooms': 'Restrooms',
      'amenityRestaurants': 'Restaurants',
      'amenityCafes': 'Cafes',
      'amenityMobileSignal': 'Mobile signal',
      'amenityLodgingNearby': 'Lodging nearby',
      'amenityAtmNearby': 'ATM nearby',
      // --- Policy screen ---
      'policyOfApp': 'Policy of App',
      'policyOfAppSubtitle':
          'Read our guidelines and policies to learn how we protect you.',
      'policyPrivacyTitle': 'Privacy Policy',
      'policyPrivacySubtitle': 'How we handle your data',
      'policyTermsTitle': 'Terms & Conditions',
      'policyTermsSubtitle': 'Rules for using the app',
      'policyCancellationTitle': 'Cancellation & Refunds',
      'policyCancellationSubtitle': 'Changing or cancelling bookings',
      'policyPaymentTitle': 'Payment Policy',
      'policyPaymentSubtitle': 'Methods, currency & charges',
      'policyLiabilityTitle': 'Liability & Disclaimer',
      'policyLiabilitySubtitle': 'Limits of our responsibility',
      'policyContactTitle': 'Contact & Complaints',
      'policyContactSubtitle': 'Reach support',
      'policyAccountDeletionTitle': 'Account & Data Deletion',
      'policyAccountDeletionSubtitle': 'Delete your account and your data',
      'policyLoadFailed': "We couldn't load this policy. Please try again.",
      // --- Help & Support screen ---
      'helpAndSupport': 'Help & Support',
      'helpAccountTitle': 'Account & Sign-in',
      'helpAccountPreview': 'How do I change my email or ...',
      'helpBookingsTitle': 'Bookings & Confirmation',
      'helpBookingsPreview': 'What is my booking reference ...',
      'helpPaymentsTitle': 'Payments & Refunds',
      'helpPaymentsPreview': 'My payment failed but I ...',
      'helpCancellationTitle': 'Cancellation & Changes',
      'helpCancellationPreview': 'Can I change my booking instead ...',
      'helpFlightsTitle': 'Flights',
      'helpFlightsPreview': 'What is the baggage allowance ...',
      'helpStaysTitle': 'Where to Stay (Hotels)',
      'helpStaysPreview': 'What are the check-in and ...',
      'helpCarRentalTitle': 'Car Rental',
      'helpCarRentalPreview': 'What documents do I need to ...',
      'helpToursTitle': 'Tours & Nature (Explore)',
      'helpToursPreview': 'What happens if the weather ...',
      'helpSafetyTitle': 'Safety & Travel Info',
      'helpSafetyPreview': 'What are the emergency numbers in ...',
      'helpContactTitle': 'Still need help? Contact us',
      'helpContactPreview': 'Get in touch with our support team ...',
      // --- My Bookings screen ---
      'bookingsFilterAll': 'All',
      'bookingsFilterHotels': 'Hotels',
      'bookingsFilterCars': 'Cars',
      'bookingsFilterFlights': 'Flights',
      'bookingsFilterTours': 'Tours',
      'bookingsSegmentUpcoming': 'Upcoming',
      'bookingsSegmentPast': 'Past',
      'bookingsSegmentCancelled': 'Cancelled',
      'bookingTypeHotel': 'HOTEL',
      'bookingTypeCar': 'CAR RENTAL',
      'bookingTypeFlight': 'FLIGHT',
      'bookingTypeTour': 'TOUR',
      'bookingStatusConfirmed': 'CONFIRMED',
      'bookingStatusPending': 'PENDING',
      'bookingStatusCancelled': 'CANCELLED',
      'bookingStatusCompleted': 'COMPLETED',
      'bookingStatusUpcoming': 'UPCOMING',
      'cabinEconomy': 'ECONOMY',
      'cabinPremiumEconomy': 'PREMIUM',
      'cabinBusiness': 'BUSINESS',
      'cabinFirst': 'FIRST',
      'bookingCheckIn': 'Check-in',
      'bookingCheckOut': 'Check-out',
      'bookingGuests': 'Guests',
      'bookingTravelers': 'Travelers',
      'bookingDriver': 'Driver',
      'bookingTraveler': 'Traveler',
      'bookingSeat': 'Seat',
      'bookingDuration': 'Duration',
      'bookingId': 'Booking ID',
      'bookingPickup': 'Pick-up',
      'bookingDropoff': 'Drop-off',
      'bookingTotalPaid': 'Total paid',
      'bookingActionCheckIn': 'Check In',
      'bookingActionOpenTicket': 'Open Ticket',
      'bookingActionPickupInfo': 'Pickup Info',
      'bookingActionTourDetails': 'Tour Details',
      'bookingActionViewDetails': 'View Details',
      'bookingAdultsCount': '{count} Adults',
      'bookingAdultCount': '{count} Adult',
      'bookingHours': '{count} Hours',
      'bookingsLoadFailed': "Couldn't load your bookings",
      'bookingsEmptyTitle': 'No bookings yet',
      'bookingsEmptyBody':
          'When you book a hotel, flight, car or tour, it will appear here.',
      'bookingsEmptyUpcoming': 'No upcoming bookings',
      'bookingsEmptyPast': 'No past bookings',
      'bookingsEmptyCancelled': 'No cancelled bookings',
      'bookingsEmptyFiltered':
          'Nothing matches this filter. Try another category.',
      'bookingsSignInTitle': 'Sign in to see your bookings',
      'bookingsSignInBody':
          'Your bookings are tied to your account, so we need you signed in to show them.',
      'bookingsStartExploring': 'Start exploring',
      // Month names and meridiems, for the booking date/time rows. Written out
      // here rather than taken from `intl`, which has no Kurdish (`ku`) locale.
      'month1': 'January',
      'month2': 'February',
      'month3': 'March',
      'month4': 'April',
      'month5': 'May',
      'month6': 'June',
      'month7': 'July',
      'month8': 'August',
      'month9': 'September',
      'month10': 'October',
      'month11': 'November',
      'month12': 'December',
      'timeAm': 'AM',
      'timePm': 'PM',
    },
    'ku': <String, String>{
      'chooseYourLanguage': 'زمانەکەت هەڵبژێرە',
      'selectLanguageToContinue': 'زمانێک هەڵبژێرە بۆ بەردەوامبوون',
      'logIn': 'چوونەژوورەوە',
      'email': 'ئیمەیڵ',
      'password': 'وشەی نهێنی',
      'forgetPassword': 'وشەی نهێنیت لەبیرچووە؟',
      'orLabel': 'یان',
      'dontHaveAccount': 'هەژمارت نییە؟ ',
      'registerNow': 'خۆت تۆمار بکە',
      'continueAsGuest': 'وەک میوان بەردەوام بە',
      'emailRequired': 'تکایە ئیمەیڵەکەت بنووسە',
      'emailInvalid': 'ئیمەیڵێکی دروست بنووسە',
      'passwordRequired': 'تکایە وشەی نهێنییەکەت بنووسە',
      'forgetPasswordSubtitle':
          'تکایە زانیارییەکانی پەیوەندیت هەڵبژێرە و ئێمە کۆدێکی '
          'پشتڕاستکردنەوەت بۆ دەنێرین بۆ ڕێکخستنەوەی وشەی نهێنی.',
      'phoneNumber': 'ژمارەی مۆبایل',
      'emailAddress': 'ناونیشانی ئیمەیڵ',
      'sendCode': 'کۆد بنێرە',
      'selectContactMethod': 'سەرەتا مۆبایل یان ئیمەیڵ هەڵبژێرە',
      'verificationCode': 'کۆدی پشتڕاستکردنەوە',
      'verificationSubtitle':
          'ئەو کۆدە ٦ ژمارەییە بنووسە کە ئێستا ناردمان بۆ {dest} بۆ '
          'ڕێکخستنەوەی وشەی نهێنییەکەت.',
      'didntReceiveCode': 'کۆدەکەت پێنەگەیشت؟ ',
      'resendNow': 'دووبارە بینێرە',
      'resendIn': 'دووبارە ناردن لە {seconds} چرکەدا',
      'verify': 'پشتڕاستکردنەوە',
      'codeIncomplete': 'هەر ٦ ژمارەکەی کۆدەکە بنووسە',
      'codeIncorrect': 'ئەم کۆدە دروست نییە. تکایە دووبارە هەوڵ بدەوە.',
      'codeExpired': 'ئەم کۆدە بەسەرچووە. کۆدێکی نوێ بخوازە.',
      'tooManyAttempts':
          'هەوڵی زۆر درا. تکایە پێش هەوڵدانەوە کەمێک چاوەڕێ بکە.',
      'codeResentPhone': 'کۆدێکی نوێ بە نامەی کورت نێردرا',
      'codeResentEmail': 'کۆدێکی نوێ بۆ ئیمەیڵەکەت نێردرا',
      'sendCodeFailed': 'نەمانتوانی کۆدەکە بنێرین. تکایە دووبارە هەوڵ بدەوە.',
      'networkError':
          'پەیوەندی نییە. تکایە ئینتەرنێتەکەت بپشکنە و دووبارە هەوڵ بدەوە.',
      'resetPassword': 'ڕێکخستنەوەی وشەی نهێنی',
      'resetPasswordSubtitle':
          'لانیکەم ٨ پیت، بە پیتی گەورە و پیتی بچووک و هێمایەکی تایبەت.',
      'newPassword': 'وشەی نهێنی نوێ',
      'confirmPassword': 'دووبارەکردنەوەی وشەی نهێنی',
      'updatePassword': 'نوێکردنەوەی وشەی نهێنی',
      'passwordTooShort': 'لانیکەم ٨ پیت بەکاربهێنە',
      'passwordNeedsUppercase': 'لانیکەم یەک پیتی گەورە زیاد بکە',
      'passwordNeedsLowercase': 'لانیکەم یەک پیتی بچووک زیاد بکە',
      'passwordNeedsSpecial': 'لانیکەم یەک هێمای تایبەت زیاد بکە',
      'confirmPasswordRequired': 'تکایە وشەی نهێنییە نوێیەکە دووبارە بنووسە',
      'passwordsDontMatch': 'هەردوو وشەی نهێنییەکە وەک یەک نین',
      'passwordUpdated': 'وشەی نهێنی نوێکرایەوە. تکایە بچۆرە ژوورەوە.',
      'passwordUpdateFailed':
          'نەمانتوانی وشەی نهێنییەکەت نوێ بکەینەوە. تکایە دووبارە هەوڵ بدەوە.',
      'passwordTooWeak': 'تکایە وشەیەکی نهێنی بەهێزتر هەڵبژێرە',
      'sessionExpired':
          'دانیشتنەکەت بەسەرچوو. تکایە لە سەرەتاوە دەست پێ بکەوە.',
      // --- Register screen ---
      'register': 'خۆتۆمارکردن',
      'fullName': 'ناوی تەواو',
      'age': 'تەمەن',
      'gender': 'ڕەگەز',
      'genderMale': 'نێر',
      'genderFemale': 'مێ',
      'genderOther': 'هیتر',
      'genderOptional': 'ڕەگەز (ئارەزوومەندانە)',
      'alreadyHaveAccount': 'پێشتر هەژمارت هەیە؟ ',
      'logInHere': 'لێرە بچۆرە ژوورەوە',
      'passwordHint':
          'لانیکەم ٨ پیت، بە پیتی گەورە و پیتی بچووک و هێمایەکی تایبەت.',
      'acceptTerms': 'ڕازیم بە مەرجەکانی بەکارهێنان و سیاسەتی تایبەتمەندی',
      'termsRequired': 'تکایە ڕەزامەندی بدە بە مەرجەکان و سیاسەتی تایبەتمەندی',
      'fullNameRequired': 'تکایە ناوی تەواوت بنووسە',
      'fullNameTooShort': 'تکایە ناوی تەواوت بنووسە',
      'dateOfBirthRequired': 'تکایە بەرواری لەدایکبوونت هەڵبژێرە',
      'mustBe18': 'دەبێت لانیکەم تەمەنت ١٨ ساڵ بێت بۆ دروستکردنی هەژمار',
      'phoneRequired': 'تکایە ژمارەی مۆبایلەکەت بنووسە',
      'phoneInvalid': 'ژمارەیەکی مۆبایلی دروست بنووسە',
      'selectCountryCode': 'کۆدی وڵات',
      'accountCreated': 'هەژمارەکە دروستکرا. تکایە بچۆرە ژوورەوە.',
      'registerFailed':
          'نەمانتوانی هەژمارەکەت دروست بکەین. تکایە دووبارە هەوڵ بدەوە.',
      'emailInUse': 'هەژمارێک بەم ئیمەیڵە هەیە',
      'phoneInUse': 'هەژمارێک بەم ژمارە مۆبایلە هەیە',
      'verifyNumberSubtitle':
          'ئەو کۆدە ٦ ژمارەییە بنووسە کە ئێستا ناردمان بۆ {dest} بۆ '
          'پشتڕاستکردنەوەی ژمارەکەت.',
      'verifyEmailTitle': 'ئیمەیڵەکەت پشتڕاست بکەرەوە',
      'verifyEmailSubtitle':
          'ئەو کۆدە ٦ ژمارەییە بنووسە کە ئێستا ناردمان بۆ {dest} بۆ '
          'پشتڕاستکردنەوەی ئیمەیڵەکەت.',
      'emailVerified': 'ئیمەیڵەکەت پشتڕاست کرایەوە.',
      // --- Terms of Service screen ---
      'termsOfService': 'مەرجەکانی بەکارهێنان',
      'termsAgreeCheckbox':
          'خوێندمەوە و ڕازیم بە مەرجەکانی بەکارهێنان و سیاسەتی تایبەتمەندی.',
      'continueLabel': 'بەردەوامبوون',
      'lastUpdated': 'دوایین نوێکردنەوە: {date}',
      'termsLoadFailed':
          'نەمانتوانی مەرجەکان باربکەین. تکایە دووبارە هەوڵ بدەوە.',
      'tryAgain': 'دووبارە هەوڵ بدەوە',
      'termsNotReviewed':
          'دەقی سەرەتایی — چاوەڕوانی پێداچوونەوەی یاسایی. بۆ بڵاوکردنەوە نییە.',
      // --- Account Setup screen ---
      'accountSetup': 'ڕێکخستنی هەژمار',
      'accountSetupSubtitle':
          'ڕێکخستنی هەژمارەکەت تەواو بکە بە بارکردنی وێنەی پرۆفایل و '
          'دیارکردنی ناوی بەکارهێنەر.',
      'username': 'ناوی بەکارهێنەر',
      'createAccount': 'دروستکردنی هەژمار',
      'chooseFromGallery': 'لە گەلەری هەڵبژێرە',
      'takePhoto': 'وێنەیەک بگرە',
      'removePhoto': 'وێنەکە لاببە',
      'usernameRequired': 'تکایە ناوی بەکارهێنەر بنووسە',
      'usernameTooShort': 'لانیکەم ٢ پیت بەکاربهێنە',
      'imageTooLarge':
          'ئەم وێنەیە زۆر گەورەیە. یەکێک هەڵبژێرە کە لە ٥ مێگابایت کەمتر بێت.',
      'imagePickFailed':
          'نەمانتوانی ئەم وێنەیە بکەینەوە. تکایە دووبارە هەوڵ بدەوە.',
      'profileSaveFailed':
          'نەمانتوانی پرۆفایلەکەت پاشەکەوت بکەین. تکایە دووبارە هەوڵ بدەوە.',
      'cameraPermissionDenied':
          'دەستڕاگەیشتن بە کامێرا کوژاوەتەوە. لە ڕێکخستنەکان بیکەوە.',
      'galleryPermissionDenied':
          'دەستڕاگەیشتن بە وێنەکان کوژاوەتەوە. لە ڕێکخستنەکان بیکەوە.',
      // --- Register Complete screen ---
      'registerComplete': 'تۆمارکردن تەواو بوو!',
      'registerCompleteSubtitle':
          'بە سەرکەوتوویی هەژمارەکەت دروستکرا. بەخێربێیت!',
      'explore': 'گەڕان',
      // --- Onboarding (3-slide intro) ---
      'onboardingTitleLine1': 'بدۆزەرەوە',
      'onboardingTitleLine2': 'کوردستان',
      'onboardingBody1':
          'بگەڕێ بەناو دۆڵە جوانەکان و ڕووبارەکان و ڕێڕەوە شاخاوییەکاندا کە '
          'کەم گەشتیار پێیان دەگات.\nهەمووی لە یەک ئەپدا.',
      'onboardingTitle2Line1': 'بفڕە بۆ',
      'onboardingTitle2Line2': 'کوردستان',
      'onboardingBody2':
          'بەراوردی فڕینەکان بکە، بەرواری خۆت هەڵبژێرە و لە چەند خولەکێکدا '
          'بلیتەکەت تۆمار بکە.',
      'onboardingTitle3Line1': 'ئۆتۆمبێلەکەت',
      'onboardingTitle3Line2': 'ئامادەیە !',
      'onboardingBody3':
          'ئۆتۆمبێلێک بەکرێ بگرە و بەپێی پلانی خۆت بگە بە هەموو گۆشەیەکی '
          'کوردستان.',
      'onboardingNext': 'دواتر',
      // --- Home screen ---
      'goodMorning': 'بەیانیت باش',
      'goodAfternoon': 'نیوەڕۆت باش',
      'goodEvening': 'ئێوارەت باش',
      'dearUser': 'بەکارهێنەری خۆشەویست',
      'whereWouldYouLikeToGo': 'دەتەوێت بۆ کوێ بچیت؟',
      'planYourJourney': 'گەشتەکەت پلان بکە',
      'exploreNature': 'گەڕان بە سروشتدا',
      'exploreNatureHint': 'ڕێڕەوەکان، دەریاچەکان و پارکە سەرنجڕاکێشەکان.',
      'whereToStay': 'شوێنی مانەوە',
      'whereToStayHint': 'هوتێل، کوخ و شوێنی مانەوەی تایبەت',
      'bestPrice': 'باشترین نرخ',
      'carRental': 'بەکرێدانی ئۆتۆمبێل',
      'carRentalHint': 'ئۆتۆمبێلی گونجاو بۆ سەرکێشییەکەت بدۆزەرەوە',
      'findACar': 'ئۆتۆمبێل بدۆزەرەوە',
      'flightTicketing': 'بلیتی فڕۆکە',
      'flightTicketingHint': 'فڕینی هەرزان، حیجزی ئاسان، پارەدانی پارێزراو',
      'findFlight': 'فڕین بدۆزەرەوە',
      'exploreToursTitle': 'گەڕان بە گەشتەکاندا',
      'exploreToursHint': 'ئەزموونی ناوخۆیی، شوێنە شاراوەکان و ڕێبەری شارەزا',
      'findTours': 'گەشت بدۆزەرەوە',
      'placesCount': '{count}+ شوێن',
      'navHome': 'ماڵەوە',
      'navTrips': 'گەشتەکان',
      'navMap': 'نەخشە',
      'navSaved': 'پاشەکەوتکراو',
      'featuredLoadFailed': 'نەتوانرا شوێنە هەڵبژێردراوەکان باربکرێن',
      'featuredEmpty': 'هێشتا هیچ شوێنێکی هەڵبژێردراو نییە',
      'signInToSave': 'بچۆ ژوورەوە بۆ پاشەکەوتکردن',
      'signInToSaveBody':
          'هەژمارێک دروست بکە یان بچۆ ژوورەوە بۆ هێشتنەوەی شوێنە '
          'دڵخوازەکانت.',
      'notNow': 'ئێستا نا',
      'addedToFavorites': 'زیادکرا بۆ دڵخوازەکانت',
      'removedFromFavorites': 'لابرا لە دڵخوازەکانت',
      'favoriteFailed': 'نەتوانرا دڵخوازەکانت نوێ بکرێنەوە',
      'comingSoon': 'بەم زووانە',
      'mapOpenFailed': 'نەتوانرا ئەپی نەخشە بکرێتەوە',
      'menu': 'لیستە',
      'changeLanguage': 'گۆڕینی زمان',
      // --- Home screen side drawer ---
      'close': 'داخستن',
      'services': 'خزمەتگوزارییەکان',
      'myBookings': 'حیجزەکانم',
      'billingPayments': 'پارەدان',
      'billingPaymentTitle': 'پسوڵە و پارەدانەکان',
      'currentPaymentMethod': 'شێوازی پارەدانی ئێستا',
      'addPaymentMethod': 'شێوازێکی پارەدان زیاد بکە',
      'addPaymentMethodDescription':
          'کارتی دێبیت یان کرێدیتەکەت هەڵبگرە بۆ پارەدانی هوتێل، فڕین، بەکرێگرتنی ئۆتۆمبێل و گەشتەکان.',
      'paymentInformationEncrypted':
          'زانیارییەکانی پارەدانت بە شێوەیەکی پارێزراو نهێنیکراون.',
      'addCard': 'کارت زیاد بکە',
      'debitOrCreditCard': 'کارتی دێبیت یان کرێدیت',
      'secureCheckout': 'پارەدانی پارێزراو',
      'secureCardSetupUnavailable':
          'ڕێکخستنی پارێزراوی کارت بەم زووانە بەردەست دەبێت.',
      'paymentMethodAlreadyAdded':
          'پێشتر شێوازێکی پارەدانت بە هەژمارەکەتەوە بەستووە.',
      'newCard': 'کارتی نوێ',
      'newCardDescription':
          'کارتێک زیاد بکە بۆ پارەدانی خێراتر لە حجزەکانی داهاتوو.',
      'cardDetails': 'وردەکارییەکانی کارت',
      'cardholderName': 'ناوی خاوەنی کارت',
      'cardNumber': 'ژمارەی کارت',
      'expiryDate': 'بەرواری بەسەرچوون',
      'expiryHint': 'MM/YY',
      'cvv': 'CVV',
      'country': 'وڵات',
      'yourCountry': 'وڵاتەکەت',
      'zipCode': 'کۆدی پۆستە',
      'optional': 'ئارەزوومەندانە',
      'saveCardForFutureBookings': 'ئەم کارتە بۆ حجزەکانی داهاتوو هەڵبگرە',
      'editPaymentMethodLater':
          'دەتوانیت دواتر لە پارەدان ئەم شێوازی پارەدانە دەستکاری یان بسڕیتەوە.',
      'requiredField': 'ئەم خانەیە پێویستە.',
      'invalidCardNumber': 'ژمارەی کارتێکی دروست بنووسە.',
      'invalidExpiryDate': 'بەروارێکی دروستی داهاتوو بنووسە.',
      'invalidCvv': 'CVV ـێکی دروست بنووسە.',
      'editProfile': 'دەستکاریکردنی پرۆفایل',
      'editProfileSubtitle': 'وێنە و ناوی تەواوت نوێ بکەرەوە.',
      'firstAndLastName': 'ناوی یەکەم و کۆتایی',
      'firstName': 'ناوی یەکەم',
      'lastName': 'ناوی کۆتایی',
      'firstAndLastNameRequired': 'ناوی یەکەم و کۆتایی بنووسە.',
      'saveChanges': 'پاشەکەوتکردنی گۆڕانکارییەکان',
      'profileUpdated': 'پرۆفایلەکەت نوێ کرایەوە.',
      'settingsUpdateFailed': 'نوێکردنەوە سەرکەوتوو نەبوو. دووبارە هەوڵ بدە.',
      'changeEmail': 'گۆڕینی ئیمەیڵ',
      'changeEmailSubtitle':
          'وشەی نهێنی پشتڕاست بکەرەوە، پاشان ئیمەیڵی نوێ بسەلمێنە.',
      'confirmEmailIdentitySubtitle':
          'ئیمەیڵ و وشەی نهێنی هەژمارەکەت بنووسە بۆ پشتڕاستکردنەوەی ناسنامەت.',
      'currentEmail': 'ئیمەیڵی ئێستا',
      'newEmail': 'ئیمەیڵی نوێ',
      'newEmailVerificationSubtitle':
          'ئیمەیڵە نوێیەکە و کۆدی ٦ ژمارەیی بنووسە کە بۆی دەنێرین.',
      'emailUpdated': 'ئیمەیڵەکەت نوێکرایەوە.',
      'currentPassword': 'وشەی نهێنی ئێستا',
      'enterValidEmail': 'ئیمەیڵێکی دروست بنووسە.',
      'sendVerificationLink': 'ناردنی بەستەری پشتڕاستکردنەوە',
      'emailVerificationSent': 'بەستەری پشتڕاستکردنەوە نێردرا.',
      'reauthenticationFailed': 'وشەی نهێنی ئێستا پشتڕاست نەکرایەوە.',
      'changePhoneNumber': 'گۆڕینی ژمارەی مۆبایل',
      'changePhoneSubtitle': 'کۆدی SMS بۆ پشتڕاستکردنەوە دەنێرین.',
      'newPhoneNumber': 'ژمارەی مۆبایلی نوێ',
      'phoneInternationalFormat': 'فۆرماتی نێودەوڵەتی بەکاربهێنە، وەک +964…',
      'verificationCodeSent': 'کۆدی پشتڕاستکردنەوە نێردرا.',
      // 'verificationCode' and 'sendCode' already exist earlier in this map.
      'verifyAndSave': 'پشتڕاستکردنەوە و پاشەکەوتکردن',
      'invalidVerificationCode': 'کۆدی پشتڕاستکردنەوە هەڵەیە.',
      'passwordChangeRules':
          'لانیکەم ٨ پیت، پیتێکی گەورە و هێمایەک بەکاربهێنە.',
      'kilometers': 'کیلۆمەتر (km)',
      'miles': 'مایل (mi)',
      'milesShort': 'mi',
      'defaultPayment': 'بنەڕەتی',
      'debitCard': 'کارتی دێبیت',
      'creditCard': 'کارتی کرێدیت',
      'kurdistanInternationalBank': 'بانکی نێودەوڵەتی کوردستان',
      'firstIraqiBank': 'بانکی یەکەمی عێراق',
      'newlyAddedCard': 'کارتی تازە زیادکراو',
      'savedCard': 'کارتی پاشەکەوتکراو',
      'add': 'زیادکردن',
      'change': 'گۆڕین',
      'delete': 'سڕینەوە',
      'cancel': 'پاشگەزبوونەوە',
      'setDefaultCard': 'دیاریکردنی کارتی بنەڕەتی',
      'setDefaultCardBody': 'ئەم کارتە بۆ حیجزە نوێیەکان بەکاردەهێنرێت.',
      'defaultCardUpdated': 'کارتی بنەڕەتی نوێکرایەوە',
      'deleteCardTitle': 'ئەم کارتە بسڕدرێتەوە؟',
      'deleteCardBody':
          'کارتەکە کە بە {last4} کۆتایی دێت لە شێوازە پاشەکەوتکراوەکانی پارەدانت '
          'لادەبرێت. لە هەر کاتێکدا دەتوانیت دووبارە زیادی بکەیتەوە.',
      'cardDeleted': 'کارتەکە لابرا',
      'cardAdded': 'کارتەکە زیادکرا',
      'billingSignInTitle': 'بچۆ ژوورەوە بۆ بەڕێوەبردنی پارەدان',
      'billingSignInBody':
          'کارتە پاشەکەوتکراوەکانت بە هەژمارەکەتەوە بەستراون، بۆیە پێویستە بچیتە '
          'ژوورەوە بۆ پیشاندانیان.',
      'photoSignInTitle': 'بچۆ ژوورەوە بۆ زیادکردنی وێنە',
      'photoSignInBody':
          'وێنەی پرۆفایلەکەت لە هەژمارەکەتدا پاشەکەوت دەکرێت، بۆیە پێویستە بچیتە '
          'ژوورەوە بۆ گۆڕینی.',
      'paymentHistory': 'مێژووی پارەدان',
      'paid': 'پارەدراو',
      'pending': 'چاوەڕوان',
      'viewReceipt': 'بینینی پسوڵە',
      'hotel': 'هوتێل',
      'flight': 'فڕین',
      'car': 'ئۆتۆمبێل',
      'tour': 'گەشت',
      'mountainViewResort': 'پشوودانی دیمەنی چیا',
      'erbilToIstanbul': 'هەولێر ← ئیستانبوڵ',
      'suvRental': 'بەکرێگرتنی SUV',
      'rawanduzCanyonAdventure': 'سەرکێشی دۆڵی ڕەواندز',
      'paymentDateMay24': '٢٤ی ئایاری ٢٠٢٥',
      'paymentDateMay23': '٢٣ی ئایاری ٢٠٢٥',
      'paymentDateMay25': '٢٥ی ئایاری ٢٠٢٥',
      'paymentDateMay26': '٢٦ی ئایاری ٢٠٢٥',
      'settings': 'ڕێکخستنەکان',
      'settingsAccount': 'هەژمار',
      'settingsChangePassword': 'گۆڕینی وشەی نهێنی',
      'settingsPreferences': 'هەڵبژاردەکان',
      'settingsNotifications': 'ئاگادارکردنەوەکان',
      'settingsTheme': 'ڕووکار',
      'settingsLanguage': 'زمان',
      'settingsUnits': 'یەکەکان',
      'settingsSecurityLegal': 'ئاسایش و یاسایی',
      'settingsSecurityPrivacy': 'ئاسایش و تایبەتمەندی',
      'settingsDeleteAccount': 'سڕینەوەی هەژمار',
      'notificationsPermissionDenied': 'مۆڵەتی ئاگادارکردنەوە نەدرا.',
      'notificationsUpdateFailed':
          'نەمانتوانی ئاگادارکردنەوەکان نوێ بکەینەوە. دووبارە هەوڵ بدەوە.',
      'languageEnglish': 'ئینگلیزی',
      'languageKurdish': 'کوردی',
      'languageArabic': 'عەرەبی',
      'kilometersShort': 'کم',
      'currency': 'دراو',
      'policy': 'سیاسەت',
      'helpSupport': 'یارمەتی',
      'aboutUs': 'دەربارەمان',
      'contactWay': 'ڕێگای پەیوەندی',
      'logOut': 'دەرچوون',
      'guestUser': 'میوان',
      'guestDrawerPrompt': 'بۆ بینینی پرۆفایلەکەت بچۆرە ژوورەوە',
      'signInRequired': 'تکایە سەرەتا بچۆرە ژوورەوە',
      'selectCurrency': 'دراو هەڵبژێرە',
      'currencyUSD': 'دۆلاری ئەمریکی (USD)',
      'currencyIQD': 'دیناری عێراقی (IQD)',
      'currencyEUR': 'یۆرۆ (EUR)',
      'currencyUpdated': 'دراوەکە نوێکرایەوە',
      'currencyUpdateFailed':
          'نەمانتوانی دراوەکەت نوێ بکەینەوە. تکایە دووبارە هەوڵ بدەوە.',
      'logOutFailed': 'نەمانتوانی دەرتبکەین. تکایە دووبارە هەوڵ بدەوە.',
      'profilePhotoUpdated': 'وێنەی پرۆفایل نوێکرایەوە',
      // --- Explore Nature screen ---
      'filterHiking': 'ڕێپێوان',
      'filterBeach': 'کەنارئاو',
      'filterSunsetView': 'دیمەنی خۆرئاوابوون',
      'filterCustomize': 'ڕێکخستنی خۆت',
      'locationLabel': 'شوێن:',
      'distanceLabel': 'دووری:',
      'distanceFromCurrentLocation': '{distance} لە شوێنی ئێستاتەوە',
      'natureSpotsLoadFailed':
          'نەمانتوانی شوێنەکان باربکەین. تکایە دووبارە هەوڵ بدەوە.',
      'natureSpotsEmpty': 'هیچ شوێنێک لەگەڵ ئەم پاڵاوتنانەدا نەگونجا',
      'highlightedEmpty': 'هێشتا هیچ شوێنێکی هەڵبژێردراو نییە',
      'clearFilters': 'پاڵاوتنەکان بسڕەوە',
      'aboutThisPlace': 'دەربارەی ئەم شوێنە',
      'placeNameLabel': 'ناو:',
      'placeDistanceLabel': 'دووری:',
      'suggestedStaysNearby': 'شوێنی مانەوەی پێشنیارکراو لە نزیکەوە',
      'stayDistanceAway': '{distance} کم دوورە',
      'weather': 'کەشوهەوا',
      'weatherUnavailable': 'کەشوهەوا ئێستا بەردەست نییە',
      'sunny': 'خۆرەتاو',
      'partlyCloudy': 'هەورێکی کەم',
      'cloudy': 'هەوراوی',
      'rainy': 'باراناوی',
      'snowy': 'بەفراوی',
      'ratingsAndReviews': 'هەڵسەنگاندن و بۆچوونەکان',
      'basedOnReviews': 'لەسەر بنەمای {count} بۆچوون',
      'writeReviewPrompt': 'سەردانی ئەم شوێنەت کردووە؟',
      'writeReviewHint': 'کلیک لێرە بکە بۆ هەڵسەنگاندن و نووسینی بۆچوون',
      'reviewsLoadFailed': 'نەتوانرا بۆچوونەکانی سەردانکەران باربکرێن',
      'noReviewsYet': 'هێشتا هیچ بۆچوونێک نییە. یەکەم کەس بە بۆچوونەکەت.',
      'seeAllReviews': 'هەموو بۆچوونەکان ببینە',
      'openPlaceMap': 'نەخشەی شوێنەکە بکەرەوە',
      'reviewsCount': '{count} پێداچوونەوە',
      // --- Reviews & Ratings screen ---
      'reviewsAndRatings': 'بۆچوون و هەڵسەنگاندن',
      'averageRating': 'ناوەندی هەڵسەنگاندن',
      'outOfTen': '/ ١٠',
      'allReviews': 'هەموو بۆچوونەکان',
      'sortMostRecent': 'نوێترین',
      'sortHighestRated': 'بەرزترین هەڵسەنگاندن',
      'sortLowestRated': 'نزمترین هەڵسەنگاندن',
      'sortMostHelpful': 'سوودبەخشترین',
      'sortReviewsBy': 'ڕیزکردنی بۆچوونەکان بەپێی',
      'oneReview': '١ بۆچوون',
      'noRatingsYet': 'هێشتا هەڵنەسەنگێنراوە',
      'addYourReview': 'بۆچوونەکەت زیاد بکە',
      'yourRating': 'هەڵسەنگاندنی تۆ',
      'reviewCommentHint': 'باسی ئەزموونەکەت بۆ ئەوانی تر بکە…',
      'postReview': 'ناردنی بۆچوون',
      'updateReview': 'نوێکردنەوەی بۆچوون',
      'reviewPosted': 'سوپاس — بۆچوونەکەت بڵاوکرایەوە',
      'reviewUpdated': 'بۆچوونەکەت نوێکرایەوە',
      'reviewPostFailed': 'نەتوانرا بۆچوونەکەت بنێردرێت. تکایە دووبارە هەوڵ بدە.',
      'reviewRatingRequired': 'سەرەتا ژمارەی ئەستێرە هەڵبژێرە',
      'reviewCommentTooShort': 'لانیکەم ٣ پیت بنووسە',
      'reviewCommentTooLong': 'بۆچوونەکەت کەمتر لە ١٠٠٠ پیت بێت',
      'reviewSignInTitle': 'بۆ نووسینی بۆچوون بچۆ ژوورەوە',
      'reviewSignInBody':
          'بۆچوونەکان بە هەژمارەکەتەوە بەستراون، بۆیە هەمووان دەزانن کێ سەردانی کردووە.',
      'yourReviewLabel': 'بۆچوونی تۆ',
      'editYourReview': 'دەستکاری بۆچوونەکەت بکە',
      'helpfulVote': 'ئەم بۆچوونە بە سوودبەخش نیشان بدە',
      'helpfulVoteRemove': 'دەنگی سوودبەخشی لاببە',
      'helpfulSignInBody':
          'بچۆ ژوورەوە بۆ ئەوەی بڵێیت ئەم بۆچوونە سوودبەخش بوو.',
      'helpfulFailed': 'نەتوانرا دەنگەکەت پاشەکەوت بکرێت. دووبارە هەوڵ بدە.',
      'loadMoreReviews': 'بۆچوونی زیاتر پیشان بدە',
      'reviewJustNow': 'هەر ئێستا',
      'reviewHoursAgo': 'لەمەوبەر {count} کاتژمێر',
      'reviewOneHourAgo': 'لەمەوبەر ١ کاتژمێر',
      'reviewDaysAgo': 'لەمەوبەر {count} ڕۆژ',
      'reviewOneDayAgo': 'لەمەوبەر ١ ڕۆژ',
      'reviewWeeksAgo': 'لەمەوبەر {count} هەفتە',
      'reviewOneWeekAgo': 'لەمەوبەر ١ هەفتە',
      'reviewMonthsAgo': 'لەمەوبەر {count} مانگ',
      'reviewOneMonthAgo': 'لەمەوبەر ١ مانگ',
      'reviewYearsAgo': 'لەمەوبەر {count} ساڵ',
      'reviewOneYearAgo': 'لەمەوبەر ١ ساڵ',
      // --- Customize Filters screen ---
      'customizeFilters': 'ڕێکخستنی پاڵاوتنەکان',
      'customizeFiltersSubtitle':
          'ئەو شوێنانە بدۆزەرەوە کە لەگەڵ گەشتەکەت دەگونجێن',
      'filtersSelected': '{count} پاڵاوتن هەڵبژێردراوە',
      'oneFilterSelected': '١ پاڵاوتن هەڵبژێردراوە',
      'noFiltersSelected': 'هیچ پاڵاوتنێک هەڵنەبژێردراوە',
      'resetAll': 'هەمووی بسڕەوە',
      'placeType': 'جۆری شوێن',
      'facilitiesAmenities': 'ئاسانکاری و خزمەتگوزاری',
      'showPlaces': '{count} شوێن پیشان بدە',
      'showOnePlace': '١ شوێن پیشان بدە',
      'showNoPlaces': 'هیچ شوێنێک نەگونجا',
      'placeTypeForest': 'دارستان',
      'placeTypeMountain': 'شاخ',
      'placeTypeCanyon': 'دەربەند',
      'placeTypePark': 'پارک',
      'placeTypeLake': 'دەریاچە',
      'placeTypeWaterfall': 'ئاوشار',
      'placeTypeRiver': 'ڕووبار',
      'placeTypeMuseum': 'مۆزەخانە',
      'amenityParking': 'شوێنی ئۆتۆمبێل',
      'amenityRestrooms': 'ئاودەست',
      'amenityRestaurants': 'چێشتخانە',
      'amenityCafes': 'کافێ',
      'amenityMobileSignal': 'ئاماژەی مۆبایل',
      'amenityLodgingNearby': 'شوێنی مانەوەی نزیک',
      'amenityAtmNearby': 'ئەی تی ئێمی نزیک',
      // --- Policy screen ---
      'policyOfApp': 'سیاسەتی ئەپ',
      'policyOfAppSubtitle':
          'ڕێنمایی و سیاسەتەکانمان بخوێنەوە بۆ ئەوەی بزانیت چۆن '
          'پارێزگاریت لێ دەکەین.',
      'policyPrivacyTitle': 'سیاسەتی تایبەتمەندێتی',
      'policyPrivacySubtitle': 'چۆن مامەڵە لەگەڵ زانیارییەکانت دەکەین',
      'policyTermsTitle': 'مەرج و ڕێساکان',
      'policyTermsSubtitle': 'ڕێساکانی بەکارهێنانی ئەپەکە',
      'policyCancellationTitle': 'هەڵوەشاندنەوە و گەڕاندنەوەی پارە',
      'policyCancellationSubtitle': 'گۆڕین یان هەڵوەشاندنەوەی حجزەکان',
      'policyPaymentTitle': 'سیاسەتی پارەدان',
      'policyPaymentSubtitle': 'ڕێگاکان، دراو و کرێیەکان',
      'policyLiabilityTitle': 'بەرپرسیارێتی و ڕوونکردنەوە',
      'policyLiabilitySubtitle': 'سنووری بەرپرسیارێتیمان',
      'policyContactTitle': 'پەیوەندی و سکاڵا',
      'policyContactSubtitle': 'پەیوەندی بە پشتگیرییەوە بکە',
      'policyAccountDeletionTitle': 'سڕینەوەی هەژمار و زانیاری',
      'policyAccountDeletionSubtitle': 'هەژمار و زانیارییەکانت بسڕەوە',
      'policyLoadFailed':
          'نەمانتوانی ئەم سیاسەتە باربکەین. تکایە دووبارە هەوڵ بدەوە.',
      // --- Help & Support screen ---
      'helpAndSupport': 'یارمەتی و پشتگیری',
      'helpAccountTitle': 'هەژمار و چوونەژوورەوە',
      'helpAccountPreview': 'چۆن ئیمەیڵەکەم بگۆڕم یان ...',
      'helpBookingsTitle': 'حجز و پشتڕاستکردنەوە',
      'helpBookingsPreview': 'ژمارەی ئاماژەی حجزەکەم چییە ...',
      'helpPaymentsTitle': 'پارەدان و گەڕاندنەوەی پارە',
      'helpPaymentsPreview': 'پارەدانەکەم سەرکەوتوو نەبوو بەڵام ...',
      'helpCancellationTitle': 'هەڵوەشاندنەوە و گۆڕانکاری',
      'helpCancellationPreview': 'دەتوانم لەبری ئەوە حجزەکەم بگۆڕم ...',
      'helpFlightsTitle': 'فڕینەکان',
      'helpFlightsPreview': 'ڕێژەی بارهەڵگرتن چەندە ...',
      'helpStaysTitle': 'شوێنی مانەوە (هۆتێلەکان)',
      'helpStaysPreview': 'کاتی چوونەژوورەوە و ... چییە',
      'helpCarRentalTitle': 'بەکرێگرتنی ئۆتۆمبێل',
      'helpCarRentalPreview': 'چ بەڵگەنامەیەکم پێویستە بۆ ...',
      'helpToursTitle': 'گەشت و سروشت (گەڕان)',
      'helpToursPreview': 'ئەگەر کەشوهەوا ... چی ڕوودەدات',
      'helpSafetyTitle': 'سەلامەتی و زانیاری گەشت',
      'helpSafetyPreview': 'ژمارەکانی فریاگوزاری لە ... چین',
      'helpContactTitle': 'هێشتا یارمەتیت دەوێت؟ پەیوەندیمان پێوە بکە',
      'helpContactPreview': 'پەیوەندی بە تیمی پشتگیریمانەوە بکە ...',
      // --- My Bookings screen ---
      'bookingsFilterAll': 'هەموو',
      'bookingsFilterHotels': 'هوتێلەکان',
      'bookingsFilterCars': 'ئۆتۆمبێلەکان',
      'bookingsFilterFlights': 'فڕینەکان',
      'bookingsFilterTours': 'گەشتەکان',
      'bookingsSegmentUpcoming': 'داهاتوو',
      'bookingsSegmentPast': 'ڕابردوو',
      'bookingsSegmentCancelled': 'هەڵوەشێنراوە',
      'bookingTypeHotel': 'هوتێل',
      'bookingTypeCar': 'بەکرێگرتنی ئۆتۆمبێل',
      'bookingTypeFlight': 'فڕین',
      'bookingTypeTour': 'گەشت',
      'bookingStatusConfirmed': 'پشتڕاستکراوە',
      'bookingStatusPending': 'چاوەڕوانە',
      'bookingStatusCancelled': 'هەڵوەشێنراوە',
      'bookingStatusCompleted': 'تەواوبوو',
      'bookingStatusUpcoming': 'داهاتوو',
      'cabinEconomy': 'ئابووری',
      'cabinPremiumEconomy': 'ئابووری تایبەت',
      'cabinBusiness': 'بازرگانی',
      'cabinFirst': 'پۆلی یەکەم',
      'bookingCheckIn': 'چوونەژوورەوە',
      'bookingCheckOut': 'دەرچوون',
      'bookingGuests': 'میوانەکان',
      'bookingTravelers': 'گەشتیارەکان',
      'bookingDriver': 'شۆفێر',
      'bookingTraveler': 'گەشتیار',
      'bookingSeat': 'کورسی',
      'bookingDuration': 'ماوە',
      'bookingId': 'ژمارەی حیجز',
      'bookingPickup': 'وەرگرتن',
      'bookingDropoff': 'گەڕاندنەوە',
      'bookingTotalPaid': 'کۆی دراو',
      'bookingActionCheckIn': 'چوونەژوورەوە',
      'bookingActionOpenTicket': 'کردنەوەی بلیت',
      'bookingActionPickupInfo': 'زانیاری وەرگرتن',
      'bookingActionTourDetails': 'وردەکاری گەشت',
      'bookingActionViewDetails': 'بینینی وردەکاری',
      'bookingAdultsCount': '{count} گەورە',
      'bookingAdultCount': '{count} گەورە',
      'bookingHours': '{count} کاتژمێر',
      'bookingsLoadFailed': 'نەتوانرا حیجزەکانت باربکرێن',
      'bookingsEmptyTitle': 'هێشتا هیچ حیجزێک نییە',
      'bookingsEmptyBody':
          'کاتێک هوتێل، فڕین، ئۆتۆمبێل یان گەشتێک حیجز دەکەیت، لێرە دەردەکەوێت.',
      'bookingsEmptyUpcoming': 'هیچ حیجزێکی داهاتوو نییە',
      'bookingsEmptyPast': 'هیچ حیجزێکی ڕابردوو نییە',
      'bookingsEmptyCancelled': 'هیچ حیجزێکی هەڵوەشێنراوە نییە',
      'bookingsEmptyFiltered':
          'هیچ شتێک لەگەڵ ئەم پاڵێوەرەدا ناگونجێت. جۆرێکی تر تاقی بکەرەوە.',
      'bookingsSignInTitle': 'بچۆ ژوورەوە بۆ بینینی حیجزەکانت',
      'bookingsSignInBody':
          'حیجزەکانت بە هەژمارەکەتەوە بەستراون، بۆیە پێویستە بچیتە ژوورەوە بۆ پیشاندانیان.',
      'bookingsStartExploring': 'دەست بە گەڕان بکە',
      'month1': 'کانوونی دووەم',
      'month2': 'شوبات',
      'month3': 'ئازار',
      'month4': 'نیسان',
      'month5': 'ئایار',
      'month6': 'حوزەیران',
      'month7': 'تەمووز',
      'month8': 'ئاب',
      'month9': 'ئەیلوول',
      'month10': 'تشرینی یەکەم',
      'month11': 'تشرینی دووەم',
      'month12': 'کانوونی یەکەم',
      'timeAm': 'ب.ن',
      'timePm': 'د.ن',
    },
    'ar': <String, String>{
      'chooseYourLanguage': 'اختر لغتك',
      'selectLanguageToContinue': 'اختر لغة للمتابعة',
      'logIn': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgetPassword': 'نسيت كلمة المرور؟',
      'orLabel': 'أو',
      'dontHaveAccount': 'ليس لديك حساب؟ ',
      'registerNow': 'سجّل الآن',
      'continueAsGuest': 'المتابعة كضيف',
      'emailRequired': 'الرجاء إدخال بريدك الإلكتروني',
      'emailInvalid': 'أدخل بريدًا إلكترونيًا صالحًا',
      'passwordRequired': 'الرجاء إدخال كلمة المرور',
      'forgetPasswordSubtitle':
          'يرجى اختيار بيانات الاتصال الخاصة بك وسنرسل إليك رمز تحقق '
          'لإعادة تعيين كلمة المرور.',
      'phoneNumber': 'رقم الهاتف',
      'emailAddress': 'البريد الإلكتروني',
      'sendCode': 'إرسال الرمز',
      'selectContactMethod': 'اختر الهاتف أو البريد الإلكتروني أولاً',
      'verificationCode': 'رمز التحقق',
      'verificationSubtitle':
          'أدخل الرمز المكوّن من ٦ أرقام الذي أرسلناه للتو إلى {dest} '
          'لإعادة تعيين كلمة المرور.',
      'didntReceiveCode': 'لم تستلم الرمز؟ ',
      'resendNow': 'إعادة الإرسال',
      'resendIn': 'إعادة الإرسال خلال {seconds} ثانية',
      'verify': 'تحقّق',
      'codeIncomplete': 'أدخل أرقام الرمز الستة كاملة',
      'codeIncorrect': 'هذا الرمز غير صحيح. يرجى المحاولة مرة أخرى.',
      'codeExpired': 'انتهت صلاحية هذا الرمز. اطلب رمزًا جديدًا.',
      'tooManyAttempts':
          'محاولات كثيرة جدًا. يرجى الانتظار قبل المحاولة مرة أخرى.',
      'codeResentPhone': 'تم إرسال رمز جديد عبر رسالة نصية',
      'codeResentEmail': 'تم إرسال رمز جديد إلى بريدك الإلكتروني',
      'sendCodeFailed': 'تعذّر إرسال الرمز. يرجى المحاولة مرة أخرى.',
      'networkError': 'لا يوجد اتصال. تحقّق من شبكتك ثم حاول مرة أخرى.',
      'resetPassword': 'إعادة تعيين كلمة المرور',
      'resetPasswordSubtitle':
          '٨ أحرف على الأقل، مع حرف كبير وحرف صغير ورمز خاص.',
      'newPassword': 'كلمة المرور الجديدة',
      'confirmPassword': 'تأكيد كلمة المرور',
      'updatePassword': 'تحديث كلمة المرور',
      'passwordTooShort': 'استخدم ٨ أحرف على الأقل',
      'passwordNeedsUppercase': 'أضف حرفًا كبيرًا واحدًا على الأقل',
      'passwordNeedsLowercase': 'أضف حرفًا صغيرًا واحدًا على الأقل',
      'passwordNeedsSpecial': 'أضف رمزًا خاصًا واحدًا على الأقل',
      'confirmPasswordRequired': 'يرجى إعادة إدخال كلمة المرور الجديدة',
      'passwordsDontMatch': 'كلمتا المرور غير متطابقتين',
      'passwordUpdated': 'تم تحديث كلمة المرور. يرجى تسجيل الدخول.',
      'passwordUpdateFailed':
          'تعذّر تحديث كلمة المرور. يرجى المحاولة مرة أخرى.',
      'passwordTooWeak': 'يرجى اختيار كلمة مرور أقوى',
      'sessionExpired': 'انتهت جلستك. يرجى البدء من جديد.',
      // --- Register screen ---
      'register': 'إنشاء حساب',
      'fullName': 'الاسم الكامل',
      'age': 'العمر',
      'gender': 'الجنس',
      'genderMale': 'ذكر',
      'genderFemale': 'أنثى',
      'genderOther': 'آخر',
      'genderOptional': 'الجنس (اختياري)',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟ ',
      'logInHere': 'سجّل الدخول من هنا',
      'passwordHint': '٨ أحرف على الأقل، مع حرف كبير وحرف صغير ورمز خاص.',
      'acceptTerms': 'أوافق على شروط الخدمة وسياسة الخصوصية',
      'termsRequired': 'يرجى الموافقة على الشروط وسياسة الخصوصية',
      'fullNameRequired': 'يرجى إدخال اسمك الكامل',
      'fullNameTooShort': 'يرجى إدخال اسمك الكامل',
      'dateOfBirthRequired': 'يرجى اختيار تاريخ ميلادك',
      'mustBe18': 'يجب أن يكون عمرك ١٨ عامًا على الأقل لإنشاء حساب',
      'phoneRequired': 'يرجى إدخال رقم هاتفك',
      'phoneInvalid': 'أدخل رقم هاتف صالح',
      'selectCountryCode': 'رمز الدولة',
      'accountCreated': 'تم إنشاء الحساب. يرجى تسجيل الدخول.',
      'registerFailed': 'تعذّر إنشاء حسابك. يرجى المحاولة مرة أخرى.',
      'emailInUse': 'يوجد حساب بهذا البريد الإلكتروني بالفعل',
      'phoneInUse': 'يوجد حساب بهذا الرقم بالفعل',
      'verifyNumberSubtitle':
          'أدخل الرمز المكوّن من ٦ أرقام الذي أرسلناه للتو إلى {dest} '
          'للتحقق من رقمك.',
      'verifyEmailTitle': 'تحقّق من بريدك الإلكتروني',
      'verifyEmailSubtitle':
          'أدخل الرمز المكوّن من ٦ أرقام الذي أرسلناه للتو إلى {dest} '
          'لتأكيد بريدك الإلكتروني.',
      'emailVerified': 'تم التحقق من بريدك الإلكتروني.',
      // --- Terms of Service screen ---
      'termsOfService': 'شروط الخدمة',
      'termsAgreeCheckbox':
          'لقد قرأت شروط الخدمة وسياسة الخصوصية وأوافق عليها.',
      'continueLabel': 'متابعة',
      'lastUpdated': 'آخر تحديث: {date}',
      'termsLoadFailed': 'تعذّر تحميل الشروط. يرجى المحاولة مرة أخرى.',
      'tryAgain': 'حاول مرة أخرى',
      'termsNotReviewed':
          'صيغة مبدئية — بانتظار المراجعة القانونية. غير مخصّصة للإصدار.',
      // --- Account Setup screen ---
      'accountSetup': 'إعداد الحساب',
      'accountSetupSubtitle':
          'أكمل إعداد حسابك برفع صورة الملف الشخصي وتحديد اسم المستخدم.',
      'username': 'اسم المستخدم',
      'createAccount': 'إنشاء الحساب',
      'chooseFromGallery': 'اختر من المعرض',
      'takePhoto': 'التقط صورة',
      'removePhoto': 'إزالة الصورة',
      'usernameRequired': 'يرجى إدخال اسم المستخدم',
      'usernameTooShort': 'استخدم حرفين على الأقل',
      'imageTooLarge': 'هذه الصورة كبيرة جدًا. اختر صورة أقل من ٥ ميغابايت.',
      'imagePickFailed': 'تعذّر فتح هذه الصورة. يرجى المحاولة مرة أخرى.',
      'profileSaveFailed': 'تعذّر حفظ ملفك الشخصي. يرجى المحاولة مرة أخرى.',
      'cameraPermissionDenied':
          'الوصول إلى الكاميرا مُعطّل. فعّله من الإعدادات لالتقاط صورة.',
      'galleryPermissionDenied':
          'الوصول إلى الصور مُعطّل. فعّله من الإعدادات لاختيار صورة.',
      // --- Register Complete screen ---
      'registerComplete': 'اكتمل التسجيل!',
      'registerCompleteSubtitle': 'تم إنشاء حسابك بنجاح. أهلًا بك!',
      'explore': 'استكشف',
      // --- Onboarding (3-slide intro) ---
      'onboardingTitleLine1': 'اكتشف',
      'onboardingTitleLine2': 'كردستان',
      'onboardingBody1':
          'استكشف الوديان الجميلة والأنهار ودروب الجبال التي لا يصل إليها '
          'سوى قليل من المسافرين.\nكل ذلك في تطبيق واحد.',
      'onboardingTitle2Line1': 'طر إلى',
      'onboardingTitle2Line2': 'كردستان',
      'onboardingBody2': 'قارن الرحلات واختر تواريخك واحجز تذكرتك في دقائق.',
      'onboardingTitle3Line1': 'سيارتك',
      'onboardingTitle3Line2': 'جاهزة !',
      'onboardingBody3':
          'استأجر سيارة وتنقّل إلى كل ركن في كردستان وفق جدولك الخاص.',
      'onboardingNext': 'التالي',
      // --- Home screen ---
      'goodMorning': 'صباح الخير',
      'goodAfternoon': 'طاب نهارك',
      'goodEvening': 'مساء الخير',
      'dearUser': 'عزيزي المستخدم',
      'whereWouldYouLikeToGo': 'إلى أين تودّ الذهاب؟',
      'planYourJourney': 'خطّط لرحلتك',
      'exploreNature': 'استكشف الطبيعة',
      'exploreNatureHint': 'مسارات وبحيرات وحدائق خلّابة.',
      'whereToStay': 'أين تقيم',
      'whereToStayHint': 'فنادق وأكواخ وأماكن إقامة مميّزة',
      'bestPrice': 'أفضل سعر',
      'carRental': 'تأجير السيارات',
      'carRentalHint': 'اعثر على السيارة المثالية لمغامرتك',
      'findACar': 'ابحث عن سيارة',
      'flightTicketing': 'حجز الطيران',
      'flightTicketingHint': 'رحلات رخيصة، حجز سهل، دفع آمن',
      'findFlight': 'ابحث عن رحلة',
      'exploreToursTitle': 'استكشف الجولات',
      'exploreToursHint': 'تجارب محلية وأماكن مخفية ومرشدون خبراء',
      'findTours': 'ابحث عن جولة',
      'placesCount': '{count}+ مكان',
      'navHome': 'الرئيسية',
      'navTrips': 'رحلاتي',
      'navMap': 'الخريطة',
      'navSaved': 'المحفوظات',
      'featuredLoadFailed': 'تعذّر تحميل الوجهات المميّزة',
      'featuredEmpty': 'لا توجد وجهات مميّزة بعد',
      'signInToSave': 'سجّل الدخول لحفظ المفضّلة',
      'signInToSaveBody':
          'أنشئ حسابًا أو سجّل الدخول للاحتفاظ بأماكنك المفضّلة.',
      'notNow': 'ليس الآن',
      'addedToFavorites': 'أُضيف إلى مفضّلتك',
      'removedFromFavorites': 'أُزيل من مفضّلتك',
      'favoriteFailed': 'تعذّر تحديث مفضّلتك',
      'comingSoon': 'قريبًا',
      'mapOpenFailed': 'تعذّر فتح تطبيق الخرائط',
      'menu': 'القائمة',
      'changeLanguage': 'تغيير اللغة',
      // --- Home screen side drawer ---
      'close': 'إغلاق',
      'services': 'الخدمات',
      'myBookings': 'حجوزاتي',
      'billingPayments': 'الفواتير/الدفع',
      'billingPaymentTitle': 'الفوترة والمدفوعات',
      'currentPaymentMethod': 'طريقة الدفع الحالية',
      'addPaymentMethod': 'إضافة طريقة دفع',
      'addPaymentMethodDescription':
          'احفظ بطاقة الخصم أو الائتمان للدفع مقابل الفنادق والرحلات الجوية وتأجير السيارات والجولات.',
      'paymentInformationEncrypted': 'معلومات الدفع الخاصة بك مشفّرة بأمان.',
      'addCard': 'إضافة بطاقة',
      'debitOrCreditCard': 'بطاقة خصم أو ائتمان',
      'secureCheckout': 'دفع آمن',
      'secureCardSetupUnavailable': 'إعداد البطاقة الآمن سيتوفر قريبًا.',
      'paymentMethodAlreadyAdded': 'هناك طريقة دفع مرتبطة بحسابك بالفعل.',
      'newCard': 'بطاقة جديدة',
      'newCardDescription': 'أضف بطاقة لإتمام حجوزاتك المستقبلية بشكل أسرع.',
      'cardDetails': 'تفاصيل البطاقة',
      'cardholderName': 'اسم حامل البطاقة',
      'cardNumber': 'رقم البطاقة',
      'expiryDate': 'تاريخ الانتهاء',
      'expiryHint': 'MM/YY',
      'cvv': 'CVV',
      'country': 'البلد',
      'yourCountry': 'بلدك',
      'zipCode': 'الرمز البريدي',
      'optional': 'اختياري',
      'saveCardForFutureBookings': 'احفظ هذه البطاقة للحجوزات المستقبلية',
      'editPaymentMethodLater':
          'يمكنك تعديل طريقة الدفع هذه أو إزالتها لاحقًا من الفوترة والدفع.',
      'requiredField': 'هذا الحقل مطلوب.',
      'invalidCardNumber': 'أدخل رقم بطاقة صالحًا.',
      'invalidExpiryDate': 'أدخل تاريخًا مستقبليًا صالحًا.',
      'invalidCvv': 'أدخل رمز CVV صالحًا.',
      'editProfile': 'تعديل الملف الشخصي',
      'editProfileSubtitle': 'حدّث صورتك واسمك الكامل.',
      'firstAndLastName': 'الاسم الأول واسم العائلة',
      'firstName': 'الاسم الأول',
      'lastName': 'اسم العائلة',
      'firstAndLastNameRequired': 'أدخل الاسم الأول واسم العائلة.',
      'saveChanges': 'حفظ التغييرات',
      'profileUpdated': 'تم تحديث ملفك الشخصي.',
      'settingsUpdateFailed': 'تعذّر تحديث هذا الإعداد. حاول مجددًا.',
      'changeEmail': 'تغيير البريد الإلكتروني',
      'changeEmailSubtitle': 'أكد كلمة مرورك ثم تحقق من البريد الجديد.',
      'confirmEmailIdentitySubtitle':
          'أدخل بريد حسابك الحالي وكلمة مرور التطبيق لتأكيد هويتك.',
      'currentEmail': 'البريد الإلكتروني الحالي',
      'newEmail': 'البريد الإلكتروني الجديد',
      'newEmailVerificationSubtitle':
          'أدخل البريد الجديد ورمز التحقق المكون من 6 أرقام الذي نرسله إليه.',
      'emailUpdated': 'تم تحديث بريدك الإلكتروني.',
      'currentPassword': 'كلمة المرور الحالية',
      'enterValidEmail': 'أدخل بريدًا إلكترونيًا صالحًا.',
      'sendVerificationLink': 'إرسال رابط التحقق',
      'emailVerificationSent':
          'تم إرسال رابط التحقق. يتغير البريد بعد الموافقة عليه.',
      'reauthenticationFailed': 'تعذّر التحقق من كلمة المرور الحالية.',
      'changePhoneNumber': 'تغيير رقم الهاتف',
      'changePhoneSubtitle': 'سنرسل رمز SMS للتحقق من الرقم.',
      'newPhoneNumber': 'رقم الهاتف الجديد',
      'phoneInternationalFormat': 'استخدم الصيغة الدولية، مثل +964…',
      'verificationCodeSent': 'تم إرسال رمز التحقق.',
      // 'verificationCode' and 'sendCode' already exist earlier in this map.
      'verifyAndSave': 'تحقق واحفظ',
      'invalidVerificationCode': 'رمز التحقق غير صالح.',
      'passwordChangeRules': 'استخدم 8 أحرف على الأقل وحرفًا كبيرًا ورمزًا.',
      'kilometers': 'كيلومترات (km)',
      'miles': 'أميال (mi)',
      'milesShort': 'mi',
      'defaultPayment': 'افتراضية',
      'debitCard': 'بطاقة خصم',
      'creditCard': 'بطاقة ائتمان',
      'kurdistanInternationalBank': 'مصرف كوردستان الدولي',
      'firstIraqiBank': 'المصرف العراقي الأول',
      'newlyAddedCard': 'البطاقة المضافة حديثًا',
      'savedCard': 'بطاقة محفوظة',
      'add': 'إضافة',
      'change': 'تغيير',
      'delete': 'حذف',
      'cancel': 'إلغاء',
      'setDefaultCard': 'تعيين البطاقة الافتراضية',
      'setDefaultCardBody': 'ستُستخدم هذه البطاقة للحجوزات الجديدة.',
      'defaultCardUpdated': 'تم تحديث البطاقة الافتراضية',
      'deleteCardTitle': 'حذف هذه البطاقة؟',
      'deleteCardBody':
          'ستتم إزالة البطاقة المنتهية بـ {last4} من طرق الدفع المحفوظة لديك. '
          'يمكنك إضافتها مرة أخرى في أي وقت.',
      'cardDeleted': 'تمت إزالة البطاقة',
      'cardAdded': 'تمت إضافة البطاقة',
      'billingSignInTitle': 'سجّل الدخول لإدارة الدفع',
      'billingSignInBody':
          'بطاقاتك المحفوظة مرتبطة بحسابك، لذا نحتاج إلى تسجيل دخولك لعرضها.',
      'photoSignInTitle': 'سجّل الدخول لإضافة صورة',
      'photoSignInBody':
          'تُحفظ صورة ملفك الشخصي في حسابك، لذا نحتاج إلى تسجيل دخولك لتغييرها.',
      'paymentHistory': 'سجل المدفوعات',
      'paid': 'مدفوع',
      'pending': 'قيد الانتظار',
      'viewReceipt': 'عرض الإيصال',
      'hotel': 'فندق',
      'flight': 'رحلة جوية',
      'car': 'سيارة',
      'tour': 'جولة',
      'mountainViewResort': 'منتجع إطلالة الجبل',
      'erbilToIstanbul': 'أربيل ← إسطنبول',
      'suvRental': 'تأجير سيارة SUV',
      'rawanduzCanyonAdventure': 'مغامرة وادي رواندز',
      'paymentDateMay24': '٢٤ مايو ٢٠٢٥',
      'paymentDateMay23': '٢٣ مايو ٢٠٢٥',
      'paymentDateMay25': '٢٥ مايو ٢٠٢٥',
      'paymentDateMay26': '٢٦ مايو ٢٠٢٥',
      'settings': 'الإعدادات',
      'settingsAccount': 'الحساب',
      'settingsChangePassword': 'تغيير كلمة المرور',
      'settingsPreferences': 'التفضيلات',
      'settingsNotifications': 'الإشعارات',
      'settingsTheme': 'المظهر',
      'settingsLanguage': 'اللغة',
      'settingsUnits': 'الوحدات',
      'settingsSecurityLegal': 'الأمان والشؤون القانونية',
      'settingsSecurityPrivacy': 'الأمان والخصوصية',
      'settingsDeleteAccount': 'حذف الحساب',
      'notificationsPermissionDenied': 'لم يتم منح إذن الإشعارات.',
      'notificationsUpdateFailed':
          'تعذّر تحديث الإشعارات. يرجى المحاولة مرة أخرى.',
      'languageEnglish': 'الإنجليزية',
      'languageKurdish': 'الكردية',
      'languageArabic': 'العربية',
      'kilometersShort': 'كم',
      'currency': 'العملة',
      'policy': 'السياسة',
      'helpSupport': 'المساعدة والدعم',
      'aboutUs': 'من نحن',
      'contactWay': 'طرق التواصل',
      'logOut': 'تسجيل الخروج',
      'guestUser': 'ضيف',
      'guestDrawerPrompt': 'سجّل الدخول لعرض ملفك الشخصي',
      'signInRequired': 'يرجى تسجيل الدخول أولاً',
      'selectCurrency': 'اختر العملة',
      'currencyUSD': 'دولار أمريكي (USD)',
      'currencyIQD': 'دينار عراقي (IQD)',
      'currencyEUR': 'يورو (EUR)',
      'currencyUpdated': 'تم تحديث العملة',
      'currencyUpdateFailed': 'تعذّر تحديث العملة. يرجى المحاولة مرة أخرى.',
      'logOutFailed': 'تعذّر تسجيل خروجك. يرجى المحاولة مرة أخرى.',
      'profilePhotoUpdated': 'تم تحديث صورة الملف الشخصي',
      // --- Explore Nature screen ---
      'filterHiking': 'المشي الجبلي',
      'filterBeach': 'الشاطئ',
      'filterSunsetView': 'منظر الغروب',
      'filterCustomize': 'تخصيص',
      'locationLabel': 'الموقع:',
      'distanceLabel': 'المسافة:',
      'distanceFromCurrentLocation': '{distance} من موقعك الحالي',
      'natureSpotsLoadFailed': 'تعذّر تحميل الأماكن. يرجى المحاولة مرة أخرى.',
      'natureSpotsEmpty': 'لا توجد أماكن تطابق هذه الفلاتر بعد',
      'highlightedEmpty': 'لا توجد أماكن مميّزة بعد',
      'clearFilters': 'مسح الفلاتر',
      'aboutThisPlace': 'حول هذا المكان',
      'placeNameLabel': 'الاسم:',
      'placeDistanceLabel': 'المسافة:',
      'suggestedStaysNearby': 'أماكن إقامة مقترحة قريبة',
      'stayDistanceAway': 'يبعد {distance} كم',
      'weather': 'الطقس',
      'weatherUnavailable': 'الطقس غير متاح الآن',
      'sunny': 'مشمس',
      'partlyCloudy': 'غائم جزئياً',
      'cloudy': 'غائم',
      'rainy': 'ممطر',
      'snowy': 'مثلج',
      'ratingsAndReviews': 'التقييمات والمراجعات',
      'basedOnReviews': 'بناءً على {count} مراجعة',
      'writeReviewPrompt': 'هل زرت هذا المكان؟',
      'writeReviewHint': 'اضغط هنا لتقييم زيارتك وكتابة تعليق',
      'reviewsLoadFailed': 'تعذّر تحميل مراجعات الزوار',
      'noReviewsYet': 'لا توجد مراجعات بعد. كن أول من يشارك زيارته.',
      'seeAllReviews': 'عرض كل المراجعات',
      'openPlaceMap': 'فتح خريطة المكان',
      'reviewsCount': '{count} تقييم',
      // --- Reviews & Ratings screen ---
      'reviewsAndRatings': 'المراجعات والتقييمات',
      'averageRating': 'متوسط التقييم',
      'outOfTen': '/ ١٠',
      'allReviews': 'كل المراجعات',
      'sortMostRecent': 'الأحدث',
      'sortHighestRated': 'الأعلى تقييماً',
      'sortLowestRated': 'الأقل تقييماً',
      'sortMostHelpful': 'الأكثر إفادة',
      'sortReviewsBy': 'ترتيب المراجعات حسب',
      'oneReview': 'مراجعة واحدة',
      'noRatingsYet': 'لم يُقيَّم بعد',
      'addYourReview': 'أضف مراجعتك',
      'yourRating': 'تقييمك',
      'reviewCommentHint': 'أخبر الآخرين عن تجربتك…',
      'postReview': 'نشر المراجعة',
      'updateReview': 'تحديث المراجعة',
      'reviewPosted': 'شكراً — تم نشر مراجعتك',
      'reviewUpdated': 'تم تحديث مراجعتك',
      'reviewPostFailed': 'تعذّر نشر مراجعتك. يرجى المحاولة مرة أخرى.',
      'reviewRatingRequired': 'اختر عدد النجوم أولاً',
      'reviewCommentTooShort': 'اكتب 3 أحرف على الأقل',
      'reviewCommentTooLong': 'اجعل مراجعتك أقل من 1000 حرف',
      'reviewSignInTitle': 'سجّل الدخول لكتابة مراجعة',
      'reviewSignInBody':
          'ترتبط المراجعات بحسابك، ليعرف الجميع من قام بالزيارة.',
      'yourReviewLabel': 'مراجعتك',
      'editYourReview': 'تعديل مراجعتك',
      'helpfulVote': 'وسم هذه المراجعة بأنها مفيدة',
      'helpfulVoteRemove': 'إزالة تصويتك بأنها مفيدة',
      'helpfulSignInBody': 'سجّل الدخول لتخبر الآخرين أن المراجعة كانت مفيدة.',
      'helpfulFailed': 'تعذّر حفظ تصويتك. يرجى المحاولة مرة أخرى.',
      'loadMoreReviews': 'عرض مراجعات أكثر',
      'reviewJustNow': 'الآن',
      'reviewHoursAgo': 'قبل {count} ساعات',
      'reviewOneHourAgo': 'قبل ساعة',
      'reviewDaysAgo': 'قبل {count} أيام',
      'reviewOneDayAgo': 'قبل يوم',
      'reviewWeeksAgo': 'قبل {count} أسابيع',
      'reviewOneWeekAgo': 'قبل أسبوع',
      'reviewMonthsAgo': 'قبل {count} أشهر',
      'reviewOneMonthAgo': 'قبل شهر',
      'reviewYearsAgo': 'قبل {count} سنوات',
      'reviewOneYearAgo': 'قبل سنة',
      // --- Customize Filters screen ---
      'customizeFilters': 'تخصيص الفلاتر',
      'customizeFiltersSubtitle': 'اعثر على أماكن تناسب رحلتك',
      'filtersSelected': 'تم اختيار {count} فلاتر',
      'oneFilterSelected': 'تم اختيار فلتر واحد',
      'noFiltersSelected': 'لم يتم اختيار أي فلتر',
      'resetAll': 'إعادة تعيين الكل',
      'placeType': 'نوع المكان',
      'facilitiesAmenities': 'المرافق والخدمات',
      'showPlaces': 'عرض {count} مكان',
      'showOnePlace': 'عرض مكان واحد',
      'showNoPlaces': 'لا توجد أماكن مطابقة',
      'placeTypeForest': 'غابة',
      'placeTypeMountain': 'جبل',
      'placeTypeCanyon': 'وادٍ',
      'placeTypePark': 'حديقة',
      'placeTypeLake': 'بحيرة',
      'placeTypeWaterfall': 'شلال',
      'placeTypeRiver': 'نهر',
      'placeTypeMuseum': 'متحف',
      'amenityParking': 'موقف سيارات',
      'amenityRestrooms': 'دورات مياه',
      'amenityRestaurants': 'مطاعم',
      'amenityCafes': 'مقاهٍ',
      'amenityMobileSignal': 'تغطية الهاتف',
      'amenityLodgingNearby': 'إقامة قريبة',
      'amenityAtmNearby': 'صرّاف آلي قريب',
      // --- Policy screen ---
      'policyOfApp': 'سياسة التطبيق',
      'policyOfAppSubtitle': 'اطّلع على إرشاداتنا وسياساتنا لتعرف كيف نحميك.',
      'policyPrivacyTitle': 'سياسة الخصوصية',
      'policyPrivacySubtitle': 'كيف نتعامل مع بياناتك',
      'policyTermsTitle': 'الشروط والأحكام',
      'policyTermsSubtitle': 'قواعد استخدام التطبيق',
      'policyCancellationTitle': 'الإلغاء واسترداد الأموال',
      'policyCancellationSubtitle': 'تغيير الحجوزات أو إلغاؤها',
      'policyPaymentTitle': 'سياسة الدفع',
      'policyPaymentSubtitle': 'الطرق والعملة والرسوم',
      'policyLiabilityTitle': 'المسؤولية وإخلاء المسؤولية',
      'policyLiabilitySubtitle': 'حدود مسؤوليتنا',
      'policyContactTitle': 'التواصل والشكاوى',
      'policyContactSubtitle': 'تواصل مع الدعم',
      'policyAccountDeletionTitle': 'حذف الحساب والبيانات',
      'policyAccountDeletionSubtitle': 'احذف حسابك وبياناتك',
      'policyLoadFailed': 'تعذّر تحميل هذه السياسة. يرجى المحاولة مرة أخرى.',
      // --- Help & Support screen ---
      'helpAndSupport': 'المساعدة والدعم',
      'helpAccountTitle': 'الحساب وتسجيل الدخول',
      'helpAccountPreview': 'كيف أغيّر بريدي الإلكتروني أو ...',
      'helpBookingsTitle': 'الحجوزات والتأكيد',
      'helpBookingsPreview': 'ما هو الرقم المرجعي لحجزي ...',
      'helpPaymentsTitle': 'المدفوعات والاسترداد',
      'helpPaymentsPreview': 'فشلت عملية الدفع لكنني ...',
      'helpCancellationTitle': 'الإلغاء والتعديلات',
      'helpCancellationPreview': 'هل يمكنني تعديل حجزي بدلًا من ...',
      'helpFlightsTitle': 'الرحلات الجوية',
      'helpFlightsPreview': 'ما هو وزن الأمتعة المسموح ...',
      'helpStaysTitle': 'أماكن الإقامة (الفنادق)',
      'helpStaysPreview': 'ما هي مواعيد تسجيل الدخول و ...',
      'helpCarRentalTitle': 'تأجير السيارات',
      'helpCarRentalPreview': 'ما المستندات التي أحتاجها لـ ...',
      'helpToursTitle': 'الجولات والطبيعة (استكشاف)',
      'helpToursPreview': 'ماذا يحدث إذا كان الطقس ...',
      'helpSafetyTitle': 'السلامة ومعلومات السفر',
      'helpSafetyPreview': 'ما هي أرقام الطوارئ في ...',
      'helpContactTitle': 'ما زلت بحاجة إلى مساعدة؟ تواصل معنا',
      'helpContactPreview': 'تواصل مع فريق الدعم لدينا ...',
      // --- My Bookings screen ---
      'bookingsFilterAll': 'الكل',
      'bookingsFilterHotels': 'الفنادق',
      'bookingsFilterCars': 'السيارات',
      'bookingsFilterFlights': 'الرحلات',
      'bookingsFilterTours': 'الجولات',
      'bookingsSegmentUpcoming': 'القادمة',
      'bookingsSegmentPast': 'السابقة',
      'bookingsSegmentCancelled': 'الملغاة',
      'bookingTypeHotel': 'فندق',
      'bookingTypeCar': 'تأجير سيارة',
      'bookingTypeFlight': 'رحلة',
      'bookingTypeTour': 'جولة',
      'bookingStatusConfirmed': 'مؤكد',
      'bookingStatusPending': 'قيد الانتظار',
      'bookingStatusCancelled': 'ملغى',
      'bookingStatusCompleted': 'مكتمل',
      'bookingStatusUpcoming': 'قادم',
      'cabinEconomy': 'اقتصادية',
      'cabinPremiumEconomy': 'اقتصادية مميزة',
      'cabinBusiness': 'رجال الأعمال',
      'cabinFirst': 'الأولى',
      'bookingCheckIn': 'تسجيل الدخول',
      'bookingCheckOut': 'تسجيل الخروج',
      'bookingGuests': 'الضيوف',
      'bookingTravelers': 'المسافرون',
      'bookingDriver': 'السائق',
      'bookingTraveler': 'مسافر',
      'bookingSeat': 'المقعد',
      'bookingDuration': 'المدة',
      'bookingId': 'رقم الحجز',
      'bookingPickup': 'الاستلام',
      'bookingDropoff': 'التسليم',
      'bookingTotalPaid': 'إجمالي المدفوع',
      'bookingActionCheckIn': 'تسجيل الدخول',
      'bookingActionOpenTicket': 'فتح التذكرة',
      'bookingActionPickupInfo': 'معلومات الاستلام',
      'bookingActionTourDetails': 'تفاصيل الجولة',
      'bookingActionViewDetails': 'عرض التفاصيل',
      'bookingAdultsCount': '{count} بالغين',
      'bookingAdultCount': '{count} بالغ',
      'bookingHours': '{count} ساعات',
      'bookingsLoadFailed': 'تعذر تحميل حجوزاتك',
      'bookingsEmptyTitle': 'لا توجد حجوزات بعد',
      'bookingsEmptyBody': 'عند حجز فندق أو رحلة أو سيارة أو جولة، ستظهر هنا.',
      'bookingsEmptyUpcoming': 'لا توجد حجوزات قادمة',
      'bookingsEmptyPast': 'لا توجد حجوزات سابقة',
      'bookingsEmptyCancelled': 'لا توجد حجوزات ملغاة',
      'bookingsEmptyFiltered': 'لا شيء يطابق هذا الفلتر. جرّب فئة أخرى.',
      'bookingsSignInTitle': 'سجّل الدخول لعرض حجوزاتك',
      'bookingsSignInBody':
          'حجوزاتك مرتبطة بحسابك، لذا نحتاج إلى تسجيل دخولك لعرضها.',
      'bookingsStartExploring': 'ابدأ الاستكشاف',
      'month1': 'يناير',
      'month2': 'فبراير',
      'month3': 'مارس',
      'month4': 'أبريل',
      'month5': 'مايو',
      'month6': 'يونيو',
      'month7': 'يوليو',
      'month8': 'أغسطس',
      'month9': 'سبتمبر',
      'month10': 'أكتوبر',
      'month11': 'نوفمبر',
      'month12': 'ديسمبر',
      'timeAm': 'ص',
      'timePm': 'م',
    },
  };

  String _t(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;

  String get chooseYourLanguage => _t('chooseYourLanguage');
  String get selectLanguageToContinue => _t('selectLanguageToContinue');
  String get logIn => _t('logIn');
  String get email => _t('email');
  String get password => _t('password');
  String get forgetPassword => _t('forgetPassword');
  String get forgetPasswordSubtitle => _t('forgetPasswordSubtitle');
  String get phoneNumber => _t('phoneNumber');
  String get emailAddress => _t('emailAddress');
  String get sendCode => _t('sendCode');
  String get selectContactMethod => _t('selectContactMethod');
  String get orLabel => _t('orLabel');
  String get dontHaveAccount => _t('dontHaveAccount');
  String get registerNow => _t('registerNow');
  String get continueAsGuest => _t('continueAsGuest');
  String get emailRequired => _t('emailRequired');
  String get emailInvalid => _t('emailInvalid');
  String get passwordRequired => _t('passwordRequired');

  // --- Verification Code screen ---
  String get verificationCode => _t('verificationCode');
  String get didntReceiveCode => _t('didntReceiveCode');
  String get resendNow => _t('resendNow');
  String get verify => _t('verify');
  String get codeIncomplete => _t('codeIncomplete');
  String get codeIncorrect => _t('codeIncorrect');
  String get codeExpired => _t('codeExpired');
  String get tooManyAttempts => _t('tooManyAttempts');
  String get codeResentPhone => _t('codeResentPhone');
  String get codeResentEmail => _t('codeResentEmail');
  String get sendCodeFailed => _t('sendCodeFailed');
  String get networkError => _t('networkError');

  /// The raw subtitle template, still containing the literal `{dest}`
  /// placeholder. The screen splits on it so the destination can be drawn
  /// bold (and left-to-right) inside an otherwise right-to-left sentence.
  String get verificationSubtitleTemplate => _t('verificationSubtitle');

  /// Splits [verificationSubtitleTemplate] into the text before and after
  /// `{dest}`. Returns `(before, after)`.
  (String, String) verificationSubtitleParts() =>
      _splitOnDest(verificationSubtitleTemplate);

  String resendIn(int seconds) =>
      _t('resendIn').replaceAll('{seconds}', '$seconds');

  // --- Register screen ---
  String get register => _t('register');
  String get fullName => _t('fullName');
  String get age => _t('age');
  String get gender => _t('gender');
  String get genderMale => _t('genderMale');
  String get genderFemale => _t('genderFemale');
  String get genderOther => _t('genderOther');
  String get genderOptional => _t('genderOptional');
  String get alreadyHaveAccount => _t('alreadyHaveAccount');
  String get logInHere => _t('logInHere');
  String get passwordHint => _t('passwordHint');
  String get acceptTerms => _t('acceptTerms');
  String get termsRequired => _t('termsRequired');
  String get fullNameRequired => _t('fullNameRequired');
  String get fullNameTooShort => _t('fullNameTooShort');
  String get dateOfBirthRequired => _t('dateOfBirthRequired');
  String get mustBe18 => _t('mustBe18');
  String get phoneRequired => _t('phoneRequired');
  String get phoneInvalid => _t('phoneInvalid');
  String get selectCountryCode => _t('selectCountryCode');
  String get accountCreated => _t('accountCreated');
  String get registerFailed => _t('registerFailed');
  String get emailInUse => _t('emailInUse');
  String get phoneInUse => _t('phoneInUse');

  // --- Register Complete screen ---
  String get registerComplete => _t('registerComplete');
  String get registerCompleteSubtitle => _t('registerCompleteSubtitle');
  String get explore => _t('explore');
  String get onboardingTitleLine1 => _t('onboardingTitleLine1');
  String get onboardingTitleLine2 => _t('onboardingTitleLine2');
  String get onboardingBody1 => _t('onboardingBody1');
  String get onboardingTitle2Line1 => _t('onboardingTitle2Line1');
  String get onboardingTitle2Line2 => _t('onboardingTitle2Line2');
  String get onboardingBody2 => _t('onboardingBody2');
  String get onboardingTitle3Line1 => _t('onboardingTitle3Line1');
  String get onboardingTitle3Line2 => _t('onboardingTitle3Line2');
  String get onboardingBody3 => _t('onboardingBody3');
  String get onboardingNext => _t('onboardingNext');

  // --- Account Setup screen ---
  String get accountSetup => _t('accountSetup');
  String get accountSetupSubtitle => _t('accountSetupSubtitle');
  String get username => _t('username');
  String get createAccount => _t('createAccount');
  String get chooseFromGallery => _t('chooseFromGallery');
  String get takePhoto => _t('takePhoto');
  String get removePhoto => _t('removePhoto');
  String get usernameRequired => _t('usernameRequired');
  String get usernameTooShort => _t('usernameTooShort');
  String get imageTooLarge => _t('imageTooLarge');
  String get imagePickFailed => _t('imagePickFailed');
  String get profileSaveFailed => _t('profileSaveFailed');
  String get cameraPermissionDenied => _t('cameraPermissionDenied');
  String get galleryPermissionDenied => _t('galleryPermissionDenied');

  // --- Terms of Service screen ---
  String get termsOfService => _t('termsOfService');
  String get termsAgreeCheckbox => _t('termsAgreeCheckbox');
  String get continueLabel => _t('continueLabel');
  String get termsLoadFailed => _t('termsLoadFailed');
  String get tryAgain => _t('tryAgain');
  String get termsNotReviewed => _t('termsNotReviewed');

  String lastUpdated(String date) =>
      _t('lastUpdated').replaceAll('{date}', date);

  /// Subtitle for the Verification Code screen when it is verifying a phone
  /// number during registration, rather than resetting a password.
  String get verifyNumberSubtitleTemplate => _t('verifyNumberSubtitle');

  /// Splits [verifyNumberSubtitleTemplate] around `{dest}` — see
  /// [verificationSubtitleParts].
  (String, String) verifyNumberSubtitleParts() =>
      _splitOnDest(verifyNumberSubtitleTemplate);

  /// Title and subtitle for the registration **email** verification step.
  String get verifyEmailTitle => _t('verifyEmailTitle');
  String get verifyEmailSubtitleTemplate => _t('verifyEmailSubtitle');
  String get emailVerified => _t('emailVerified');

  /// Splits [verifyEmailSubtitleTemplate] around `{dest}`.
  (String, String) verifyEmailSubtitleParts() =>
      _splitOnDest(verifyEmailSubtitleTemplate);

  static (String, String) _splitOnDest(String template) {
    const marker = '{dest}';
    final index = template.indexOf(marker);
    if (index < 0) return (template, '');
    return (
      template.substring(0, index),
      template.substring(index + marker.length),
    );
  }

  // --- Reset Password screen ---
  String get resetPassword => _t('resetPassword');
  String get resetPasswordSubtitle => _t('resetPasswordSubtitle');
  String get newPassword => _t('newPassword');
  String get confirmPassword => _t('confirmPassword');
  String get updatePassword => _t('updatePassword');
  String get passwordTooShort => _t('passwordTooShort');
  String get passwordNeedsUppercase => _t('passwordNeedsUppercase');
  String get passwordNeedsLowercase => _t('passwordNeedsLowercase');
  String get passwordNeedsSpecial => _t('passwordNeedsSpecial');
  String get confirmPasswordRequired => _t('confirmPasswordRequired');
  String get passwordsDontMatch => _t('passwordsDontMatch');
  String get passwordUpdated => _t('passwordUpdated');
  String get passwordUpdateFailed => _t('passwordUpdateFailed');
  String get passwordTooWeak => _t('passwordTooWeak');
  String get sessionExpired => _t('sessionExpired');

  // --- Home screen ---
  String get dearUser => _t('dearUser');
  String get whereWouldYouLikeToGo => _t('whereWouldYouLikeToGo');
  String get planYourJourney => _t('planYourJourney');
  String get exploreNature => _t('exploreNature');
  String get exploreNatureHint => _t('exploreNatureHint');
  String get whereToStay => _t('whereToStay');
  String get whereToStayHint => _t('whereToStayHint');
  String get bestPrice => _t('bestPrice');
  String get carRental => _t('carRental');
  String get carRentalHint => _t('carRentalHint');
  String get findACar => _t('findACar');
  String get flightTicketing => _t('flightTicketing');
  String get flightTicketingHint => _t('flightTicketingHint');
  String get findFlight => _t('findFlight');
  String get exploreToursTitle => _t('exploreToursTitle');
  String get exploreToursHint => _t('exploreToursHint');
  String get findTours => _t('findTours');
  String get navHome => _t('navHome');
  String get navTrips => _t('navTrips');
  String get navMap => _t('navMap');
  String get navSaved => _t('navSaved');
  String get featuredLoadFailed => _t('featuredLoadFailed');
  String get featuredEmpty => _t('featuredEmpty');
  String get signInToSave => _t('signInToSave');
  String get signInToSaveBody => _t('signInToSaveBody');
  String get notNow => _t('notNow');
  String get addedToFavorites => _t('addedToFavorites');
  String get removedFromFavorites => _t('removedFromFavorites');
  String get favoriteFailed => _t('favoriteFailed');
  String get comingSoon => _t('comingSoon');
  String get mapOpenFailed => _t('mapOpenFailed');
  String get menu => _t('menu');
  String get changeLanguage => _t('changeLanguage');

  // --- Home screen side drawer ---
  String get close => _t('close');
  String get services => _t('services');
  String get myBookings => _t('myBookings');
  String get billingPayments => _t('billingPayments');
  String get billingPaymentTitle => _t('billingPaymentTitle');
  String get currentPaymentMethod => _t('currentPaymentMethod');
  String get addPaymentMethod => _t('addPaymentMethod');
  String get addPaymentMethodDescription => _t('addPaymentMethodDescription');
  String get paymentInformationEncrypted => _t('paymentInformationEncrypted');
  String get addCard => _t('addCard');
  String get debitOrCreditCard => _t('debitOrCreditCard');
  String get secureCheckout => _t('secureCheckout');
  String get secureCardSetupUnavailable => _t('secureCardSetupUnavailable');
  String get paymentMethodAlreadyAdded => _t('paymentMethodAlreadyAdded');
  String get newCard => _t('newCard');
  String get newCardDescription => _t('newCardDescription');
  String get cardDetails => _t('cardDetails');
  String get cardholderName => _t('cardholderName');
  String get cardNumber => _t('cardNumber');
  String get expiryDate => _t('expiryDate');
  String get expiryHint => _t('expiryHint');
  String get cvv => _t('cvv');
  String get country => _t('country');
  String get yourCountry => _t('yourCountry');
  String get zipCode => _t('zipCode');
  String get optional => _t('optional');
  String get saveCardForFutureBookings => _t('saveCardForFutureBookings');
  String get editPaymentMethodLater => _t('editPaymentMethodLater');
  String get requiredField => _t('requiredField');
  String get invalidCardNumber => _t('invalidCardNumber');
  String get invalidExpiryDate => _t('invalidExpiryDate');
  String get invalidCvv => _t('invalidCvv');
  String get editProfile => _t('editProfile');
  String get editProfileSubtitle => _t('editProfileSubtitle');
  String get firstAndLastName => _t('firstAndLastName');
  String get firstName => _t('firstName');
  String get lastName => _t('lastName');
  String get firstAndLastNameRequired => _t('firstAndLastNameRequired');
  String get saveChanges => _t('saveChanges');
  String get profileUpdated => _t('profileUpdated');
  String get settingsUpdateFailed => _t('settingsUpdateFailed');
  String get changeEmail => _t('changeEmail');
  String get changeEmailSubtitle => _t('changeEmailSubtitle');
  String get confirmEmailIdentitySubtitle => _t('confirmEmailIdentitySubtitle');
  String get currentEmail => _t('currentEmail');
  String get newEmail => _t('newEmail');
  String get newEmailVerificationSubtitle => _t('newEmailVerificationSubtitle');
  String get emailUpdated => _t('emailUpdated');
  String get currentPassword => _t('currentPassword');
  String get enterValidEmail => _t('enterValidEmail');
  String get sendVerificationLink => _t('sendVerificationLink');
  String get emailVerificationSent => _t('emailVerificationSent');
  String get reauthenticationFailed => _t('reauthenticationFailed');
  String get changePhoneNumber => _t('changePhoneNumber');
  String get changePhoneSubtitle => _t('changePhoneSubtitle');
  String get newPhoneNumber => _t('newPhoneNumber');
  String get phoneInternationalFormat => _t('phoneInternationalFormat');
  String get verificationCodeSent => _t('verificationCodeSent');
  // `verificationCode` and `sendCode` are deliberately NOT redeclared here —
  // both already exist above (Login / Verification Code screen) and resolve to
  // the same keys. Declaring them twice does not compile.
  String get verifyAndSave => _t('verifyAndSave');
  String get invalidVerificationCode => _t('invalidVerificationCode');
  String get passwordChangeRules => _t('passwordChangeRules');
  String get kilometers => _t('kilometers');
  String get miles => _t('miles');
  String get milesShort => _t('milesShort');
  String get defaultPayment => _t('defaultPayment');
  String get debitCard => _t('debitCard');
  String get creditCard => _t('creditCard');
  String get kurdistanInternationalBank => _t('kurdistanInternationalBank');
  String get firstIraqiBank => _t('firstIraqiBank');
  String get newlyAddedCard => _t('newlyAddedCard');
  String get savedCard => _t('savedCard');
  String get add => _t('add');
  String get change => _t('change');
  String get delete => _t('delete');
  String get cancel => _t('cancel');
  String get setDefaultCard => _t('setDefaultCard');
  String get setDefaultCardBody => _t('setDefaultCardBody');
  String get defaultCardUpdated => _t('defaultCardUpdated');
  String get deleteCardTitle => _t('deleteCardTitle');
  String deleteCardBody(String last4) =>
      _t('deleteCardBody').replaceAll('{last4}', last4);
  String get cardDeleted => _t('cardDeleted');
  String get cardAdded => _t('cardAdded');
  String get billingSignInTitle => _t('billingSignInTitle');
  String get billingSignInBody => _t('billingSignInBody');
  String get photoSignInTitle => _t('photoSignInTitle');
  String get photoSignInBody => _t('photoSignInBody');
  String get paymentHistory => _t('paymentHistory');
  String get paid => _t('paid');
  String get pending => _t('pending');
  String get viewReceipt => _t('viewReceipt');
  String get hotel => _t('hotel');
  String get flight => _t('flight');
  String get car => _t('car');
  String get tour => _t('tour');
  String get mountainViewResort => _t('mountainViewResort');
  String get erbilToIstanbul => _t('erbilToIstanbul');
  String get suvRental => _t('suvRental');
  String get rawanduzCanyonAdventure => _t('rawanduzCanyonAdventure');
  String get paymentDateMay24 => _t('paymentDateMay24');
  String get paymentDateMay23 => _t('paymentDateMay23');
  String get paymentDateMay25 => _t('paymentDateMay25');
  String get paymentDateMay26 => _t('paymentDateMay26');
  String get settings => _t('settings');
  String get settingsAccount => _t('settingsAccount');
  String get settingsChangePassword => _t('settingsChangePassword');
  String get settingsPreferences => _t('settingsPreferences');
  String get settingsNotifications => _t('settingsNotifications');
  String get settingsTheme => _t('settingsTheme');
  String get settingsLanguage => _t('settingsLanguage');
  String get settingsUnits => _t('settingsUnits');
  String get settingsSecurityLegal => _t('settingsSecurityLegal');
  String get settingsSecurityPrivacy => _t('settingsSecurityPrivacy');
  String get settingsDeleteAccount => _t('settingsDeleteAccount');
  String get notificationsPermissionDenied =>
      _t('notificationsPermissionDenied');
  String get notificationsUpdateFailed => _t('notificationsUpdateFailed');
  String get languageEnglish => _t('languageEnglish');
  String get languageKurdish => _t('languageKurdish');
  String get languageArabic => _t('languageArabic');
  String get kilometersShort => _t('kilometersShort');
  String get currency => _t('currency');
  String get policy => _t('policy');
  String get helpSupport => _t('helpSupport');
  String get aboutUs => _t('aboutUs');
  String get contactWay => _t('contactWay');
  String get logOut => _t('logOut');
  String get guestUser => _t('guestUser');
  String get guestDrawerPrompt => _t('guestDrawerPrompt');
  String get signInRequired => _t('signInRequired');
  String get selectCurrency => _t('selectCurrency');
  String get currencyUSD => _t('currencyUSD');
  String get currencyIQD => _t('currencyIQD');
  String get currencyEUR => _t('currencyEUR');
  String get currencyUpdated => _t('currencyUpdated');
  String get currencyUpdateFailed => _t('currencyUpdateFailed');
  String get logOutFailed => _t('logOutFailed');
  String get profilePhotoUpdated => _t('profilePhotoUpdated');
  // --- Explore Nature screen ---
  String get filterHiking => _t('filterHiking');
  String get filterBeach => _t('filterBeach');
  String get filterSunsetView => _t('filterSunsetView');
  String get filterCustomize => _t('filterCustomize');
  String get locationLabel => _t('locationLabel');
  String get distanceLabel => _t('distanceLabel');
  String get natureSpotsLoadFailed => _t('natureSpotsLoadFailed');
  String get natureSpotsEmpty => _t('natureSpotsEmpty');
  String get highlightedEmpty => _t('highlightedEmpty');
  String get clearFilters => _t('clearFilters');
  String get aboutThisPlace => _t('aboutThisPlace');
  String get placeNameLabel => _t('placeNameLabel');
  String get placeDistanceLabel => _t('placeDistanceLabel');
  String get suggestedStaysNearby => _t('suggestedStaysNearby');
  String stayDistanceAway(String distance) =>
      _t('stayDistanceAway').replaceAll('{distance}', distance);
  String get weather => _t('weather');
  String get weatherUnavailable => _t('weatherUnavailable');
  String get sunny => _t('sunny');
  String get partlyCloudy => _t('partlyCloudy');
  String get cloudy => _t('cloudy');
  String get rainy => _t('rainy');
  String get snowy => _t('snowy');
  String get ratingsAndReviews => _t('ratingsAndReviews');
  String basedOnReviews(int count) =>
      _t('basedOnReviews').replaceAll('{count}', '$count');
  String get writeReviewPrompt => _t('writeReviewPrompt');
  String get writeReviewHint => _t('writeReviewHint');
  String get reviewsLoadFailed => _t('reviewsLoadFailed');
  String get noReviewsYet => _t('noReviewsYet');
  String get seeAllReviews => _t('seeAllReviews');
  String get openPlaceMap => _t('openPlaceMap');

  /// e.g. "2.5 km from current location". [distance] is already formatted and
  /// is drawn left-to-right by the card, even in Kurdish and Arabic — a
  /// measurement is not a sentence.
  String distanceFromCurrentLocation(String distance) =>
      _t('distanceFromCurrentLocation').replaceAll('{distance}', distance);

  String reviewsCount(int count) =>
      _t('reviewsCount').replaceAll('{count}', '$count');

  // --- Reviews & Ratings screen ---
  String get reviewsAndRatings => _t('reviewsAndRatings');
  String get averageRating => _t('averageRating');

  /// The "/ 10" suffix beside the average score. Kept separate from the number
  /// so the number can be drawn larger, exactly as the reference does.
  String get outOfTen => _t('outOfTen');
  String get allReviews => _t('allReviews');
  String get sortReviewsBy => _t('sortReviewsBy');
  String get noRatingsYet => _t('noRatingsYet');
  String get addYourReview => _t('addYourReview');
  String get yourRating => _t('yourRating');
  String get reviewCommentHint => _t('reviewCommentHint');
  String get postReview => _t('postReview');
  String get updateReview => _t('updateReview');
  String get reviewPosted => _t('reviewPosted');
  String get reviewUpdated => _t('reviewUpdated');
  String get reviewPostFailed => _t('reviewPostFailed');
  String get reviewRatingRequired => _t('reviewRatingRequired');
  String get reviewCommentTooShort => _t('reviewCommentTooShort');
  String get reviewCommentTooLong => _t('reviewCommentTooLong');
  String get reviewSignInTitle => _t('reviewSignInTitle');
  String get reviewSignInBody => _t('reviewSignInBody');
  String get yourReviewLabel => _t('yourReviewLabel');
  String get editYourReview => _t('editYourReview');
  String get helpfulVote => _t('helpfulVote');
  String get helpfulVoteRemove => _t('helpfulVoteRemove');
  String get helpfulSignInBody => _t('helpfulSignInBody');
  String get helpfulFailed => _t('helpfulFailed');
  String get loadMoreReviews => _t('loadMoreReviews');

  /// The label on the sort control. One method rather than four getters at the
  /// call site, so a new [ReviewSort] cannot be added without a label.
  String reviewSortLabel(ReviewSort sort) => switch (sort) {
    ReviewSort.mostRecent => _t('sortMostRecent'),
    ReviewSort.highestRated => _t('sortHighestRated'),
    ReviewSort.lowestRated => _t('sortLowestRated'),
    ReviewSort.mostHelpful => _t('sortMostHelpful'),
  };

  /// "128 reviews" / "1 review". Singular is a separate string rather than a
  /// suffix rule, because Kurdish and Arabic do not pluralise the way English
  /// does and a stripped "s" would be wrong in both.
  String reviewCountLabel(int count) =>
      count == 1 ? _t('oneReview') : reviewsCount(count);

  /// Relative age of a review ("3 hours ago"), in the coarsest unit that still
  /// says something useful. Computed from [createdAt] rather than stored, so a
  /// review never claims to be newer than it is.
  String reviewAge(DateTime createdAt, {DateTime? now}) {
    final elapsed = (now ?? DateTime.now()).difference(createdAt);
    if (elapsed.inMinutes < 60) return _t('reviewJustNow');
    if (elapsed.inHours < 24) {
      return elapsed.inHours == 1
          ? _t('reviewOneHourAgo')
          : _t('reviewHoursAgo').replaceAll('{count}', '${elapsed.inHours}');
    }
    if (elapsed.inDays < 7) {
      return elapsed.inDays == 1
          ? _t('reviewOneDayAgo')
          : _t('reviewDaysAgo').replaceAll('{count}', '${elapsed.inDays}');
    }
    if (elapsed.inDays < 30) {
      final weeks = elapsed.inDays ~/ 7;
      return weeks == 1
          ? _t('reviewOneWeekAgo')
          : _t('reviewWeeksAgo').replaceAll('{count}', '$weeks');
    }
    if (elapsed.inDays < 365) {
      final months = elapsed.inDays ~/ 30;
      return months == 1
          ? _t('reviewOneMonthAgo')
          : _t('reviewMonthsAgo').replaceAll('{count}', '$months');
    }
    final years = elapsed.inDays ~/ 365;
    return years == 1
        ? _t('reviewOneYearAgo')
        : _t('reviewYearsAgo').replaceAll('{count}', '$years');
  }

  // --- Customize Filters screen ---
  String get customizeFilters => _t('customizeFilters');
  String get customizeFiltersSubtitle => _t('customizeFiltersSubtitle');
  String get resetAll => _t('resetAll');
  String get placeType => _t('placeType');
  String get facilitiesAmenities => _t('facilitiesAmenities');

  /// "6 Filters selected". Zero and one get their own wording rather than
  /// "0 Filters selected" / "1 Filters selected" — Arabic and Kurdish do not
  /// tolerate a plural noun after 1 any better than English does.
  String filtersSelected(int count) {
    if (count == 0) return _t('noFiltersSelected');
    if (count == 1) return _t('oneFilterSelected');
    return _t('filtersSelected').replaceAll('{count}', '$count');
  }

  /// "Show 32 Places" — the label on the apply button.
  String showPlaces(int count) {
    if (count == 0) return _t('showNoPlaces');
    if (count == 1) return _t('showOnePlace');
    return _t('showPlaces').replaceAll('{count}', '$count');
  }

  String placeTypeLabel(NaturePlaceType type) => switch (type) {
    NaturePlaceType.forest => _t('placeTypeForest'),
    NaturePlaceType.mountain => _t('placeTypeMountain'),
    NaturePlaceType.canyon => _t('placeTypeCanyon'),
    NaturePlaceType.park => _t('placeTypePark'),
    NaturePlaceType.lake => _t('placeTypeLake'),
    NaturePlaceType.waterfall => _t('placeTypeWaterfall'),
    NaturePlaceType.river => _t('placeTypeRiver'),
    NaturePlaceType.museum => _t('placeTypeMuseum'),
  };

  String amenityLabel(NatureAmenity amenity) => switch (amenity) {
    NatureAmenity.parking => _t('amenityParking'),
    NatureAmenity.restrooms => _t('amenityRestrooms'),
    NatureAmenity.restaurants => _t('amenityRestaurants'),
    NatureAmenity.cafes => _t('amenityCafes'),
    NatureAmenity.mobileSignal => _t('amenityMobileSignal'),
    NatureAmenity.lodgingNearby => _t('amenityLodgingNearby'),
    NatureAmenity.atmNearby => _t('amenityAtmNearby'),
  };

  // --- Policy screen ---
  String get policyOfApp => _t('policyOfApp');
  String get policyOfAppSubtitle => _t('policyOfAppSubtitle');
  String get policyLoadFailed => _t('policyLoadFailed');

  // --- Help & Support screen ---
  String get helpAndSupport => _t('helpAndSupport');

  String helpTopicTitle(HelpTopic topic) => switch (topic) {
    HelpTopic.account => _t('helpAccountTitle'),
    HelpTopic.bookings => _t('helpBookingsTitle'),
    HelpTopic.payments => _t('helpPaymentsTitle'),
    HelpTopic.cancellation => _t('helpCancellationTitle'),
    HelpTopic.flights => _t('helpFlightsTitle'),
    HelpTopic.stays => _t('helpStaysTitle'),
    HelpTopic.carRental => _t('helpCarRentalTitle'),
    HelpTopic.tours => _t('helpToursTitle'),
    HelpTopic.safety => _t('helpSafetyTitle'),
    HelpTopic.contact => _t('helpContactTitle'),
  };

  /// The truncated question under each row's title, e.g. "How do I change my
  /// email or ...". Deliberately cut off in the source copy — it is a teaser
  /// for the questions inside, not a sentence.
  String helpTopicPreview(HelpTopic topic) => switch (topic) {
    HelpTopic.account => _t('helpAccountPreview'),
    HelpTopic.bookings => _t('helpBookingsPreview'),
    HelpTopic.payments => _t('helpPaymentsPreview'),
    HelpTopic.cancellation => _t('helpCancellationPreview'),
    HelpTopic.flights => _t('helpFlightsPreview'),
    HelpTopic.stays => _t('helpStaysPreview'),
    HelpTopic.carRental => _t('helpCarRentalPreview'),
    HelpTopic.tours => _t('helpToursPreview'),
    HelpTopic.safety => _t('helpSafetyPreview'),
    HelpTopic.contact => _t('helpContactPreview'),
  };

  String policyTopicTitle(PolicyTopic topic) => switch (topic) {
    PolicyTopic.privacy => _t('policyPrivacyTitle'),
    PolicyTopic.terms => _t('policyTermsTitle'),
    PolicyTopic.cancellation => _t('policyCancellationTitle'),
    PolicyTopic.payment => _t('policyPaymentTitle'),
    PolicyTopic.liability => _t('policyLiabilityTitle'),
    PolicyTopic.contact => _t('policyContactTitle'),
    PolicyTopic.accountDeletion => _t('policyAccountDeletionTitle'),
  };

  String policyTopicSubtitle(PolicyTopic topic) => switch (topic) {
    PolicyTopic.privacy => _t('policyPrivacySubtitle'),
    PolicyTopic.terms => _t('policyTermsSubtitle'),
    PolicyTopic.cancellation => _t('policyCancellationSubtitle'),
    PolicyTopic.payment => _t('policyPaymentSubtitle'),
    PolicyTopic.liability => _t('policyLiabilitySubtitle'),
    PolicyTopic.contact => _t('policyContactSubtitle'),
    PolicyTopic.accountDeletion => _t('policyAccountDeletionSubtitle'),
  };

  String placesCount(int count) =>
      _t('placesCount').replaceAll('{count}', '$count');

  // --- My Bookings screen ---
  String get myBookingsTitle => _t('myBookings');
  String get bookingsLoadFailed => _t('bookingsLoadFailed');
  String get bookingsEmptyTitle => _t('bookingsEmptyTitle');
  String get bookingsEmptyBody => _t('bookingsEmptyBody');
  String get bookingsEmptyFiltered => _t('bookingsEmptyFiltered');
  String get bookingsSignInTitle => _t('bookingsSignInTitle');
  String get bookingsSignInBody => _t('bookingsSignInBody');
  String get bookingsStartExploring => _t('bookingsStartExploring');
  String get bookingCheckIn => _t('bookingCheckIn');
  String get bookingCheckOut => _t('bookingCheckOut');
  String get bookingSeat => _t('bookingSeat');
  String get bookingDuration => _t('bookingDuration');
  String get bookingId => _t('bookingId');
  String get bookingPickup => _t('bookingPickup');
  String get bookingDropoff => _t('bookingDropoff');
  String get bookingTotalPaid => _t('bookingTotalPaid');

  String bookingTypeFilterLabel(BookingTypeFilter filter) => switch (filter) {
    BookingTypeFilter.all => _t('bookingsFilterAll'),
    BookingTypeFilter.hotels => _t('bookingsFilterHotels'),
    BookingTypeFilter.cars => _t('bookingsFilterCars'),
    BookingTypeFilter.flights => _t('bookingsFilterFlights'),
    BookingTypeFilter.tours => _t('bookingsFilterTours'),
  };

  String bookingTimeFilterLabel(BookingTimeFilter filter) => switch (filter) {
    BookingTimeFilter.upcoming => _t('bookingsSegmentUpcoming'),
    BookingTimeFilter.past => _t('bookingsSegmentPast'),
    BookingTimeFilter.cancelled => _t('bookingsSegmentCancelled'),
  };

  /// The empty state shown when a time segment has no bookings at all — more
  /// specific than [bookingsEmptyTitle], which covers "no bookings ever".
  String bookingsEmptySegment(BookingTimeFilter filter) => switch (filter) {
    BookingTimeFilter.upcoming => _t('bookingsEmptyUpcoming'),
    BookingTimeFilter.past => _t('bookingsEmptyPast'),
    BookingTimeFilter.cancelled => _t('bookingsEmptyCancelled'),
  };

  /// The card's type label — "HOTEL", "FLIGHT" and so on.
  String bookingTypeLabel(BookingType type) => switch (type) {
    BookingType.hotel => _t('bookingTypeHotel'),
    BookingType.car => _t('bookingTypeCar'),
    BookingType.flight => _t('bookingTypeFlight'),
    BookingType.tour => _t('bookingTypeTour'),
  };

  String bookingStatusLabel(BookingStatus status) => switch (status) {
    BookingStatus.confirmed => _t('bookingStatusConfirmed'),
    BookingStatus.pending => _t('bookingStatusPending'),
    BookingStatus.cancelled => _t('bookingStatusCancelled'),
    BookingStatus.completed => _t('bookingStatusCompleted'),
  };

  String get bookingStatusUpcoming => _t('bookingStatusUpcoming');

  String cabinClassLabel(CabinClass cabin) => switch (cabin) {
    CabinClass.economy => _t('cabinEconomy'),
    CabinClass.premiumEconomy => _t('cabinPremiumEconomy'),
    CabinClass.business => _t('cabinBusiness'),
    CabinClass.first => _t('cabinFirst'),
  };

  /// The noun for the person-count column, which differs per product: a hotel
  /// has guests, a tour has travelers, a car has a driver, a flight has a
  /// traveler. One schema field, four labels — see `DATA_MODEL.md`.
  String bookingGuestLabel(BookingType type) => switch (type) {
    BookingType.hotel => _t('bookingGuests'),
    BookingType.tour => _t('bookingTravelers'),
    BookingType.car => _t('bookingDriver'),
    BookingType.flight => _t('bookingTraveler'),
  };

  /// The primary action on each card, which differs per product.
  String bookingActionLabel(BookingType type) => switch (type) {
    BookingType.hotel => _t('bookingActionCheckIn'),
    BookingType.flight => _t('bookingActionOpenTicket'),
    BookingType.car => _t('bookingActionPickupInfo'),
    BookingType.tour => _t('bookingActionTourDetails'),
  };

  String adultsCount(int count) => count == 1
      ? _t('bookingAdultCount').replaceAll('{count}', '$count')
      : _t('bookingAdultsCount').replaceAll('{count}', '$count');

  String bookingHours(int count) =>
      _t('bookingHours').replaceAll('{count}', '$count');

  String monthName(int month) => _t('month${month.clamp(1, 12)}');

  /// "May 24, 2025" in English; "24 ئایار 2025" in Kurdish and Arabic, where
  /// the day precedes the month.
  ///
  /// Written by hand rather than via `intl`, which ships no `ku` locale — the
  /// same reason the rest of this file is hand-written. Digits stay Western in
  /// all three languages, matching how every other number in the app is drawn.
  String bookingDate(DateTime date) {
    final month = monthName(date.month);
    if (locale.languageCode == 'en') return '$month ${date.day}, ${date.year}';
    return '${date.day} $month ${date.year}';
  }

  /// "9:35 AM" — 12-hour in all three languages, matching the reference.
  String bookingTime(DateTime time) {
    final isPm = time.hour >= 12;
    var hour = time.hour % 12;
    if (hour == 0) hour = 12;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${isPm ? _t('timePm') : _t('timeAm')}';
  }

  /// "2h 45m", assembled from digits only so it needs no per-language string.
  String flightDuration(int minutes) {
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (hours == 0) return '${rest}m';
    if (rest == 0) return '${hours}h';
    return '${hours}h ${rest}m';
  }

  /// Time-of-day greeting, e.g. "Good evening".
  ///
  /// Three buckets. There is deliberately **no "Good night"**: the dashboard
  /// greets someone who has just opened the app, and telling them good night
  /// reads as a farewell. Evening therefore runs from 17:00 straight through
  /// to 05:00, so a 1am visit still reads "Good evening".
  ///
  /// The afternoon band stays, because without it 13:00 would have to read
  /// either "Good morning" or "Good evening" — both wrong in all three
  /// languages.
  String greetingForHour(int hour) {
    if (hour >= 5 && hour < 12) return _t('goodMorning');
    if (hour >= 12 && hour < 17) return _t('goodAfternoon');
    return _t('goodEvening');
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const <String>['en', 'ku', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// --- Kurdish fallback delegates -------------------------------------------
// Flutter's global localizations don't support `ku`, so for Kurdish we reuse
// Arabic's localizations. That also gives Kurdish right-to-left layout.

class _KurdishMaterialDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _KurdishMaterialDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(_KurdishMaterialDelegate old) => false;
}

class _KurdishCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _KurdishCupertinoDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(_KurdishCupertinoDelegate old) => false;
}

class _KurdishWidgetsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _KurdishWidgetsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(_KurdishWidgetsDelegate old) => false;
}
