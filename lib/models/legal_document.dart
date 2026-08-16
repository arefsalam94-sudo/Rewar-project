/// What one block inside a [LegalSection] is drawn as.
enum LegalBlockType {
  /// A run of prose.
  paragraph,

  /// A "•" item with a hanging indent, so wrapped lines line up with the text
  /// rather than sitting under the bullet.
  bullet,
}

/// One paragraph or bullet inside a legal document.
///
/// [lead] is the bold run at the start of a bullet — "**Account & contact
/// details:** name, email, …". It is a separate field rather than a marker
/// inside [text] so nothing has to be parsed at render time: a typo in the
/// admin panel can't silently break the formatting, and Kurdish/Arabic
/// bullets lay out right-to-left correctly without a parser having to know
/// which end of the string the bold run is on.
class LegalBlock {
  const LegalBlock({required this.type, required this.text, this.lead});

  const LegalBlock.paragraph(this.text)
    : type = LegalBlockType.paragraph,
      lead = null;

  const LegalBlock.bullet(this.text, {this.lead})
    : type = LegalBlockType.bullet;

  final LegalBlockType type;

  /// Bold lead-in, drawn immediately before [text] on the same line. Null on
  /// a bullet that has no emphasised opening.
  final String? lead;

  final String text;

  /// The block as plain text, used for the legacy [LegalSection.body].
  String get plainText => lead == null ? text : '$lead $text';

  static LegalBlock? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final text = raw['text'];
    if (text is! String || text.isEmpty) return null;
    final lead = raw['lead'];
    return LegalBlock(
      type: raw['type'] == 'bullet'
          ? LegalBlockType.bullet
          : LegalBlockType.paragraph,
      lead: lead is String && lead.isNotEmpty ? lead : null,
      text: text,
    );
  }
}

/// One block of a legal document — an optional heading plus its content.
///
/// Two stored shapes are accepted, because `terms_of_service` predates the
/// Privacy Policy and must keep parsing untouched:
///
/// - **`{heading, body}`** — the original. Becomes a single paragraph block.
/// - **`{heading?, blocks: [...]}`** — headings, paragraphs and bullets. The
///   heading is optional here: the Privacy Policy opens with an untitled
///   lead-in paragraph before its first section.
class LegalSection {
  const LegalSection({required this.heading, required this.blocks});

  /// Convenience for the bundled documents, which are written in Dart.
  LegalSection.prose({required String heading, required String body})
    : this(heading: heading, blocks: [LegalBlock.paragraph(body)]);

  /// Empty string when the section has no heading of its own. Not nullable,
  /// so the already-built Terms screen keeps compiling against it unchanged.
  final String heading;

  final List<LegalBlock> blocks;

  /// The section's content as one string.
  ///
  /// Kept for the Terms screen, which predates [blocks] and renders a plain
  /// paragraph. New screens should draw [blocks] so bullets survive.
  String get body => blocks.map((b) => b.plainText).join('\n');

  static LegalSection? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final heading = raw['heading'];
    if (heading != null && heading is! String) return null;

    final rawBlocks = raw['blocks'];
    if (rawBlocks is List) {
      final blocks = rawBlocks
          .map(LegalBlock.tryParse)
          .whereType<LegalBlock>()
          .toList();
      if (blocks.isEmpty) return null;
      return LegalSection(heading: (heading as String?) ?? '', blocks: blocks);
    }

    // Legacy `{heading, body}` shape — heading is required there.
    final body = raw['body'];
    if (heading is! String || body is! String) return null;
    return LegalSection(heading: heading, blocks: [LegalBlock.paragraph(body)]);
  }
}

/// A versioned legal document (Terms of Service, Privacy Policy) held in the
/// `legal_documents` Firestore collection so the wording can be updated from
/// the admin panel without an app-store release — which is what the Terms
/// text itself promises.
///
/// [version] is the part that matters operationally: consent is recorded
/// against it (`users.termsVersion`), so when the wording changes you can
/// tell exactly who agreed to which text and re-prompt only those who
/// haven't seen the current one.
class LegalDocument {
  const LegalDocument({
    required this.version,
    required this.updatedAt,
    required this.sections,
    required this.legalReviewed,
  });

  final int version;
  final DateTime? updatedAt;
  final List<LegalSection> sections;

  /// False until a qualified translator/lawyer has signed off the wording.
  /// Surfaced in the UI so an unreviewed document can't ship unnoticed.
  final bool legalReviewed;

  /// Reads the document for [languageCode], falling back to English when a
  /// translation is missing — never showing an empty legal page.
  static LegalDocument? fromMap(
    Map<String, dynamic>? data,
    String languageCode,
  ) {
    if (data == null) return null;
    final content = data['content'];
    if (content is! Map) return null;

    final localized = content[languageCode] ?? content['en'];
    if (localized is! Map) return null;

    final rawSections = localized['sections'];
    if (rawSections is! List) return null;

    final sections = rawSections
        .map(LegalSection.tryParse)
        .whereType<LegalSection>()
        .toList();
    if (sections.isEmpty) return null;

    final rawUpdatedAt = data['updatedAt'];
    return LegalDocument(
      version: (data['version'] as num?)?.toInt() ?? 1,
      // Accepts a Firestore Timestamp (which exposes toDate()) without this
      // model needing to depend on cloud_firestore.
      updatedAt: switch (rawUpdatedAt) {
        DateTime dt => dt,
        // The bundled JSON asset stores an ISO-8601 string; Firestore hands
        // back a Timestamp. Both have to land on the same DateTime.
        String iso => DateTime.tryParse(iso),
        final dynamic ts when ts != null => _tryToDate(ts),
        _ => null,
      },
      sections: sections,
      legalReviewed: data['legalReviewed'] == true,
    );
  }

  static DateTime? _tryToDate(dynamic value) {
    try {
      return value.toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
