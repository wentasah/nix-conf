# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/home-printer.nix
    ];

  # # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  # boot.loader.grub.enable = false;
  # # Enables the generation of /boot/extlinux/extlinux.conf
  # boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.grub = {
    gfxmodeBios= "auto";
    gfxpayloadBios="keep";
    devices = [
      "/dev/disk/by-id/wwn-0x5000c5001eb74fa9"
      "/dev/disk/by-id/wwn-0x50015179594cb6d4"
    ];
    #default = 1; # Debian
    extraEntries = ''
      menuentry "Debian" {
	        insmod part_gpt
          search --set=debian --fs-uuid d14e491e-4f2e-4617-8963-9cd76c555d66
          configfile "($debian)/boot/grub/grub.cfg"
      }
      '';
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 card_label="OBS Cam" exclusive_caps=1
    # video_nr=10 (breaks visibility in MS Teams)
  '';
  boot.kernelModules = [
    "v4l2loopback"
  ];

  networking.hostName = "resox"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #networking.interfaces.enp2s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "cs_CZ.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  system.autoUpgrade.enable = true;
  system.autoUpgrade.randomizedDelaySec = "30min";
  systemd.timers.nixos-upgrade.timerConfig.Persistent = true;
  systemd.services.nixos-upgrade.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "1min";
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
      #persistent = true; # Enable for 21.05
    };

    distributedBuilds = true;
    buildMachines = [ {
      hostName = "ritchie";
      system = "x86_64-linux";
      sshKey = "/root/.ssh/nix_remote";
      sshUser = "sojka";
	    speedFactor = 2;
	    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
	    mandatoryFeatures = [ ];
    } ];
	  # optional, useful when the builder has a faster internet connection than yours
	  extraOptions = ''
      builders-use-substitutes = true
    '';
  };

  nixpkgs.config = {
    #allowUnfree = true;
    allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
      "skypeforlinux"
      "mfcl2700dwlpr"
      "brscan4" "brscan4-etc-files" "brother-udev-rule-type1"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (import ./emacs.nix { inherit pkgs; })
	  home-manager
    chromium
    firefox-wayland
    gitAndTools.gitAnnex lsof
    gitAndTools.gitFull
    krita
    libreoffice-fresh
    mc
    ncdu
    obs-studio
    skypeforlinux
    tree
    vim
    wget
  ];

  environment.homeBinInPath = true;

  documentation = {
    enable = true;
    man.enable = true;
    info.enable = true;
    doc.enable = true;
    dev.enable = true;
    nixos.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };
  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      bindkey -e
    '';
  };

  # List services that you want to enable:

  services.avahi = {
    publish = {
      enable = true;
      addresses = true; # Enable finding this computer via <hostname>.local
    };
  };

  services.fwupd.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh = {
    startAgent = true;
    agentTimeout = "24h";
  };

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  hardware.opengl = {
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    driSupport = true;
  };

  services.gpm.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  services.xserver.videoDrivers = [ "amdgpu" ];
#  services.xserver.videoDrivers = [ "amdgpu-pro" ];
  services.xserver.windowManager.i3.enable = true;
  services.xserver.desktopManager.gnome.enable = true;


  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wsh = {
    description = "Michal";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "scanner" ]; # Enable ‘sudo’ for the user.
    uid = 1000;
    shell = pkgs.zsh;
  };

  users.users.lucka = {
    description = "Lucka";
    isNormalUser = true;
    extraGroups = [ "scanner" ];
    uid = 1001;
  };

  users.users.tom = {
    description = "Tomáš";
    isNormalUser = true;
    extraGroups = [ "scanner" ];
  };

  users.users.miki = {
    description = "Miki";
    isNormalUser = true;
    extraGroups = [ "scanner" ];
    uid = 1004;
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}


# Local Variables:
# compile-command: "nixos-rebuild switch"
# End:
