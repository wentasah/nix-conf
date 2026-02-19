{
  config,
  inputs,
  lib,
  ...
}:
let
  defaultSopsPath = "${inputs.self}/machines/${config.networking.hostName}/secrets.yaml";
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.defaultSopsFile = lib.mkIf (builtins.pathExists defaultSopsPath) defaultSopsPath;
}
