import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Phase 1 (per your project spec):
/// - NO real checkout yet (we’ll wire Google Play Billing later)
/// - User selects a tier (we’ll save it next step)
/// - "Restore purchase" exists (UI for now)
///
/// Tiers:
/// $1 = Ahadith Only
/// $2 = Ahadith + Tafasir
/// $3 = Complete Library

enum SubscriptionTier { tier1, tier2, tier3 }

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionTier _selected = SubscriptionTier.tier2; // recommended default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0F),
        elevation: 0,
        centerTitle: true,
        title: const Text("Subscriptions"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text(
                "Unlock the Library",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "No ads • Cancel anytime • Activates via the Store",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: ListView(
                  children: [
                    _TierCard(
                      title: "\$1 / month",
                      subtitle: "Ahadith Only",
                      badgeText: null,
                      isSelected: _selected == SubscriptionTier.tier1,
                      bullets: const [
                        "Access to Hadith collections",
                        "Unlimited reading",
                        "Bookmarks & highlights",
                      ],
                      onTap: () => setState(() => _selected = SubscriptionTier.tier1),
                    ),
                    const SizedBox(height: 12),
                    _TierCard(
                      title: "\$2 / month",
                      subtitle: "Ahadith + Tafasir",
                      badgeText: "Recommended",
                      isSelected: _selected == SubscriptionTier.tier2,
                      bullets: const [
                        "Everything in \$1",
                        "Tafsir collections included",
                        "Offline reading (Phase 2)",
                      ],
                      onTap: () => setState(() => _selected = SubscriptionTier.tier2),
                    ),
                    const SizedBox(height: 12),
                    _TierCard(
                      title: "\$3 / month",
                      subtitle: "Complete Library",
                      badgeText: "Best Access",
                      isSelected: _selected == SubscriptionTier.tier3,
                      bullets: const [
                        "Everything in \$2",
                        "All Dar El Fikr books",
                        "Premium collections (Phase 2)",
                      ],
                      onTap: () => setState(() => _selected = SubscriptionTier.tier3),
                    ),
                    const SizedBox(height: 18),

                    _TrustStrip(),
                    const SizedBox(height: 18),
                  ],
                ),
              ),

              // Bottom actions
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                  onPressed: () async {
  final prefs = await SharedPreferences.getInstance();

  // Always overwrite the tier (upgrade-safe)
  await prefs.setString(
    'df_subscription_tier',
    _selected.name, // tier1 / tier2 / tier3
  );

  Navigator.pop(context, _selected);
},

                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.25)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        // Phase 1: UI only. We’ll implement restore with billing later.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Restore will be added in Phase 2.")),
                        );
                      },
                      child: const Text(
                        "Restore Purchase",
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Back to Library",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeText;
  final bool isSelected;
  final List<String> bullets;
  final VoidCallback onTap;

  const _TierCard({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.isSelected,
    required this.bullets,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? Colors.white : Colors.white.withOpacity(0.15);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: Colors.white.withOpacity(0.9)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        b,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget pill(IconData icon, String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white.withOpacity(0.85)),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        pill(Icons.verified_rounded, "Trusted Publisher"),
        pill(Icons.lock_rounded, "Secure via Store"),
        pill(Icons.block_rounded, "No Ads"),
      ],
    );
  }
}
