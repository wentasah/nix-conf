# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  myOverlay = self: super: {
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
      ../../modules/qt.nix
      #../../modules/greetd.nix
    ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "Oracle_VirtualBox_Extension_Pack"
        "aspell-dict-en-science"
        "brother-udev-rule-type1"
        "brscan4"
        "brscan4-etc-files"
        "drawio"
        "konica-minolta-bizhub"
        "kyocera-driver"
        "mfcl2700dwlpr"
        "saleae-logic-2"
        "slack"
        "steam-unwrapped"
        "unrar"
        "xkcd-font"
        "zoom" # zoom-us is now just zoom
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
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

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
#     # For the tunnel to wrwb license server
#     127.0.0.1 k2.felk.cvut.cz
  '';

  systemd = {
    settings.Manager = {
      # Don't block reboot for too long
      DefaultTimeoutStopSec = 30;
    };

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

  documentation = {
    dev.enable = true;
    doc.enable = true;
    enable = true;
    info.enable = true;
    man.enable = true;
    #man.generateCaches = true;
    nixos.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    android-tools
    binutils-unwrapped # for strings etc.
    cntr
    compsize
    dash # TODO: Try is as /bin/sh (environment.binsh)
    ddrescue
    dmidecode
    elinks
    emacs-nox
    ethtool
    file
    gitFull
    gnumake
    htop
    iftop
    lsof
    mc
    nautilus-python
    ncdu
    net-tools
    nethogs
    ntfs3g
    pciutils
    psmisc
    ripgrep
    stlink
    tcpdump
    tftp-hpa
    tree
    vim
    wget
    wireguard-tools
    zoom-us
  ];

  environment.homeBinInPath = true;

  # Get zsh completion for system packages (e.g. systemd).
  environment.pathsToLink = [ "/share/zsh" ];

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

  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
      PubkeyAcceptedKeyTypes ssh-ed25519
      ServerAliveInterval 60
      IPQoS throughput
      IdentityFile /root/.ssh/nixbuild-key
  '';

  programs.ssh.knownHosts = {
    nixbuild = {
      hostNames = [ "eu.nixbuild.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
  };

  programs.sysdig.enable = true;

  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      slack = "${pkgs.slack}/bin/slack";
      #zoom-us = "${pkgs.zoom-us}/bin/zoom-us";
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
  programs.hyprland = {
    enable = true;
    #withUWSM = true;
  };

  programs.scroll = {
    enable = true;
    # Commands executed before scroll gets launched, see more examples here:
    # https://github.com/dawsers/scroll#environment-variables
    extraSessionCommands = ''
      # Tell QT, GDK and others to use the Wayland backend by default, X11 if not available
      export QT_QPA_PLATFORM="wayland;xcb"
      export GDK_BACKEND="wayland,x11"
      export SDL_VIDEODRIVER=wayland
      export CLUTTER_BACKEND=wayland

      # XDG desktop variables to set scroll as the desktop
      export XDG_CURRENT_DESKTOP=scroll
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=scroll

      # Configure Electron to use Wayland instead of X11
      export ELECTRON_OZONE_PLATFORM_HINT=wayland
    '';
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

  programs.nix-ld.enable = true;

  programs.bcc.enable = true;

  programs.wshowkeys.enable = true;

  #virtualisation.virtualbox.host.enable = true;  # broken <2025-10-08 Wed>
  #virtualisation.virtualbox.host.enableExtensionPack = true; # Enable temporarily for USB 2.0+ devices

  # List services that you want to enable:

  services.nixseparatedebuginfod2.enable = true;

  services.nscd.enableNsncd = true; # https://nixos.org/manual/nixos/stable/release-notes.html#sec-release-22.11-highlights

  services.envfs.enable = true;
  # buildroot needs /usr/bin/file :-(. See
  # https://gitlab.com/buildroot.org/buildroot/-/blob/2bd1723c0a5224efca245edf6930aa485e29341b/support/dependencies/dependencies.sh#L64
  services.envfs.extraFallbackPathCommands = ''
    ln -s ${pkgs.findutils}/bin/file $out/file
  '';

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
  programs.ydotool.enable = true;

  services.tailscale.enable = true;
  services.tailscale.extraUpFlags = "--accept-routes"; # Enable subnet routes automatically
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
    packages = [
      pkgs.stlink
      pkgs.yubikey-personalization
      pkgs.librealsense
    ];
    extraRules = builtins.concatStringsSep "\n" [
      # USB relays
      ''SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05df", MODE="0600", OWNER="wsh"''
    ];
  };

  services.pcscd.enable = true;

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
  services.pulseaudio.enable = false;

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

  hardware.graphics.extraPackages = with pkgs; [ intel-compute-runtime ];

  hardware.rtl-sdr.enable = true;
  hardware.saleae-logic.enable = true;

  services.locate.enable = true;

#   services.nullmailer = {
#     enable = true;

#     config = {
#       adminaddr = "ms@2x.cz";
#       defaultdomain = "2x.cz";
#       me = "steelpick.2x.cz";
#     };
#   };

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
    enable = false;
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

  services.gnome.gcr-ssh-agent.enable = false; # collides with ssh-agent

  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    PowerKeyIgnoreInhibited = "yes"; # suspend even when locked
    # Stop user systemd instance immediately after logout. This is
    # needed because I start session daemons by systemd. If they are
    # not restarted, they cannot connect to a new WAYLAND DISPLAY.
    UserStopDelaySec = 1;
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    wacom.enable = true;

    xkb.layout = "us,cz";
    xkb.variant = ",ucw";
    xkb.options = "compose:ralt,grp:caps_switch,terminate:ctrl_alt_bksp,wsh:caps_arrows";
  };

  # Enable touchpad support.
  services.libinput.enable = true;

  #services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.defaultSession = "sway";
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # TODO: localsearch needs to be overriden to not block Gtk File Open/Save dialogs.
  # systemctl --user edit localsearch-3.service
  # [Unit]
  # # Remove ConditionEnvironment=XDG_SESSION_CLASS=user
  # ConditionEnvironment=

  # services.desktopManager.plasma6.enable = true;
  # # When using both KDE and Gnome, askPassword conflicts. Force gnome.
  # #programs.ssh.askPassword = lib.mkForce "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";
  # programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";

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
        "plugdev"               # for rtl-sdr
        "scanner"
        "vboxusers"
        "wheel"
        "ydotool"
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

  nix.settings = {
    trusted-users = [ "root" "@wheel" ];
    auto-optimise-store = true;
    builders-use-substitutes = true;
    experimental-features = [ "nix-command" "flakes" ];
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
  nix.package = pkgs.nixVersions.latest;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false; # use socket activation
  virtualisation.docker.autoPrune.enable = true;

  #virtualisation.lxd.enable = true;
  #virtualisation.lxc.lxcfs.enable = true;

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
