{ stdenv, fetchFromGitHub, cmake, asio, tinyxml-2 }:

let
  foonathan-memory = stdenv.mkDerivation rec {
    pname = "foonathan_memory";
    version = "0.7-3";
    src = fetchFromGitHub {
      owner = "foonathan";
      repo = "memory";
      rev = "v${version}";
      sha256 = "sha256-nLBnxPbPKiLCFF2TJgD/eJKJJfzktVBW3SRW2m3WK/s=";
    };

    #   patches = [
    #     (fetchPatch {
    #       name = ""
    #     })
    #   ];

    nativeBuildInputs = [
      cmake
    ];

    cmakeFlags = [
      "-DFOONATHAN_MEMORY_BUILD_EXAMPLES=OFF"
      "-DFOONATHAN_MEMORY_BUILD_TESTS=OFF"
      "-DFOONATHAN_MEMORY_BUILD_TOOLS=ON"
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    ];
  };
  fastcdr = stdenv.mkDerivation rec {
    pname = "fastcdr";
    version = "2.3.4";
    src = fetchFromGitHub {
      owner = "eProsima";
      repo = "Fast-CDR";
      rev = "v${version}";
      sha256 = "sha256-KXQRQieyDPuSmLltf7iOVO4QdsHgaek+x1vneZyEg0E=";
    };

    nativeBuildInputs = [
      cmake
    ];
    buildInputs = [
      foonathan-memory
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "fastdds";
  version = "3.4.1";
  src = fetchFromGitHub {
    owner = "eProsima";
    repo = "Fast-DDS";
    rev = "v${version}";
    sha256 = "sha256-6b7qjKrc59Uk7D9erh+tuqqNRhU2JKFDNlylnIp9rBg=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    asio tinyxml-2
  ];
  propagatedBuildInputs = [
    foonathan-memory fastcdr
  ];
  passthru = {
    inherit fastcdr foonathan-memory;
  };
}
