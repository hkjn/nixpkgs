{ stdenv, buildPythonPackage, jsonschema, fetchPypi, fetchFromGitHub }:

buildPythonPackage rec {
  pname = "apply-defaults";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "bcb";
    repo = "apply_defaults";
    rev = "0.1.3";
    sha256 = "0nsryd1mc31rjjpvbykm0lxx24v6rf6qf30xjc40hcs5ihnl2sg8";
  };

  propagatedBuildInputs = [ ];

  # xx: populate
  meta = with stdenv.lib; {
    description = "";
    homepage = https://github.com/;
    license = licenses.bsd3;
    maintainers = with maintainers; [ hkjn ];
  };
}
