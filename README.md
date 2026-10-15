# WorkBuddy AI Linux Pack

Per-user Linux installer for the WorkBuddy AI international edition.

This repository contains the installer and release packaging layout only. The proprietary WorkBuddy application payload is distributed as a release asset, not tracked in git.

## Install

Download the latest release archive, then run:

```bash
tar --zstd -xf workbuddy-ai-linux-pack-5.5.2.37849279-x86_64.tar.zst
cd workbuddy-ai-linux-pack
./install.sh
```

Launch from your app menu as **WorkBuddy AI**, or run:

```bash
~/.local/bin/workbuddy-ai
```

## What it installs

The installer checks common Ubuntu/Debian Electron runtime packages and uses `sudo apt-get install` for any missing packages when available.


- WorkBuddy AI app under `~/.local/opt/workbuddy-ai`
- launcher at `~/.local/bin/workbuddy-ai`
- desktop entry at `~/.local/share/applications/workbuddy-ai.desktop`
- browser login callback handlers:
  - `workbuddy-ai://`
  - `workbuddy://`

## Uninstall

From the extracted package directory:

```bash
./install.sh --uninstall
```

User login/cache data in `~/.workbuddy-ai` is left untouched.

## Notes

- This package does not include any user credentials, login sessions, or cache data.
- Share or use this only if WorkBuddy/Tencent's license allows redistribution in your jurisdiction/use case.
