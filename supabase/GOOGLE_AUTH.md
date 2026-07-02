# Google OAuth kurulumu (Supabase)

## 1. Google Cloud Console
1. [console.cloud.google.com](https://console.cloud.google.com) → yeni proje veya mevcut proje
2. **APIs & Services** → **OAuth consent screen** → External → uygulama adı: FIRETRACK
3. **Credentials** → **Create Credentials** → **OAuth client ID**

### Web client (zorunlu)
- Application type: **Web application**
- Authorized redirect URIs:
  ```
  https://cfdyqykyxjcabmslgifk.supabase.co/auth/v1/callback
  ```

### Android client (mobil için)
- Application type: **Android**
- Package name: `com.firetrack.firetrack`
- SHA-1: debug keystore fingerprint (`keytool -list -v -keystore ~/.android/debug.keystore`)

## 2. Supabase Dashboard
1. **Authentication** → **Providers** → **Google** → Enable
2. Web client **Client ID** ve **Client Secret** yapıştırın
3. **Authentication** → **URL Configuration** → **Redirect URLs** ekleyin:
   ```
   com.firetrack.firetrack://login-callback
   http://localhost:**
   ```
   (Chrome'da test için localhost portu değişebilir; çalıştırdığınız adresi ekleyin)

## 3. Uygulamayı çalıştırın
```bash
flutter run --dart-define-from-file=dart_defines.local.json
```

Giriş ekranında **Google ile devam et** butonuna tıklayın.
