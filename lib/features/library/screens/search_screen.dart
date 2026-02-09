import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/library_repository.dart';
import '../data/local_library_repository.dart';
import '../domain/book.dart';
import 'category_books_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final LibraryRepository repo = const LocalLibraryRepository();
  final TextEditingController _controller = TextEditingController();

  static const _kIsSubscribedKey = 'df_is_subscribed';
  static const _kTierKey = 'df_subscription_tier';

  bool _isSubscribed = false;
  String? _tier;

  Timer? _debounce;
  List<Work> _results = const [];
  bool _loading = false;

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

  void _onChanged(String value) {
     setState(() {}); 
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final q = value.trim();
      if (q.isEmpty) {
        if (!mounted) return;
        setState(() => _results = const []);
        return;
      }

      if (!mounted) return;
      setState(() => _loading = true);

      final res = await repo.searchWorks(q);
      if (!mounted) return;

      setState(() {
        _results = res;
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child:TextField(
               controller: _controller,
               autofocus: true,
              onChanged: _onChanged,
              decoration: InputDecoration(
              hintText: 'Search by title or author',
               prefixIcon: const Icon(Icons.search),
               border: const OutlineInputBorder(),
              suffixIcon: _controller.text.trim().isEmpty
             ? null
        : IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _controller.clear();
              setState(() => _results = const []);
              FocusScope.of(context).unfocus();
            },
          ),
  ),
),

          ),
          if (_loading) const LinearProgressIndicator(),
         Expanded(
  child: () {
    final q = _controller.text.trim();

    if (_results.isEmpty) {
      return Center(
        child: Text(
          q.isEmpty ? 'Start typing to search' : 'No results for "$q"',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final w = _results[i];
        return ListTile(
          title: Text(w.titleEn),
          subtitle: Text(w.authorEn),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            await _loadSubscription();
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VolumesScreen(
                  repo: repo,
                  work: w,
                  isSubscribed: _isSubscribed,
                  tier: _tier,
                ),
              ),
            );
          },
        );
      },
    );
  }(),
),

        ],
      ),
    );
  }
}
