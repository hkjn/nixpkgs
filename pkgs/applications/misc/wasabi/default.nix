{ stdenv
, fetchzip
, dotnet-sdk
, buildDotnetPackage
, dotnetbuildhelpers
, dotnetPackages
, makeWrapper
, gtk2 }:
let
  version = "1.1.6";
in stdenv.mkDerivation {
  name = "wasabi-${version}";

  src = fetchzip {
    url = "https://github.com/zkSNACKs/WalletWasabi/archive/v${version}.zip";
    sha256 = "11ljln9jchzk71434y1agz5369458fym8869qabal6yqgp6ac2pd";
  };

  checkInputs = (with dotnetPackages; [ NUnitConsole ]);
  nativeBuildInputs = [ dotnet-sdk makeWrapper ];

  installPhase = ''
     # work around dotnet command attempting to modify /homeless-shelter/.dotnet,
     # via https://github.com/NixOS/nixpkgs/issues/16144
     export HOME=$TMP
     # disable telemetry
     export DOTNET_CLI_TELEMETRY_OPTOUT=1
     # follow instructions in output to work around error:
     # Permission denied to modify the '/nix/store/r1[..]-dotnet-sdk-2.2.103/sdk/NuGetFallbackFolder' folder. 
     export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true
     cd WalletWasabi.Gui
     # xx: currently fails with /nix/store/r1[..]-dotnet-sdk-2.2.103/sdk/2.2.103/NuGet.targets(114,5):
     #   error : Unable to load the service index for source https://api.nuget.org/v3/index.json.
     #   [/build/source/WalletWasabi.Gui/WalletWasabi.Gui.csproj]
     #
     # it's possible that using buildDotnetPackage or fetchNuGet from pkgs/build-support/build-dotnet-package/default.nix
     # would be easier..
     #
     # also, should this package be defined directly in pkgs/top-level/dotnet-packages.nix?
     ${dotnet-sdk}/bin/dotnet run
  '';

  meta = with stdenv.lib; {
    description = "Wasabi";
    homepage = https://wasabiwallet.io;
    license = licenses.gpl2;
    maintainers = [ maintainers.hkjn ];
  };
}
