{ fetchFromGitHub
, lib
, python3
, pkgs
}:
python3.pkgs.buildPythonPackage rec {
  pname = "hhd-adjustor";
  version = "3.10.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hhd-dev";
    repo = "adjustor";
    rev = "refs/tags/v${version}";
    hash = "sha256-DShb1chEkkTRGjQCE708tJABwYERJxajT3nHwHqyKN4=";
  };

  propagatedBuildInputs = (with python3.pkgs; [
    pyroute2
    fuse
    pygobject3
    dbus-python
    pyyaml
    rich
    setuptools
  ]) ++ (with pkgs; [
    wrapGAppsHook3
    glib
    busybox
    gobject-introspection
  ]);

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/hhd-dev/adjustor/";
    description = "The Adjustor TDP plugin for Handheld Daemon.";
    platforms = platforms.linux;
    license = licenses.mit;
    maintainers = with maintainers; [ harryaskham ];
    mainProgram = "adjustor";
  };
}
