import '../domain/book.dart';
import 'book_seeds.dart';
import 'library_repository.dart';

class LocalLibraryRepository implements LibraryRepository {
  const LocalLibraryRepository();

  static final List<Work> _works = workSeeds.map((s) {
    return Work(
      id: s.id,
      titleEn: s.title,            // Arabic stored here intentionally
      authorEn: s.author,          // Arabic stored here intentionally
      category: s.category,
      tags: List<String>.from(s.tags),
      volumesCount: s.volumeCount, // seed field is volumeCount
    );
  }).toList(growable: false);

  static final Map<String, Work> _byId = {for (final w in _works) w.id: w};

  @override
  Future<List<Work>> getWorksByCategory(String tag) async {
    return _works.where((w) => w.tags.contains(tag)).toList(growable: false);
  }

  @override
  Future<List<Work>> getWorksByFiqhSchool(String school) async {
    return _works.where((w) => w.tags.contains(school)).toList(growable: false);
  }

  @override
  Future<List<Volume>> getVolumesForWork(String workId) async {
    final work = _byId[workId];
    if (work == null) return const [];

    final count = work.volumesCount;
    if (count <= 0) return const [];

    return List<Volume>.generate(
      count,
      (i) => Volume(workId: workId, volumeNumber: i + 1),
      growable: false,
    );
  }

  @override
  Future<List<Work>> getFeaturedWorks({int limit = 10}) async {
    // Use explicit featured flag from seeds (not "first N")
    final featured = _works.where((w) {
      final seed = workSeedsById[w.id];
      return seed?.isFeatured ?? false;
    }).toList(growable: false);

    return featured.take(limit).toList(growable: false);
  }

  @override
  Future<List<Work>> getRecentWorks({int limit = 20}) async {
    // Use explicit recent flag from seeds (not "last N")
    final recent = _works.where((w) {
      final seed = workSeedsById[w.id];
      return seed?.isRecent ?? false;
    }).toList(growable: false);

    return recent.take(limit).toList(growable: false);
  }
    @override
  Future<List<Work>> searchWorks(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final lower = q.toLowerCase();

    return _works.where((w) {
      final title = w.titleEn.toLowerCase();
      final author = w.authorEn.toLowerCase();
      return title.contains(lower) || author.contains(lower);
    }).toList(growable: false);
  }
}

/// Simple lookup so featured/recent can follow the seed flags.
final Map<String, WorkSeed> workSeedsById = {
  for (final s in workSeeds) s.id: s,
};

