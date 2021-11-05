{ runCommand, xkeyboard_config }:
runCommand "wsh-xkb-config" {} ''
  set -x
  mkdir -p $out/rules $out/symbols
  sed -e 's|%S|${xkeyboard_config}/etc/X11/xkb/rules|' ${./rules/evdev} > $out/rules/evdev
  ln -s ${./symbols/wsh} $out/symbols/wsh
''
