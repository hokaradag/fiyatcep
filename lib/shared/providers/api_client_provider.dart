import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

/// Base URL for the backend API. Centralized here to avoid duplication.
/// Android emulator: 10.0.2.2 maps to host localhost.
/// Physical device: replace with http://{LAN_IP}:8000/api/v1.
const String apiBaseUrl = 'http://192.168.1.49:8000/api/v1';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: apiBaseUrl);
});
