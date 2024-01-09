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

  # For NixOS >= 24.05
  services.avahi.enable = true;
  #services.avahi.nssmdns4 = true; # enable after removing ./home-printer-fix23.11.nix
  services.avahi.nssmdns = true;

  hardware.sane.enable = true;
  hardware.sane.brscan4 = {
    enable = true;
    netDevices = {
      home = { model = "MFC-L2700DW"; ip = "192.168.1.10"; };
    };
  };
}
