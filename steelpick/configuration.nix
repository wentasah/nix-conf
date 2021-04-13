# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let myOverlay = self: super:
      rec {
        # Fix Teams screen sharing on i3wm
        # https://docs.microsoft.com/en-us/answers/questions/42095/sharing-screen-not-working-anymore-bug.html
#        teams = super.teams.overrideAttrs (attr: {
#           postFixup = attr.postFixup + ''
#             mv $out/opt/teams/resources/app.asar.unpacked/node_modules/slimcore/bin/rect-overlay{,.bak}
#           '';
#        });
      };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/home-printer.nix
    ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
        "skypeforlinux"
        "slack"
        "teams"
        "zoom-us" "faac" "zoom" # zoom-us is now just zoom
        "teamviewer"
        "brscan4" "brscan4-etc-files" "brother-udev-rule-type1"
        "mfcl2700dwlpr"
        "Oracle_VM_VirtualBox_Extension_Pack"
      ];
    };
    overlays = [ myOverlay ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  #boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.kernelPackages = pkgs.linuxPackages_5_9;
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 card_label="OBS Cam" exclusive_caps=1
    # video_nr=10 (breaks visibility in MS Teams)
  '';
  boot.kernelModules = [
    "v4l2loopback"
  ];

  networking.hostName = "steelpick"; # Define your hostname.
  networking.domain = "2x.cz";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # networking.interfaces.enp0s31f6.useDHCP = true;
  # networking.interfaces.wlp1s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.extraHosts = ''
    10.35.95.3 ritchie
    10.35.95.4 optim
    10.35.0.32 ritchie-bmc
    10.35.0.31 optim-bmc
  '';

  systemd = {
    enableUnifiedCgroupHierarchy = false; # breaks DEmOS
    extraConfig = ''
      DefaultTimeoutStopSec=30  # Don't block reboot for too long
    '';

#     sockets.tftpd = {
#       description = "TFTP server socket";
#       listenDatagrams = [ "69" ];
#       wantedBy = [ "sockets.target" ];
#     };
    services.tftpd = {
      description = "TFTP server";
      #requires = [ "tftpd.socket" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.tftp-hpa}/bin/in.tftpd --listen --foreground --secure --verbose /srv/tftp";
        #StandardInput = "socket";
      };
    };

  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  environment.variables.EDITOR = "vim";

  documentation.dev.enable = true;
  documentation.man.generateCaches = true;

  environment.extraOutputsToInstall = [ "man" "info" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    binutils-unwrapped # for strings etc.
    dash # TODO: Try is as /bin/sh (environment.binsh)
    emacs-nox
    file
    gitAndTools.gitFull
    gnumake
    home-manager
    htop
    lsof
    mc
    ncdu
    tftp-hpa
    tree
    vim
    wget
    elinks
    stlink
    glibcInfo
    ddrescue
    zoom-us
    cntr
  ];

  environment.homeBinInPath = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  programs.zsh.enable = true;

  programs.ssh.startAgent = true;

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

  programs.adb.enable = true;

  virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;

  # List services that you want to enable:

  #services.teamviewer.enable = true;

  #services.jack.jackd.enable = true;

  # Add pam limits for jack without starting jack at boot (copied from
  # jack.nix module)
  security.pam.loginLimits = [
    { domain = "@jackaudio"; type = "-"; item = "rtprio"; value = "99"; }
    { domain = "@jackaudio"; type = "-"; item = "memlock"; value = "unlimited"; }
  ];
  users.groups.jackaudio = {};

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.gpm.enable = true;

  services.udev.packages = [ pkgs.stlink ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.interfaces.enp0s31f6.allowedUDPPorts = [ 69 ]; # TFTP
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  networking.wireguard.enable = true;

  services.flatpak.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  hardware.opengl.extraPackages = with pkgs; [ intel-compute-runtime ];

  services.locate = {
    enable = true;
    locate = pkgs.mlocate;
    localuser = null;
  };

  services.nullmailer = {
    enable = true;

    config = {
      adminaddr = "ms@2x.cz";
      defaultdomain = "2x.cz";
      me = "steelpick.2x.cz";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts.localhost = {
      listen = [{ addr = "127.0.0.1"; }];
      locations."/~wsh/" = {
        alias = "/home/wsh/public_html/";
      };
    };
  };

  systemd.services.nginx.serviceConfig.ProtectHome = false;

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    wacom.enable = true;
    # services.xserver.layout = "us";
    # services.xserver.xkbOptions = "eurosign:e";
  };

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  #services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  services.autorandr.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  users.users = {
    wsh = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "docker" "dialout" "scanner" "lp" "jackaudio" "adbusers" "vboxusers" ];
      uid = 1000;
      group = "wsh";
      shell = pkgs.zsh;
    };
    gitea = {
      isNormalUser = true;
      uid = 1002;
      packages = [ pkgs.gitea ];
    };
    novaboot-test = {
      isNormalUser = true;
      uid = 1003;
      shell = "/home/wsh/src/novaboot/server/novaboot-shell";
    };
  };

  security.sudo = {
    enable = true;
    extraConfig = ''
    wsh  ALL=(novaboot-test) NOPASSWD: ALL
    wsh  ALL=NOPASSWD: /run/current-system/sw/bin/modprobe/modprobe vboxdrv
    '';
  };

  users.groups = { wsh = { gid = 1000; }; };

  nix.trustedUsers = [ "root" "@wheel" ];
#   nix.nixPath = [
#     "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
#     "nixos-config=/etc/nixos/configuration.nix"
#     "/nix/var/nix/profiles/per-user/root/channels"
  #   ];
  nix.buildMachines = [ {
    hostName = "ritchie";
    system = "x86_64-linux";
    # if the builder supports building for multiple architectures,
    # replace the previous line by, e.g.,
    # systems = ["x86_64-linux" "aarch64-linux"];
    maxJobs = 10;
    speedFactor = 2;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
  } ];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
    persistent = true;
  };

  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?

}

# Local Variables:
# compile-command: "sudo -A nixos-rebuild switch"
# End:
