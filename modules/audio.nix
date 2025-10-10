{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    #adlplug # broken <2025-10-08 Wed>
    aether-lv2
    ardour
    bs2b-lv2
    calf
    #(calf.overrideAttrs (o: { cmakeFlags = [ "-DENABLE_EXPERIMENTAL=1" ]; }))
    caps
    coppwr
    dragonfly-reverb
    fomp
    guitarix
    gxplugins-lv2
    hydrogen
    jack-example-tools
    jack2
    ladspaPlugins
    lsp-plugins
    mda_lv2
    meterbridge
    molot-lite
    odin2
    # opnplug # broken
    padthv1
    qjackctl
    # rkrlv2 # broken
    # surge-XT # broken
    swh_lv2
    synthv1
    tap-plugins
    x42-avldrums
    x42-gmsynth
    x42-plugins
    zam-plugins
    zynaddsubfx
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
