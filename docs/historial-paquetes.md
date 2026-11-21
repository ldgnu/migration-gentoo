# Historial de Portage (emerge.log)

Generado desde `/var/log/emerge.log` el 2026-11-20. Cada bloque es una sesión de `emerge`: el comando pedido y los paquetes que Portage efectivamente mergeó. Incluye instalaciones, actualizaciones y reinstalaciones por cambio de USE/ABI.

## Resumen por día

| Fecha | Sesiones | Paquetes mergeados |
|---|---:|---:|
| 2026-11-17 | 45 | 430 |
| 2026-11-18 | 20 | 266 |
| 2026-11-19 | 1 | 1 |

**Total:** 66 sesiones y 697 merges.

## Sesiones

### 2026-11-17 18:04 — `emerge --jobs=3 --load-average=12.0 --regex-search-auto=y --sync`

### 2026-11-17 18:07 — `emerge --oneshot --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose app-portage/mirrorselect`

Paquetes: `net-analyzer/netselect-0.4-r3`, `dev-util/dialog-1.3.20250817`, `app-portage/mirrorselect-2.7.0`

### 2026-11-17 18:10 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y screen`

### 2026-11-17 18:11 — `emerge --oneshot --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose app-misc/screen`

Paquetes: `acct-group/utmp-0-r3`, `app-misc/screen-4.9.1-r2`

### 2026-11-17 18:27 — `emerge --newuse --update --deep --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose @world`

Paquetes: `net-libs/nghttp2-1.70.0`, `net-libs/nghttp3-1.18.0`, `sys-devel/gettext-0.23.2`

### 2026-11-17 18:29 — `emerge --newuse --update --deep --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose @world`

### 2026-11-17 18:30 — `emerge --newuse --update --deep --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose @world`

Paquetes: `net-libs/nghttp2-1.70.0`, `net-libs/nghttp3-1.18.0`, `sys-devel/gettext-0.23.2`, `net-libs/ngtcp2-1.25.0`, `app-crypt/libb2-0.98.1-r3`, `net-misc/iputils-20250605-r4`, `net-misc/curl-8.23.0-r1`, `app-portage/portage-utils-0.97.1`

### 2026-11-17 18:35 — `emerge --jobs=3 --load-average=12.0 --regex-search-auto=y --depclean`

### 2026-11-17 18:38 — `emerge --jobs=3 --load-average=12.0 --regex-search-auto=y --sync`

### 2026-11-17 18:40 — `emerge --newuse --update --ask --deep --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose @world`

Paquetes: `sys-kernel/linux-headers-7.1`, `sys-libs/glibc-2.44-r4`, `dev-libs/xxhash-0.8.4`, `dev-lang/python-exec-conf-2.4.6`, `sys-libs/zlib-1.4`, `app-crypt/libmd-1.3.0`, `dev-build/automake-wrapper-20261107`, `dev-util/pkgconf-3.0.11`, `dev-lang/python-exec-2.4.10`, `sys-libs/readline-8.3_p6-r2`, `net-libs/nghttp2-1.71.0`, `sys-libs/timezone-data-2026f`, `sys-devel/patch-2.8.1`, `dev-libs/libffi-3.8.1`, `net-libs/nghttp3-1.19.0`, `app-editors/nano-9.3`, `sys-apps/sandbox-2.51`, `net-libs/libmicrohttpd-1.0.5`, `dev-db/sqlite-3.54.1`, `dev-libs/openssl-4.1.0`, `net-libs/ngtcp2-1.26.0`, `sys-apps/groff-1.25.0`, `sys-apps/coreutils-9.12`, `dev-build/automake-1.20`, `dev-build/libtool-2.6.2`, `net-misc/rsync-3.5.2-r1`, `sys-apps/gawk-5.4.2`, `sys-apps/iproute2-7.3.0`, `sys-apps/sysvinit-3.18`, `sys-libs/pam-1.7.3`, `sys-apps/util-linux-2.42.4`, `dev-lang/python-3.14.10_p1`, `sys-apps/systemd-utils-262`, `sys-auth/pam_xdg-0.8.5`, `sys-auth/pambase-20260730`, `net-libs/libpsl-0.23.3`, `virtual/service-manager-3`, `net-misc/curl-8.23.0-r1`, `app-arch/libarchive-3.8.11`, `net-misc/wget-1.25.0-r3`, `dev-libs/elfutils-0.197`, `sys-apps/man-db-2.13.3`, `net-misc/openssh-10.6_p2`, `dev-util/debugedit-5.4`, `dev-python/gpep517-23`, `sys-apps/man-pages-6.19`, `dev-python/flit-core-4.2.0`, `dev-python/ensurepip-pip-26.3`, `dev-python/platformdirs-4.14.5`, `dev-python/wheel-0.48.0`, `dev-python/jaraco-context-6.1.2`, `dev-python/editables-0.6`, `dev-python/pathspec-1.1.1`, `dev-python/jaraco-functools-4.6.0`, `dev-lang/python-3.15.2_p1`, `dev-python/jaraco-text-4.3.0`, `dev-python/hatchling-1.33.0`, `dev-python/setuptools-84.2.1`, `dev-python/vcs-versioning-2.6.0`, `dev-python/setuptools-scm-10.3.4`, `dev-python/hatch-vcs-0.5.0`

### 2026-11-17 19:13 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --depclean`

### 2026-11-17 19:13 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y @preserved-rebuild`

### 2026-11-17 19:13 — `emerge --newuse --update --deep --jobs=3 --load-average=12.0 --regex-search-auto=y @world`

### 2026-11-17 19:33 — `emerge --jobs=3 --load-average=12.0 --regex-search-auto=y --config sys-libs/timezone-data`

### 2026-11-17 16:43 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y =sys-kernel/gentoo-sources-6.18.63 sys-kernel/linux-firmware sys-kernel/installkernel sys-kernel/dracut sys-boot/grub`

Paquetes: `sys-apps/hwdata-0.413`, `virtual/libudev-257`, `app-text/asciidoc-10.2.1`, `virtual/libelf-3-r1`, `media-libs/libpng-1.6.59-r1`, `app-text/mandoc-1.14.6-r1`, `sys-libs/binutils-libs-2.47`, `sys-boot/grub-themes-gentoo-1.0-r2`, `app-arch/cpio-2.15`, `sys-devel/bc-1.08.2`, `sys-fs/lvm2-2.03.39`, `sys-apps/pciutils-3.15.0`, `media-libs/freetype-2.15.0`, `sys-libs/efivar-39-r2`, `app-alternatives/cpio-0`, `app-alternatives/bc-0`, `sys-boot/efibootmgr-18-r2`, `sys-kernel/dracut-112`, `sys-kernel/linux-firmware-20261019`, `sys-kernel/gentoo-sources-6.18.63`, `sys-boot/grub-2.16-r1`, `sys-kernel/installkernel-70-r1`

### 2026-11-17 17:30 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y sys-fs/dosfstools`

Paquetes: `sys-fs/dosfstools-4.2`

### 2026-11-17 17:32 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y tmux`

Paquetes: `dev-libs/libevent-2.1.13`, `app-misc/tmux-3.8`

### 2026-11-17 17:41 — `emerge --ask --jobs=3 --load-average=12.0 --getbinpkg --regex-search-auto=y --usepkg fastfetch`

Paquetes: `dev-libs/yyjson-0.13.0`, `app-crypt/rhash-1.4.6-r1`, `dev-libs/jsoncpp-1.9.8`, `dev-libs/libuv-1.53.0`, `dev-build/cmake-4.3.6`, `app-misc/fastfetch-2.71.0`

### 2026-11-17 19:21 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y sys-firmware/intel-microcode`

Paquetes: `sys-apps/iucode_tool-2.3.1-r2`, `sys-firmware/intel-microcode-20261110_p20261111`

### 2026-11-17 19:27 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y app-admin/sudo app-admin/sysklogd sys-process/cronie app-portage/gentoolkit app-shells/bash-completion net-misc/chrony app-misc/screen`

Paquetes: `sys-apps/miscfiles-1.5-r4`, `app-shells/gentoo-bashcomp-20260905`, `acct-group/ntp-0-r3`, `acct-group/cron-0-r2`, `acct-group/nullmail-0-r2`, `acct-group/utmp-0-r3`, `dev-libs/libedit-20240808.3.1`, `acct-group/crontab-0-r2`, `sys-apps/debianutils-5.23.2`, `app-admin/sysklogd-2.7.2`, `app-portage/gentoolkit-0.8.2`, `app-shells/bash-completion-2.18.0`, `acct-user/ntp-0-r3`, `acct-user/cron-0-r3`, `acct-user/nullmail-0-r2`, `app-misc/screen-4.9.1-r2`, `virtual/logger-0-r3`, `sys-process/cronbase-0.3.7-r10`, `net-misc/chrony-4.9`, `mail-mta/nullmailer-2.2-r2`, `sys-process/cronie-1.7.2-r1`, `virtual/mta-1-r2`, `app-admin/sudo-1.9.17_p2-r1`

### 2026-11-17 19:47 — `emerge --oneshot --jobs=3 --load-average=12.0 --regex-search-auto=y gui-wm/sway gui-apps/foot media-fonts/dejavu sys-auth/elogind dbus`

### 2026-11-17 19:47 — `emerge --oneshot --jobs=3 --load-average=12.0 --regex-search-auto=y gui-wm/sway gui-apps/foot media-fonts/dejavu sys-auth/elogind`

### 2026-11-17 19:49 — `emerge --ask --jobs=3 --load-average=12.0 --getbinpkg --regex-search-auto=y --usepkg gui-wm/sway gui-apps/foot media-fonts/dejavu sys-auth/elogind`

Paquetes: `dev-libs/tllist-1.1.0`, `x11-misc/compose-tables-1.8.14`, `llvm-core/llvm-common-23.1.5`, `llvm-runtimes/libclc-22.1.8`, `media-fonts/dejavu-2.37`, `dev-libs/gobject-introspection-common-1.86.0`, `app-i18n/unicode-data-18.0.0`, `app-eselect/eselect-fontconfig-20220403`, `llvm-core/clang-linker-config-23`, `llvm-core/clang-linker-config-22`, `llvm-core/clang-common-23.1.5`, `dev-util/spirv-headers-1.4.363.0`, `llvm-runtimes/clang-rtlib-config-23`, `llvm-runtimes/clang-stdlib-config-23`, `llvm-runtimes/clang-unwindlib-config-23`, `x11-libs/pixman-0.46.4`, `dev-libs/wayland-1.26.0`, `dev-util/wayland-scanner-1.26.0`, `dev-libs/libutf8proc-2.12.0`, `dev-lang/duktape-2.7.0-r3`, `media-libs/libjpeg-turbo-3.1.4.1`, `media-gfx/graphite2-1.3.14_p20210810-r5`, `x11-libs/libxshmfence-1.3.3`, `dev-libs/libyaml-0.2.5`, `llvm-runtimes/compiler-rt-22.1.8`, `llvm-runtimes/compiler-rt-sanitizers-22.1.8`, `llvm-runtimes/clang-rtlib-config-22`, `llvm-runtimes/clang-unwindlib-config-22`, `llvm-runtimes/clang-stdlib-config-22`, `x11-libs/libXau-1.0.12`, `x11-libs/libXdmcp-1.1.5`, `dev-libs/fribidi-1.0.16`, `x11-libs/libpciaccess-0.19`, `sys-libs/mtdev-1.1.7`, `llvm-core/llvm-22.1.8`, `media-libs/freetype-2.15.0`, `acct-group/polkitd-0-r3`, `app-text/xmlto-0.0.28-r11`, `app-text/docbook-xml-dtd-4.4-r3`, `acct-group/messagebus-0-r3`, `x11-misc/xkeyboard-config-2.49`, `dev-libs/libevdev-1.14.0`, `x11-base/xorg-proto-2026.1`, `dev-python/mako-1.4.3`, `dev-python/olefile-0.47`, `media-libs/libdisplay-info-0.4.0`, `dev-python/alabaster-1.0.0`, `dev-python/babel-2.18.0`, `dev-python/imagesize-2.0.1`, `dev-python/roman-numerals-4.1.0`, `dev-python/snowballstemmer-3.1.1`, `dev-python/mdurl-0.1.2`, `dev-python/uc-micro-py-2.0.0`, `dev-python/lxml-6.1.3`, `dev-python/pygments-2.21.0`, `dev-python/sphinxcontrib-applehelp-2.0.0-r1`, `dev-python/sphinxcontrib-devhelp-2.0.0-r1`, `dev-python/sphinxcontrib-htmlhelp-2.1.0-r1`, `dev-python/sphinxcontrib-jsmath-2.0.0`, `dev-python/sphinxcontrib-qthelp-2.0.0-r1`, `dev-python/sphinxcontrib-serializinghtml-2.0.0-r1`

### 2026-11-17 19:50 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y dbus`

Paquetes: `virtual/ttf-fonts-1-r2`, `x11-libs/libxcb-1.17.0`, `x11-libs/xcb-util-keysyms-0.4.1`, `x11-libs/libdrm-2.4.134`, `llvm-core/llvm-toolchain-symlinks-22`, `media-libs/fontconfig-2.18.3`, `acct-user/polkitd-0-r3`, `acct-user/messagebus-0-r3`, `dev-libs/wayland-protocols-1.50`, `dev-util/spirv-tools-1.4.363.0`, `dev-python/pyyaml-6.0.3`, `x11-libs/libxkbcommon-1.13.2`, `dev-libs/libinput-1.32.0`, `x11-libs/libX11-1.8.14`, `dev-python/pillow-13.0.0`, `dev-python/linkify-it-py-2.2.0`, `sys-auth/elogind-257.16`, `llvm-core/clang-22.1.8`, `x11-libs/libXext-1.3.7`, `media-libs/libglvnd-1.7.0`, `x11-libs/libXxf86vm-1.1.7`, `x11-libs/libXfixes-6.0.2`, `dev-util/spirv-llvm-translator-22.1.8`, `x11-libs/libXrender-0.9.13`, `dev-python/docutils-0.23`, `dev-python/markdown-it-py-4.3.0`, `sys-apps/dbus-1.16.4-r1`, `sys-auth/seatd-0.9.3-r1`, `llvm-core/clang-toolchain-symlinks-22`, `x11-libs/libXrandr-1.5.5`, `dev-util/glib-utils-2.88.4`, `dev-python/mdit-py-plugins-0.7.0`, `dev-libs/glib-2.88.4`, `dev-util/mesa_clc-26.2.7`, `dev-python/sphinx-9.2.0`, `x11-misc/shared-mime-info-2.5.1`, `dev-util/desktop-file-utils-0.29`, `x11-libs/cairo-1.18.6`, `media-libs/mesa-26.2.7`, `dev-python/myst-parser-5.2.0`, `gnome-base/dconf-0.49.0`, `dev-libs/gobject-introspection-1.86.0-r1`, `sys-auth/polkit-128`, `media-libs/harfbuzz-12.3.2`, `x11-libs/gdk-pixbuf-2.44.8`, `media-libs/fcft-3.3.3`, `x11-libs/pango-1.58.2`, `gui-libs/wlroots-0.20.2`, `llvm-core/llvm-23.1.5`, `gui-apps/foot-1.28.0`, `llvm-core/llvmgold-23`, `llvm-core/llvm-toolchain-symlinks-23`, `llvm-core/clang-23.1.5-r1`, `gui-wm/sway-1.12-r2`, `llvm-core/clang-toolchain-symlinks-23`, `llvm-runtimes/compiler-rt-23.1.5`, `llvm-runtimes/openmp-23.1.5`, `llvm-runtimes/clang-runtime-22-r1`, `llvm-runtimes/compiler-rt-sanitizers-23.1.5`, `llvm-runtimes/clang-runtime-23-r2`

### 2026-11-17 21:53 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y dbus`

### 2026-11-17 21:53 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y sys-apps/dbus`

Paquetes: `sys-apps/dbus-1.16.4-r1`

### 2026-11-17 22:09 — `emerge --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose sys-auth/seatd`

Paquetes: `acct-group/seat-0-r1`, `sys-auth/seatd-0.9.3-r1`

### 2026-11-17 22:24 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y wofi`

### 2026-11-17 22:26 — `emerge --ask --jobs=3 --load-average=12.0 --getbinpkg --regex-search-auto=y --usepkg wofi`

### 2026-11-17 22:33 — `emerge --jobs=3 --load-average=12.0 --regex-search-auto=y --sync`

### 2026-11-17 22:33 — `emerge --jobs=3 --load-average=12.0 --regex-search-auto=y --sync`

### 2026-11-17 22:36 — `emerge --jobs=3 --load-average=12.0 --regex-search-auto=y --sync`

### 2026-11-17 22:39 — `emerge --ask --jobs=3 --load-average=12.0 --getbinpkg --regex-search-auto=y --usepkg wofi`

### 2026-11-17 22:40 — `emerge --jobs=3 --keep-going --load-average=12.0 --reinstall=changed-use --quiet-build=y --regex-search-auto=y gui-apps/wmenu gui-apps/mako gui-apps/wl-clipboard gui-apps/grim gui-apps/slurp gui-apps/swayidle gui-apps/swaylock gui-apps/swaybg x11-base/xwayland sys-apps/xdg-desktop-portal gui-libs/xdg-desktop-portal-wlr sys-apps/xdg-desktop-portal-gtk media-fonts/liberation-fonts media-video/pipewire media-video/wireplumber media-libs/libpulse media-sound/alsa-utils sys-auth/rtkit media-libs/libfreeaptx media-libs/opus net-wireless/bluez`

Paquetes: `media-libs/libogg-1.3.6`, `media-fonts/liberation-fonts-2.1.5`, `media-libs/libfreeaptx-0.1.1-r1`, `dev-libs/ell-0.83`, `dev-util/xxd-2025.08.24-r1`, `media-libs/alsa-topology-conf-1.2.5.1-r1`, `media-libs/alsa-ucm-conf-1.2.16.1`, `media-libs/libsamplerate-0.2.2`, `media-libs/sbc-2.1`, `x11-themes/hicolor-icon-theme-0.17`, `dev-libs/vala-common-0.56.19`, `dev-libs/libltdl-2.6.2`, `x11-libs/xtrans-1.6.0`, `dev-libs/libbsd-0.11.8`, `dev-libs/libatomic_ops-7.10.0`, `media-libs/fdk-aac-2.0.3`, `media-fonts/font-util-1.4.2`, `dev-libs/libusb-1.0.30`, `media-libs/flac-1.5.0`, `app-eselect/eselect-lua-4-r3`, `app-eselect/eselect-mpg123-0.1-r1`, `net-libs/libssh2-1.11.1-r2`, `net-libs/llhttp-9.4.4`, `media-libs/libldac-2.0.2.3-r2`, `virtual/perl-Time-Local-1.350.0-r2`, `virtual/libusb-1-r2`, `dev-lang/lua-5.4.8`, `virtual/perl-Compress-Raw-Bzip2-2.218.0`, `virtual/perl-Compress-Raw-Zlib-2.222.0-r1`, `dev-perl/Net-SSLeay-1.960.0-r1`, `dev-perl/Regexp-IPv6-0.30.0-r2`, `dev-perl/TimeDate-2.330.0-r1`, `sys-apps/lsb-release-3.3`, `virtual/perl-MIME-Base64-3.160.100_rc-r3`, `dev-perl/Encode-Locale-1.50.0-r1`, `dev-perl/LWP-MediaTypes-6.40.0`, `dev-perl/Try-Tiny-0.320.0`, `dev-perl/MIME-Base32-1.303.0-r1`, `dev-perl/Clone-0.470.0`, `dev-perl/IO-HTML-1.4.0`, `dev-perl/HTML-Tagset-3.240.0`, `dev-perl/Devel-CheckLib-1.160.0-r1`, `media-libs/alsa-lib-1.2.16.1`, `net-libs/libasyncns-0.8-r5`, `dev-perl/Socket6-0.290.0-r2`, `media-libs/libvorbis-1.3.7-r2`, `media-sound/lame-3.100-r3`, `media-sound/mpg123-base-1.33.7`, `app-eselect/eselect-rust-20210703`, `x11-libs/libXcursor-1.2.3`

### 2026-11-17 22:44 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y wofi`

Paquetes: `sys-apps/lsb-release-3.3`, `app-eselect/eselect-rust-20210703`, `x11-libs/libXi-1.8.4`, `x11-libs/libXcursor-1.2.3`, `app-text/docbook-xml-dtd-4.3-r2`, `dev-libs/libgit2-1.9.7`, `media-libs/libepoxy-1.5.10-r3`, `x11-libs/libXcomposite-0.4.7`, `x11-libs/libXdamage-1.1.7`, `x11-libs/libXres-1.2.3`, `x11-libs/cairo-1.18.6`, `dev-util/gdbus-codegen-2.88.4`, `dev-lang/vala-0.56.19`, `dev-lang/rust-bin-1.99.0`, `x11-libs/libXtst-1.2.6`, `dev-util/gtk-update-icon-cache-3.24.42`, `dev-util/cargo-c-0.10.26`, `app-accessibility/at-spi2-core-2.60.7`, `gnome-base/librsvg-2.62.4`

### 2026-11-17 22:49 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y zen-browser`

Paquetes: `x11-themes/adwaita-icon-theme-legacy-46.2-r1`, `x11-themes/adwaita-icon-theme-50.0-r1`, `x11-libs/gtk+-3.24.52`, `gui-apps/wofi-1.5`

### 2026-11-17 22:56 — `emerge --ask --jobs=3 --load-average=12.0 --getbinpkg --regex-search-auto=y --usepkg gui-apps/wmenu gui-apps/mako gui-apps/wl-clipboard gui-apps/grim gui-apps/slurp gui-apps/swayidle gui-apps/swaylock gui-apps/swaybg x11-base/xwayland sys-apps/xdg-desktop-portal gui-libs/xdg-desktop-portal-wlr sys-apps/xdg-desktop-portal-gtk media-fonts/liberation-fonts`

Paquetes: `media-fonts/liberation-fonts-2.1.5`, `x11-themes/sound-theme-freedesktop-0.8-r1`, `dev-libs/inih-62`, `media-libs/alsa-lib-1.2.16.1`, `media-sound/liblc3-1.1.3`, `dev-lang/lua-5.4.8`, `media-libs/libvorbis-1.3.7-r2`, `dev-libs/icu-78.3`, `sys-apps/bubblewrap-0.13.0`, `x11-libs/libxcvt-0.1.3`, `x11-libs/libfontenc-1.1.9`, `x11-libs/libxkbfile-1.2.0`, `acct-group/pipewire-0-r2`, `acct-group/cuse-0`, `media-libs/opus-1.6.1`, `gui-apps/wl-clipboard-2.3.0`, `gui-apps/grim-1.5.0`, `gnome-base/gsettings-desktop-schemas-50.1`, `gui-apps/slurp-1.5.0`, `gui-apps/swaybg-1.2.2`, `gui-apps/swayidle-1.9.0`, `dev-libs/json-glib-1.10.8`, `gui-apps/swaylock-1.8.6`, `gui-apps/wmenu-0.2.0`, `gui-apps/mako-1.11.0`, `media-libs/libcanberra-0.30-r8`, `x11-libs/libXfont2-2.0.9`, `x11-apps/xkbcomp-1.5.0-r2`, `sys-fs/fuse-common-3.10.4-r3`, `sys-fs/fuse-3.18.3`, `x11-base/xwayland-24.1.15`, `dev-libs/libical-3.0.20-r2`, `net-wireless/bluez-5.88`, `media-video/pipewire-1.6.11`, `media-video/wireplumber-0.5.19`, `sys-apps/xdg-desktop-portal-1.22.1-r1`, `gui-libs/xdg-desktop-portal-wlr-0.8.5`, `sys-apps/xdg-desktop-portal-gtk-1.15.3`

### 2026-11-17 23:05 — `emerge --ask --jobs=3 --load-average=12.0 --getbinpkg --regex-search-auto=y --usepkg media-video/pipewire media-video/wireplumber media-libs/libpulse media-sound/alsa-utils sys-auth/rtkit media-libs/libfreeaptx media-libs/opus net-wireless/bluez`

Paquetes: `media-libs/libfreeaptx-0.1.1-r1`, `net-libs/libasyncns-0.8-r5`, `media-sound/lame-3.100-r3`, `media-sound/mpg123-base-1.33.7`, `media-sound/alsa-utils-1.2.16`, `acct-group/rtkit-0-r3`, `media-libs/opus-1.6.1`, `net-wireless/bluez-5.88`, `acct-user/rtkit-0-r3`, `media-libs/libsndfile-1.2.2-r2`, `sys-auth/rtkit-0.14`, `media-video/pipewire-1.6.11`, `media-video/wireplumber-0.5.19`, `media-libs/libpulse-17.0`

### 2026-11-17 23:11 — `emerge --ask --jobs=3 --load-average=12.0 --getbinpkg --regex-search-auto=y --usepkg www-client/firefox-bin`

### 2026-11-17 23:20 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --depclean`

### 2026-11-17 23:33 — `emerge --ask --jobs=3 --load-average=12.0 --getbinpkg --regex-search-auto=y --usepkg app-eselect/eselect-repository dev-vcs/git`

Paquetes: `dev-perl/Error-0.170.300-r1`, `dev-perl/Crypt-URandom-0.550.0`, `dev-perl/TimeDate-2.330.0-r1`, `dev-perl/Net-SSLeay-1.960.0-r1`, `virtual/perl-Digest-MD5-2.590.0-r1`, `virtual/perl-Digest-SHA-6.40.0-r3`, `dev-perl/Digest-HMAC-1.50.0`, `dev-perl/IO-Socket-SSL-2.95.0`, `virtual/perl-libnet-3.150.0-r3`, `dev-perl/Authen-SASL-2.200.0`, `dev-perl/MailTools-2.220.0`, `dev-vcs/git-2.56.1`, `app-eselect/eselect-repository-15`

### 2026-11-17 23:35 — `emerge --jobs=3 --load-average=12.0 --regex-search-auto=y --sync guru`

### 2026-11-17 23:35 — `emerge --ask --jobs=3 --load-average=12.0 --getbinpkg --regex-search-auto=y --usepkg www-client/zen-bin`

Paquetes: `dev-libs/libunibreak-8.0`, `x11-libs/libICE-1.1.2`, `dev-lang/nasm-3.02`, `app-text/libpaper-2.1.3`, `media-libs/dav1d-1.5.4`, `dev-libs/boehm-gc-8.2.12`, `dev-libs/nspr-4.40`, `x11-apps/xprop-1.2.8`, `x11-libs/libXv-1.0.13`, `acct-group/lpadmin-0-r3`, `dev-libs/nss-3.133`, `www-client/w3m-0.5.6`, `x11-libs/libSM-1.2.6`, `media-libs/libass-0.17.5-r1`, `virtual/w3m-1`, `x11-libs/libXt-1.3.1-r1`, `x11-libs/libXmu-1.3.1`, `x11-apps/xset-1.2.6`, `app-text/xmlto-0.0.28-r11`, `x11-misc/xdg-utils-1.2.1-r11`, `media-video/ffmpeg-compat-7.1.5-r1`, `net-print/cups-2.4.19`, `www-client/zen-bin-1.24.1b`

### 2026-11-17 23:45 — `emerge --ask --jobs=3 --load-average=12.0 --getbinpkg --regex-search-auto=y --usepkg gui-apps/wmenu gui-apps/mako gui-apps/wl-clipboard gui-apps/grim gui-apps/slurp gui-apps/swayidle gui-apps/swaylock gui-apps/swaybg x11-base/xwayland media-fonts/liberation-fonts`

Paquetes: `media-fonts/liberation-fonts-2.1.5`, `gui-apps/wmenu-0.2.0`, `gui-apps/wl-clipboard-2.3.0`, `gui-apps/grim-1.5.0`, `gui-apps/slurp-1.5.0`, `gui-apps/swaybg-1.2.2`, `x11-base/xwayland-24.1.15`, `gui-apps/mako-1.11.0`, `gui-apps/swayidle-1.9.0`, `gui-apps/swaylock-1.8.6`

### 2026-11-17 23:51 — `emerge --ask --jobs=3 --load-average=12.0 --getbinpkg --regex-search-auto=y --usepkg sys-fs/exfatprogs sys-fs/ntfs3g`

Paquetes: `sys-fs/exfatprogs-1.4.3`, `sys-fs/ntfs3g-2026.9.28`

### 2026-11-18 01:01 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose app-editors/neovim app-misc/ranger sys-process/btop sys-apps/ripgrep sys-apps/fd app-shells/fzf app-shells/zoxide sys-apps/bat sys-apps/eza sys-fs/ncdu sys-fs/duf app-arch/7zip app-arch/unrar app-arch/zip app-arch/atool app-misc/jq app-text/poppler media-gfx/chafa sys-apps/lm-sensors sys-apps/smartmontools sys-apps/plocate app-admin/eclean-kernel app-admin/logrotate media-sound/playerctl media-sound/ncpamixer media-video/mpv net-misc/yt-dlp gui-apps/swappy app-misc/cliphist app-misc/yazi`

### 2026-11-18 01:12 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose app-editors/neovim app-misc/ranger sys-process/btop sys-apps/ripgrep sys-apps/fd app-shells/fzf app-shells/zoxide sys-apps/bat sys-apps/eza sys-fs/ncdu sys-fs/duf app-arch/7zip app-arch/unrar app-arch/zip app-arch/atool app-misc/jq app-text/poppler media-gfx/chafa sys-apps/lm-sensors sys-apps/smartmontools sys-apps/plocate app-admin/eclean-kernel app-admin/logrotate media-sound/playerctl media-sound/ncpamixer media-video/mpv net-misc/yt-dlp gui-apps/swappy app-misc/cliphist app-misc/yazi dev-vcs/lazygit`

Paquetes: `dev-lang/luajit-2.1.1787165859`, `dev-libs/oniguruma-6.9.10`, `dev-build/bmake-20260912`, `dev-libs/tree-sitter-c-0.24.2`, `dev-libs/tree-sitter-lua-0.5.0`, `dev-libs/tree-sitter-markdown-0.5.3-r1`, `dev-libs/tree-sitter-query-0.8.0`, `dev-libs/tree-sitter-vim-0.8.1`, `dev-libs/tree-sitter-vimdoc-4.1.0`, `dev-lang/go-bootstrap-1.24.6`, `app-arch/unrar-7.3.2`, `app-arch/7zip-26.06`, `sys-libs/liburing-2.15`, `media-libs/tiff-4.7.1`, `app-arch/zip-3.0_p16`, `app-eselect/eselect-vi-20221122`, `app-eselect/eselect-zig-2`, `dev-lang/lua-5.1.5-r200`, `llvm-core/clang-linker-config-20`, `dev-lang/go-1.27.4`, `dev-util/vulkan-headers-1.4.363.0`, `app-i18n/uchardet-0.0.8`, `dev-lua/luv-1.52.1.0`, `dev-libs/msgpack-7.0.1`, `dev-libs/tree-sitter-0.26.13`, `app-text/lowdown-3.2.1`, `sys-apps/lm-sensors-3.6.2`, `llvm-runtimes/clang-rtlib-config-20`, `llvm-runtimes/clang-stdlib-config-20`, `dev-lang/deno-bin-2.9.8`, `llvm-runtimes/clang-unwindlib-config-20`, `sys-apps/ripgrep-15.2.0`, `app-shells/zoxide-0.10.0`, `sys-apps/bat-0.26.1-r1`, `sys-apps/eza-0.23.5`, `dev-libs/jemalloc-5.4.0-r2`, `dev-libs/libvterm-0.3.3`, `dev-libs/unibilium-2.1.4`, `dev-libs/libmpack-1.0.5-r5`, `app-arch/atool-0.39.0-r1`, `app-misc/jq-1.8.2`, `acct-group/locate-0-r3`, `net-mail/mailutils-3.21`, `virtual/cron-0-r3`, `dev-util/glslang-1.4.363.0`, `x11-apps/mkfontscale-1.2.4`, `media-libs/lcms-2.19.1`, `x11-libs/libXScrnSaver-1.2.5`, `x11-libs/libXpresent-1.0.2`, `dev-python/ply-3.11-r2`, `dev-python/distro-1.9.0`, `dev-python/pymountboot-0.2.3-r2`, `dev-python/yt-dlp-ejs-0.8.0`, `app-misc/ranger-1.9.4-r1`, `media-sound/playerctl-2.4.1-r1`, `media-video/ffmpeg-9.0.2-r1`, `llvm-core/llvm-20.1.8`

### 2026-11-18 01:43 — `emerge --oneshot --jobs=3 --load-average=12.0 --quiet --regex-search-auto=y pulsemixer`

Paquetes: `media-sound/pulsemixer-1.5.1-r2`

### 2026-11-18 01:47 — `emerge --jobs=3 --load-average=12.0 --quiet --regex-search-auto=y --unmerge =gui-apps/wofi-1.5`

### 2026-11-18 01:54 — `emerge --oneshot --jobs=3 --load-average=12.0 --quiet --regex-search-auto=y bluetui`

Paquetes: `net-wireless/bluetui-0.8.2`, `media-gfx/chafa-1.18.3`, `dev-lua/lpeg-1.1.0`, `media-libs/vulkan-loader-1.4.363.0`, `app-shells/fzf-0.74.4`, `sys-fs/duf-0.9.1`, `sys-apps/fd-10.5.2`, `dev-vcs/lazygit-0.66.3`, `sys-process/btop-1.4.7`, `app-misc/yazi-26.9.1`, `app-misc/cliphist-0.7.0`, `media-sound/ncpamixer-1.3.8`, `dev-lua/mpack-1.0.13`, `virtual/mailx-4`, `app-admin/logrotate-3.22.0-r1`, `media-libs/shaderc-2026.4`, `sys-apps/plocate-1.1.24`, `media-fonts/encodings-1.1.0`, `media-libs/openjpeg-2.5.4-r1`, `dev-python/pycparser-3.12`, `app-admin/eclean-kernel-2.99.10`, `llvm-core/llvm-toolchain-symlinks-20-r1`, `llvm-core/clang-20.1.8`, `llvm-core/lld-20.1.8`, `sys-apps/smartmontools-7.5-r1`, `media-fonts/fontawesome-6.5.1`, `media-libs/libplacebo-7.387.0`, `dev-python/cffi-2.1.1`, `app-editors/neovim-0.12.6`, `app-text/poppler-26.09.0`, `llvm-core/clang-toolchain-symlinks-20`, `llvm-runtimes/compiler-rt-20.1.8-r1`, `llvm-core/lld-toolchain-symlinks-20`, `dev-lang/zig-0.15.2`, `dev-python/pycryptodome-4.5.0`, `media-video/mpv-0.42.0`, `llvm-runtimes/compiler-rt-sanitizers-20.1.8-r1`, `gui-apps/swappy-1.5.1`, `net-misc/yt-dlp-2026.10.26`, `llvm-runtimes/clang-runtime-20.1.8-r2`, `sys-fs/ncdu-2.9.2`

### 2026-11-18 11:27 — `emerge --oneshot --jobs=3 --load-average=12.0 --quiet-build=y --regex-search-auto=y dev-util/github-cli`

Paquetes: `dev-util/github-cli-2.103.3`

### 2026-11-18 11:51 — `emerge --jobs=3 --load-average=12.0 --regex-search-auto=y --sync`

### 2026-11-18 11:54 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose sys-kernel/gentoo-sources`

Paquetes: `sys-kernel/gentoo-sources-7.3.5`

### 2026-11-18 12:18 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose app-portage/cpuid2cpuflags`

Paquetes: `app-portage/cpuid2cpuflags-18`

### 2026-11-18 12:19 — `emerge --newuse --update --ask --deep --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose @world`

Paquetes: `llvm-core/llvm-common-23.1.6`, `media-libs/libfreeaptx-0.1.1-r1`, `app-arch/ncompress-5.0-r2`, `media-libs/flac-1.5.0`, `dev-libs/nettle-3.10.2`, `media-fonts/urw-fonts-20230503-r1`, `media-fonts/dejavu-2.37`, `llvm-core/clang-common-23.1.6`, `dev-cpp/eigen-3.4.1-r1`, `virtual/perl-Time-Local-1.350.0-r2`, `virtual/perl-Compress-Raw-Bzip2-2.218.0`, `virtual/perl-Compress-Raw-Zlib-2.222.0-r1`, `dev-perl/Regexp-IPv6-0.30.0-r2`, `virtual/perl-MIME-Base64-3.160.100_rc-r3`, `dev-libs/nss-3.133`, `dev-perl/HTTP-Date-6.80.0`, `dev-perl/Encode-Locale-1.50.0-r1`, `dev-perl/LWP-MediaTypes-6.40.0`, `dev-perl/Try-Tiny-0.320.0`, `dev-perl/MIME-Base32-1.303.0-r1`, `dev-perl/Clone-0.470.0`, `dev-perl/IO-HTML-1.4.0`, `dev-perl/HTML-Tagset-3.240.0`, `virtual/perl-IO-Compress-2.223.0-r1`, `dev-perl/URI-5.340.0`, `dev-perl/Devel-CheckLib-1.160.0-r1`, `dev-perl/File-Listing-6.160.0`, `dev-perl/HTTP-Message-7.10.0`, `dev-perl/WWW-RobotRules-6.20.0-r2`, `dev-perl/HTML-Parser-3.830.0`, `dev-perl/HTTP-Cookies-6.110.0`, `dev-perl/HTTP-Negotiate-6.10.0-r2`, `dev-libs/libgcrypt-1.12.4`, `sys-process/psmisc-23.7`, `dev-perl/Socket6-0.290.0-r2`, `app-crypt/pinentry-1.3.3`, `dev-perl/IO-Socket-INET6-2.730.0`, `dev-perl/Net-HTTP-6.240.0`, `x11-libs/xcb-util-wm-0.4.2`, `dev-perl/libwww-perl-6.810.0`, `dev-perl/LWP-Protocol-https-6.140.0`, `dev-perl/XML-Parser-2.470.0-r1`, `dev-util/intltool-0.51.0-r3`, `dev-libs/json-c-0.19-r3`, `sys-libs/pam-1.7.3`, `dev-lang/python-3.14.10_p1`, `sys-apps/dbus-1.16.4-r1`, `sys-auth/pambase-20260730`, `sys-process/procps-4.0.6`, `x11-libs/libdrm-2.4.134`, `x11-libs/pixman-0.46.4`, `x11-libs/libxkbcommon-1.13.2`, `x11-base/xcb-proto-1.17.0`, `x11-libs/libXpm-3.5.20`, `app-misc/fastfetch-2.71.0`, `x11-libs/libXft-2.3.9`, `dev-lang/python-3.15.2_p1`, `x11-libs/libXaw-1.0.16`, `sys-apps/groff-1.25.0`, `dev-python/pyproject-metadata-0.12.1`, `media-libs/mesa-26.2.7`, `dev-python/cython-3.3.1`, `x11-libs/pango-1.58.2`, `dev-python/scikit-build-core-1.1.2`, `gui-libs/wlroots-0.20.2`, `dev-python/pybind11-3.1.0`, `gui-wm/sway-1.12-r2`, `media-video/mpv-0.42.0`, `llvm-core/llvm-23.1.6`, `llvm-core/clang-23.1.6-r1`, `llvm-runtimes/openmp-23.1.6`, `llvm-runtimes/compiler-rt-23.1.6`, `llvm-runtimes/compiler-rt-sanitizers-23.1.6`

### 2026-11-18 16:08 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --depclean`

### 2026-11-18 16:09 — `emerge --jobs=3 --load-average=12.0 --regex-search-auto=y --sync`

### 2026-11-18 16:16 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose @gaming`

### 2026-11-18 16:20 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose @gaming`

### 2026-11-18 16:20 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose @gaming`

### 2026-11-18 16:28 — `emerge --jobs=3 --load-average=12.0 --regex-search-auto=y net-vpn/tailscale`

Paquetes: `net-vpn/tailscale-1.104.5`

### 2026-11-18 16:46 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose games-util/steam-launcher`

Paquetes: `virtual/libintl-0-r2`, `virtual/libiconv-0-r2`, `sys-libs/zlib-1.4`, `media-libs/libogg-1.3.6`, `app-arch/bzip2-1.0.8-r5`, `virtual/zlib-1.3.1-r1`, `app-arch/xz-utils-5.8.4`, `dev-libs/libffi-3.8.1`, `x11-libs/libXau-1.0.12`, `media-libs/libpng-1.6.59-r1`, `x11-libs/libxshmfence-1.3.3`, `media-libs/flac-1.5.0`, `dev-libs/libpcre2-10.49`, `x11-libs/libXdmcp-1.1.5`, `dev-libs/expat-2.10.0`, `dev-libs/elfutils-0.197`, `media-libs/libvorbis-1.3.7-r2`, `net-libs/libasyncns-0.8-r5`, `media-sound/lame-3.100-r3`, `media-sound/mpg123-base-1.33.7`, `media-gfx/graphite2-1.3.14_p20210810-r5`, `dev-lang/rust-bin-1.99.0`, `media-libs/freetype-2.15.0`, `sys-apps/util-linux-2.42.4`, `virtual/libelf-3-r1`, `sys-apps/systemd-utils-262`, `virtual/libudev-257`, `media-libs/fontconfig-2.18.4`, `dev-libs/wayland-1.26.0`, `x11-libs/libdrm-2.4.134`, `media-libs/opus-1.6.1`, `sys-libs/libudev-compat-186-r1`, `games-util/game-device-udev-rules-20260625`, `dev-util/spirv-tools-1.4.363.0`, `x11-libs/libxcb-1.17.0`, `x11-libs/pixman-0.46.4`, `dev-libs/libevdev-1.14.0`, `dev-libs/glib-2.88.4`, `llvm-core/llvm-22.1.8`, `media-libs/libsndfile-1.2.2-r2`, `x11-libs/libX11-1.8.14`, `x11-libs/xcb-util-keysyms-0.4.1`, `x11-libs/extest-1.0.2`, `x11-libs/libXext-1.3.7`, `x11-libs/libXfixes-6.0.2`, `x11-libs/libXrender-0.9.13`, `media-libs/libglvnd-1.7.0`, `x11-libs/libXrandr-1.5.5`, `x11-libs/libXxf86vm-1.1.7`, `sys-process/lsof-4.99.7`, `sys-apps/dbus-1.16.4-r1`, `x11-libs/cairo-1.18.6`, `media-libs/vulkan-loader-1.4.363.0`, `virtual/opengl-8`, `media-libs/mesa-26.2.7`, `media-libs/harfbuzz-12.3.2`, `media-libs/libpulse-17.0`, `games-util/steam-launcher-1.0.0.87-r1`

### 2026-11-18 19:34 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y @gaming`

Paquetes: `dev-libs/stb-20260415-r1`, `x11-libs/libXi-1.8.4`, `x11-libs/libXcursor-1.2.3`, `acct-group/gamemode-0-r2`, `x11-libs/libXft-2.3.9`, `dev-libs/libxml2-2.15.4`, `x11-libs/libXtst-1.2.6`, `dev-libs/fribidi-1.0.16`, `media-libs/libepoxy-1.5.10-r3`, `x11-libs/libXcomposite-0.4.7`, `x11-libs/libXdamage-1.1.7`, `media-libs/glm-1.0.3`, `dev-util/vulkan-tools-1.4.363.0`, `games-util/gamemode-1.8.2`, `x11-libs/gdk-pixbuf-2.44.8`, `x11-libs/libxkbcommon-1.13.2`, `app-accessibility/at-spi2-core-2.60.7`, `x11-libs/pango-1.58.2`, `gnome-base/librsvg-2.62.4`, `x11-libs/gtk+-3.24.52`, `gui-libs/libdecor-0.2.5`, `games-util/steam-launcher-1.0.0.87-r1`, `media-libs/libsdl2-2.32.10`, `gui-wm/gamescope-3.17.0`

### 2026-11-18 20:22 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose media-libs/mesa media-libs/vulkan-loader dev-util/vulkan-tools`

Paquetes: `media-libs/vulkan-loader-1.4.363.0`, `dev-util/vulkan-tools-1.4.363.0`, `media-libs/libdisplay-info-0.4.0`, `media-libs/mesa-26.2.7`

### 2026-11-18 21:12 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y --verbose @gaming`

Paquetes: `dev-util/vulkan-tools-1.4.363.0`, `games-util/gamemode-1.8.2`, `games-util/steam-launcher-1.0.0.87-r1`, `gui-wm/gamescope-3.17.0`

### 2026-11-19 23:35 — `emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y net-vpn/tailscale`

Paquetes: `net-vpn/tailscale-1.104.5`
