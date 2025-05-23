{ config, pkgs, ... }:
let
  isync = pkgs.isync.override { withCyrusSaslXoauth2 = true; };
in {
  home.packages = with pkgs; [
    goimapnotify
    isync
    oauth2ms
  ];

  services.imapnotify = {
    enable = true;
    package = pkgs.goimapnotify;
    path = with pkgs; [
      afew
      bash
      coreutils
      hostname
      isync
      jq
      libnotify
      notmuch
      oauth2ms
    ];
  };
  # Run mailsync manually at start until
  # https://gitlab.com/shackra/goimapnotify/-/issues/48 is resolved.
  systemd.user.services.imapnotify-cvut = {
    Install.WantedBy = pkgs.lib.mkForce [ ]; # Don't start by default
    # serviceConfig = {
    #   KillMode = "mixed";
    #   TimeoutStopSec = "5min";
    # };
  };

  accounts.email.accounts.cvut = {
    primary = true;
    address = "michal.sojka@cvut.cz";
    userName = "sojkam1@cvut.cz";
    passwordCommand = "oauth2ms";
    imap = {
      host = "outlook.office365.com";
      port = 143;
      tls.useStartTls = true;
    };
    imapnotify = {
      enable = true;
      boxes = [ "INBOX" ];
      onNotify = "${config.home.homeDirectory}/bin/mailsync";
      extraConfig = {
        xoAuth2 = true;
      };
    };
  };
}
