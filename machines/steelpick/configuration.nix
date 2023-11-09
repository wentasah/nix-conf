# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  myOverlay = self: super:
    rec {
      #i3 = import ../../pkgs/i3 { pkgs = super; };
    };
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/home-printer.nix
      ./novaboot.nix
      ../../modules/tftpd-hpa.nix
      ../../modules/fastdds.nix
      ../../modules/xkb-wsh.nix
      ../../modules/qt5.nix
      ../../modules/ydotool.nix
      #../../modules/greetd.nix
    ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "skypeforlinux"
        "slack"
        "zoom-us"
        "faac"
        "zoom" # zoom-us is now just zoom
        "teamviewer"
        "brscan4"
        "brscan4-etc-files"
        "brother-udev-rule-type1"
        "mfcl2700dwlpr"
        "Oracle_VM_VirtualBox_Extension_Pack"
        "kyocera-phase5"
        "konica-minolta-bizhub"
        "saleae-logic"
        "saleae-logic-2"
        "unrar"
        "xkcd-font"
      ];
      permittedInsecurePackages = [
        "zotero-6.0.27"
      ];
    };
    overlays = [ myOverlay ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  #boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = [
    #{ name = "can-isotp-poll"; patch = ../../pkgs/linux/0001-can-isotp-fix-poll-to-not-report-false-positive-EPOL.patch; }
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 card_label="OBS Cam" exclusive_caps=1
    # video_nr=10 (breaks visibility in MS Teams)
  '';
  boot.kernelModules = [
    "v4l2loopback"
  ];

  boot.kernel.sysctl = {
    "kernel.perf_event_paranoid" = 0; # Enable perf for non-root
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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
    #enableUnifiedCgroupHierarchy = false; # true breaks demos-sched
    enableUnifiedCgroupHierarchy = lib.mkForce true; # override LXD to test DEmOS
    extraConfig = ''
      # Don't block reboot for too long
      DefaultTimeoutStopSec=30
    '';

#     sockets.tftpd = {
#       description = "TFTP server socket";
#       listenDatagrams = [ "69" ];
#       wantedBy = [ "sockets.target" ];
#     };
  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8" "cs_CZ.UTF-8/UTF-8" ];
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  # time.timeZone = "Europe/Prague";
  services.automatic-timezoned.enable = true;
  services.geoclue2.enableDemoAgent = lib.mkForce true;

  fonts.enableGhostscriptFonts = true;

  environment.variables.EDITOR = "vim";

  documentation.dev.enable = true;
  #documentation.man.generateCaches = true;

  environment.extraOutputsToInstall = [ "man" "info" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    binutils-unwrapped # for strings etc.
    compsize
    dash # TODO: Try is as /bin/sh (environment.binsh)
    emacs-nox
    file
    gitAndTools.gitFull
    gnumake
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
    gnome.nautilus-python
    glibcInfo
    psmisc
    ddrescue
    zoom-us
    cntr
    ripgrep
    ntfs3g
    tcpdump
  ];

  environment.homeBinInPath = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.wsh = import ./home.nix;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  programs.zsh.enable = true;

  programs.command-not-found.enable = false; # the same functionality is handled by nix-index-database
  programs.nix-index-database.comma.enable = true;

#   programs.zsh.interactiveShellInit = ''
#     source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
#   '';
#   programs.bash.interactiveShellInit = ''
#     source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
#   '';
  # Enable starship for other users
  programs.bash.promptInit = ''
    if [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "vterm") ]]; then
      export STARSHIP_CONFIG=/home/wsh/.config/starship.toml
      eval "$(${pkgs.starship}/bin/starship init bash)"
    fi
  '';


  programs.ssh.startAgent = true;

  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      slack = "${pkgs.slack}/bin/slack";
      #zoom-us = "${pkgs.zoom-us}/bin/zoom-us";
      skypeforlinux = "${pkgs.skypeforlinux}/bin/skypeforlinux";
    };
  };

  networking.networkmanager.enable = true;

  programs.sway = {
    enable = true;
    extraSessionCommands = ''
      PATH=$HOME/bin:$PATH

      # Vivado shows blank white screen without this:
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
  };
  xdg.portal = {
    enable = true; # Screen sharing under sway
    # gtk portal needed to make gtk apps happy
    extraPortals = lib.mkForce [
      # override nixos/modules/services/x11/desktop-managers/gnome.nix
      # gnome portal breaks things in sway (https://github.com/swaywm/sway/wiki#gtk-applications-take-20-seconds-to-start)
      # we still want gnome apps, but don't care about working gnome desktop
      #pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
  };
  security.polkit.enable = true; # Needed by sway

  programs.adb.enable = true;

  programs.nix-ld.enable = true;

  programs.bcc.enable = true;

  programs.wshowkeys.enable = true;

  virtualisation.virtualbox.host.enable = true;

  virtualisation.virtualbox.host.enableExtensionPack = true; # Enable temporarily for USB 2.0+ devices

  # List services that you want to enable:

  services.nixseparatedebuginfod.enable = true;

  services.nscd.enableNsncd = true; # https://nixos.org/manual/nixos/stable/release-notes.html#sec-release-22.11-highlights

  services.envfs.enable = true;

  services.avahi = {
    publish = {
      enable = true;
      addresses = true; # Enable finding this computer via <hostname>.local
    };
  };

  services.syncthing = {
    enable = true;
    user = "wsh";
    dataDir = "/home/wsh/sync";
    configDir = "/home/wsh/.config/syncthing";
    openDefaultPorts = true;
  };

  services.fwupd.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [
    (pkgs.callPackage ./../../pkgs/kyocera-phase5.nix { })
    (pkgs.callPackage ./../../pkgs/kmbeu { })
  ];
  services.ipp-usb.enable = true; # USB printers
  programs.system-config-printer.enable = true;

  services.tailscale.enable = true;
  systemd.services.tailscaled.wantedBy = lib.mkForce []; # Don't start automatically

  #services.teamviewer.enable = true;

  #services.jack.jackd.enable = true;

  # Add pam limits for jack without starting jack at boot (copied from
  # jack.nix module)
  security.pam.loginLimits = [
    { domain = "@jackaudio"; type = "-"; item = "rtprio"; value = "99"; }
    { domain = "@jackaudio"; type = "-"; item = "memlock"; value = "unlimited"; }
  ];
  users.groups.jackaudio = { };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.AllowUsers = [ "wsh" "root" "novaboot-test" ];
  services.openssh.settings.X11Forwarding = true;

  services.tftpd-hpa = {
    enable = true;
    extraOptions = [
      "--verbose"
    ];
  };

  services.gpm.enable = true;

  services.udev = {
    packages = [ pkgs.stlink ];
    extraRules = builtins.concatStringsSep "\n" [
      # USB relays
      ''SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05df", MODE="0600", OWNER="wsh"''
    ];
  };


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.interfaces.enp0s31f6.allowedUDPPorts = [ 69 ]; # TFTP
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i wg-ipa2x -j ACCEPT
  '';
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # networking.firewall.logRefusedPackets = true;

  networking.wireguard.enable = true;

  services.flatpak.enable = true;

  # Enable sound.
  # sound.enable = true;
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.opengl.extraPackages = with pkgs; [ intel-compute-runtime ];

  services.locate = {
    enable = true;
    package = pkgs.mlocate;
    localuser = null;
  };

#   services.nullmailer = {
#     enable = true;

#     config = {
#       adminaddr = "ms@2x.cz";
#       defaultdomain = "2x.cz";
#       me = "steelpick.2x.cz";
#     };
#   };

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

  # Make the authoritative version of NOVA available also from the internal repo
  fileSystems."/home/wsh/vyuka/osy/cviceni/nova/nova" = { options = [ "bind" ]; device = "/home/wsh/vyuka/osy/pages/nova"; };

  fileSystems."/srv/blender" = {
      device = "//turris.lan/flamenco";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in ["${automount_opts},mfsymlinks,uid=wsh,gid=wsh,forceuid,forcegid,file_mode=0600,dir_mode=0700,credentials=/etc/nixos/smb-flamenco.secret"];
  };

  systemd.nspawn.ros-melodic = {
    enable = true;
    execConfig = {
      ResolvConf = "bind-host";
    };
    filesConfig = {
      Bind = "/home/wsh";
      BindReadOnly = "/tmp/.X11-unix";
    };
    networkConfig = {
      VirtualEthernet = false; # Use host networking
    };
  };

  services.logind.extraConfig = ''
    HandlePowerKey=suspend

    # Stop user systemd instance immediately after logout. This is
    # needed because I start session daemons by systemd. If they are
    # not restarted, they cannot connect to a new WAYLAND DISPLAY.
    UserStopDelaySec=0
  '';

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    wacom.enable = true;

    layout = "us,cz";
    xkbVariant = ",ucw";
    xkbOptions = "compose:ralt,grp:caps_switch,terminate:ctrl_alt_bksp,wsh:caps_arrows";
  };

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  #services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.defaultSession = "sway";
  services.xserver.windowManager.i3.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

#   services.xserver.desktopManager.plasma5.enable = true;
#   # When using both KDE and Gnome, askPassword conflicts. Force gnome.
#   programs.ssh.askPassword = lib.mkForce "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";

  #services.autorandr.enable = true;

  services.grafana = {
    enable = true;
    settings = {
      server.http_addr = "127.0.0.1";
      server.http_port = 3000;
      analytics.reporting_enabled = false;
    };
  };

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
      extraGroups = [
        "adbusers"
        "dialout"
        "docker"
        "jackaudio"
        "lp"
        "lxd"
        "networkmanager"
        "scanner"
        "uinput"
        "vboxusers"
        "wheel"
      ];
      uid = 1000;
      group = "wsh";
      shell = pkgs.zsh;
    };
    gitea = {
      isNormalUser = true;
      uid = 1002;
      packages = [ pkgs.gitea ];
    };
    test = {
      isNormalUser = true;
    };
  };

  security.sudo = {
    enable = true;
    extraConfig = ''
      wsh  ALL=NOPASSWD: /run/current-system/sw/bin/modprobe vboxdrv
    '';
  };

  users.groups = { wsh = { gid = 1000; }; };

  nix.package = pkgs.nixUnstable.overrideAttrs (old: {
    patches = old.patches ++ [
      # nix flakes metadata: Show lastModified timestamp for each input
      (pkgs.fetchpatch {
        url = "https://github.com/wentasah/nix/commit/8702614ec23d8491b08260e95239246886b65c97.patch";
        hash = "sha256-hcKBeqmNCZlltPGXUSiVKp8M3IzGse8PfsGzr1YRklo=";
      })
    ];
  });
  nix.settings = {
    trusted-users = [ "root" "@wheel" ];
    auto-optimise-store = true;
    builders-use-substitutes = true;
    experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    keep-derivations = true; # Allow building off-line
    keep-outputs = true; # Recommended by nix-direnv
  };
  nix.nixPath = [
    #"nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "nixpkgs=/home/wsh/nix/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];
  nix.distributedBuilds = true;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 4d";
    persistent = true;
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false; # use socket activation

  virtualisation.lxd.enable = true;
  virtualisation.lxc.lxcfs.enable = true;

  specialisation = {
#     test = {
#       inheritParentConfig = false;
#       configuration = {
#         imports = [ # Include the results of the hardware scan.
#           ./hardware-configuration.nix
#         ];
#         services.xserver.enable = true;
#         services.xserver.windowManager.dwm.enable = true;
#         environment.systemPackages = with pkgs; [kitty dmenu];

#         boot.kernelPackages = pkgs.linuxPackages_5_19;

#         documentation.nixos.enable = false;
#       };
#     };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?

}
