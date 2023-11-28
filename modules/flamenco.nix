{ pkgs, config, ... }:
let
  flamenco = pkgs.callPackage ../pkgs/flamenco {};
  blender = (pkgs.blender-hip.withPackages (p: [ p.pyclothoids p.scenariogeneration ])).overrideAttrs { pname = "blender"; };
in
{
  #fileSystems."/srv/blender" = {device = "turris.lan:/srv/blender"; fsType = "nfs";};
  fileSystems."/srv/blender" = {
      device = "//turris.lan/flamenco";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in ["${automount_opts},mfsymlinks,uid=flamenco-manager,gid=flamenco,forceuid,forcegid,file_mode=0664,dir_mode=0775,credentials=/etc/nixos/smb-flamenco.secret"];
  };
  users.users.flamenco-manager = {
    isSystemUser = true;
    group = "flamenco";
  };
  users.users.flamenco = {
    isNormalUser = true;        # We need home directory to store blender's config
    group = "flamenco";
  };
  users.groups = {
    flamenco = { };
  };
  environment.systemPackages = [
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
      User = "flamenco-manager"; # have full control over shared storage
      Group = "flamenco";       # access to shared files
      ExecStart = "${flamenco}/flamenco-manager";
      UMask = 0002;
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
    path = [ blender ];
    serviceConfig = {
      User = "flamenco"; # worker needs access to blender's config (e.g. Prefs → System → Render devices)
      Group = "flamenco";       # access to shared files
      ExecStart = "${flamenco}/flamenco-worker";
      UMask = 0002;
      StateDirectory = "flamenco-worker";
      WorkingDirectory = "/var/lib/flamenco-worker";
      Restart = "always";
      ReadWritePaths = "/srv/blender";
    };
  };

  # Add python packages for using in Blender Addons (prepared for 23.11)
  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (python-final: python-prev: {
          pyclothoids = python-final.callPackage ../pkgs/pyclothoids.nix { };
          scenariogeneration = python-final.callPackage ../pkgs/scenariogeneration.nix { };
        })
      ];
    })
  ];
}
