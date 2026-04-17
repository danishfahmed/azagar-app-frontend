import 'dart:async';

import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/models/product_model.dart';
import 'package:azager/core/network/api_exception.dart';
import 'package:azager/core/services/product_service.dart';
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
  final _searchService = SearchService();

  Timer? _debounce;
  String _query = '';
  bool _isLoadingResults = false;
  bool _isLoadingRecent = true;
  String? _error;

  List<ProductModel> _results = const [];
  List<String> _suggestions = const [];
  List<RecentSearchItem> _recentSearches = const [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();

    if (widget.initialQuery.trim().isNotEmpty) {
      _controller.text = widget.initialQuery.trim();
      _query = widget.initialQuery.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      });
      _performSearch(_query, withLoader: true);
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNode.requestFocus(),
      );
    }

    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller
      ..removeListener(_onQueryChanged)
      ..dispose();
    _focusNode.dispose();
    _searchService.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    setState(() {
      _isLoadingRecent = true;
    });

    try {
      final recent = await _searchService.getRecentSearches();
      if (!mounted) return;
      setState(() {
        _recentSearches = recent;
        _isLoadingRecent = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingRecent = false;
      });
    }
  }

  void _onQueryChanged() {
    final next = _controller.text.trim();
    setState(() {
      _query = next;
      _error = null;
    });

    _debounce?.cancel();

    if (next.isEmpty) {
      setState(() {
        _results = const [];
        _suggestions = const [];
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _loadSuggestions(next);
      _performSearch(next, withLoader: false);
    });
  }

  Future<void> _loadSuggestions(String query) async {
    try {
      final items = await _searchService.getSearchSuggestions(query: query);
      if (!mounted || _query != query) return;
      setState(() {
        _suggestions = items.take(8).toList();
      });
    } catch (_) {
      // Suggestions are non-blocking.
    }
  }

  Future<void> _performSearch(String query, {required bool withLoader}) async {
    if (query.trim().isEmpty) return;

    if (withLoader) {
      setState(() {
        _isLoadingResults = true;
      });
    }

    try {
      final items = await _searchService.searchProducts(query: query);
      if (!mounted || _query != query.trim()) return;
      setState(() {
        _results = items;
        _isLoadingResults = false;
      });
    } on ApiException catch (e) {
      if (!mounted || _query != query.trim()) return;
      setState(() {
        _results = const [];
        _error = e.message;
        _isLoadingResults = false;
      });
    } catch (_) {
      if (!mounted || _query != query.trim()) return;
      setState(() {
        _results = const [];
        _error = 'Unable to search products right now.';
        _isLoadingResults = false;
      });
    }
  }

  void _submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _performSearch(trimmed, withLoader: true);
    _focusNode.unfocus();
  }

  Future<void> _removeRecent(RecentSearchItem item) async {
    setState(() {
      _recentSearches = _recentSearches.where((x) => x.id != item.id).toList();
    });

    if (item.id <= 0) return;

    try {
      await _searchService.deleteRecentSearch(item.id);
    } catch (_) {
      // Keep optimistic UI state.
    }
  }

  Future<void> _clearRecent() async {
    final old = _recentSearches;
    setState(() => _recentSearches = const []);

    try {
      await _searchService.clearRecentSearches();
    } catch (_) {
      if (!mounted) return;
      setState(() => _recentSearches = old);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                                hintText: 'Search products',
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_query.isNotEmpty) {
      if (_isLoadingResults && _results.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (_results.isNotEmpty) {
        return _SearchResults(query: _query, results: _results);
      }

      if (_suggestions.isNotEmpty) {
        return _SuggestionsList(
          suggestions: _suggestions,
          onTap: (value) {
            _controller.text = value;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: value.length),
            );
            _submitSearch(value);
          },
        );
      }

      if (_error != null) {
        return _InlineError(message: _error!);
      }

      return _NoResults(query: _query);
    }

    if (_isLoadingRecent) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return _RecentSearches(
      searches: _recentSearches,
      onTap: (item) {
        _controller.text = item.query;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: item.query.length),
        );
        _submitSearch(item.query);
      },
      onRemove: _removeRecent,
      onClearAll: _recentSearches.isEmpty ? null : _clearRecent,
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<RecentSearchItem> searches;
  final ValueChanged<RecentSearchItem> onTap;
  final ValueChanged<RecentSearchItem> onRemove;
  final VoidCallback? onClearAll;

  const _RecentSearches({
    required this.searches,
    required this.onTap,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (searches.isEmpty) {
      return Center(
        child: Text(
          'No recent searches yet',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(onPressed: onClearAll, child: const Text('Clear All')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
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
                  item.query,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
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
          ),
        ),
      ],
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const _SuggestionsList({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: suggestions.length,
      itemBuilder: (_, i) {
        final item = suggestions[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.north_west,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(
            item,
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
          ),
          onTap: () => onTap(item),
        );
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  final List<ProductModel> results;

  const _SearchResults({required this.query, required this.results});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
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
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => ProductCard(product: results[i]),
              childCount: results.length,
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

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

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
          const Text(
            'Try another keyword or category name.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
