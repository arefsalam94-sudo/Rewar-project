import 'help_topic.dart';

/// One bundled Help & Support question and answer.
class HelpFaqEntry {
  const HelpFaqEntry({required this.question, required this.answer});

  final String question;
  final String answer;
}

/// English fallback content supplied for the ten Help & Support rows.
///
/// Firestore remains the planned live source (`help_topics/{docId}`), but the
/// bundled copy makes the accordion useful before that collection is seeded.
/// Kurdish and Arabic continue to use their localized row titles/previews and
/// fall back to this English body until translated Q&A copy is supplied.
const Map<HelpTopic, List<HelpFaqEntry>> bundledHelpFaqs = {
  HelpTopic.account: [
    HelpFaqEntry(
      question: 'How do I create an account?',
      answer:
          'Open the app, tap Sign Up, and register with your email or phone number, or continue with Google or Apple. Verify the code we send you and your account is ready.',
    ),
    HelpFaqEntry(
      question: 'I forgot my password. What do I do?',
      answer:
          "On the sign-in screen tap 'Forgot Password', enter your registered email, and follow the reset link we send you.",
    ),
    HelpFaqEntry(
      question: 'How do I change my email or phone number?',
      answer:
          'Go to Settings > Account. You can update your email or phone there. For security we will send a verification code to confirm the change.',
    ),
    HelpFaqEntry(
      question: 'How do I turn on extra security (MFA)?',
      answer:
          'In Settings > Security you can enable SMS verification or an authenticator app for an added layer of protection on your account.',
    ),
    HelpFaqEntry(
      question: 'How do I delete my account?',
      answer:
          'Go to Settings > Account > Delete Account. This permanently removes your data. Any active bookings should be completed or cancelled first.',
    ),
    HelpFaqEntry(
      question: 'I think someone accessed my account. What should I do?',
      answer:
          'Change your password immediately in Settings > Security, sign out of all devices, and contact us using the number below so we can help secure your account.',
    ),
  ],
  HelpTopic.bookings: [
    HelpFaqEntry(
      question: 'Where can I see my bookings?',
      answer:
          "All your flight, hotel, car, and tour bookings appear under 'My Bookings' in the main menu.",
    ),
    HelpFaqEntry(
      question: "I didn't receive a confirmation. What should I do?",
      answer:
          "Confirmations usually arrive within a few minutes by email and in-app. Check 'My Bookings' first. If it's still missing, contact us with your booking details.",
    ),
    HelpFaqEntry(
      question: 'Can you resend my confirmation?',
      answer:
          "Yes. Open the booking in 'My Bookings' and tap 'Resend Confirmation', or contact us and we'll send it again.",
    ),
    HelpFaqEntry(
      question: 'What is my booking reference and where do I find it?',
      answer:
          "Your booking reference is a unique ID shown on each booking in 'My Bookings' and in your confirmation. Keep it handy when contacting support.",
    ),
    HelpFaqEntry(
      question: 'My booking is not confirmed yet. What does that mean?',
      answer:
          "Some bookings need a short confirmation from the provider. Keep checking 'My Bookings'. If it remains pending, contact us with your booking reference.",
    ),
  ],
  HelpTopic.payments: [
    HelpFaqEntry(
      question: 'What payment methods can I use?',
      answer:
          'You can pay with FIB (First Iraqi Bank), NassWallet, or credit/debit card. Apple Pay and Google Pay are also supported on compatible devices.',
    ),
    HelpFaqEntry(
      question: 'My payment failed but I want to complete the booking.',
      answer:
          'Check your card or wallet balance and details, then try again. If it keeps failing, use a different method or contact us for help.',
    ),
    HelpFaqEntry(
      question: "I was charged but didn't get a confirmation.",
      answer:
          "Don't book again. Contact us with the payment details and we'll locate the transaction and confirm or refund it.",
    ),
    HelpFaqEntry(
      question: 'I was charged twice. What do I do?',
      answer:
          "Contact us with your booking reference and both charge details. We'll investigate and refund any duplicate charge.",
    ),
    HelpFaqEntry(
      question: 'When will I get my refund?',
      answer:
          'Approved refunds are processed back to your original payment method. Timing depends on your bank or wallet, usually within a few business days.',
    ),
    HelpFaqEntry(
      question: 'Am I eligible for a refund?',
      answer:
          "It depends on the booking's cancellation policy, shown before you book and in your booking details. Non-refundable bookings may not qualify.",
    ),
  ],
  HelpTopic.cancellation: [
    HelpFaqEntry(
      question: 'How do I cancel a booking?',
      answer:
          "Open the booking in 'My Bookings' and tap Cancel. You'll see any applicable fees before you confirm.",
    ),
    HelpFaqEntry(
      question: 'Will I be charged if I cancel?',
      answer:
          "That depends on the cancellation policy of your specific booking. Free-cancellation bookings won't be charged if cancelled in time; non-refundable ones may be.",
    ),
    HelpFaqEntry(
      question: 'Can I change my booking instead of cancelling?',
      answer:
          "For many bookings you can change the date, name, or details. Open the booking and tap Modify, or contact us if the option isn't available.",
    ),
    HelpFaqEntry(
      question: 'How do I check my cancellation status?',
      answer:
          "The status updates in 'My Bookings'. If it hasn't changed after some time, contact us with your booking reference.",
    ),
  ],
  HelpTopic.flights: [
    HelpFaqEntry(
      question: 'How do I change or cancel a flight ticket?',
      answer:
          "Open the flight in 'My Bookings'. Change and cancellation options depend on the airline's fare rules, which are shown before you book.",
    ),
    HelpFaqEntry(
      question: 'What is the baggage allowance for my ticket?',
      answer:
          'Baggage allowance is set by the airline and shown on your ticket details. Extra baggage can sometimes be added before departure.',
    ),
    HelpFaqEntry(
      question: 'The name on my ticket is wrong. Can I fix it?',
      answer:
          "Name corrections depend on airline rules. Contact us as early as possible with your booking reference and we'll check what's possible.",
    ),
    HelpFaqEntry(
      question: 'How do I check in for my flight?',
      answer:
          'Check-in is handled by the airline, usually online before departure or at the airport counter. Your e-ticket has the details you need.',
    ),
  ],
  HelpTopic.stays: [
    HelpFaqEntry(
      question: 'What are the check-in and check-out times?',
      answer:
          'These are set by each property and shown in your booking details. Contact the property or us if you need early check-in or late check-out.',
    ),
    HelpFaqEntry(
      question: 'Is breakfast included?',
      answer:
          'This depends on the room and rate you booked. Your booking details show whether breakfast is included.',
    ),
    HelpFaqEntry(
      question: 'Can I make a special request (bed type, non-smoking, etc.)?',
      answer:
          "Yes, you can add special requests to your booking. They are requests, not guarantees, and depend on the property's availability.",
    ),
    HelpFaqEntry(
      question: "The property can't find my reservation. What do I do?",
      answer:
          "Show them your booking reference and confirmation. If they still can't locate it, contact us right away and we'll assist.",
    ),
    HelpFaqEntry(
      question: 'Is parking available at the property?',
      answer:
          "Parking availability is listed on each property's detail page. Some offer free parking, others paid or nearby options.",
    ),
  ],
  HelpTopic.carRental: [
    HelpFaqEntry(
      question: 'What documents do I need to rent a car?',
      answer:
          "You'll typically need a valid driving licence, an ID or passport, and the payment card used for booking. Requirements are shown at booking.",
    ),
    HelpFaqEntry(
      question: 'Is insurance included?',
      answer:
          "Insurance options are listed on each car's detail page. Some rates include basic cover; extra protection can often be added.",
    ),
    HelpFaqEntry(
      question: 'Is there a security deposit?',
      answer:
          'Many rentals require a refundable deposit held at pickup. The amount is shown in the booking details before you confirm.',
    ),
    HelpFaqEntry(
      question: 'Where do I pick up and return the car?',
      answer:
          'Pickup and return locations are shown in your booking. Contact the rental provider or us if you need to change them.',
    ),
    HelpFaqEntry(
      question: 'What is the fuel policy?',
      answer:
          'Fuel policy (for example, return with a full tank) is stated in the booking terms for each car.',
    ),
  ],
  HelpTopic.tours: [
    HelpFaqEntry(
      question: "What's included in a tour?",
      answer:
          "Each tour lists what's included, such as guide, transport, and entry fees, on its detail page before you book.",
    ),
    HelpFaqEntry(
      question: 'Where and when do we meet?',
      answer:
          'The meeting point and time are shown in your booking confirmation. Arrive a little early to avoid missing the start.',
    ),
    HelpFaqEntry(
      question: 'What happens if the weather is bad?',
      answer:
          "Outdoor tours may be rescheduled or refunded if conditions are unsafe. Check the tour's policy or contact us for options.",
    ),
    HelpFaqEntry(
      question: 'What should I bring for nature trips?',
      answer:
          'Bring comfortable shoes, water, sun protection, and weather-appropriate clothing. Specific tips are listed on each tour.',
    ),
    HelpFaqEntry(
      question: 'Are the tours suitable for families or beginners?',
      answer:
          "Difficulty and suitability are noted on each tour. If you're unsure which fits your group, contact us and we'll recommend one.",
    ),
  ],
  HelpTopic.safety: [
    HelpFaqEntry(
      question: 'What are the emergency numbers in the Kurdistan Region?',
      answer:
          'For emergencies dial the local police, ambulance, or tourist police. Keep your accommodation address and booking reference with you.',
    ),
    HelpFaqEntry(
      question: 'Do I need permits or ID at checkpoints?',
      answer:
          'Carry a valid ID or passport when travelling between areas. Requirements can change, so check current local guidance before your trip.',
    ),
    HelpFaqEntry(
      question: 'When is the best time to visit?',
      answer:
          'Spring and autumn are ideal for nature and mountains, with mild weather. Summer is hot in the plains; winter can bring snow to higher areas.',
    ),
  ],
  HelpTopic.contact: [],
};

List<HelpFaqEntry> bundledHelpFaqsFor(HelpTopic topic) =>
    bundledHelpFaqs[topic] ?? const [];
