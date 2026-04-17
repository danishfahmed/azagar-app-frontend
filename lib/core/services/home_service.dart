import 'package:azager/core/models/home_models.dart';
import 'package:azager/core/network/api_client.dart';
import 'package:azager/core/network/api_config.dart';
import 'package:azager/core/services/session_manager.dart';

class HomeService {
  final ApiClient _apiClient;

  HomeService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<HomeResponse> fetchHome({int page = 1, int perPage = 8}) async {
    final token = SessionManager.token;
    final response = await _apiClient.get(
      '${ApiConfig.home}?page=$page&per_page=$perPage',
      headers: token != null ? ApiConfig.authHeaders(token) : null,
    );
    return HomeResponse.fromJson(response);
  }

  Future<SplashScreenResponse> fetchSplashScreens() async {
    final response = await _apiClient.get(
      ApiConfig.splashScreens,
      headers: {'Accept': 'application/json'},
    );
    return SplashScreenResponse.fromJson(response);
  }

  void dispose() {
    _apiClient.dispose();
  }
}
