# Firebase Setup — Required Before Running

## What You Need to Do

The app **will not build** without a valid `google-services.json`. This is expected.

### Steps

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a project for FiyatCep (or use an existing one).
2. Register your Android app:
   - Package name: `com.example.fiyatcep`
   - Navigate to: Project Settings -> General -> Your apps -> Add app -> Android
3. Download the `google-services.json` file.
4. Place `google-services.json` in: `android/app/google-services.json`
5. (iOS) Download `GoogleService-Info.plist` and place it in `ios/Runner/GoogleService-Info.plist`.
6. (iOS) Upload your APNs Auth Key (.p8) to Firebase Console under Project Settings -> Cloud Messaging.

### Verification

After placing the file, run:
```
flutter build apk --debug
```

The build should succeed and the FCM token will be printed to logcat on first app launch.

### Notes

- The `google-services.json` file is in `.gitignore` — never commit it to source control.
- See Plan 03 for backend FCM token sync (the token is stored locally in SharedPreferences for now).
