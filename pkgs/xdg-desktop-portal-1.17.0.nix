{ final, prev }:
prev.xdg-desktop-portal.overrideAttrs (finalAttrs: previousAttrs: {
  version = "1.17.0";
  outputs = [ "out" ];
  src = final.fetchFromGitHub {
    owner = "flatpak";
    repo = "xdg-desktop-portal";
    rev = finalAttrs.version;
    hash = "sha256-OGf2ohP/Qd+ff3KfJYoHu9wbCAUXCP3wm/utjqkgccE=";
  };
  # Needs to override due to switch from autotools to meson
  nativeBuildInputs = with final; [
    meson ninja
    libxml2
    pkg-config
    wrapGAppsHook
  ];
  buildInputs = with final; [
    acl
    dbus
    flatpak
    fuse3
    bubblewrap
    systemdMinimal # libsystemd
    glib
    gsettings-desktop-schemas
    json-glib
    libportal
    pipewire

    # For icon validator
    gdk-pixbuf
    librsvg

    geoclue2
  ] ++ (with final; [
    xmlto
    docbook_xsl
    docbook_xml_dtd_43
    # For document-fuse installed test.
    (python3.withPackages (pp: with pp; [
      pygobject3
      pytest
      pydbus
      python-dbusmock
    ]))
  ]);
})
