rotate-attic: rotate-attic-homeassistant

rotate-attic-homeassistant:
    ssh atticd atticd-atticadm make-token --sub homeassistant --validity 12months  --pull wsh | jq -R . | sops set machines/homeassistant/secrets.yaml '["attic-token"]' --value-stdin
