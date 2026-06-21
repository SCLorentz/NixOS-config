{ config, pkgs, lib, ... }
{
  systemd.tmpfiles.rules = [
    	"d /dev/binderfs 0755 root root -"
    	"f /dev/binderfs/binder 0666 root root -"
    	"f /dev/binderfs/hwbinder 0666 root root -"
    	"f /dev/binderfs/vndbinder 0666 root root -"
  ];
  fileSystems."/dev/binderfs" = {
    	fsType = "binder";
    	device = "binderfs";
    	options = [ "bind" ];
  };
  virtualisation.waydroid.enable = true;

  systemd.user.services.waydroid-session = {
    	wantedBy = [ "graphical-session.target" ];
    	after = [ "graphical-session.target" ];
    	serviceConfig = {
    	  	ExecStart = "${pkgs.waydroid}/bin/waydroid session start";
    	  	Restart = "on-failure";
    	};
  };

  systemd.services."waydroid-set-props" = {
    	wantedBy = [ "multi-user.target" ];
    	after = [ "waydroid-container.service" ];
    	serviceConfig = {
    	  	Type = "oneshot";
    	  	ExecStart = pkgs.writeShellScript "set-waydroid-props" ''
    	  	${pkgs.waydroid}/bin/waydroid prop set persist.waydroid.multi_windows true
    	  	${pkgs.waydroid}/bin/waydroid prop set persist.sys.nativebridge 1
    	  	${pkgs.waydroid}/bin/waydroid prop set ro.hardware ranchu
    	  	'';
    	};
  };

  environment.systemPackages = with pkgs; [
    	waydroid
    	gst_all_1.gstreamer
    	gst_all_1.gst-plugins-base
    	gst_all_1.gst-plugins-good
    	gst_all_1.gst-plugins-bad
    	gst_all_1.gst-plugins-ugly
    	gst_all_1.gst-libav
    	pulseaudio
  ];
}
