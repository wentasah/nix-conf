{ config, pkgs, lib, ... }:
let
  swayr = (pkgs.swayr.overrideAttrs ({patches ? [], ...}: {
    patches = patches ++ [
      ../patches/swayr/Add-next-matching-lru-window-command.patch
      ../patches/swayr/Add-workspace-__visible__-criteria.patch
    ];
  }));
in
{
  imports = [
    ./dunst.nix
  ];

  xsession = {
    preferStatusNotifierItems = true;
  };

  wayland.windowManager.sway = {
    enable = true;
    config = null; # don't generate the config automatically
    extraConfigEarly = ''
      include config.local
    '';
    extraSessionCommands = ''
      . /etc/set-environment || echo >&2 "Ignoring ^^^"
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"  || echo >&2 "Ignoring ^^^"
      # We want out services to have the same PATH as our session
      systemctl --user set-environment PATH=$PATH  || echo >&2 "Ignoring ^^^"
      # Fix some JAVA apps
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
    systemd.enable = true;
  };

  home.packages = with pkgs; let
    swappy = pkgs.swappy.overrideAttrs ({ patches ? [], ... }:
      {
        patches = patches ++ [
          # Feature: Save as dialog (https://github.com/jtheoof/swappy/pull/133)
          (fetchpatch {
            url = "https://github.com/jtheoof/swappy/commit/e670f7283664840d0200df88df194da503b9b3ad.patch";
            excludes = [ "src/po/tr.po" ];
            hash = "sha256-jDV9YeNVoFe1E/Hd9NR+fiBMGOG9qXR+MpO546Z/WyE=";
          })
        ];
      });
    in [
    brightnessctl
    cantarell-fonts
    swappy grim slurp
    font-awesome_4
    powerline-fonts
    networkmanagerapplet # need for tray icons
    swaylock
    swayr
    wdisplays
    wev
    wl-clipboard
    wl-mirror pipectl
    wl-screenrec
    wlr-randr
    wofi
    way-displays
    rofi
    xdg-desktop-portal-wlr
    networkmanager_dmenu
  ];

  services.clipman.enable = true;
  systemd.user.services.clipman.Service.ExecStart = lib.mkForce
    ("${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${config.services.clipman.package}/bin/clipman store"
     # --no-persist is needed to resolve copying problem in Nautilus.
     # --See https://www.reddit.com/r/swaywm/comments/112sew3/copyingmoving_files_using_gui_file_managers/
     + " --no-persist");

  services.network-manager-applet.enable = true;

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "sway-session.target";
    };
  };
  systemd.user.services.waybar.Service = {
    # Append to PATH to allow running my scripts in ~/bin, which I
    # have configured in ~/.config/waybar/config for custom blocks.
    ExecStart = lib.mkForce (pkgs.writeShellScript "start-waybar" ''
      PATH=$PATH:${lib.strings.makeBinPath (with pkgs; [ bash coreutils procps "$HOME" ])}
      exec ${config.programs.waybar.package}/bin/waybar
    '');
  };

  systemd.user.services.swayrd = {
    Unit = {
      Description = "Advanced window switcher for sway";
      PartOf = [ "sway-session.target" ];
      After = [ "sway-session.target" ];
    };

    Service = {
      ExecStart = "${swayr}/bin/swayrd";
      Environment = "RUST_BACKTRACE=1 RUST_LOG=swayr=info";
    };

    Install = { WantedBy = [ "sway-session.target" ]; };
  };

  #services.xsettingsd.enable = true;
}
