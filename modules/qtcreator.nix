{ pkgs, ...}:
{
  home.packages = with pkgs; [
    qtcreator
  ] ++  (with qt5; # To make qtcreator find the qt automatically
    [ # This is qt5.full without insecure qtwebkit
      qt3d qtcharts qtconnectivity qtdeclarative qtdoc qtgraphicaleffects qtimageformats
      qtlocation qtmultimedia qtquickcontrols qtquickcontrols2 qtscript qtsensors qtserialport
      qtsvg qttools qttranslations qtvirtualkeyboard qtwebchannel qtwebengine qtwebsockets
      qtwebview qtx11extras qtxmlpatterns qtlottie
    ]);
}
