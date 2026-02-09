import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/router.dart';
import '../data/library_repository.dart';
import '../data/local_library_repository.dart';
import '../domain/book.dart';
import '../reader/reader_screen.dart';
import '../widgets/books_list.dart';

enum CategoryBooksMode { category, fiqhSchool }

class CategoryBooksScreen extends StatefulWidget {
  final String title;
  final String filterTag;
  final CategoryBooksMode mode;

  const CategoryBooksScreen({
    super.key,
    required this.title,
    required this.filterTag,
    required this.mode,
  });

  @override
  State<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
  final LibraryRepository repo = const LocalLibraryRepository();

  static const _kIsSubscribedKey = 'df_is_subscribed';
  static const _kTierKey = 'df_subscription_tier';

  bool _isSubscribed = false;
  String? _tier;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isSubscribed = prefs.getBool(_kIsSubscribedKey) ?? false;
      _tier = prefs.getString(_kTierKey);
    });
  }

  List<String> _grantedTagsForTier(String? tier) {
    switch (tier) {
      case 'tier1':
        return const ['hadith'];
      case 'tier2':
        return const ['hadith', 'tafsir'];
      case 'tier3':
        return const ['hadith', 'tafsir', 'fiqh', 'aqidah', 'seerah', 'arabic'];
      default:
        return const [];
    }
  }

  bool _hasAccess(List<String> requiredTags) {
    if (requiredTags.isEmpty) return true;
    final granted = _grantedTagsForTier(_tier);
    return requiredTags.any(granted.contains);
  }

  String _prettyTier(String? tier) {
    switch (tier) {
      case 'tier1':
        return 'Basic';
      case 'tier2':
        return 'Standard';
      case 'tier3':
        return 'Premium';
      default:
        return 'Active';
    }
  }

  Future<void> _showUpgradeDialog(List<String> tags) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Upgrade required'),
        content: Text(
          'Your plan (${_prettyTier(_tier)}) does not include this work.\n\nRequired: ${tags.join(', ')}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.pushNamed(context, AppRoutes.subscription);
              if (!mounted) return;
              await _loadSubscription();
            },
            child: const Text('View subscriptions'),
          ),
        ],
      ),
    );
  }

  Future<List<Work>> _loadWorks() {
    if (widget.mode == CategoryBooksMode.fiqhSchool) {
      return repo.getWorksByFiqhSchool(widget.filterTag);
    }
    return repo.getWorksByCategory(widget.filterTag);
  }

  Future<void> _openWork(Work work) async {
    // Access check on WORK tap
    if (_isSubscribed && !_hasAccess(work.tags)) {
      await _showUpgradeDialog(work.tags);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VolumesScreen(
          repo: repo,
          work: work,
          isSubscribed: _isSubscribed,
          tier: _tier,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Work>>(
        future: _loadWorks(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const SafeArea(child: Center(child: CircularProgressIndicator()));
          }

          final works = (snap.data ?? const <Work>[]).toList();
          works.sort((a, b) => a.titleEn.compareTo(b.titleEn));

          return BooksList(
            works: works,
            onTapWork: _openWork,
          );
        },
      ),
    );
  }
}

class VolumesScreen extends StatefulWidget {
  final LibraryRepository repo;
  final Work work;
  final bool isSubscribed;
  final String? tier;

  const VolumesScreen({
    super.key,
    required this.repo,
    required this.work,
    required this.isSubscribed,
    required this.tier,
  });

  @override
  State<VolumesScreen> createState() => _VolumesScreenState();
}

class _VolumesScreenState extends State<VolumesScreen> {
  bool isSubscribed = false;
  String? tier;

  @override
  void initState() {
    super.initState();
    isSubscribed = widget.isSubscribed;
    tier = widget.tier;
  }

  Future<void> _reloadSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isSubscribed = prefs.getBool('df_is_subscribed') ?? false;
      tier = prefs.getString('df_subscription_tier');
    });
  }

  List<String> _grantedTagsForTier(String? tier) {
    switch (tier) {
      case 'tier1':
        return const ['hadith'];
      case 'tier2':
        return const ['hadith', 'tafsir'];
      case 'tier3':
        return const ['hadith', 'tafsir', 'fiqh', 'aqidah', 'seerah', 'arabic'];
      default:
        return const [];
    }
  }

  bool _hasAccess(List<String> requiredTags) {
    if (requiredTags.isEmpty) return true;
    final granted = _grantedTagsForTier(tier);
    return requiredTags.any(granted.contains);
  }

  String _prettyTier(String? tier) {
    switch (tier) {
      case 'tier1':
        return 'Basic';
      case 'tier2':
        return 'Standard';
      case 'tier3':
        return 'Premium';
      default:
        return 'Active';
    }
  }

  Future<void> _showUpgradeDialog(BuildContext context, List<String> tags) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Upgrade required'),
        content: Text(
          'Your plan (${_prettyTier(tier)}) does not include this work.\n\nRequired: ${tags.join(', ')}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Not now')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Navigator.pushNamed(context, AppRoutes.subscription);
              await _reloadSubscription();
              if (!mounted) return;
              if (_hasAccess(tags)) {
                return;
              }

              await _showUpgradeDialog(context, tags);
            },
            child: const Text('View subscriptions'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.work.titleEn)),
      body: FutureBuilder<List<Volume>>(
        future: widget.repo.getVolumesForWork(widget.work.id),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const SafeArea(child: Center(child: CircularProgressIndicator()));
          }

          final volumes = snap.data ?? const <Volume>[];
          if (volumes.isEmpty) return const SafeArea(child: Center(child: Text('No volumes')));

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            itemCount: volumes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final v = volumes[i];
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () async {
                  // Access check on VOLUME tap
                  if (isSubscribed && !_hasAccess(widget.work.tags)) {
                    await _showUpgradeDialog(context, widget.work.tags);
                    if (!mounted) return;
                    if (isSubscribed && !_hasAccess(widget.work.tags)) {
                      return;
                    }
                  }

                  if (!mounted) return;
                  if (isSubscribed && !_hasAccess(widget.work.tags)) {
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReaderScreen(
                        workId: widget.work.id,
                        workTitleEn: widget.work.titleEn,
                        volumeNumber: v.volumeNumber,
                        requiredTags: widget.work.tags,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x14000000)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F2FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.bookmark_outline_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          v.title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
