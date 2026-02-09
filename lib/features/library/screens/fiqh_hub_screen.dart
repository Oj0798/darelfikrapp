import 'package:flutter/material.dart';

import 'category_books_screen.dart';

/// Fiqh special-case hub: exactly 4 schools.
/// Flow: Fiqh → Hub → School → Works → Volumes → Reader
class FiqhHubScreen extends StatelessWidget {
  const FiqhHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _Item('Hanafi', 'fiqh_hanafi'),
      _Item('Maliki', 'fiqh_maliki'),
      _Item('Shafi\u2018i', 'fiqh_shafii'),
      _Item('Hanbali', 'fiqh_hanbali'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Fiqh')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final it = items[i];
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryBooksScreen(
                    title: it.title,
                    filterTag: it.tag,
                    mode: CategoryBooksMode.fiqhSchool,
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
                    child: const Icon(Icons.balance_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(it.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Item {
  final String title;
  final String tag;
  const _Item(this.title, this.tag);
}
