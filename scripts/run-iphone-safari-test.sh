#!/usr/bin/env bash
# iphone'da safari ile test (mac / developer hesabi gerekmez)
# bilgisayar ve iphone ayni wi-fi'de olmali
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FLUTTER="${FLUTTER_ROOT:-/c/gencyazilim/flutter-sdk}/bin/flutter"
if [[ ! -x "$FLUTTER" ]]; then
  FLUTTER="$(command -v flutter)"
fi

DEFINES_FILE="dart_defines.local.json"
PORT="${PORT:-8080}"

if [[ ! -f "$DEFINES_FILE" ]]; then
  echo "HATA: $DEFINES_FILE yok."
  echo "Örnek: cp dart_defines.example.json dart_defines.local.json"
  exit 1
fi

# windows'ta yerel ip (git bash)
LOCAL_IP=""
if command -v ipconfig >/dev/null 2>&1; then
  LOCAL_IP="$(ipconfig 2>/dev/null | tr -d '\r' | grep -E 'IPv4' | head -1 | sed -E 's/.*: *//')"
fi
if [[ -z "$LOCAL_IP" ]]; then
  LOCAL_IP="<BILGISAYAR_IP>"
fi

echo "=========================================="
echo " iPhone Safari test sunucusu"
echo "=========================================="
echo ""
echo "1) iPhone ve bu bilgisayar AYNI Wi-Fi'de olsun"
echo "2) iPhone Safari'de ac:"
echo "   http://${LOCAL_IP}:${PORT}"
echo ""
echo "Google giris calismazsa Supabase → URL Configuration'a ekle:"
echo "   http://${LOCAL_IP}:${PORT}/**"
echo ""
echo "Not: Bu web surumu. Native iOS (kamera, push vb.) ayri test edilir."
echo "Durdurmak icin: Ctrl+C"
echo "=========================================="
echo ""

exec "$FLUTTER" run -d web-server \
  --web-hostname=0.0.0.0 \
  --web-port="$PORT" \
  --dart-define-from-file="$DEFINES_FILE"
