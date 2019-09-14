{ stdenv
, buildPythonPackage
, apply-defaults
, async-timeout
, click
, jsonschema
, aiohttp
, fetchFromGitHub
, fetchPypi
, pytest
, pyzmq
, requests
, testfixtures
, tornado
, websockets
}:

buildPythonPackage rec {
  pname = "jsonrpcclient";
  version = "3.3.5";

  src = fetchFromGitHub {
    owner = "hkjn";
    repo = "jsonrpcclient";
    rev = "3.3.5";
    sha256 = "11q4rh24a7prhszk4bapzv5m9zjdjmpvnl3z0kn9mwmng20lj7hs";
  };

  propagatedBuildInputs = [ aiohttp async-timeout apply-defaults click jsonschema pyzmq tornado requests websockets ];

  buildInputs = [ pytest ];

  checkInputs = [ testfixtures ];

  # xx: populate
  meta = with stdenv.lib; {
    description = "";
    homepage = https://github.com/;
    license = licenses.bsd3;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
