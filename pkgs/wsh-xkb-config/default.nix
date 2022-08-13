{ xkeyboard_config }:
xkeyboard_config.overrideAttrs (old: {
  # Add my symbols and rules to the xkb config. X11 do not support (as
  # opposed to Wayland) user-specific xkb configuration:
  # https://who-t.blogspot.com/2020/09/no-user-specific-xkb-configuration-in-x.html
  postFixup = ''
    cat ${./rules/wsh} >> $out/share/X11/xkb/rules/evdev
    cp ${./symbols/wsh} $out/share/X11/xkb/symbols/wsh
  '';
})
