{ pkgs, ...}:
{
  home.packages = with pkgs; [
    #qtcreator # broken <2025-10-23 Thu>
  ] ++ (with qt6; [
    qt3d
    qt5compat
    qtcharts
    qtconnectivity
    qtdatavis3d
    qtdeclarative
    qtdoc
    qtgraphs
    qtgrpc
    qthttpserver
    qtimageformats
    qtlanguageserver
    qtlocation
    qtlottie
    qtmqtt
    qtmultimedia
    qtnetworkauth
    qtpositioning
    qtquick3d
    qtquick3dphysics
    qtquickeffectmaker
    qtquicktimeline
    qtremoteobjects
    qtscxml
    qtsensors
    qtserialbus
    qtserialport
    qtshadertools
    qtspeech
    qtsvg
    qttools
    qttranslations
    qtvirtualkeyboard
    qtwebchannel
    qtwebengine
    qtwebsockets
    qtwebview
  ]);
}
