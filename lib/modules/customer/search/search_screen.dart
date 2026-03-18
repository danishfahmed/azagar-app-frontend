import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/constants/dummy_data.dart';
import 'package:azager/core/models/product_model.dart';
import 'package:azager/modules/shared/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;
  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _recentSearches = List<String>.from(DummyData.recentSearches);
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery.isNotEmpty) {
      _controller.text = widget.initialQuery;
      _query = widget.initialQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNode.requestFocus(),
      );
    }
    _controller.addListener(() {
      setState(() => _query = _controller.text.trim());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<ProductModel> get _results {
    if (_query.isEmpty) return [];
    return DummyData.products
        .where(
          (p) =>
              p.name.toLowerCase().contains(_query.toLowerCase()) ||
              p.category.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
  }

  void _submitSearch(String q) {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _recentSearches.remove(trimmed);
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
  }

  void _removeRecent(String item) {
    setState(() => _recentSearches.remove(item));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isSearching = _query.isNotEmpty;
    final bool hasResults = _results.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Bar ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(
                            Icons.search,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              textInputAction: TextInputAction.search,
                              onSubmitted: _submitSearch,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Explore Fashion',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () => _controller.clear(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────
            Expanded(
              child: isSearching
                  ? (hasResults
                        ? _SearchResults(query: _query, results: _results)
                        : _NoResults(query: _query))
                  : _RecentSearches(
                      searches: _recentSearches,
                      onTap: (s) {
                        _controller.text = s;
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: s.length),
                        );
                      },
                      onRemove: _removeRecent,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recent Searches ────────────────────────────────────────────────────────

class _RecentSearches extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;

  const _RecentSearches({
    required this.searches,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: searches.length,
      itemBuilder: (_, i) {
        final item = searches[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.history,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          title: Text(
            item,
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
          ),
          trailing: GestureDetector(
            onTap: () => onRemove(item),
            child: Icon(
              Icons.close,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          onTap: () => onTap(item),
        );
      },
    );
  }
}

// ── Search Results ─────────────────────────────────────────────────────────

class _SearchResults extends StatelessWidget {
  final String query;
  final List<ProductModel> results;

  const _SearchResults({required this.query, required this.results});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Results for "$query"',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${results.length} items found',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Product grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => ProductCard(product: results[i]),
              childCount: results.length > 2 ? 2 : results.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
          ),
        ),

        // Mega Sale inline banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SHOP NOW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'MEGA SALE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'UP TO 70% OFF',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Remaining products
        if (results.length > 2)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => ProductCard(product: results[i + 2]),
                childCount: results.length - 2,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ── No Results ─────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  /// Very simple "did you mean" suggestion
  String get _suggestion {
    final words = query.split(' ');
    return words
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No result for "$query"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: 'Did you mean ',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: '"$_suggestion"',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
