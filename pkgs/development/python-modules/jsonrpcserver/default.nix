{ stdenv
, apply-defaults
, bitstring
, buildPythonPackage
, fetchFromGitHub
, jsonschema
}:

buildPythonPackage rec {
  pname = "jsonrpcserver";
  version = "4.0.5";

  src = fetchFromGitHub {
    owner = "bcb";
    repo = "jsonrpcserver";
    rev = "4.0.5";
    sha256 = "0rxkxmza9chnv7ma7i5xhg7jc1balihvxzd1gvh99sy0aacikr7m";
  };

  propagatedBuildInputs = [ apply-defaults bitstring jsonschema ];

  # xx: populate
  meta = with stdenv.lib; {
    description = "";
    homepage = https://github.com/;
    license = licenses.bsd3;
    maintainers = with maintainers; [ hkjn ];
  };
}
