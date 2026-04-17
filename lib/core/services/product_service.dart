import 'dart:convert';

import 'package:azager/core/models/product_model.dart';
import 'package:azager/core/network/api_client.dart';
import 'package:azager/core/network/api_config.dart';
import 'package:azager/core/network/api_exception.dart';
import 'package:azager/core/services/session_manager.dart';

class ProductFilterOption {
  final int id;
  final String name;

  const ProductFilterOption({required this.id, required this.name});

  factory ProductFilterOption.fromJson(Map<String, dynamic> json) {
    return ProductFilterOption(
      id: _toInt(json['id']),
      name: (json['name'] ?? json['label'] ?? '').toString(),
    );
  }
}

class ProductFilters {
  final List<ProductFilterOption> sizes;
  final List<ProductFilterOption> colors;
  final List<ProductFilterOption> brands;
  final double minPrice;
  final double maxPrice;

  const ProductFilters({
    this.sizes = const [],
    this.colors = const [],
    this.brands = const [],
    this.minPrice = 0,
    this.maxPrice = 0,
  });

  factory ProductFilters.fromJson(Map<String, dynamic> json) {
    return ProductFilters(
      sizes: _parseOptions(json['sizes']),
      colors: _parseOptions(json['colors']),
      brands: _parseOptions(json['brands']),
      minPrice: _toDouble(json['min_price']),
      maxPrice: _toDouble(json['max_price']),
    );
  }

  static List<ProductFilterOption> _parseOptions(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map(ProductFilterOption.fromJson)
          .toList();
    }
    return const [];
  }
}

class ProductListResponse {
  final List<ProductModel> products;
  final ProductFilters filters;
  final int currentPage;
  final int lastPage;
  final int total;

  const ProductListResponse({
    required this.products,
    this.filters = const ProductFilters(),
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });
}

class ProductQuery {
  final int page;
  final int perPage;
  final String? search;
  final int? categoryId;
  final int? subCategoryId;
  final int? shopId;
  final int? sizeId;
  final int? colorId;
  final int? brandId;
  final double? minPrice;
  final double? maxPrice;
  final int? rating;
  final String? sortType;

  const ProductQuery({
    this.page = 1,
    this.perPage = 15,
    this.search,
    this.categoryId,
    this.subCategoryId,
    this.shopId,
    this.sizeId,
    this.colorId,
    this.brandId,
    this.minPrice,
    this.maxPrice,
    this.rating,
    this.sortType,
  });

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    void addIfNotNull(String key, dynamic value) {
      if (value == null) return;
      final parsed = value.toString().trim();
      if (parsed.isNotEmpty) {
        params[key] = parsed;
      }
    }

    addIfNotNull('search', search);
    addIfNotNull('category_id', categoryId);
    addIfNotNull('sub_category_id', subCategoryId);
    addIfNotNull('shop_id', shopId);
    addIfNotNull('size_id', sizeId);
    addIfNotNull('color_id', colorId);
    addIfNotNull('brand_id', brandId);
    addIfNotNull('min_price', minPrice?.toStringAsFixed(0));
    addIfNotNull('max_price', maxPrice?.toStringAsFixed(0));
    addIfNotNull('rating', rating);
    addIfNotNull('sort_type', sortType);

    return params;
  }
}

class RecentSearchItem {
  final int id;
  final String query;

  const RecentSearchItem({required this.id, required this.query});

  factory RecentSearchItem.fromJson(Map<String, dynamic> json) {
    return RecentSearchItem(
      id: _toInt(json['id']),
      query: (json['query'] ?? json['keyword'] ?? json['search'] ?? '')
          .toString(),
    );
  }
}

class ProductDetailsResponse {
  final ProductModel product;
  final List<ProductModel> relatedProducts;

  const ProductDetailsResponse({
    required this.product,
    this.relatedProducts = const [],
  });
}

class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<ProductListResponse> getProducts({
    ProductQuery query = const ProductQuery(),
  }) async {
    final endpoint = _buildEndpoint(
      ApiConfig.products,
      query.toQueryParameters(),
    );
    final response = await _apiClient.get(endpoint);
    return _parseProductListResponse(response);
  }

  Future<ProductListResponse> getCategoryProducts({
    required int categoryId,
    int page = 1,
    int perPage = 15,
  }) async {
    final endpoint = _buildEndpoint(ApiConfig.categoryProducts, {
      'page': '$page',
      'per_page': '$perPage',
      'category_id': '$categoryId',
    });
    final response = await _apiClient.get(endpoint);
    return _parseProductListResponse(response);
  }

  Future<ProductDetailsResponse> getProductDetails({
    required String productId,
  }) async {
    final endpoint = _buildEndpoint(ApiConfig.productDetails, {
      'product_id': productId,
    });
    final response = await _apiClient.get(endpoint);

    final data = _asMap(response['data']) ?? response;

    final productMap =
        _asMap(data['product']) ??
        _asMap(data['product_details']) ??
        _asMap(data['item']) ??
        data;

    final product = ProductModel.fromApi(productMap);

    final relatedRaw = _asList(
      data['related_products'] ??
          data['you_may_like'] ??
          data['similar_products'],
    );

    final relatedProducts = relatedRaw
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromApi)
        .toList();

    return ProductDetailsResponse(
      product: product,
      relatedProducts: relatedProducts,
    );
  }

  Future<void> submitProductReview({
    required String productId,
    required int orderId,
    required int rating,
    required String comment,
  }) async {
    final token = SessionManager.token;
    if (token == null || token.isEmpty) {
      throw ApiException(message: 'Please login to submit a review.');
    }

    await _apiClient.post(
      ApiConfig.productReview,
      headers: ApiConfig.authHeaders(token),
      body: {
        'product_id': _toInt(productId),
        'order_id': orderId,
        'rating': rating,
        'comment': comment,
      },
    );
  }

  ProductListResponse _parseProductListResponse(Map<String, dynamic> response) {
    final data = _asMap(response['data']);

    final productList = _asList(
      data?['products'] ??
          data?['items'] ??
          data?['data'] ??
          response['data'] ??
          response['products'],
    );

    final products = productList
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromApi)
        .toList();

    final filtersJson = _asMap(data?['filters']) ?? _asMap(response['filters']);
    final filters = filtersJson != null
        ? ProductFilters.fromJson(filtersJson)
        : const ProductFilters();

    return ProductListResponse(
      products: products,
      filters: filters,
      currentPage:
          _toInt(data?['current_page'] ?? response['current_page']) == 0
          ? 1
          : _toInt(data?['current_page'] ?? response['current_page']),
      lastPage: _toInt(data?['last_page'] ?? response['last_page']) == 0
          ? 1
          : _toInt(data?['last_page'] ?? response['last_page']),
      total: _toInt(data?['total'] ?? response['total']),
    );
  }

  String _buildEndpoint(String path, Map<String, String> query) {
    final uri = Uri(path: path, queryParameters: query);
    final encoded = uri.toString();
    return encoded.startsWith('/') ? encoded : '/$encoded';
  }

  void dispose() {
    _apiClient.dispose();
  }
}

class WishlistService {
  final ApiClient _apiClient;

  WishlistService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<ProductModel>> getWishlist() async {
    final token = SessionManager.token;
    if (token == null || token.isEmpty) {
      throw ApiException(message: 'Please login to view wishlist.');
    }

    final response = await _apiClient.get(
      ApiConfig.wishlist,
      headers: ApiConfig.authHeaders(token),
    );

    final data = _asMap(response['data']) ?? response;

    final list = _asList(
      data['products'] ??
          data['favorites'] ??
          data['favorite_products'] ??
          response['data'],
    );

    return list
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromApi)
        .toList();
  }

  Future<bool> toggleFavorite({
    required String productId,
    required bool currentFavoriteState,
  }) async {
    final token = SessionManager.token;
    if (token == null || token.isEmpty) {
      throw ApiException(message: 'Please login to manage wishlist.');
    }

    final response = await _apiClient.post(
      ApiConfig.toggleFavorite,
      headers: ApiConfig.authHeaders(token),
      body: {'product_id': _toInt(productId)},
    );

    final data = _asMap(response['data']);
    if (data != null) {
      if (data.containsKey('is_favorite')) {
        return _toBool(data['is_favorite']);
      }
      if (data.containsKey('in_wishlist')) {
        return _toBool(data['in_wishlist']);
      }
      if (data.containsKey('favorite')) {
        return _toBool(data['favorite']);
      }
      final action = (data['action'] ?? '').toString().toLowerCase();
      if (action.contains('add')) return true;
      if (action.contains('remove')) return false;
    }

    final message = (response['message'] ?? '').toString().toLowerCase();
    if (message.contains('added')) return true;
    if (message.contains('removed')) return false;

    return !currentFavoriteState;
  }

  void dispose() {
    _apiClient.dispose();
  }
}

class SearchService {
  final ApiClient _apiClient;

  SearchService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<ProductModel>> searchProducts({
    required String query,
    int page = 1,
    int perPage = 15,
  }) async {
    final endpoint = Uri(
      path: ApiConfig.search,
      queryParameters: {
        'query': query,
        'page': '$page',
        'per_page': '$perPage',
      },
    ).toString();

    final token = SessionManager.token;
    final response = await _apiClient.get(
      endpoint.startsWith('/') ? endpoint : '/$endpoint',
      headers: (token != null && token.isNotEmpty)
          ? ApiConfig.authHeaders(token)
          : null,
    );
    final data = _asMap(response['data']) ?? response;
    final list = _asList(
      data['products'] ?? data['items'] ?? data['results'] ?? response['data'],
    );

    return list
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromApi)
        .toList();
  }

  Future<List<String>> getSearchSuggestions({required String query}) async {
    final endpoint = Uri(
      path: ApiConfig.searchSuggestions,
      queryParameters: {'query': query},
    ).toString();

    final token = SessionManager.token;
    final response = await _apiClient.get(
      endpoint.startsWith('/') ? endpoint : '/$endpoint',
      headers: (token != null && token.isNotEmpty)
          ? ApiConfig.authHeaders(token)
          : null,
    );

    final suggestionsRaw = _asList(
      response['data'] ?? response['suggestions'] ?? response['results'],
    );

    return suggestionsRaw
        .map((item) {
          if (item is String) return item;
          if (item is Map<String, dynamic>) {
            return (item['query'] ?? item['name'] ?? item['suggestion'] ?? '')
                .toString();
          }
          return '';
        })
        .where((item) => item.trim().isNotEmpty)
        .cast<String>()
        .toList();
  }

  Future<List<RecentSearchItem>> getRecentSearches() async {
    final token = SessionManager.token;
    if (token == null || token.isEmpty) {
      return const [];
    }

    final response = await _apiClient.get(
      ApiConfig.recentSearches,
      headers: ApiConfig.authHeaders(token),
    );

    final list = _asList(response['data'] ?? response['recent_searches']);
    return list
        .whereType<Map<String, dynamic>>()
        .map(RecentSearchItem.fromJson)
        .where((item) => item.query.trim().isNotEmpty)
        .toList();
  }

  Future<void> deleteRecentSearch(int id) async {
    final token = SessionManager.token;
    if (token == null || token.isEmpty) {
      throw ApiException(message: 'Please login to manage recent searches.');
    }

    await _apiClient.delete(
      '${ApiConfig.recentSearches}/$id',
      headers: ApiConfig.authHeaders(token),
    );
  }

  Future<void> clearRecentSearches() async {
    final token = SessionManager.token;
    if (token == null || token.isEmpty) {
      throw ApiException(message: 'Please login to manage recent searches.');
    }

    await _apiClient.delete(
      ApiConfig.recentSearches,
      headers: ApiConfig.authHeaders(token),
    );
  }

  void dispose() {
    _apiClient.dispose();
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is String && value.trim().isNotEmpty) {
    final decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  }
  return null;
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  if (value is Map<String, dynamic>) {
    if (value['data'] is List) return value['data'] as List;
  }
  return const [];
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1;
  if (value is String) {
    final v = value.toLowerCase();
    return v == '1' || v == 'true' || v == 'yes';
  }
  return false;
}
