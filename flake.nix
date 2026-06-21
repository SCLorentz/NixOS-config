{
description = "SCLorentz's system";

inputs = {
	home-manager = {
		url = "github:nix-community/home-manager/release-25.11";
  		inputs.nixpkgs.follows = "nixpkgs";
	};
        flake-utils.url = "github:numtide/flake-utils";
        #
	nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
	unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
	#
	hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
	zen-browser = {
		url = "github:0xc000022070/zen-browser-flake";
		inputs.nixpkgs.follows = "nixpkgs";
	};
	rust-overlay.url = "github:oxalica/rust-overlay";
};

outputs = { self, nixpkgs, flake-utils, home-manager, rust-overlay, unstable, ... }@inputs: 
let
	system = "arm64-linux";
   	pkgs = import nixpkgs {
		inherit system;
		overlays = [ rust-overlay.overlays.default ];
	};
in
{
	nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
		inherit system;
		modules = [
          	        /etc/nixos/configuration.nix
          	        /etc/nixos/hardware-configuration.nix
			home-manager.nixosModules.home-manager
			({ config, lib, ... }: {
     				 _module.args = {
        				inherit inputs;
      				};
    			})
                ];
	};
};
}

