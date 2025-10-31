{ config, pkgs, lib, ... }:
{

  systemd.user.services = {
    git-annex-assistant = {
      Unit = {
        Description = "Git Annex Assistant";
      };

      Service = {
        Environment = with pkgs; "PATH=${lib.makeBinPath [ git openssh lsof rsync ]}";
        ExecStart = "${pkgs.git-annex}/bin/git-annex assistant --autostart --startdelay 60 --notify-start --notify-finish --foreground";
        ExecStop = "${pkgs.git-annex}/bin/git-annex assistant --autostop";
        #LimitCPU = "10m";
        CPUAccounting = true;
        CPUQuota = "20%";
        Restart = "on-failure";
        RestartSec = "5s";
      };

      Install = { WantedBy = [ "default.target" ]; };
    };
  };

  home.packages = with pkgs; [
    git-annex
  ];
}
