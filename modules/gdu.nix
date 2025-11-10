{ config, pkgs, ... }:
{

#   systemd.user.services.ncdu-save = {
#     Service = {
#       ExecStart = "${pkgs.gnumake}/bin/make -C %h/srv/steelpick/ncdu save";
#     };
#   };

  systemd.user.timers.gdu-save = {
    Timer = {
      Persistent = true;
      OnCalendar = "weekly";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # TODO: This this work?
  systemd.user.tmpfiles.rules = [ "d %h/srv/%H/gdu 0700 - - 6w" ];

  systemd.user.services.gdu-save = {
    Unit.ConditionACPower = true;
    Service = {
      ExecStart = toString (pkgs.writeShellScript "gdu-home" ''
        set -euo pipefail
        dir=$HOME/srv/$(hostname)/gdu
        mkdir -p "$dir"
        ${pkgs.gdu}/bin/gdu $HOME -o- | ${pkgs.zstd}/bin/zstd -o "$dir"/gdu-$(date +'%F_%T').json.zst
      '');
    };
  };

  home.packages = with pkgs; [
    gdu
  ];
}
