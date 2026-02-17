import 'package:flutter/material.dart';
import '../../data/models/ground_model.dart';
import '../../data/services/api_service.dart';
import '../../core/constants/api_constants.dart';

enum GroundStatus { initial, loading, success, error }

class GroundProvider extends ChangeNotifier {
  final ApiService _apiService;

  GroundProvider({required ApiService apiService}) : _apiService = apiService;

  List<Ground> _grounds = [];
  GroundStatus _status = GroundStatus.initial;
  String? _errorMessage;

  List<Ground> get grounds => _grounds;
  GroundStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == GroundStatus.loading;

  Future<void> fetchGrounds() async {
    _status = GroundStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConstants.grounds);

      if (response.statusCode == 200) {
        // Handle Laraval Resource Collection { data: [...] }
        final data = response.data['data'] as List<dynamic>;
        _grounds = data.map((json) => Ground.fromJson(json)).toList();
        _status = GroundStatus.success;
      } else {
        _errorMessage = 'Failed to load grounds';
        _status = GroundStatus.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = GroundStatus.error;
    }
    notifyListeners();
  }

  Future<Ground?> fetchGroundBySlug(String slug) async {
    try {
      final response = await _apiService.get('${ApiConstants.grounds}/$slug');
      if (response.statusCode == 200) {
        return Ground.fromJson(response.data['data'] ?? response.data);
      }
    } catch (e) {
      debugPrint('Error fetching ground: $e');
    }
    return null;
  }
}
