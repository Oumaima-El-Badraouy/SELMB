import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/moroccan_trades.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/post_model.dart';
import '../providers/app_providers.dart';
import '../widgets/client_feed_post_card.dart';
import '../widgets/moroccan_internal_dashboard.dart';

final _clientFeedProvider = FutureProvider.autoDispose.family<List<PostModel>, String>((ref, key) async {
  ref.watch(feedSocketTickProvider);
  final parts = key.split('|');
  final cat = parts.isEmpty || parts[0].isEmpty ? null : parts[0];
  final sort = parts.length > 1 ? parts[1] : '';
  final q = parts.length > 2 ? parts[2] : '';
  final repo = ref.watch(marketplaceRepositoryProvider);
  return repo.postsFeed(
    category: cat,
    postType: 'artisan_service',
    sort: sort == 'popular' ? 'popular' : null,
    q: q.isEmpty ? null : q,
  );
});

class ClientFeedScreen extends ConsumerStatefulWidget {
  const ClientFeedScreen({super.key});

  @override
  ConsumerState<ClientFeedScreen> createState() => _ClientFeedScreenState();
}

class _ClientFeedScreenState extends ConsumerState<ClientFeedScreen> {
  String catKey = '';
  String sortMode = 'recent';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  static List<String> get _cats => ['', ...moroccanTradeIds];

  String get _providerKey => '$catKey|$sortMode|$_searchQuery';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _searchQuery = v.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_clientFeedProvider(_providerKey));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_clientFeedProvider(_providerKey));
          await ref.read(_clientFeedProvider(_providerKey).future);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: AppColors.shellAppBarSurface,
              surfaceTintColor: Colors.transparent,
              elevation: 2,
              shadowColor: AppColors.deepBlue.withValues(alpha: 0.06),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.5),
                child: Container(height: 1.5, color: AppColors.gold.withValues(alpha: 0.85)),
              ),
              title: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                style: GoogleFonts.cairo(fontSize: 14),
                decoration: InputDecoration(
                  hintText: S.searchHint,
                  hintStyle: GoogleFonts.cairo(color: AppColors.muted, fontSize: 14),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.deepBlue.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.9), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.deepBlue, size: 22),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: sortMode,
                      icon: Icon(Icons.sort_rounded, size: 24, color: AppColors.deepBlue.withValues(alpha: 0.9)),
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: AppColors.deepBlue, fontSize: 12),
                      items: [
                        DropdownMenuItem(value: 'recent', child: Text(S.sortRecent, style: GoogleFonts.cairo())),
                        DropdownMenuItem(value: 'popular', child: Text(S.sortPopular, style: GoogleFonts.cairo())),
                      ],
                      onChanged: (v) => setState(() => sortMode = v ?? 'recent'),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: MoroccanFeedWelcomeStrip(line: S.clientFeedHeroLine),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepBlue.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 46,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      children: [
                        for (final c in _cats)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilterChip(
                              label: Text(S.categoryLabel(c), style: const TextStyle(fontSize: 13)),
                              selected: catKey == c,
                              onSelected: (_) => setState(() => catKey = c),
                              selectedColor: AppColors.terracotta.withValues(alpha: 0.2),
                              checkmarkColor: AppColors.deepBlue,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            async.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(S.noPosts)),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _PostRow(post: posts[i], feedKey: _providerKey),
                      childCount: posts.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('$e', style: const TextStyle(color: AppColors.muted))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostRow extends ConsumerWidget {
  const _PostRow({required this.post, required this.feedKey});

  final PostModel post;
  final String feedKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fol = ref.watch(artisanFollowStatusProvider(post.userId));
    return fol.when(
      data: (isF) => ClientFeedPostCard(
        post: post,
        isFollowing: isF,
        onFollowToggle: () async {
          final repo = ref.read(marketplaceRepositoryProvider);
          if (isF) {
            await repo.unfollowArtisan(post.userId);
          } else {
            await repo.followArtisan(post.userId);
          }
          ref.invalidate(artisanFollowStatusProvider(post.userId));
        },
        onEngagementChanged: () => ref.invalidate(_clientFeedProvider(feedKey)),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => ClientFeedPostCard(
        post: post,
        isFollowing: false,
        onFollowToggle: () {},
        onEngagementChanged: () => ref.invalidate(_clientFeedProvider(feedKey)),
      ),
    );
  }
}
