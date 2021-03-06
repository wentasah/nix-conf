# From https://discourse.julialang.org/t/using-julia-with-nixos/35129/32

{ pkgs ? import <nixpkgs> { } }:
with pkgs;
stdenv.mkDerivation rec {
  pname = "julia-bin";
  version = "1.6.4";

  src = fetchurl {
    url = "https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-${version}-linux-x86_64.tar.gz";
    # Use `nix-prefetch-url` to get the hash.
    sha256 = "0ci1dd8g1pgpp6j1v971zg8xpw120hdjblf9zcyhgs4pfvj4l92j";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  # Stripping the shared libraries breaks dynamic loading.
  dontStrip = true;

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out
    tar -x -C $out -f $src --strip-components 1
    # Lacks a string table, so we are unable to patch it.
    rm $out/lib/julia/libccalltest.so.debug
    # Patch for pre-as compilation the Nix store file time stamps are pinned to the start of the epoch.
    sed -i 's/\(ftime != trunc(ftime_req, digits=6)\)$/\1 \&\& ftime != 1.0/' $out/share/julia/base/loading.jl
    grep '&& ftime != 1.0$' $out/share/julia/base/loading.jl > /dev/null || exit 1
  '';

  meta = with pkgs.lib; {
    description =
      "High-level performance-oriented dynamical language for technical computing";
    homepage = "https://julialang.org";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
