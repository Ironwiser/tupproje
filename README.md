# FIRETRACK

Yangın tüpü takip ve yönetim mobil uygulaması (Flutter).

## Kurulum

```bash
flutter pub get
flutter run
```

## Supabase bağlantısı

### 1. Supabase projesi oluşturun
- [supabase.com](https://supabase.com) → New project
- Bölge: `Frankfurt (eu-central-1)` önerilir

### 2. Veritabanı şemasını kurun
- Dashboard → **SQL Editor**
- `supabase/schema.sql` dosyasının içeriğini yapıştırıp çalıştırın

### 3. Storage bucket oluşturun
- Dashboard → **Storage** → New bucket
- Ad: `extinguisher-photos`
- Public: **kapalı**

### 4. Telefon OTP (SMS) ayarı
- Dashboard → **Authentication** → **Providers** → Phone
- Twilio veya MessageBird bilgilerini girin (Türkiye numaraları için gerekli)

### 5. API anahtarlarını alın
- Dashboard → **Project Settings** → **API**
- `Project URL` ve `anon public` key

### 6. Uygulamayı çalıştırın

`dart_defines.local.json` dosyası oluşturun (örnek: `dart_defines.example.json`):

```json
{
  "SUPABASE_URL": "https://XXXX.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_XXXX"
}
```

```bash
flutter run --dart-define-from-file=dart_defines.local.json
```

VS Code / Cursor'da: **firetrack (Supabase)** launch profilini seçin.

Anahtarlar verilmezse uygulama **demo modunda** çalışır.

> **Not:** `postgresql://...` bağlantı dizesi yalnızca sunucu/admin işlemleri içindir; Flutter uygulamasına eklenmez. Veritabanı şifresini asla repoya commit etmeyin.

## Proje yapısı

```
lib/
├── core/           # Tema, router, Supabase config
├── features/       # auth, dashboard, extinguishers, ...
└── shared/         # Ortak widget'lar
supabase/
└── schema.sql      # Veritabanı şeması + RLS
```

## Teknolojiler

- Flutter + Riverpod + GoRouter
- Supabase (Auth, PostgreSQL, Storage)
