{ stdenv
# , fetchurl
, secp256k1
, enableQt ? true
, fetchFromGitHub
, python3Packages
, wrapQtAppsHook
, python3
}:

let
  py = python3.override {
    packageOverrides = self: super: {
      dnspython = super.dnspython_1;
    };
  };

  libsecp256k1_name =
    if stdenv.isLinux then "libsecp256k1.so.0"
    else if stdenv.isDarwin then "libsecp256k1.0.dylib"
    else "libsecp256k1${stdenv.hostPlatform.extensions.sharedLibrary}";

in
python3Packages.buildPythonApplication rec {
  pname = "electrum-ltc";
  version = "e25217f77b928637b00f5cf7e061f4832c6f7641";

  #src = fetchurl {
  #  url = "https://electrum-ltc.org/download/Electrum-LTC-${version}.tar.gz";
  #  sha256 = "1kxcx1xf6h9z8x0k483d6ykpnmfr30n6z3r6lgqxvbl42pq75li7";
  #};

  src = fetchFromGitHub {
    owner = "pooler";
    repo = pname;
    rev = "${version}";
    sha256 = "1m8y5fjpc6l1ypvmxkvqs82y80n7zk5wsy0ax7d6aidqallimgdg";
  };

  nativeBuildInputs = with python3Packages; [ pyqt5 wrapQtAppsHook ];

  propagatedBuildInputs = with py.pkgs; [
    aiohttp
    aiohttp-socks
    aiorpcx
    attrs
    pyaes
    bitstring
    dnspython
    ecdsa
    jsonrpclib-pelix
    matplotlib
    pbkdf2
    ecdsa
    pbkdf2
    requests
    qrcode
    py_scrypt
    pyqt5
    protobuf
    dnspython
    jsonrpclib-pelix
    pysocks
    trezor
    btchip
  ] ++ stdenv.lib.optionals enableQt [ pyqt5 qdarkstyle ];

  preBuild = ''
    sed -i 's,usr_share = .*,usr_share = "'$out'/share",g' setup.py
    ls -al
    substituteInPlace ./electrum_ltc/ecc_fast.py \
      --replace ${libsecp256k1_name} ${secp256k1}/lib/libsecp256k1${stdenv.hostPlatform.extensions.sharedLibrary}
    # pyrcc5 icons.qrc -o gui/qt/icons_rc.py
    # Recording the creation timestamps introduces indeterminism to the build
    # sed -i '/Created: .*/d' gui/qt/icons_rc.py
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  checkPhase = ''
    $out/bin/electrum-ltc help >/dev/null
  '';

  meta = with stdenv.lib; {
    description = "Litecoin thin client";
    longDescription = ''
      Electrum-LTC is a simple, but powerful Litecoin wallet. A twelve-word
      security passphrase (or “seed”) leaves intruders stranded and your peace
      of mind intact. Keep it on paper, or in your head... and never worry
      about losing your litecoins to theft or hardware failure. No waiting, no
      lengthy blockchain downloads and no syncing to the network.
    '';
    homepage = "https://electrum-ltc.org/";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
