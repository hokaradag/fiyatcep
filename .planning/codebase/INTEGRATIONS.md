# External Integrations

**Analysis Date:** 2026-03-27

## APIs & External Services

**Markets API:**
- Service: Markets data endpoint
  - SDK/Client: `dio` (5.3.0)
  - Implementation: `lib/features/markets/data/datasources/market_remote_datasource.dart`
  - Endpoints:
    - `GET /markets` - Fetch all markets
    - `GET /markets/{id}` - Fetch market by ID
    - `GET /markets/search?q={query}` - Search markets

**Discounts API:**
- Service: Discounts data endpoint
  - SDK/Client: `dio` (5.3.0)
  - Implementation: `lib/features/discounts/data/datasources/discount_remote_datasource.dart`
  - Endpoints:
    - `GET /discounts` - Fetch all discounts
    - `GET /discounts?marketId={marketId}` - Fetch discounts by market
    - `GET /discounts/search?q={query}` - Search discounts

**Products API:**
- Service: Products data endpoint
  - SDK/Client: `dio` (5.3.0)
  - Implementation: Not yet fully implemented, models present in `lib/features/products/models/`

## Data Storage

**Databases:**
- No server-side database directly integrated (API client only)

**File Storage:**
- Local filesystem only (no cloud storage integration)

**Local Storage:**
- Shared Preferences (2.5.4) for favorites persistence
  - Key: `favorite_products`
  - Storage: Device-native key-value store (SharedPreferences on Android, UserDefaults on iOS, etc.)
  - Implementation: `lib/features/favorites/data/favorites_store.dart`

**Caching:**
- HTTP response caching via Dio interceptor (configured but no custom implementation)
- In-memory state management via Riverpod for runtime data

## Authentication & Identity

**Auth Provider:**
- None currently integrated
- Placeholder in code: `lib/core/network/api_client.dart` lines 97-101 contain commented-out Bearer token authorization
- TODO: Authentication implementation pending when API requires it

## Monitoring & Observability

**Error Tracking:**
- None detected (custom error handling via exceptions)

**Logs:**
- Console logging via Flutter's standard logging (no external service)
- Custom exception hierarchy in `lib/core/errors/exceptions.dart`

## CI/CD & Deployment

**Hosting:**
- Not configured (local development only)

**CI Pipeline:**
- None detected

## Environment Configuration

**Required env vars:**
- None required - all configuration is hardcoded in source

**Current Configuration:**
- API Base URL: `https://api.example.com/api/v1` (hardcoded, marked as TODO for change)
  - Location: `lib/shared/providers/api_client_provider.dart` line 6
- HTTP Timeouts: 30 seconds (both connection and receive)
- Content-Type: application/json
- Accept: application/json

**Secrets location:**
- Not configured - no .env file present
- Authorization header template exists but is commented out

## Network Configuration

**HTTP Client:**
- Library: Dio 5.3.0
- Base URL: `https://api.example.com/api/v1`
- Timeout: 30 seconds (connection and receive)
- Interceptors: Custom request/response/error handling (no-op implementations currently)
- Content-Type: application/json

**Error Handling:**
- Dio exception mapping to custom exception types in `lib/core/network/api_client.dart`
- Exception hierarchy:
  - `AppException` (base)
  - `ServerException` (500+)
  - `ClientException` (400-499)
  - `NetworkException` (timeouts, connection errors)

**Response Format:**
- Nested JSON structure: `{ "data": [...] }` for list endpoints
- Single object: `{ "data": {...} }` for detail endpoints
- Models use Freezed and json_serializable for deserialization

## Webhooks & Callbacks

**Incoming:**
- None detected

**Outgoing:**
- None detected

---

*Integration audit: 2026-03-27*
