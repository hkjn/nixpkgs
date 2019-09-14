{ stdenv, fetchzip, fetchFromGitHub, wrapQtAppsHook, python3, python3Packages, zbar, secp256k1
, enableQt ? !stdenv.isDarwin


# for updater.nix
, writeScript
, common-updater-scripts
, bash
, coreutils
, curl
, gnugrep
, gnupg
, gnused
, nix
}:

let
  version = "c7346c1e";

  libsecp256k1_name =
    if stdenv.isLinux then "libsecp256k1.so.0"
    else if stdenv.isDarwin then "libsecp256k1.0.dylib"
    else "libsecp256k1${stdenv.hostPlatform.extensions.sharedLibrary}";

  libzbar_name =
    if stdenv.isLinux then "libzbar.so.0"
    else "libzbar${stdenv.hostPlatform.extensions.sharedLibrary}";

  # Not provided in official source releases, which are what upstream signs.
  tests = fetchFromGitHub {
    owner = "spesmilo";
    repo = "electrum";
    rev = version;
    sha256 = "0n1ndx3afxhhxqsgr5w5cglkssw4sqxq6141fa88islqqx9xh7kw";

    extraPostFetch = ''
      mv $out ./all
      mv ./all/electrum/tests $out
    '';
  };
in

python3Packages.buildPythonApplication {
  pname = "electrum";
  inherit version;

  src = fetchzip {
    # xx
    url = "https://github.com/spesmilo/electrum/archive/c7346c1eb8f790ad71d14c634097fa67d2839ac5.zip";
    sha256 = "0n1ndx3afxhhxqsgr5w5cglkssw4sqxq6141fa88islqqx9xh7kw";
  };

  postUnpack = ''
    # can't symlink, tests get confused
    cp -ar ${tests} $sourceRoot/electrum/tests
  '';

  nativeBuildInputs = stdenv.lib.optionals enableQt [ wrapQtAppsHook ];

  propagatedBuildInputs = with python3Packages; [
    aiorpcx
    aiohttp
    aiohttp-socks
    dnspython
    ecdsa
    jsonrpcclient
    jsonrpclib-pelix
    jsonschema
    jsonrpcserver
    matplotlib
    pbkdf2
    protobuf
    pyaes
    pycryptodomex
    pysocks
    qrcode
    requests
    tlslite-ng

    # plugins
    keepkey
    trezor
    btchip

    # TODO plugins
    # amodem
  ] ++ stdenv.lib.optionals enableQt [ pyqt5 qdarkstyle ];

  preBuild = ''
    sed -i 's,usr_share = .*,usr_share = "'$out'/share",g' setup.py
    substituteInPlace ./electrum/ecc_fast.py \
      --replace ${libsecp256k1_name} ${secp256k1}/lib/libsecp256k1${stdenv.hostPlatform.extensions.sharedLibrary}
  '' + (if enableQt then ''
    substituteInPlace ./electrum/qrscanner.py \
      --replace ${libzbar_name} ${zbar.lib}/lib/libzbar${stdenv.hostPlatform.extensions.sharedLibrary}
  '' else ''
    sed -i '/qdarkstyle/d' contrib/requirements/requirements.txt
  '');

  postInstall = stdenv.lib.optionalString stdenv.isLinux ''
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

  postFixup = stdenv.lib.optionalString enableQt ''
    wrapQtApp $out/bin/electrum
  '';

  checkInputs = with python3Packages; [ pytest ];

  checkPhase = ''
    py.test electrum/tests
    $out/bin/electrum help >/dev/null
  '';

  passthru.updateScript = import ./update.nix {
    inherit (stdenv) lib;
    inherit
      writeScript
      common-updater-scripts
      bash
      coreutils
      curl
      gnupg
      gnugrep
      gnused
      nix
    ;
  };

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
    platforms = platforms.all;
    maintainers = with maintainers; [ ehmry joachifm np ];
  };
}
