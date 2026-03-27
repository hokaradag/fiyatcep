import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: 'https://api.example.com/api/v1',
    // TODO: Change to actual API base URL when available
  );
});
