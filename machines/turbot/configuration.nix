# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    ambient    = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1Ic+lRqxo0d+1+69Anoae4NXKGiVwiTL6GrHeXg9V2hEYCQdE1n6zaMjDtKnGmjW8a1NrG7C+2WepPxZ0WtKNJ0ixr7jx5VRd6Z4jFENPSsr9EXLhGQaRekRKTk9DoZnVK1SpAjHZvliK5EFX3i8aqMWD53LrWUGD7wabued30AGyTXmfUcMKT2dX94SOPGyTh7ygtXhpbuWGXA0ptxctFxsjRENkDbwcs2PNZhB6BKebNq4iI4xERJuppH1ODmG4N5wDxEXdzlPFZ2HfBnaUnuJ2w9ox/S2QjKzKidpDgwyGf63pXd+2DcvN4e3PJR4UpLAvgtbDmZr+mr016vt3 wsh-password-protected" ];
    };
    imx8b      = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcYBe6j8N1bRMXFlkWVcIoTDs2iIJbYS+hTDg96DqcTofHOXrV6zqC62SZSnSEHstd5NejPWjUJjc734bWnCbRKlckje/OXkePy37zjTWucDqhUM+VBswvF2zuOF2uPG+LZFR34DWfQApJQisb20cdLEcTkndaIjdyhGdMetQMWwBy9lHJNkg8vStUHv4rbcegbeaX03A+Fo76YaQWqD3Yio8kGCRKOmW7iR+b+KnpTyvId/Gi6JpCIwPqhrgnU6hC0fWttcj3wth5moNsK7tTBOgVYPZcFbGI1lCZL+zyX7HmflGxjpsL9nbJw2iWefLY5UvY+m/Ldfhfz406QAyp imx8b@rtime"
      ];
    };
    imx8ctrl   = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2r2sb3HKDPt4qYbKY95aXs+qe6DdxKwWomOGmxgAwxegvNBErfd8p0kPVeScmHMtSg9ft34sC3lPrD6NVYW+QWRzMX2ymevqZXBaeNAupgpT4EYOr1nks9CbS3MgBFFoVOqujIm5GzQlSw9JQ0EVJEDQWj3OhIOnd4RyZxli1z/rNM5cspYYTkhkDvwrz5KUq70M8MqfGMbuyTW6A71VX4SKBKjMUuu7nRIBYkyN7IyiiktKiq68p0EdgDlYROn6mjqMvMAOv92CCagI6+f4xhkfkbV5DbUCBX2fgVSQl1TuiHy9c7DaiUECOlHlbAMOzXpxLDH/+Nr4B5tpXJyYj imx8@rtime"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcYBe6j8N1bRMXFlkWVcIoTDs2iIJbYS+hTDg96DqcTofHOXrV6zqC62SZSnSEHstd5NejPWjUJjc734bWnCbRKlckje/OXkePy37zjTWucDqhUM+VBswvF2zuOF2uPG+LZFR34DWfQApJQisb20cdLEcTkndaIjdyhGdMetQMWwBy9lHJNkg8vStUHv4rbcegbeaX03A+Fo76YaQWqD3Yio8kGCRKOmW7iR+b+KnpTyvId/Gi6JpCIwPqhrgnU6hC0fWttcj3wth5moNsK7tTBOgVYPZcFbGI1lCZL+zyX7HmflGxjpsL9nbJw2iWefLY5UvY+m/Ldfhfz406QAyp imx8b@rtime"
      ];
    };
    imx8fan    = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1Ic+lRqxo0d+1+69Anoae4NXKGiVwiTL6GrHeXg9V2hEYCQdE1n6zaMjDtKnGmjW8a1NrG7C+2WepPxZ0WtKNJ0ixr7jx5VRd6Z4jFENPSsr9EXLhGQaRekRKTk9DoZnVK1SpAjHZvliK5EFX3i8aqMWD53LrWUGD7wabued30AGyTXmfUcMKT2dX94SOPGyTh7ygtXhpbuWGXA0ptxctFxsjRENkDbwcs2PNZhB6BKebNq4iI4xERJuppH1ODmG4N5wDxEXdzlPFZ2HfBnaUnuJ2w9ox/S2QjKzKidpDgwyGf63pXd+2DcvN4e3PJR4UpLAvgtbDmZr+mr016vt3 wsh-password-protected"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFBmvpJUNpYDkpMAL1Y6UVe+QmYndHZrsZ2l/VX4a81dytRLnawJU/MJCnt7tUA7mB4wiZ3LGWci6ioLbsM98fChjacijvbq+AVPbksWatxBnh9Dhn1jxxlsgJTpV58x7FeRoE0Ulaqgd00ZPMf3apDawitrK+ejUbrp2SouLD1pnG6YtBbyw6fyKsx8uyNxmMtM8hRZvWUP0lIUgkZzWMIqW7VgjPxPzbYJjv/yZkpzoRFxE/CO3USI2XT+Ta+WTgrkok88xn4jUkAWSVxbhkRkDbRUdvnXXNdXF4cWOLGRZntLJKc4DM0tT42XmFOGIsDaBX+Y9dBZfacpN3djeB imx8fan@c2c-vostro1"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2r2sb3HKDPt4qYbKY95aXs+qe6DdxKwWomOGmxgAwxegvNBErfd8p0kPVeScmHMtSg9ft34sC3lPrD6NVYW+QWRzMX2ymevqZXBaeNAupgpT4EYOr1nks9CbS3MgBFFoVOqujIm5GzQlSw9JQ0EVJEDQWj3OhIOnd4RyZxli1z/rNM5cspYYTkhkDvwrz5KUq70M8MqfGMbuyTW6A71VX4SKBKjMUuu7nRIBYkyN7IyiiktKiq68p0EdgDlYROn6mjqMvMAOv92CCagI6+f4xhkfkbV5DbUCBX2fgVSQl1TuiHy9c7DaiUECOlHlbAMOzXpxLDH/+Nr4B5tpXJyYj imx8@rtime"
      ];
    };
    power      = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1Ic+lRqxo0d+1+69Anoae4NXKGiVwiTL6GrHeXg9V2hEYCQdE1n6zaMjDtKnGmjW8a1NrG7C+2WepPxZ0WtKNJ0ixr7jx5VRd6Z4jFENPSsr9EXLhGQaRekRKTk9DoZnVK1SpAjHZvliK5EFX3i8aqMWD53LrWUGD7wabued30AGyTXmfUcMKT2dX94SOPGyTh7ygtXhpbuWGXA0ptxctFxsjRENkDbwcs2PNZhB6BKebNq4iI4xERJuppH1ODmG4N5wDxEXdzlPFZ2HfBnaUnuJ2w9ox/S2QjKzKidpDgwyGf63pXd+2DcvN4e3PJR4UpLAvgtbDmZr+mr016vt3 wsh-password-protected"
      ];
    };
    sensors    = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1Ic+lRqxo0d+1+69Anoae4NXKGiVwiTL6GrHeXg9V2hEYCQdE1n6zaMjDtKnGmjW8a1NrG7C+2WepPxZ0WtKNJ0ixr7jx5VRd6Z4jFENPSsr9EXLhGQaRekRKTk9DoZnVK1SpAjHZvliK5EFX3i8aqMWD53LrWUGD7wabued30AGyTXmfUcMKT2dX94SOPGyTh7ygtXhpbuWGXA0ptxctFxsjRENkDbwcs2PNZhB6BKebNq4iI4xERJuppH1ODmG4N5wDxEXdzlPFZ2HfBnaUnuJ2w9ox/S2QjKzKidpDgwyGf63pXd+2DcvN4e3PJR4UpLAvgtbDmZr+mr016vt3 wsh-password-protected"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDInUzFdOLoOA5ttGGGAlQVKsguW2fc1X9mPRW30kegt/CInpHkajZzKWUcIh65K4smHnNMeKICHtGoyORJHt6PH5gteG7ulpBGesJB+hbPDOYrM/i8+n5XUkOGtVr5mpF9GgaF+n0GwoTxp1YINIQpNGF83aRjRx/AdbnBrgaZVe9mIRpuSJQDit3ElT1ubRgI/TAR2vswGmUzROGVothAqnaclK+dgzNp7Q58u9ijwFndeCQ4mb8R1sB9MnQNGzsvh/ZbvtLOJ5oFK2WD21+5+/wJT1NobgTfowvT3U5Hrbs5V7MRhUh4axu2Q2oDC09bEh7P1KwtlIcAo3sZCddR5MbfB/P9XfWx59SOZrSY2T3K86f3cKGKkPGEIJFWsDPOK9GGPHIf+/KIXF8fzLDFdPiTful/X3OsuJ2/AFrj4uFN0bpQ4OuWGsauFyQIO9w2799duZOBl0vlxGhYjlVpHN19MfiIHiOb61/dIyBO/FS3N8FXk/5cshYjaLnoyGG5/nJR/RuVcDEnG1TGh00Dftnm03T5OVLQ8asSUYUI2sfG1ScBQb5W7Zmb+dZDAdxouzvpqhKcxSEugWf2gvN96bL5qKQgVqZ4ty2s/iZET0a19R+O6DtMYtwrVYFyQH0plIMyDT41USLr4GotMZ21SOQZCeDQz+omx1ullixk8Q== benedond@fel.cvut.cz"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCcuW1LcpwdIn4UxSaA0loMv/u9yMYSU74zTWd1pV+v62OO65dFcPcgGvqZWfqSMgs7RkUdB5+q3JkwyyRUplJzMiHk7QERE8A/MLqoDI47ydjy5qs8TLMUS/EHWrJyEtqDAbl2zYDUU/5A19PTn/COBpNMzokvoOzJGPx2XO6JRGn2DSVnbEyrdAxj1gUhslV+g6f6o3oihaY3SC/NjrZEnIiys4Bvr7CCHS21a+1Py8Ut+3ndwsiHgA58BWsrPwyXrsSPGvWzp+qGmGt5htlCN2Z2zZJIjlP4rDbP6YPXaUzaUtwpYFpJxJR9kpuiLmUXWi/noDdjiJIhKoeIme/ benedond@ritchie"
      ];
    };
    sojka      = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1Ic+lRqxo0d+1+69Anoae4NXKGiVwiTL6GrHeXg9V2hEYCQdE1n6zaMjDtKnGmjW8a1NrG7C+2WepPxZ0WtKNJ0ixr7jx5VRd6Z4jFENPSsr9EXLhGQaRekRKTk9DoZnVK1SpAjHZvliK5EFX3i8aqMWD53LrWUGD7wabued30AGyTXmfUcMKT2dX94SOPGyTh7ygtXhpbuWGXA0ptxctFxsjRENkDbwcs2PNZhB6BKebNq4iI4xERJuppH1ODmG4N5wDxEXdzlPFZ2HfBnaUnuJ2w9ox/S2QjKzKidpDgwyGf63pXd+2DcvN4e3PJR4UpLAvgtbDmZr+mr016vt3 wsh-password-protected"
      ];
    };
    thermintel = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8+XhcJBfF9gTzNbLONPIU7E3TQDuDkk6+M3hPtPOk6gonvSL/coB/KJ/jwkP/VkiCeUlQvNlJpm6n8QWsnXE1pw+l6gNo0Xsgd9xvgG3yUx5GzUu8IQtwF3gWJ+NtJg9MfxH+alse2dH8ts/2vDMvZykFRLz8fvacxTM74+Lxre1fY1yJUHso6L0eW39mkeyVPc65Thn1N6Dsvv+iwsQyIfIaiG5E9lcFw4LbVdA3doLlsqiuPRcONverUUo2Wg/ElKtLNSt1Nqu/Ca+YMNjfznlaYNc7MJNeRmZGttVqFT3XEUpYOj86F75TQviLkT9wb4OXydPRMrmnLYd3M86aN6l2NaJ0ei3l/Z3+5yagnHBJNQeI+NRruwaesPl3Bf/WaJxLyZb67DXA2/T0zhwIr9A9jx99Vu1HGU6s2p5Um4/ZJ2gRkxxQIk70oHeRh2meizRcHksbFRsTaF4RwWv4BUDkSS+5t3NT2QgQAaOriF8IviW8Kw0QcSBYD0OUeVU= thermintel@rtime"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChprdfM2LrOxO02j1qLW8gJIQgs0ohvc/W7hYAekImm3NmaSeoy6JvQTa39ski5y+X+arEVjCkcBaqddj8W19jqEPsjHDw9TIJjUl4Ih7aFab1/WiUJsuImQPJ6pEJMNPyt+ZBZ4jfknjPRYVNFDHpjXjEhkHPyQrsjR9qfboWXIIx9cXzbGkGU26RQaiU08RKigxjguHsF25xaBDBj7SUJtBk2HHDfNLz44AGsToSIPYql8xV4ITBeRqj7rBbYCkirZI6Dyn2mBFRE6228jahR0LrXrDgMQQJwNe+ObPcN5K6OOU7aqUDQGhEe32ZEozL8Hkzwt9BQ6EypgQ+L4voreMBzPEfnm6GorkIOtkYg8e+o5JlhEhaXnjXWxjVg33cmxS+dPFB7UdI8DjnQd8xBa3Try2x9XSbfu9UEQzbCLZTNvEmRx7uY8szCjUdGFsawiOxPOUdb3gzCkZn11B9K4KQe6vd4j8mQjf2n/qqmoVjloxuceQog40hpRSrpdE= root@thermintel"
      ];
    };
    thermocam  = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
      ];
    };
    ubuntu     = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1Ic+lRqxo0d+1+69Anoae4NXKGiVwiTL6GrHeXg9V2hEYCQdE1n6zaMjDtKnGmjW8a1NrG7C+2WepPxZ0WtKNJ0ixr7jx5VRd6Z4jFENPSsr9EXLhGQaRekRKTk9DoZnVK1SpAjHZvliK5EFX3i8aqMWD53LrWUGD7wabued30AGyTXmfUcMKT2dX94SOPGyTh7ygtXhpbuWGXA0ptxctFxsjRENkDbwcs2PNZhB6BKebNq4iI4xERJuppH1ODmG4N5wDxEXdzlPFZ2HfBnaUnuJ2w9ox/S2QjKzKidpDgwyGf63pXd+2DcvN4e3PJR4UpLAvgtbDmZr+mr016vt3 wsh-password-protected"
      ];
    };
    #     jane = {
    #       isNormalUser = true;
    #       extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    #       packages = with pkgs; [
    #         firefox
    #         thunderbird
    #       ];
    #     };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    extraConfig = ''
      Match User ambient Host 10.35.95.35,10.35.95.42
          PasswordAuthentication yes
          PermitEmptyPasswords yes
      #    DisableForwarding yes
      #    PermitTTY no

      Match User ambient
          ForceCommand /home/ambient/bin/read-temperature

      Match user imx8fan host 10.35.95.35
          PasswordAuthentication yes
          PermitEmptyPasswords yes
      #    DisableForwarding yes
      #    PermitTTY no

      Match user imx8fan
          ForceCommand /home/imx8fan/bin/fan

      # imx8
      Match User power Host 10.35.95.35
          PasswordAuthentication yes
          PermitEmptyPasswords yes
          ForceCommand /home/power/bin/powermeter imx8

      # imx8b
      Match User power Host 10.35.95.42
          PasswordAuthentication yes
          PermitEmptyPasswords yes
          ForceCommand /home/power/bin/powermeter imx8b

      Match User power
          PasswordAuthentication no
          ForceCommand /home/power/bin/powermeter

      # imx8
      Match User sensors Host 10.35.95.35
          PasswordAuthentication yes
          PermitEmptyPasswords yes
          ForceCommand /bin/nc -U /home/sensors/imx8

      # imx8b
      Match User sensors Host 10.35.95.42
          PasswordAuthentication yes
          PermitEmptyPasswords yes
          ForceCommand /bin/nc -U /home/sensors/imx8b

      Match User sensors
          PasswordAuthentication no
          ForceCommand /home/power/bin/powermeter

      # imx8
      Match User thermocam Host 10.35.95.35
          PasswordAuthentication yes
          PermitEmptyPasswords yes
          # No heat sources for this board
          ForceCommand /bin/sleep inf

      # imx8b
      Match User thermocam Host 10.35.95.42
          PasswordAuthentication yes
          PermitEmptyPasswords yes
          ForceCommand /home/thermocam/bin/thermocam
    '';
  };

  systemd.services.sensord = {
    enable = true;
    description = "Simple power consumption averaging daemon";
    unitConfig = {
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "/usr/local/bin/sensord";
      WorkingDirectory = "/home/sensors";
      User = "sensors";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    wantedBy = [ "multi-user.target" ];
  };


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
