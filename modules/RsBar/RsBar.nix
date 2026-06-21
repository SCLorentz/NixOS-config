{ pkgs ? import <nixpkgs> {} }:

pkgs.rustPlatform.buildRustPackage rec {
  	pname = "RsBar";
  	version = "0.1.0";

  	src = pkgs.fetchFromGitHub {
  	  	owner = "Iprime111";
  	  	repo = "RsBar";
  	  	rev = "aeafb48f3266762e746bf7f24a022f087e1fa4fe";
  	  	sha256 = "sha256-wi8hHwE3rinKnzMS+78JKDheSLpnQROTBu/1SI+mLV4=";
  	};

  	cargoLock.lockFile = ./Cargo.lock;

  	cargoBuildFlags = [
  	    "--bin" "rsbar"
  	    "--bin" "rsbar-daemon"
  	];
  	cargoBuildProfile = "release";

  	nativeBuildInputs = [ pkgs.pkg-config ];
  	buildInputs = with pkgs; [
  		glib
		gtk4
  		gcc
  	    	pkg-config
  	    	cairo
  	    	graphene
  	    	gtk4-layer-shell
  	];

  	meta = with pkgs.lib; {
  	  	description = "rsbar + rsbar-daemon em Rust";
  	  	license = licenses.mit;
  	  	maintainers = [ ];
  	  	platforms = platforms.linux;
  	};
}
