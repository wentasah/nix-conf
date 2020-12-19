# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  myEmacs = pkgs.emacs-nox; 
  emacsWithPackages = (pkgs.emacsPackagesGen myEmacs).emacsWithPackages; 
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lucka-ntb"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp2s0.useDHCP = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  
  networking.networkmanager.logLevel = "INFO";

  # Select internationalisation properties.
  i18n.defaultLocale = "cs_CZ.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  nix = {
    gc.automatic = true;
    gc.dates = "weekly";
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
      "skypeforlinux" "faac"
      "zoom-us"
      "brscan4" "brscan4-etc-files" "brother-udev-rule-type1"
      "mfcl2700dwlpr"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (emacsWithPackages (epkgs: (with epkgs.melpaPackages; [ nix-mode ])))
    firefox-wayland
    gitAndTools.git-annex lsof git
    gnomeExtensions.appindicator
    libreoffice-fresh
    links2
    mc
    skypeforlinux
    wget vim
    zoom-us
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  programs.mosh.enable = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.randomizedDelaySec = "30min";
  systemd.timers.nixos-upgrade.timerConfig.Persistent = true;
  systemd.services.nixos-upgrade.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "10min";
  };


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.fwupd.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = (
    let
      mfcl2700dwlpr = pkgs.callPackage ./../pkgs/mfcl2700dwlpr.nix {};
      mfcl2700dwcupswrapper = pkgs.callPackage ./../pkgs/mfcl2700dwcupswrapper.nix { inherit mfcl2700dwlpr; };
    in [
      mfcl2700dwlpr
      mfcl2700dwcupswrapper
    ]);
  services.avahi.enable = true;
  # Important to resolve .local domains of printers, otherwise you get an error
  # like  "Impossible to connect to XXX.local: Name or service not known"
  services.avahi.nssmdns = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  hardware.sane.enable = true;
  hardware.sane.brscan4 = {
    enable = true;
    netDevices = {
      home = { model = "MFC-L2700DW"; ip = "192.168.1.10"; };
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lucka = {
    isNormalUser = true;
    description = "Lucka";
    extraGroups = [ "scanner" ];
  };
  users.users.wsh = {
    isNormalUser = true;
    description = "Michal";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
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
