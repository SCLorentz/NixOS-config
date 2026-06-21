{ pkgs }:

pkgs.rustPlatform.buildRustPackage rec {
	pname = "rio_term";
	version = "0.2.30";

	src = pkgs.fetchFromGitHub {
		owner = "raphamorim";
		repo = "rio";
		rev = "af14ba69b64335894cafa21cfd0a352fc9fa52cc";
		sha256 = "sha256-wM6SxwtF0Zywb0LZqjDaO8BrPymGenjHTA+GTjKiEC0=";
	};

	cargoLock.lockFile = ./Cargo.lock;

	#RUSTFLAGS = lib.concatStringsSep " " [
    	#	"-C target-cpu=native"
    	#	"-C opt-level=3"
    	#	"-C lto=yes"
    	#	"-C codegen-units=1"
	#];

	cargoBuildFlags = [
		"--no-default-features"
		#"--features=wayland,audio"
		"--features=wayland"
	];

	cargoBuildProfile = "release";
	buildInputs = with pkgs; [
		fontconfig
        	libGL
        	libxkbcommon
        	vulkan-loader
		wayland
	];

	nativeBuildInputs = [ pkgs.rust-bin.stable.latest.default ];

	meta = with pkgs.lib; {
		description = "rio terminal emulator";
		homepage = "https://github.com/raphamorim/rio";
		license = licenses.mit;
		platforms = platforms.linux;
	};
}
