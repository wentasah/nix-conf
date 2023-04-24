{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.ydotool ];

  systemd.user.services.ydotoold = {
    description = "ydotoold service";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.ydotool}/bin/ydotoold";
      Restart = "always";
    };
  };
}
