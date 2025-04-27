This command can be used to test my layout configured in this
directory:

```bash
sudo xkbcli interactive-evdev --include $PWD --include-defaults \
  --rules evdev --layout us,cz --variant basic,ucw --options compose:ralt,grp:caps_switch,wsh:caps_arrows
```
