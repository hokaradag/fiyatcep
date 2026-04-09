import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    // Android emulator: 10.0.2.2 maps to host localhost
    baseUrl: 'http://10.0.2.2:8000/api/v1',
    // Physical device: replace with http://{LAN_IP}:8000/api/v1
  );
});
