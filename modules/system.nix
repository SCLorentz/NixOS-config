{ config, pkgs, lib, ... }:
let
  inherit (lib) concatStringsSep mkDefault mkIf mkOption types pipe;
  currentZfs = config.boot.zfs.package;
in
{
  networking = {
		hostId = "deadbeef";
    	hostName = "nixos";
    	networkmanager.enable = true;
  };

  time.timeZone = "America/Sao_Paulo";
  console.keyMap = "br-abnt2";

  zramSwap.enable = true;
  zramSwap.memoryPercent = 85;
  zramSwap.algorithm = "zstd";
  virtualisation.libvirtd.enable = true;

  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true;
  services.auto-cpufreq.enable = true;
  services.seatd.enable = true;

  environment.systemPackages = with pkgs; [ policycoreutils ];
  systemd.package = pkgs.systemd.override { withSelinux = true; };

  boot = {
	loader = {
	  	systemd-boot.enable = true;
	 	systemd-boot.editor = false;
	  	systemd-boot.configurationLimit = 5;
	  	efi.canTouchEfiVariables = true;
	  	timeout = 0;
	  	grub = {
     		efiSupport = true;
     		device = "nodev";
  		};
	};

	kernelPatches = [ {
        name = "selinux-config";
        patch = null;
        extraConfig = ''
            SECURITY_SELINUX y
            SECURITY_SELINUX_BOOTPARAM n
            SECURITY_SELINUX_DISABLE n
            SECURITY_SELINUX_DEVELOP y
            SECURITY_SELINUX_AVC_STATS y
            SECURITY_SELINUX_CHECKREQPROT_VALUE 0
            DEFAULT_SECURITY_SELINUX n
        '';
    }];

	zfs = {
	  	requestEncryptionCredentials = true;
	  	devNodes = "/dev/disk/by-uuid";
	  	#extraPools = [ "rpool" ];
	};

	supportedFilesystems = [ "zfs" "ntfs" "exfat" "btrfs" ];
	kernelModules = [
		"uvcvideo"	# <<- usb camera driver
		"videodev"	# <<- kernel video base
		"media"		# <<- generic media driver
		"snd-usb-audio"
	  	"cdc_ether"	# <<- 4G share via USB-A
		"snd-hda-intel"
		"kvm-intel" 	# <<- support for virtualization
	  	"kvm-amd"
	  	"zfs"		# <<- z file system
	  	"btrfs"
	  	"binder"
	  	"binderfs"
	  	"ashmem_linux"
	  	"vboxdrv"	# <<- virtual box optimizations
	  	"usbnet"	# <<- share internet with USB
	  	"wireguard" 	# <<- kernel level vpn
	  	"v4l2loopback"	# <<- virtual camera
	  	"overlaysfs"	# <<- container base
	  	"kyber"		# <<- SSD manager
	  	"hid-sony"	# <<- gaming with sony
	  	"hid_steam"	# <<- gaming with steam/xbox
	  	"hid_nintendo"	# <<- gaming with nintendo<LeftMouse>
	];
	initrd.supportedFilesystems = [ "zfs" ];
	initrd.systemd.enable = true;

	consoleLogLevel = 0;
	kernelParams = [
		"i915.enable_psr=0" 
		"quiet"
		"udev.log_level=3"
		"rd.systemd.show_status=false"
		"rd.udev.log_level=3"
		"splash"
		"zswap.enabled=1"
		"zswap.compressor=lz4"
 		"zswap.max_pool_percent=20"
  		"zswap.shrinker_enabled=1"
		"plymouth.ignore-serial-consoles"
		"vt.global_cursor_default=0"
		"vt.default_vt=7"
		"pcie_aspm=force"
  		"intel_iommu=on"
		"intel_pstate=active"
  		"nvme.noacpi=1" 
	];
	initrd.verbose = false;

	extraModulePackages = with config.boot.kernelPackages; [
		v4l2loopback
	];
  };

  console.earlySetup = true;

  security.lsm = [
  	"landlock"
	"lockdown"
	"yama"
	"integrity"
	"selinux"
	"bpf"
  ];

  services = {
	zfs = {
	  	autoScrub.enable = true;
	  	autoSnapshot.enable = true;
	};
  };
}
