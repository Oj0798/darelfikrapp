import '../domain/book.dart';

abstract class LibraryRepository {
  Future<List<Work>> getWorksByCategory(String tag);

  /// school: fiqh_hanafi | fiqh_maliki | fiqh_shafii | fiqh_hanbali
  Future<List<Work>> getWorksByFiqhSchool(String school);

  Future<List<Volume>> getVolumesForWork(String workId);

  /// Home sections
  Future<List<Work>> getFeaturedWorks({int limit = 10});
  Future<List<Work>> getRecentWorks({int limit = 20});
  // ✅ ADD THIS
  Future<List<Work>> searchWorks(String query);
  
}
