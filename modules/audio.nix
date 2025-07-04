{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    ardour
    jack2
    x42-plugins
    gxplugins-lv2
    qjackctl
    lsp-plugins
  ];

  home.sessionSearchVariables = {
    DSSI_PATH = [
      "$HOME/.dssi"
      "$HOME/.nix-profile/lib/dssi"
      "/run/current-system/sw/lib/dssi"
      "/etc/profiles/per-user/$USER/lib/dssi"
    ];
    LADSPA_PATH = [
      "$HOME/.ladspa"
      "$HOME/.nix-profile/lib/ladspa"
      "/run/current-system/sw/lib/ladspa"
      "/etc/profiles/per-user/$USER/lib/ladspa"
    ];
    LV2_PATH = [
      "$HOME/.lv2"
      "$HOME/.nix-profile/lib/lv2"
      "/run/current-system/sw/lib/lv2"
      "/etc/profiles/per-user/$USER/lib/lv2"
    ];
    LXVST_PATH = [
      "$HOME/.lxvst"
      "$HOME/.nix-profile/lib/lxvst"
      "/run/current-system/sw/lib/lxvst"
      "/etc/profiles/per-user/$USER/lib/lxvst"
    ];
    # Ardour freezes with VST_PATH set
    # VST_PATH = [
    #   "$HOME/.vst"
    #   "$HOME/.nix-profile/lib/vst"
    #   "/run/current-system/sw/lib/vst"
    #   "/etc/profiles/per-user/$USER/lib/vst"
    # ];
    # [ "${config.home.profileDirectory}/share/icons" ]}
  };
}
