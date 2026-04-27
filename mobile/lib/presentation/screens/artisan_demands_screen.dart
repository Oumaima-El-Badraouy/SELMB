import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/moroccan_trades.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/post_model.dart';
import '../providers/app_providers.dart';
import '../widgets/moroccan_internal_dashboard.dart';
import '../widgets/post_card.dart';

final _demandsFeedProvider = FutureProvider.autoDispose.family<List<PostModel>, String>((ref, catKey) async {
  ref.watch(feedSocketTickProvider);
  return ref.watch(marketplaceRepositoryProvider).postsFeed(
        postType: 'client_request',
        category: catKey.isEmpty ? null : catKey,
      );
});

class ArtisanDemandsScreen extends ConsumerStatefulWidget {
  const ArtisanDemandsScreen({super.key});

  @override
  ConsumerState<ArtisanDemandsScreen> createState() => _ArtisanDemandsScreenState();
}

class _ArtisanDemandsScreenState extends ConsumerState<ArtisanDemandsScreen> {
  String catKey = '';

  static List<String> get _cats => ['', ...moroccanTradeIds];

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_demandsFeedProvider(catKey));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_demandsFeedProvider(catKey));
            await ref.read(_demandsFeedProvider(catKey).future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              MoroccanDashboardHeroSliver(
                title: S.clientDemandsScreenTitle,
                subtitle: S.artisanDemandsHeroSubtitle,
                icon: Icons.handshake_rounded,
              ),
              SliverToBoxAdapter(
                child: MoroccanChipsPanel(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    children: [
                      for (final c in _cats)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: FilterChip(
                            label: Text(S.categoryLabel(c), style: const TextStyle(fontSize: 13)),
                            selected: catKey == c,
                            onSelected: (_) => setState(() => catKey = c),
                            selectedColor: AppColors.terracotta.withValues(alpha: 0.22),
                            checkmarkColor: AppColors.deepBlue,
                            side: BorderSide(color: AppColors.deepBlue.withValues(alpha: 0.15)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ...async.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: MoroccanEmptyState(
                          title: S.noDemandsYet,
                          icon: Icons.inbox_outlined,
                        ),
                      ),
                    ];
                  }
                  return [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(10, 4, 10, 28),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => PostCard(
                            post: posts[i],
                            showChat: true,
                            showFollow: false,
                            onEngagementChanged: () => ref.invalidate(_demandsFeedProvider(catKey)),
                          ),
                          childCount: posts.length,
                        ),
                      ),
                    ),
                  ];
                },
                loading: () => [
                  const SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(color: AppColors.deepBlue),
                      ),
                    ),
                  ),
                ],
                error: (e, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          '$e',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
