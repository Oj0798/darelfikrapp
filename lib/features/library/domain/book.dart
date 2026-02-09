/// CRITICAL:
/// Work = entire scholarly work (not a volume)
/// Volume = generated from Work.volumesCount
/// Titles/authors are Latin-only for now (Arabic later via i18n)
library;

class Work {
  final String id;
  final String titleEn;
  final String authorEn;

  /// One of: Hadith, Tafsir, Fiqh, Aqidah, Seerah, Arabic
  final String category;

  /// Tags drive filtering + subscription access.
  /// Examples:
  /// hadith, tafsir, aqidah, seerah, arabic
  /// fiqh_hanafi, fiqh_maliki, fiqh_shafii, fiqh_hanbali
  final List<String> tags;

  /// number only
  final int volumesCount;

  const Work({
    required this.id,
    required this.titleEn,
    required this.authorEn,
    required this.category,
    required this.tags,
    required this.volumesCount,
  });
}

class Volume {
  final String workId;
  final int volumeNumber;

  const Volume({
    required this.workId,
    required this.volumeNumber,
  });

  String get title => 'Volume $volumeNumber';
}
