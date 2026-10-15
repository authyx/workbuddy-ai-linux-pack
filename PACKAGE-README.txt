WorkBuddy AI Linux Pack
=======================

This package installs the WorkBuddy AI international edition on Ubuntu/Debian-like Linux as a per-user install under ~/.local.

Install
-------

1. Extract the archive:

   tar -xzf workbuddy-ai-linux-pack-5.5.2.37849279-x86_64-plug-and-play.tar.gz
   cd workbuddy-ai-linux-pack

2. Install:

   ./install.sh

3. Launch WorkBuddy AI from the app menu, or run:

   ~/.local/bin/workbuddy-ai

Login note
----------

This is the international WorkBuddy AI build. The installer registers both URI schemes needed for browser login callbacks:

   workbuddy-ai://
   workbuddy://

Uninstall
---------

From inside the extracted folder:

   ./install.sh --uninstall

User login/cache data in ~/.workbuddy-ai is left untouched.

