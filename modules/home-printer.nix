{ config, pkgs, ... }:
{
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
  #services.avahi.nssmdns = true; # Use original settings

  # Despite enabling services.avahi.nssmdns, I often (but not always)
  # got "Impossible to connect to XXX.local: Name or service not
  # known". It turns out that the cause is long mDNS delay. By default
  # NixOS uses mdns NSS module, which tries to resolve both IPv4 and
  # IPv6 addresses sequentially. It seems to start with IPv6, which
  # does not resolve so after 5s timeout the resolution continues with
  # IPv4. So the address of the printer is returned after slightly
  # more that 5 seconds, which seems to be too long for CUPS so it
  # gives up and tries again later and the same repeats, because nscd
  # in NixOS does not cache the results.
  #
  # The solution is to use mdns4 instead of mdns NSS module.

  services.avahi.nssmdns = false; # Use my settings from below

  #services.avahi.ipv6 = false;  # Does not help

  # settings from avahi-daemon.nix where mdns is replaced with mdns4
  system.nssModules = with pkgs.lib; optional (!config.services.avahi.nssmdns) pkgs.nssmdns;
  system.nssDatabases.hosts = with pkgs.lib; optionals (!config.services.avahi.nssmdns) (mkMerge [
    (mkOrder 900 [ "mdns4_minimal [NOTFOUND=return]" ]) # must be before resolve
    (mkOrder 1501 [ "mdns4" ]) # 1501 to ensure it's after dns
  ]);

  hardware.sane.enable = true;
  hardware.sane.brscan4 = {
    enable = true;
    netDevices = {
      home = { model = "MFC-L2700DW"; ip = "192.168.1.10"; };
    };
  };
}
