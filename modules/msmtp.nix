{ config, pkgs, ... }:
{
  programs.msmtp = {
    enable = true;
    extraConfig = ''
      defaults
      port 587
      tls on
      tls_starttls on
      # Watch logs with `journalctl --facility=mail`
      syslog LOG_MAIL

      account cvut
      from *@cvut.cz
      host smtp.office365.com
      auth xoauth2
      user sojkam1@cvut.cz
      passwordeval oauth2ms

      account default
      auth on
      host smtpx.fel.cvut.cz
      user sojkam1
      passwordeval secret-tool lookup server imap.feld.cvut.cz user sojkam1 protocol imap
    '';
  };
}
