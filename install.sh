#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${PREFIX:-$HOME/.local}"
APP_NAME="workbuddy-ai"
APP_DST="$PREFIX/opt/$APP_NAME"
BIN_DST="$PREFIX/bin/$APP_NAME"
DESKTOP_DIR="$PREFIX/share/applications"
DESKTOP_DST="$DESKTOP_DIR/$APP_NAME.desktop"
ICON_DST="$PREFIX/share/icons/hicolor/256x256/apps/$APP_NAME.png"
MIME_PKG_DIR="$PREFIX/share/mime/packages"

log() { printf '\033[32m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[warn]\033[0m %s\n' "$*"; }
die() { printf '\033[31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

if [ "${1:-}" = "--uninstall" ]; then
  log "removing WorkBuddy AI from $PREFIX"
  rm -rf "$APP_DST"
  rm -f "$BIN_DST" "$DESKTOP_DST" "$ICON_DST" "$MIME_PKG_DIR/$APP_NAME.xml"
  command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
  command -v update-mime-database >/dev/null 2>&1 && update-mime-database "$PREFIX/share/mime" 2>/dev/null || true
  log "done. User data in ~/.workbuddy-ai was left untouched."
  exit 0
fi

[ -f "$HERE/files/workbuddy-ai-app.tar.zst" ] || die "missing files/workbuddy-ai-app.tar.zst"
command -v tar >/dev/null || die "tar is required"
command -v zstd >/dev/null || die "zstd is required. On Ubuntu: sudo apt-get install -y zstd"

log "installing WorkBuddy AI international edition"
log "prefix: $PREFIX"
mkdir -p "$APP_DST" "$PREFIX/bin" "$DESKTOP_DIR" "$(dirname "$ICON_DST")" "$MIME_PKG_DIR"

log "1/5 extracting application (~1 GB installed)"
rm -rf "$APP_DST"
mkdir -p "$APP_DST"
tar --zstd -xf "$HERE/files/workbuddy-ai-app.tar.zst" -C "$APP_DST"
chmod +x "$APP_DST/start.sh" "$APP_DST/electron" 2>/dev/null || true

log "2/5 writing launcher $BIN_DST"
cat > "$BIN_DST" <<EOF
#!/usr/bin/env bash
set -euo pipefail
APP_DIR="$APP_DST"
[ -x "\$APP_DIR/start.sh" ] || { echo "WorkBuddy AI is not installed correctly: \$APP_DIR/start.sh missing" >&2; exit 1; }
unset ELECTRON_RUN_AS_NODE || true
exec "\$APP_DIR/start.sh" "\$@"
EOF
chmod +x "$BIN_DST"

log "3/5 installing icon and desktop entry"
ICON_SRC=""
for candidate in \
  "$APP_DST/workbuddy-ai.png" \
  "$APP_DST/.workbuddy-linux/workbuddy-ai.png" \
  "$APP_DST/resources/app.asar.unpacked/resources/icon.png"
do
  [ -f "$candidate" ] && { ICON_SRC="$candidate"; break; }
done
[ -n "$ICON_SRC" ] && cp -f "$ICON_SRC" "$ICON_DST" || warn "icon not found; app still launches"
cat > "$DESKTOP_DST" <<EOF
[Desktop Entry]
Name=WorkBuddy AI
Comment=Run WorkBuddy AI on Linux
Exec=$BIN_DST %u
Icon=$APP_NAME
Terminal=false
Type=Application
Categories=Development;
MimeType=x-scheme-handler/workbuddy-ai;x-scheme-handler/workbuddy;
Keywords=workbuddy;ai;agent;coding;
StartupNotify=true
StartupWMClass=WorkBuddy AI
X-GNOME-WMClass=WorkBuddy AI
Actions=new-window;

[Desktop Action new-window]
Name=New Window
Exec=$BIN_DST --new-instance
EOF

log "4/5 registering URI schemes for browser login callback"
cat > "$MIME_PKG_DIR/$APP_NAME.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="x-scheme-handler/workbuddy-ai">
    <comment>WorkBuddy AI protocol (OAuth callback)</comment>
  </mime-type>
  <mime-type type="x-scheme-handler/workbuddy">
    <comment>WorkBuddy deep link protocol</comment>
  </mime-type>
</mime-info>
EOF
command -v update-mime-database >/dev/null 2>&1 && update-mime-database "$PREFIX/share/mime" 2>/dev/null || true
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
if command -v xdg-mime >/dev/null 2>&1; then
  xdg-mime default "$APP_NAME.desktop" x-scheme-handler/workbuddy-ai 2>/dev/null || true
  xdg-mime default "$APP_NAME.desktop" x-scheme-handler/workbuddy 2>/dev/null || true
fi

log "5/5 self-check"
FAIL=0
[ -x "$APP_DST/start.sh" ] || { warn "start.sh missing"; FAIL=1; }
[ -x "$APP_DST/electron" ] || { warn "electron missing"; FAIL=1; }
[ -f "$APP_DST/resources/app.asar" ] || { warn "app.asar missing"; FAIL=1; }
[ -x "$BIN_DST" ] || { warn "launcher missing"; FAIL=1; }
for S in workbuddy-ai workbuddy; do
  handler="$(xdg-mime query default "x-scheme-handler/$S" 2>/dev/null || true)"
  [ "$handler" = "$APP_NAME.desktop" ] && log "  x-scheme-handler/$S -> $handler" || warn "  x-scheme-handler/$S -> ${handler:-<unregistered>}"
done
[ "$FAIL" -eq 0 ] || die "self-check failed"

log "install complete"
printf '\nLaunch:\n  %s\n  app menu -> WorkBuddy AI\n\nUninstall:\n  %s --uninstall\n' "$BIN_DST" "$HERE/install.sh"
