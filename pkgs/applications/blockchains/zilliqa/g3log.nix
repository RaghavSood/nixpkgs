{ stdenv
, fetchFromGitHub
, cmake
, pkgconfig
, libevent
, jsoncpp
, curl
, libmicrohttpd
, extra-cmake-modules
}:

stdenv.mkDerivation rec {
  pname = "g3log";
  version = "6.4.2";

  src = "${fetchFromGitHub {
    owner = "zilliqa";
    repo = pname;
    rev = "v${version}";
    sha256 = "14n38kc40hfl01z3ffipirydd2zdqirj3pj73bkdfmxplfhdcrpk";
    fetchSubmodules = true;
  }}/src/depends/g3log";

  nativeBuildInputs = [ cmake extra-cmake-modules ];

  buildInputs = [ pkgconfig libevent jsoncpp curl libmicrohttpd ];

}
