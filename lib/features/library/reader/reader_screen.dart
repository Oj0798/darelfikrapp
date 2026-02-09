import '../screens/subscription_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../app/router.dart';



class ReaderScreen extends StatefulWidget {
  /// Reader must be opened ONLY from a Volume tap.
  final String workId;
  final String workTitleEn;
  final int volumeNumber;

  /// Access control tags (kept as-is; subscription logic untouched in this phase).
  final List<String> requiredTags;

  /// Preview pages for display-only phase.
  final int freePages;

  const ReaderScreen({
    super.key,
    required this.workId,
    required this.workTitleEn,
    required this.volumeNumber,
    this.freePages = 5,
    required this.requiredTags,
  });


  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int currentPage = 1;
  bool showControls = true;
  bool isSubscribed = false;
  static const _kIsSubscribedKey = 'df_is_subscribed';
static const _kTierKey = 'df_subscription_tier';

String? subscriptionTier;

bool get _isEntitled => isSubscribed && _hasAccessToBook();

void _clampCurrentPageIfNeeded() {
  if (!_isEntitled && currentPage > widget.freePages) {
    currentPage = widget.freePages;
  }
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

bool _hasAccessToBook() {
  // No tags required = free
  if (widget.requiredTags.isEmpty) return true;

  final granted = _grantedTagsForTier(subscriptionTier);

  // Access if any required tag is granted (your books are category-tagged)
  for (final t in widget.requiredTags) {
    if (granted.contains(t)) return true;
  }
  return false;
}

Future<void> _loadSubscription() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getBool(_kIsSubscribedKey) ?? false;
  final tier = prefs.getString(_kTierKey);

  if (!mounted) return;
  setState(() {
    isSubscribed = saved;
    subscriptionTier = tier;
    _clampCurrentPageIfNeeded();
  });
}

Future<void> _saveSubscription({required bool subscribed, String? tier}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kIsSubscribedKey, subscribed);

  if (tier != null) {
    await prefs.setString(_kTierKey, tier);
  }
}

@override
void initState() {
  super.initState();
  _loadSubscription();
}


  @override
  Widget build(BuildContext context) {
   final bool previewEnded = currentPage >= widget.freePages;
final bool hasAccess = _isEntitled;
final bool isLocked = previewEnded && !hasAccess;



    return Scaffold(
  appBar: showControls
      ? AppBar(title: Text('${widget.workTitleEn} · Volume ${widget.volumeNumber}'))
      : null,

     body: Padding(
  padding: const EdgeInsets.all(24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
  if (!isLocked) ...[
  Text(
    'Page $currentPage',
    style: Theme.of(context).textTheme.titleLarge,
  ),
  Padding(
    padding: const EdgeInsets.only(top: 4),
    child:Text(
  isSubscribed
      ? 'Subscribed · ${_prettyTier(subscriptionTier)}'
      : 'Free preview · ${widget.freePages} pages',
  style: Theme.of(context)
      .textTheme
      .bodySmall
      ?.copyWith(color: Colors.grey),
),

  ),
]  else ...[
  Text(
    isSubscribed ? 'Upgrade required' : 'Preview ended',
    style: Theme.of(context).textTheme.titleLarge,
  ),
  Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      isSubscribed
          ? 'Your plan (${_prettyTier(subscriptionTier)}) does not include this book.'
          : 'You reached page ${widget.freePages}. Subscribe to continue.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
    ),
  ),
],




    Expanded(
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => setState(() => showControls = !showControls),
    child: Stack(
      children: [
        // Always render content, even when locked
  _PageContent(
  page: isLocked
      ? widget.freePages
      : currentPage,
),


        // If locked, blur + overlay the lock UI
        if (isLocked) ...[
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Center(
  child: _LockedView(
    isSubscribed: isSubscribed,
    onViewSubscriptions: () async {
      await Navigator.pushNamed(
        context,
        AppRoutes.subscription,
      );
      await _loadSubscription();
      if (!mounted) return;

      if (!_isEntitled) {
        setState(() {
          _clampCurrentPageIfNeeded();
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unlocked with: ${_prettyTier(subscriptionTier)}')),
      );
    },
  ),
),

        ],
      ],
    ),
  ),
),


      const SizedBox(height: 16),

      if (showControls)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: currentPage > 1
                  ? () => setState(() => currentPage--)
                  : null,
              child: const Text('Previous'),
            ),
            ElevatedButton(
              onPressed: (!hasAccess && currentPage >= widget.freePages)
                  ? null
                  : () => setState(() {
                        final nextPage = currentPage + 1;
                        if (!hasAccess && nextPage > widget.freePages) {
                          currentPage = widget.freePages;
                          return;
                        }
                        currentPage = nextPage;
                      }),
              child: const Text('Next'),
            ),
          ],
        ),
    ],
  ),
),

    );
  }
}

class _PageContent extends StatelessWidget {
  final int page;

  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Text(
      'This is the content of page $page.\n\n'
      'Replace this later with real book text.',
      style: const TextStyle(fontSize: 16, height: 1.6),
    );
  }
}

 class _LockedView extends StatelessWidget {
  final Future<void> Function() onViewSubscriptions;
  final bool isSubscribed;

  const _LockedView({
    required this.onViewSubscriptions,
    required this.isSubscribed,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock, size: 48),
        const SizedBox(height: 16),
      Text(
  isSubscribed ? 'Upgrade required' : 'Free preview ended',
  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),
Text(
  isSubscribed ? 'Upgrade your plan to unlock this book.' : 'Subscribe to continue reading',
  textAlign: TextAlign.center,
),

        ElevatedButton(
          onPressed: () => onViewSubscriptions(),
          child: const Text('View subscriptions'),
        ),
      ],
    );
  }
}

