# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/home-printer.nix
      ../../modules/xkb-wsh.nix
      ../../modules/fastdds.nix
      ../../modules/ydotool.nix
    ];

  #services.emacs.package = pkgs.emacsGcc;
  nixpkgs.overlays = [
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 2;

  #boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_0;

  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 card_label="OBS Cam" exclusive_caps=1
    # video_nr=10 (breaks visibility in MS Teams)
  '';
  boot.kernelModules = [
    "v4l2loopback"
  ];

  boot.binfmt.emulatedSystems = [ "armv7l-linux" "aarch64-linux" ];

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

  networking.wireguard.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "cs_CZ.UTF-8";
  i18n.supportedLocales =  [ "en_US.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8" "cs_CZ.UTF-8/UTF-8" ];

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  system.autoUpgrade = {
    enable = true;
    flake = "/home/wsh/nix/conf";
    flags = [ "--update-input" "nixpkgs-stable" ];
    randomizedDelaySec = "30min";
  };
  systemd.services.nixos-upgrade.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "1min";
  };

  nix = {
    settings = {
      max-jobs = 16;
      trusted-public-keys = [
        "wsh-ritchie-1:cf+FhlpvnmqrTWKrGMuQo6oQVKFHckDPAWt6oOms7kE="
      ];
      trusted-users = [ "root" "wsh" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    distributedBuilds = true;
#    buildMachines = [ {
#      hostName = "ritchie";
#      system = "x86_64-linux";
#      sshKey = "/root/.ssh/nix_remote";
#      sshUser = "sojka";
#      maxJobs = 10;
#	    speedFactor = 2;
#	    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
#	    mandatoryFeatures = [ ];
#    } ];
	  extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config = {
    #allowUnfree = true;
    allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
      "skypeforlinux"
      "mfcl2700dwlpr"
      "brscan4" "brscan4-etc-files" "brother-udev-rule-type1"
      "steam"
      "steam-original"
      "steam-run"

      "saleae-logic"
      "slack"
      "teams"
      "unrar"
      "xkcd-font"
      "zoom-us" "faac" "zoom" # zoom-us is now just zoom
    ];
  };

  programs.steam.enable = true;
  programs.nix-ld.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (import ./emacs.nix { inherit pkgs; })
    btrfs-progs
    compsize
    chromium
    file
    firefox-wayland
    gdu
    gitAndTools.gitAnnex lsof
    gitAndTools.gitFull
    htop
    iftop
    krita
    gwenview
    shotwell
    libreoffice-fresh
    mc
    nix-output-monitor
    ncdu
    nvtop-amd
    obs-studio
    pciutils
#    (shotcut.overrideAttrs ({ patches ? [], ...}: {
#      patches = patches ++ [ ../../nixpkgs/pkgs/applications/video/shotcut/0001-Don-t-use-connection_type-x11-for-VAAPI-HW-accelerat.patch ];
 #   }))
    skypeforlinux
    tree
    vim
    wget
    gnome.gnome-tweaks
  ];

  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      slack = "${pkgs.slack}/bin/slack";
      teams = "${pkgs.teams}/bin/teams";
      #zoom-us = "${pkgs.zoom-us}/bin/zoom-us";
      skypeforlinux = "${pkgs.skypeforlinux}/bin/skypeforlinux";
    };
  };

  programs.sway = {
    enable = true;
    extraSessionCommands = ''
      PATH=$HOME/bin:$PATH
    '';
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
  };
  # xdg.portal = {
  #   enable = true;     # Screen sharing under sway
  #   # gtk portal needed to make gtk apps happy
  #   extraPortals = lib.mkForce [ # override nixos/modules/services/x11/desktop-managers/gnome.nix
  #     # gnome portal breaks things in sway (https://github.com/swaywm/sway/wiki#gtk-applications-take-20-seconds-to-start)
  #     # we still want gnome apps, but don't care about working gnome desktop
  #     #pkgs.xdg-desktop-portal-gnome
  #     pkgs.xdg-desktop-portal-gtk
  #   ];
  # };
  
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    noto-fonts
    liberation_ttf
  ];

  environment.homeBinInPath = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.wsh = import ./home.nix;

  documentation = {
    enable = true;
    man.enable = true;
    #man.generateCaches = true;
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

  services.nixseparatedebuginfod.enable = true;

  services.avahi = {
    publish = {
      enable = true;
      addresses = true; # Enable finding this computer via <hostname>.local
    };
  };

  services.syncthing = {
    enable = true;
    dataDir = "/home/share/sync";
    openDefaultPorts = true;
  };

  services.nginx = {
    enable = true;
    virtualHosts.localhost = {
      listen = [{ addr = "127.0.0.1"; }];
      locations."/~wsh/" = {
        alias = "/srv/www/wsh/";
      };
    };
  };
  systemd.services.nginx.serviceConfig.ProtectHome = false;

  # Make my public_html accessible by default. It's not accessible
  # directly from $HOME, because the $HOME has permissions 0700 and
  # nginx runs under a different user.
  fileSystems."/srv/www/wsh" = { options = [ "bind" ]; device = "/home/wsh/public_html"; };

  services.fwupd.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
    };
  };

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
  networking.firewall.enable = false;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  services.gpm.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  services.xserver.windowManager.i3.enable = true;
  services.xserver.desktopManager.gnome.enable = true;


  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # This prevents immediate wakeup after suspend
  systemd.services.disable-wakeup = {
    script = ''
      for dev in GPP0 SWUS; do
        if grep -q "^$dev\>.*enabled" /proc/acpi/wakeup; then
          echo $dev > /proc/acpi/wakeup
        fi
      done
    '';
    wantedBy = [ "multi-user.target" ];
  };

  networking.interfaces.eno1.wakeOnLan.enable = true;

  services.nullmailer = {
    enable = true;

    config = {
      adminaddr = "ms@2x.cz";
      defaultdomain = "2x.cz";
      me = "resox.2x.cz";
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false; # use socket activation

  services.flatpak.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wsh = {
    description = "Michal";
    isNormalUser = true;
    extraGroups = [ "adbusers" "dialout" "docker" "networkmanager" "scanner" "wheel" ];
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
