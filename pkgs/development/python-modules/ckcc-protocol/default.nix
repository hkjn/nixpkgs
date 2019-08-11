{ stdenv
, buildPythonPackage
, click
, ecdsa
, hidapi
, lib
, fetchPypi
, pytest
, pyaes
}:

buildPythonPackage rec {
  pname = "ckcc-protocol";
  version = "0.7.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "242568738a6d8b8f651920fc6022c9b68373855e894a6e89e8c809c72e321298";
  };

  checkInputs = [
    pytest
  ];
  propagatedBuildInputs = [ click ecdsa hidapi pyaes ];
  meta = {
    description = "Communicate with your Coldcard using Python";
    homepage = https://github.com/Coldcard/ckcc-protocol;
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ];
  };
}
