#!/usr/bin/env bash
set -euo pipefail
export JAVA_HOME="${JAVA_HOME:-/c/Program Files/Microsoft/jdk-17.0.19.10-hotspot}"
export PATH="$JAVA_HOME/bin:$PATH"
cd "$(dirname "$0")/.."
echo "JAVA_HOME=$JAVA_HOME"
"C:/gencyazilim/flutter-sdk/bin/flutter" build apk --debug --dart-define-from-file=dart_defines.local.json
echo "APK: $(pwd)/build/app/outputs/flutter-apk/app-debug.apk"
