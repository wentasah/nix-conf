# NixOS module for tftpd-hpa TFTP server

{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.tftpd-hpa;

in

{

  options = {

    services.tftpd-hpa = {

      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Whether to enable the tftpd-hpa TFTP server. By default, the server
          binds to address 0.0.0.0.
        '';
      };

      extraOptions = mkOption {
        default = [];
        type = types.listOf types.str;
        example = literalExpression ''
          [
            "--address 192.168.9.1:6969"
            "--verbosity 5"
          ]
        '';
        description = ''
          Extra command line arguments to pass to tftpd-hpa.
        '';
      };

      root = mkOption {
        default = "/srv/tftp";
        type = types.path;
        description = ''
          Document root directory for the tftpd-hpa.
        '';
      };

    };

  };

  config = mkIf cfg.enable {

    systemd.services.tftpd-hpa = {
      description = "TFTP Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      # runs as nobody
      serviceConfig = {
        ExecStart = "${pkgs.tftp-hpa}/bin/in.tftpd --listen --foreground --secure ${lib.concatStringsSep " " cfg.extraOptions} ${cfg.root}";
#        DynamicUser = true;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.root} 0755 root root"
    ];

  };

}
