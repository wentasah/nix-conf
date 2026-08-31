{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  gettext,
  glib,
  gtk4,
  nautilus,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nautilus-image-converter";
  version = "0.4.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "coreyberla";
    repo = "nautilus-image-converter";
    tag = finalAttrs.version;
    hash = "sha256-o3/l/juQ3wl2JRj606+z/hsprPqt5iz/0I5BrpKrK5s=";
  };

  # po/fr.po declares an empty charset, which recent gettext refuses to
  # treat as a portable encoding name.
  postPatch = ''
    substituteInPlace po/fr.po \
      --replace-fail 'charset=\n' 'charset=UTF-8\n'
    substituteInPlace src/meson.build --replace-fail \
      "install_dir: nautilus_extension_dir" \
      "install_dir: '${placeholder "out"}/lib/nautilus/extensions-4'"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
  ];

  buildInputs = [
    glib
    gtk4
    nautilus
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Nautilus extension that allows resizing/rotating images from Nautilus";
    homepage = "https://gitlab.gnome.org/coreyberla/nautilus-image-converter";
    changelog = "https://gitlab.gnome.org/coreyberla/nautilus-image-converter/-/blob/${finalAttrs.src.rev}/ChangeLog";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "nautilus-image-converter";
    platforms = lib.platforms.all;
  };
})
