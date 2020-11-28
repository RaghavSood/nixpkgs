{ stdenv
, fetchFromGitHub
, fetchurl
, cmake
, pkgconfig
, libevent
, jsoncpp
, curl
, libmicrohttpd
, boost172
, python37
, leveldb
, miniupnpc
, breakpointHook
, protobuf3_9
}:

let
  boost = boost172;

  protobuf = protobuf3_9;

  python-boost = boost.override {
    enablePython = true;
    enableStatic = true;
    enableShared = true;
    python = python37;
  };

  libjson-rpc-cpp = fetchurl {
    url = "https://github.com/cinemast/libjson-rpc-cpp/archive/v1.2.0.tar.gz";
    sha256 = "14808kvkj9fygs2dxm8ghazn0i4vx19jz6lzbl16qm5x4yymcma8";
  };
in
stdenv.mkDerivation rec {
  pname = "zilliqa";
  version = "6.4.2";

  src = fetchFromGitHub {
    owner = "zilliqa";
    repo = pname;
    rev = "v${version}";
    sha256 = "14n38kc40hfl01z3ffipirydd2zdqirj3pj73bkdfmxplfhdcrpk";
    fetchSubmodules = true;
  };

  preConfigure = ''
    substituteInPlace cmake/InstallJsonrpccpp.cmake --replace "URL https://github.com/cinemast/libjson-rpc-cpp/archive/v1.2.0.tar.gz" "URL ${libjson-rpc-cpp}"

    mkdir -p /build/source/build/src/depends/jsonrpc/lib64
    ln -s /build/source/build/src/depends/jsonrpc/lib64 /build/source/build/src/depends/jsonrpc/lib

    rm cmake/FindProtobuf.cmake
  '';

  patches = [ 
    ./CMakeLists_g3log.txt
    ./CMakeLists_websocketpp.txt
    ./CMakeLists_schnorr.txt
    # ./CMakeLists_protobuf.txt
    ./CMakeLists_libjsonrpc.txt
    ./CMakeLists.txt.patch
  ];

  cmakeFlags = [ 
    "-DUSE_PYTHON=true" 
  #  "-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON" 
  ];

  nativeBuildInputs = [ pkgconfig cmake python37 ];

  buildInputs = [ python-boost libevent jsoncpp curl libmicrohttpd leveldb miniupnpc protobuf ];

  dontStrip = true;
}
