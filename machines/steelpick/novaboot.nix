# Configuration for novaboot testing
{ config, lib, pkgs, modulesPath, ... }:
let
  novaboot-unfsd-override = pkgs.writeText "novaboot-unfsd@.service.override.conf" ''
    [Service]
    ExecSearchPath=/run/current-system/sw/bin
    ExecSearchPath=/etc/profiles/per-user/novaboot-test/bin
    ExecSearchPath=/home/novaboot-test/.nix-profile/bin
  '';
in
{
  users.users = {
    novaboot-test = {
      isNormalUser = true;
      uid = 1003;
      shell = "/home/novaboot-test/src/server/novaboot-shell";
      packages = [ pkgs.unfs3 ];
    };
  };
  # Make novaboot sources accessible to novaboot-test user
  fileSystems."/home/novaboot-test/src" = {
    options = [ "bind" ];
    device = "/home/wsh/src/novaboot";
  };
  security.sudo = {
    extraConfig = ''
      # For testing
      wsh  ALL=(novaboot-test) NOPASSWD: ALL

      # Recommended sudo configuration for novaboot

      # Uncomment the following lines to enable --dhcp-tftp option
      Cmnd_Alias NOVABOOT_DHCP = ${pkgs.iproute2}/bin/ip a add 10.23.23.1/24 dev enp0s31f6, ${pkgs.iproute2}/ip l set dev enp0s31f6 up, ${pkgs.dhcp}/bin/dhcpd -d -cf dhcpd.conf -lf dhcpd.leases -pf dhcpd.pid, ${pkgs.coreutils}/bin/touch dhcpd.leases, ${pkgs.procps}/bin/pkill --pidfile=dhcpd.pid
      wsh ALL=NOPASSWD: NOVABOOT_DHCP

      # Uncomment the following lines to enable --dhcp-tftp and --tftp options
      Cmnd_Alias NOVABOOT_TFTP = ${pkgs.tftp-hpa}/bin/in.tftpd --listen --secure -v -v -v --pidfile tftpd.pid *, ${pkgs.procps}/bin/pkill --pidfile=*/tftpd.pid
      wsh ALL=NOPASSWD: NOVABOOT_TFTP

    '';
  };

  # For novaboot testing (TODO: Why I needed this?)
  environment.etc."qemu/bridge.conf".text = "allow br0";

  systemd.services.novaboot-test-setup = {
    wantedBy = [ "default.target" ];
    unitConfig =  {
      RequiresMountsFor = "/home/novaboot-test/src";
    };
    script = ''
      mkdir -p /home/novaboot-test/.config/systemd/user/novaboot-unfsd@.service.d
      ln -sf /home/novaboot-test/{src/server/systemd,.config/systemd/user}/novaboot-unfsd@.service
      ln -sf ${novaboot-unfsd-override} /home/novaboot-test/.config/systemd/user/novaboot-unfsd@.service.d/override.conf
    '';
  };
}
