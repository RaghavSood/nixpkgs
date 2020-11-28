{ stdenv, callPackage, fetchurl }:

callPackage ./default.nix ( rec {
  version = "0.9.44";

  src = fetchurl {
    url = "mirror://gnu/libmicrohttpd/libmicrohttpd-${version}.tar.gz";
    sha256 = "07j1p21rvbrrfpxngk8xswzkmjkh94bp1971xfjh1p0ja709qwzj";
  };
})
