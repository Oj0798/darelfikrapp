import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/search_screen.dart';

import '../../app/router.dart';
import 'data/library_repository.dart';
import 'data/local_library_repository.dart';
import 'domain/book.dart';
import 'screens/category_books_screen.dart';
import 'screens/fiqh_hub_screen.dart';

const _kIsSubscribedKey = 'df_is_subscribed';
const _kTierKey = 'df_subscription_tier';

class _SubState {
  final bool isSubscribed;
  final String? tier;
  const _SubState({required this.isSubscribed, required this.tier});
}

Future<_SubState> _loadSub() async {
  final prefs = await SharedPreferences.getInstance();
  final sub = prefs.getBool(_kIsSubscribedKey) ?? false;
  final tier = prefs.getString(_kTierKey);
  return _SubState(isSubscribed: sub, tier: tier);
}

List<String> _grantedTagsForTier(String? tier) {
  switch (tier) {
    case 'tier1':
      return const ['hadith'];
    case 'tier2':
      return const ['hadith', 'tafsir'];
    case 'tier3':
      // Premium = ALL categories
      return const ['hadith', 'tafsir', 'fiqh', 'aqidah', 'seerah', 'arabic'];
    default:
      return const [];
  }
}

bool _hasAccess(List<String> requiredTags, String? tier) {
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

Future<void> _showUpgradeDialog(BuildContext context, String? tier, List<String> tags) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Upgrade required'),
      content: Text(
        'Your plan (${_prettyTier(tier)}) does not include this work.\n\nRequired: ${tags.join(', ')}',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await Navigator.pushNamed(context, AppRoutes.subscription);
          },
          child: const Text('View subscriptions'),
        ),
      ],
    ),
  );
}

class LibraryHomeScreen extends StatelessWidget {
  const LibraryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LibraryRepository repo = const LocalLibraryRepository();

    final categories = const [
      _CategoryData('Hadith', Icons.format_quote_rounded, 'hadith'),
      _CategoryData('Tafsir', Icons.menu_book_rounded, 'tafsir'),
      _CategoryData('Fiqh', Icons.balance_rounded, 'fiqh'),
      _CategoryData('Aqidah', Icons.lightbulb_rounded, 'aqidah'),
      _CategoryData('Seerah', Icons.auto_stories_rounded, 'seerah'),
      _CategoryData('Arabic', Icons.translate_rounded, 'arabic'),
    ];

    return FutureBuilder<_SubState>(
      future: _loadSub(),
      builder: (context, subSnap) {
        if (subSnap.connectionState != ConnectionState.done) {
          return const Scaffold(body: SafeArea(child: Center(child: CircularProgressIndicator())));
        }
        final isSubscribed = subSnap.data?.isSubscribed ?? false;
        final tier = subSnap.data?.tier;

        return FutureBuilder<List<List<Work>>>(
          future: Future.wait([
            repo.getFeaturedWorks(limit: 10),
            repo.getRecentWorks(limit: 20),
          ]),
          builder: (context, dataSnap) {
            if (dataSnap.connectionState != ConnectionState.done) {
              return const Scaffold(body: SafeArea(child: Center(child: CircularProgressIndicator())));
            }

            final featured = (dataSnap.data?[0] ?? const <Work>[]);
            final recent = (dataSnap.data?[1] ?? const <Work>[]);

            return Scaffold(
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Dar El Fikr',
                                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                                  SizedBox(height: 6),
                                  Text('Premium Islamic e-Library', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            _CircleIconButton(icon: Icons.person_outline_rounded, onTap: () {}),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _SearchBar(
                          hintText: 'Search works, authors…',
                          onTap: () {
                            // Search logic intentionally postponed.
                          Navigator.push(
                          context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                        ); 
                         },
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _SectionTitle(title: 'Featured'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 260,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                          scrollDirection: Axis.horizontal,
                          itemCount: featured.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final w = featured[i];
                            return _FeaturedWorkCard(
                              work: w,
                              isSubscribed: isSubscribed,
                              tier: tier,
                              onTap: () async {
                                // WORK TAP access check
                                if (isSubscribed && !_hasAccess(w.tags, tier)) {
                                  await _showUpgradeDialog(context, tier, w.tags);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VolumesScreen(
                                      repo: repo,
                                      work: w,
                                      isSubscribed: isSubscribed,
                                      tier: tier,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _SectionTitle(title: 'Categories'),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _CategoryCard(
                            data: categories[i],
                            onTap: () {
                              if (categories[i].tag == 'fiqh') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const FiqhHubScreen()),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CategoryBooksScreen(
                                      title: categories[i].title,
                                      filterTag: categories[i].tag,
                                      mode: CategoryBooksMode.category,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          childCount: categories.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.55,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _SectionTitle(title: 'Recently added'),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final w = recent[i];
                          return Padding(
                            padding: EdgeInsets.fromLTRB(20, i == 0 ? 12 : 8, 20, i == recent.length - 1 ? 20 : 8),
                            child: _RecentRow(
                              work: w,
                              onTap: () async {
                                // WORK TAP access check
                                if (isSubscribed && !_hasAccess(w.tags, tier)) {
                                  await _showUpgradeDialog(context, tier, w.tags);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VolumesScreen(
                                      repo: repo,
                                      work: w,
                                      isSubscribed: isSubscribed,
                                      tier: tier,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: recent.length,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))]);
  }
}

class _SearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback onTap;

  const _SearchBar({required this.hintText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x14000000))],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded),
            const SizedBox(width: 10),
            Expanded(child: Text(hintText, style: const TextStyle(fontSize: 14))),
            const Icon(Icons.tune_rounded),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x14000000))],
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _FeaturedWorkCard extends StatelessWidget {
  final Work work;
  final bool isSubscribed;
  final String? tier;
  final VoidCallback onTap;

  const _FeaturedWorkCard({
    required this.work,
    required this.isSubscribed,
    required this.tier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF1F2FF)],
          ),
          boxShadow: const [BoxShadow(blurRadius: 22, offset: Offset(0, 10), color: Color(0x14000000))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Badge(text: 'Featured'),
            const Spacer(),
            Text(work.titleEn, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(work.authorEn, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF6D5DF6), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData data;
  final VoidCallback onTap;

  const _CategoryCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x14000000))],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: const Color(0xFFF1F2FF), borderRadius: BorderRadius.circular(14)),
              child: Icon(data.icon),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(data.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
          ],
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  final Work work;
  final VoidCallback onTap;

  const _RecentRow({required this.work, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x14000000))],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 60,
              decoration: BoxDecoration(color: const Color(0xFFF1F2FF), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.book_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(work.titleEn, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(work.authorEn, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  final String title;
  final IconData icon;
  final String tag;
  const _CategoryData(this.title, this.icon, this.tag);
}
