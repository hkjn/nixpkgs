{ lib, fetchzip, python3Packages }:

# install with:
# nix-env -i custom-exporter-${version}
python3Packages.buildPythonApplication rec {
  name = "custom-exporter-${version}";
  version = "0.1.5";

  # just a single .py file
  format = "other";

  # xx: how to handle authentication, e.g through long/secure url?

  # calculate with:
  # nix-prefetch-url --unpack https://store.hkjn.me/coinstack/coinstack-${version}.tar.gz
  src = fetchzip {
    url = "https://store.hkjn.me/coinstack/coinstack-${version}.tar.gz";
    sha256 = "0ba8pvq5blimsa5w6v6p76n24r33q91gzpbwki0j92lmfgwvpkhc";
  };

  propagatedBuildInputs = with python3Packages; [ prometheus_client ];

  # need to override this, or the Makefile will be run by the default builder
  buildPhase = ''
     true
  '';
  installPhase = ''
    mkdir -p $out/share/
    echo "installing stuff from coinstack: $(ls -hsal .)"
    cp prometheus_tor.py $out/share/
  '';

  fixupPhase = ''
    makeWrapper "${python3Packages.python.interpreter}" "$out/bin/prometheus_tor" \
          --set PYTHONPATH "$PYTHONPATH" \
          --add-flags "$out/share/prometheus_tor.py"
  '';

  meta = with lib; {
    description = "Prometheus exporter that exposes metrics from custom services";
    homepage = https://github.com/xx;
    license = licenses.mit;
    maintainers = with maintainers; [ hkjn ];
  };
}
