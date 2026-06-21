{ config, pkgs, lib, ... }:
let
  nix-software-center = import (pkgs.fetchFromGitHub {
    	owner = "snowfallorg";
    	repo = "nix-software-center";
    	rev = "0.1.2";
    	sha256 = "xiqF1mP8wFubdsAQ1BmfjzCgOD3YZf7EGWl9i69FTls=";
  }) {};
  dotfiles = ./dotfiles;

  listRecursive = path:
    let
      entries = builtins.readDir path;
    in
      lib.flatten (lib.mapAttrsToList (name: type:
        let
          fullPath = "${path}/${name}";
        in
          if type == "directory"
          then listRecursive fullPath
          else [{
            source = fullPath;
            target = builtins.toString (lib.removePrefix "${toString dotfiles}/" (toString fullPath));
          }]
      ) entries);

  etcFiles = listRecursive dotfiles;

  etcMapped = builtins.listToAttrs (map (entry: {
    name = "xdg/${entry.target}";
    value.source = entry.source;
  }) etcFiles);

  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
  imports = [
	#<home-manager/nixos>
	#inputs.home-manager
	./modules/system.nix
	./modules/programs.nix
  ];

  nix.settings.experimental-features = [
  	"nix-command"
	"flakes"
  ];

  nix.settings = {
  	max-jobs = 1;
  	keep-derivations = false;
  	keep-outputs = false;
  	auto-optimise-store = true;
  	substituters = [
  	  	"https://cache.nixos.org"
  	  	"https://hyprland.cachix.org"
  	];
  	trusted-public-keys = [
  	  	"cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  	  	"hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  	];
  };

  nixpkgs.config = {
  	flake.setDirty = false;
  	pulseaudio = true;
  	allowUnfree = true;
    	packageOverrides = pkgs: {
      		unstable = import unstableTarball {
        		config = config.nixpkgs.config;
      		};
    	};
  };

  fonts = {
    	enableDefaultPackages = true;

    	fontconfig = {
			enable = true;
			defaultFonts = {
			monospace = [
				"Fira Code"
				"JetBrainsMono Nerd Font Mono"
			];
        		sansSerif = [ "Fira Code" "Roboto" ];
		};
  	};

    	packages = with pkgs; [
      		nerd-fonts.jetbrains-mono
		fira-code
		roboto
    	];
  };

  services = {
    	pipewire = {
      		enable = true;
      		alsa = {
        		enable = true;
        		support32Bit = true;
      		};
      		pulse.enable = true;
      		jack.enable = true;
    	};
    	displayManager = {
      		defaultSession = "hyprland-uwsm";
		sddm = {
      			enable = true;
      			theme = "sugar-dark";
      			package = pkgs.libsForQt5.sddm;
			wayland.enable = true;
    		};
    	};
    	libinput.enable = true;
    	printing.enable = true;
  };

  security.rtkit.enable = true;

  users.users.sclorentz = {
    	isNormalUser = true;
    	description  = "Felipe Lorentz";
    	extraGroups  = [
		"networkmanager"
		"wheel"
		"kvm"
		"libvirtd"
	];
  };

  home-manager.users.sclorentz = {
	home.stateVersion = "25.05";
  };

  xdg.mime.defaultApplications = {
    	"text/*" = "zed.desktop";
    	"application/x-zerosize" = "zed.desktop";
    	"application/xhtml+xml" = "zen.desktop";
    	"application/pdf" = "zen.desktop";
    	"x-scheme-handler/https" = "zen.desktop";
    	"x-scheme-handler/http" = "zen.desktop";
    	"x-scheme-handler/ftp" = "zen.desktop";
    	"inode/directory" = "nemo.desktop";
    	"x-directory/normal" = "nemo.desktop";
  };

  xdg.portal = {
    	enable = true;
    	extraPortals = with pkgs; [
      		pkgs.xdg-desktop-portal-gtk
      		kdePackages.xdg-desktop-portal-kde
      		xdg-desktop-portal-hyprland
    	];
    	configPackages = [ pkgs.gtk3 pkgs.qt6.qtbase ];
    	config.hyprland.preferred = [ "hyprland" "gtk" ];
    	config.common.default = "*";
  };

  xdg.icons.enable = true;
  xdg.menus.enable = true;

  disabledModules = [ "services/mako.nix" ];

  system.stateVersion = "25.05";
}
