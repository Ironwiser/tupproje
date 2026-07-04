#!/usr/bin/env bash
# telefona atmak için release apk (debug'dan çok daha hızlı ve küçük)
set -euo pipefail

export JAVA_HOME="${JAVA_HOME:-/c/Program Files/Microsoft/jdk-17.0.19.10-hotspot}"
export PATH="$JAVA_HOME/bin:$PATH"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FLUTTER="${FLUTTER_ROOT:-/c/gencyazilim/flutter-sdk}/bin/flutter"
if [[ ! -x "$FLUTTER" ]]; then
  FLUTTER="$(command -v flutter)"
fi

DEFINES_FILE="dart_defines.local.json"
if [[ ! -f "$DEFINES_FILE" ]]; then
  echo "HATA: $DEFINES_FILE yok."
  echo "Örnek: cp dart_defines.example.json dart_defines.local.json"
  exit 1
fi

STAMP="$(date +%Y%m%d-%H%M)"
OUT_DIR="$ROOT/setup"
APK_NAME="KontrolPlus-phone-${STAMP}.apk"

echo "==> JAVA_HOME=$JAVA_HOME"
echo "==> flutter pub get"
"$FLUTTER" pub get

echo "==> flutter build apk --release --split-per-abi"
"$FLUTTER" build apk --release --split-per-abi --dart-define-from-file="$DEFINES_FILE"

APK_SRC="$ROOT/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
if [[ ! -f "$APK_SRC" ]]; then
  APK_SRC="$ROOT/build/app/outputs/flutter-apk/app-release.apk"
fi

mkdir -p "$OUT_DIR"
cp "$APK_SRC" "$OUT_DIR/$APK_NAME"
cp -f "$APK_SRC" "$OUT_DIR/KontrolPlus-phone-latest.apk"

BYTES=$(wc -c < "$OUT_DIR/$APK_NAME" | tr -d ' ')
MB=$(awk "BEGIN {printf \"%.1f\", $BYTES/1024/1024}")

echo ""
echo "=========================================="
echo " APK hazır (release)"
echo "=========================================="
echo "Dosya : $OUT_DIR/$APK_NAME"
echo "Kısayol: $OUT_DIR/KontrolPlus-phone-latest.apk"
echo "Boyut : ${MB} MB"
echo ""
echo "Not: Eski debug APK kuruluysa önce kaldırıp bunu kurun."
echo ""
echo "Telefona kurulum:"
echo "  1) APK'yı WhatsApp / Telegram / Drive ile telefona gönder"
echo "  2) Telefonda dosyayı aç → Kur"
echo "  3) Bilinmeyen kaynak uyarısı çıkarsa: Ayarlar → Bu kaynağa izin ver"
echo ""
