import 'package:flutter/material.dart';
import '../domain/book.dart';

/// WORKS list only (never volumes).
class BooksList extends StatelessWidget {
  final List<Work> works;
  final void Function(Work work) onTapWork;

  const BooksList({
    super.key,
    required this.works,
    required this.onTapWork,
  });

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return const Center(child: Text('No works'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: works.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final w = works[i];
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onTapWork(w),
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
                  width: 46,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.titleEn, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(w.authorEn, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        );
      },
    );
  }
}
