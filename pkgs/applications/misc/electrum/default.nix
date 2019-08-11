{ stdenv, fetchurl, fetchFromGitHub, python3, python3Packages, zbar, secp256k1 }:

let
  version = "3.3.8";

  qdarkstyle = python3Packages.buildPythonPackage rec {
    pname = "QDarkStyle";
    version = "2.5.4";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "1w715m1i5pycfqcpkrggpn0rs9cakx6cm5v8rggcxnf4p0i0kdiy";
    };
    doCheck = false; # no tests
  };

  # Not provided in official source releases, which are what upstream signs.
  tests = fetchFromGitHub {
    owner = "spesmilo";
    repo = "electrum";
    rev = version;
    sha256 = "1di8ba77kgapcys0d7h5nx1qqakv3s60c6sp8skw8p69ramsl73c";

    extraPostFetch = ''
      mv $out ./all
      mv ./all/electrum/tests $out
    '';
  };
in

python3Packages.buildPythonApplication rec {
  pname = "electrum";
  inherit version;

  src = fetchurl {
    url = "https://download.electrum.org/${version}/Electrum-${version}.tar.gz";
    sha256 = "1g00cj1pmckd4xis8r032wmraiv3vd3zc803hnyxa2bnhj8z3bg2";
  };

  postUnpack = ''
    # can't symlink, tests get confused
    cp -ar ${tests} $sourceRoot/electrum/tests
  '';

  propagatedBuildInputs = with python3Packages; [
    aiorpcx
    aiohttp
    aiohttp-socks
    dnspython
    ecdsa
    jsonrpclib-pelix
    matplotlib
    pbkdf2
    protobuf
    pyaes
    pycryptodomex
    pyqt5
    pysocks
    qdarkstyle
    qrcode
    requests
    tlslite-ng

    # plugins
    ckcc-protocol
    keepkey
    trezor
    btchip

    # TODO plugins
    # amodem
  ];

  preBuild = ''
    sed -i 's,usr_share = .*,usr_share = "'$out'/share",g' setup.py
    sed -i "s|name = 'libzbar.*'|name='${zbar}/lib/libzbar.so'|" electrum/qrscanner.py
    substituteInPlace ./electrum/ecc_fast.py --replace libsecp256k1.so.0 ${secp256k1}/lib/libsecp256k1.so.0
  '';

  postInstall = ''
    # Despite setting usr_share above, these files are installed under
    # $out/nix ...
    mv $out/${python3.sitePackages}/nix/store"/"*/share $out
    rm -rf $out/${python3.sitePackages}/nix

    substituteInPlace $out/share/applications/electrum.desktop \
      --replace 'Exec=sh -c "PATH=\"\\$HOME/.local/bin:\\$PATH\"; electrum %u"' \
                "Exec=$out/bin/electrum %u" \
      --replace 'Exec=sh -c "PATH=\"\\$HOME/.local/bin:\\$PATH\"; electrum --testnet %u"' \
                "Exec=$out/bin/electrum --testnet %u"
  '';

  checkInputs = with python3Packages; [ pytest ];

  checkPhase = ''
    py.test electrum/tests
    $out/bin/electrum help >/dev/null
  '';

  meta = with stdenv.lib; {
    description = "A lightweight Bitcoin wallet";
    longDescription = ''
      An easy-to-use Bitcoin client featuring wallets generated from
      mnemonic seeds (in addition to other, more advanced, wallet options)
      and the ability to perform transactions without downloading a copy
      of the blockchain.
    '';
    homepage = https://electrum.org/;
    license = licenses.mit;
    maintainers = with maintainers; [ ehmry joachifm np ];
  };
}
