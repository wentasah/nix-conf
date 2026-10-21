{ pkgs, lib, ... }:
{
  # https://wiki.nixos.org/wiki/Thumbnails
  home.packages = [
    (lib.lowPrio pkgs.ffmpeg-headless)
    pkgs.ffmpegthumbnailer

    # For general HEIF container support (this includes the AVIF file format)
    pkgs.libheif.bin # provides heif-thumbnailer (the program that generates HEIF thumbnails)
    pkgs.libheif.out # provides heif.thumbnailer (allows for the viewing of HEIF thumbnails)

    # For more newer AVIF specific support usually not needed if libheif is installed
    pkgs.libavif

    # For JXL(JPEG XL) support
    pkgs.libjxl

    # For WebP support
    pkgs.webp-pixbuf-loader

    # 3D Model Thumbnails
    pkgs.f3d
  ];
}
