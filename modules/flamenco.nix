{ pkgs, config, ... }:
let flamenco = pkgs.callPackage ../pkgs/flamenco {};
in
{
  #fileSystems."/srv/blender" = {device = "turris.lan:/srv/blender"; fsType = "nfs";};
  fileSystems."/srv/blender" = {
      device = "//turris.lan/flamenco";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in ["${automount_opts},mfsymlinks,gid=flamenco,forcegid,file_mode=0664,dir_mode=0775,credentials=/etc/nixos/smb-flamenco.secret"];
  };
  users.groups = {
    flamenco = { };
  };
  environment.systemPackages = with pkgs; [
    blender
    pkgs.cifs-utils
  ];
  systemd.services.flamenco-manager = {
    description = "Flamenco Manager";
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      ${flamenco}/flamenco-manager -write-config
      # Storage location is always relative to executable. Set it outside of read-only Nix store.
      sed -i -e '/^local_manager_storage_path:/ s|.*|local_manager_storage_path: ../../../var/lib/flamenco-manager/storage|' \
          flamenco-manager.yaml
    '';
    serviceConfig = {
      Group = "flamenco";
      ExecStart = "${flamenco}/flamenco-manager";
      UMask = 0002;
      DynamicUser = true;
      Restart = "always";
      StateDirectory = "flamenco-manager";
      WorkingDirectory = "/var/lib/flamenco-manager";
      ReadWritePaths = "/srv/blender";
    };
  };
  systemd.services.flamenco-worker = {
    description = "Flamenco Worker";
    wantedBy = [ "multi-user.target" ];
    environment = {
      FLAMENCO_HOME = "/var/lib/flamenco-worker";
    };
    serviceConfig = {
      Group = "flamenco";
      ExecStart = "${flamenco}/flamenco-worker";
      UMask = 0002;
      DynamicUser = true;
      StateDirectory = "flamenco-worker";
      WorkingDirectory = "/var/lib/flamenco-worker";
      Restart = "always";
      ReadWritePaths = "/srv/blender";
    };
  };
}
