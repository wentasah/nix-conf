{ pkgs, lib, ...}:
{
  # For NixOS < 24.05
  services.avahi.enable = true;
  services.avahi.nssmdns = lib.mkForce false; # Use my settings from below

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

  # settings from avahi-daemon.nix where mdns is replaced with mdns4
  system.nssModules = [ pkgs.nssmdns ];
  system.nssDatabases.hosts = with lib; (mkMerge [
    (mkBefore [ "mdns4_minimal [NOTFOUND=return]" ]) # before resolve
    (mkAfter [ "mdns4" ]) # after dns
  ]);
}
