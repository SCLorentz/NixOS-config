{config, pkgs, lib, inputs, ... }:
with lib; let
	#rio = import ./rio/rio.nix { inherit pkgs; };
	hyprPluginPkgs = inputs.hyprland-plugins.packages.${pkgs.system};
  	hypr-plugin-dir = pkgs.symlinkJoin {
  	  	name = "hyrpland-plugins";
  	  	paths = with hyprPluginPkgs; [
  	  	  	hyprexpo
  	  	];
  	};
in
{
nix.gc = {
	automatic = true;
	dates = "weekly";
	options = "--delete-older-than 14d";
};

nixpkgs.overlays = [
    	(final: prev: {
      		hyprland = prev.hyprland.overrideAttrs (old: {
        		NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -O2 -march=native -mtune=native -flto";
     		});
    	})
];

security.sudo-rs.enable = true;

programs = {
	fish.enable = true;

	hyprlock.enable = true;
	hyprland = {
		enable = true;
		withUWSM = true;
		xwayland.enable = true; # Xorg compat.
	};

	#steam = {
	#	enable = true;
	#	gamescopeSession.enable = true;
	#	remotePlay.openFirewall = true;
	#	dedicatedServer.openFirewall = true;
	#};

	gamemode.enable = true;
	gamescope.enable = true;
	neovim.enable = true;

	git = {
		enable = true;
		lfs.enable = true;
	};
};

environment.variables = {
	# --- GTK
	GTK_ICON_THEME = "Papirus";
	GTK_THEME = "Orchis-Dark";
	GTK_CSD = "1";
	GDK_BACKEND = "wayland,x11,*";
	GTK_APPLICATION_PREFER_DARK_THEME = "1";
	# -- Hyprland
	HYPRCURSOR_THEME="rose-pine-hyprcursor";
	HYPRCURSOR_SIZE = "32"; # def: 24
	HYPRLAND_EXTRA_CONF = "/etc/nixos/hyprland.conf";
	#HYPR_PLUGIN_DIR = hypr-plugin-dir;
	# --- fixes & compatibility
	# -- QT
	QT_STYLE_OVERRIDE = lib.mkForce null;
	QT_QPA_PLATFORM = "wayland";
	QT_QPA_PLATFORMTHEME = "qt6ct";
	QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
	QT_AUTO_SCREEN_SCALE_FACTOR = "1";
	# -- Moz
	MOZ_ENABLE_WAYLAND = "1";
	MOZ_USE_XINPUT2 = "1";
	MOZ_WEBRENDER = "1";
	# -- XDG
	XDG_CURRENT_DESKTOP = "Hyprland";
	XDG_SESSION_DESKTOP = "Hyprland";
	XDG_SESSION_TYPE = "wayland";
	# -- Other
	ELECTRON_OZONE_PLATFORM_HINT="wayland";
	CLUTTER_BACKEND = "wayland";
	WLR_NO_HARDWARE_CURSORS = "1";
	PYGOBJECT_DISABLE_DIAGNOSTIC = "1";
	NEMO_DISABLE_STARTUP_CHECK = "1";
	WINEDLLOVERRIDES = "winemenubuilder.exe=d";
	KWIN_DRM_PREFER_COLOR_DEPTH = "24";
	EDITOR = "nvim";
};

users.defaultUserShell = pkgs.fish;

services = {
	blueman.enable = true;
	upower.enable = true;
};

hardware = {
	bluetooth.enable = true;
	graphics.enable = true;
};

nixpkgs.config.qt6 = {
	enable = true;
	platformTheme = "qt6ct";
	style = {
		package = pkgs.utterly-nord-plasma;
		name = "Utterly Nord Plasma";
	};
	cursorTheme = "default";
};

environment.systemPackages = with pkgs; [
	# --- Shell ---
	unstable.rio		# <<- wGPU based terminal emulator
	nixos-generators	# <<- iso generator
	nix-prefetch-github	# <<- get sha256 from git repo
	android-tools		# <<- adb, connect phone
	duf			# <<- drive used space viewer
	eza			# <<- ls replacement
	bat			# <<- cat replacement
	neofetch		# <<- system info
	sutils
	fzf
	fishPlugins.fzf
	fishPlugins.sponge
	fishPlugins.puffer
	fishPlugins.plugin-sudope
	fishPlugins.done
	fishPlugins.autopair
	fishPlugins.async-prompt
	# --- bloatware ---
	bluetui
	signal-desktop
	# -- themes --
	sddm-sugar-dark		# <<- (KDE) DM theme
	adwaita-icon-theme
	orchis-theme
	papirus-icon-theme
	rose-pine-hyprcursor 	# <<- hyprcursor
	# --- defaults ---
	process-viewer
	feh			# <<- simple image viewer
	webcamoid		# <<- camera app
	file-roller 		# <<- GTK zip extractor
	inputs.zen-browser.packages."${system}".beta	# <<- Zen browser
	# -- nemo ("explorer") --
	nemo			# <<- GTK file browser
	nemo-fileroller 	# <<- zip integration
	nemo-preview
	nemo-emblems
	# --- Dev ---
	vulkan-loader
	libxkbcommon
    	mesa
	# --- sys ---
	#appmenu-gtk-module
 	#appmenu-qt
	# -- Qt --
	qt5.qtquickcontrols2
	qt5.qtgraphicaleffects
	qt5.qtquickcontrols
	qt5.qtbase
	qt5.qtsvg		# <<- support for SVGs
	qt5.qtdeclarative
	qt5.qtgraphicaleffects
	qt5.qtwayland		# <<- wayland compatibility
	libsForQt5.qtstyleplugin-kvantum
	qt6.qtwayland		# <<- wayland compatibility
	# --- WM & SystemUI ---
	(import ./RsBar/RsBar.nix { inherit pkgs; }) # <<- Lateral Menu Bar
	# -- Hyprland --
	hyprpaper		# <<- wallpaper engine
	hyprsysteminfo		# <<- hyprland info
	hyprcursor
	nwg-drawer		# <<- app launcher
	sysmenu
	brightnessctl
	grim
	pamixer
	playerctl
	brightnessctl		# <<- brightness managment
	pavucontrol
	wttrbar
	cliphist		# <<- clipboard managment
	xdg-desktop-portal-hyprland
	satty			# <<- screenshot and annotation tool
	hyprpicker		# <<- color picker tool
	starship
	# --- libs & dependencies ---
	ffmpeg			# <<- image & video lib
	libva
	imagemagick		# <<- image editor
	wireplumber
	libgtop
	bluez
	networkmanager
	dart-sass
	wl-clipboard
	gvfs
	swww
	v4l-utils		# <<- debug
	pulseaudioFull
	gtksourceview3
	hyprland-qtutils
	power-profiles-daemon
	dunst			# <<- notifications
	swayosd			# <<- shows popup for actions
	openssl
];
}

