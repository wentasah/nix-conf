rotate-attic: rotate-attic-homeassistant

rotate-attic-homeassistant:
    ssh atticd atticd-atticadm make-token --sub homeassistant --validity 12m  --pull wsh | jq -R . | sops set machines/rpi/secrets.yaml '["attic-token"]' --value-stdin
