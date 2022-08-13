{ lib
, stdenv
, fetchurl
, buildFHSUserEnvBubblewrap
, autoPatchelfHook
, llvmPackages_8
, pigz
, libusb1
, patchelf
, autoconf
, automake
, libxkbcommon
, xorg
}:

let
  carla = stdenv.mkDerivation rec {
    pname = "carla-bin";
    version = "0.9.12";
    src = fetchurl {
      url = "https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_${version}.tar.gz";
      sha256 = "04vgcsmai9bhq8bpzmaq1jcmqk7w42irkwi2x457vf266hy1ha8x";
    };

    nativeBuildInputs = [
      pigz
      patchelf
    ];
    buildInputs = [
      autoPatchelfHook
      llvmPackages_8.openmp
      libusb1
    ];

    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      cd $out
      pigz -dc $src | tar xf -
    '';

    postFixup = ''
      for i in libChronoModels_robot.so libChronoEngine_vehicle.so libChronoEngine.so libChronoModels_vehicle.so; do
        patchelf --replace-needed libomp.so.5 libomp.so $out/CarlaUE4/Plugins/Carla/CarlaDependencies/lib/$i
      done
    '';

  };
in
(buildFHSUserEnvBubblewrap {
  name = "carla-${carla.version}";
  targetPkgs = pkgs: (with pkgs; [
    carla
    libglvnd
    libxkbcommon
    systemd                     # for libudev
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcursor
    xorg.libXext
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXxf86vm
    vulkan-loader
  ]);
  profile = ''
    export UE4_PROJECT_ROOT=${carla}
  '';
  runScript = ''
    ${carla}/CarlaUE4.sh "$@"
  '';
})