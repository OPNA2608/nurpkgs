{ stdenv, lib, fetchFromGitHub
, pkg-config, cppunit
, libvgm, glfw
, libpthreadstubs, libXau, libXdmcp, libX11
}:

stdenv.mkDerivation rec {
  pname   = "mmlgui";
  version = "unstable-2020-10-08";

  src = fetchFromGitHub {
    owner = "superctr";
    repo = pname;
    rev = "38d7a0540ce79f3f434f9d235fdbaa4ed6d18698";
    sha256 = "1pnyx68w487fl4b2c0rq5ldgz7mk7q546hnlwh9682cws1szvj46";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace libvgm.mak \
      --replace "--with-path=/usr/local/lib/pkgconfig" ""
  '';

  nativeBuildInputs = [ pkg-config cppunit ];

  buildInputs = [ libvgm glfw ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ libpthreadstubs libXau libXdmcp libX11 ];

  installPhase = ''
    install -Dm755 {,$out/}bin/mmlgui
  '';

  meta = with lib; {
    description = "GUI for ctrmml";
    homepage    = "https://github.com/superctr/mmlgui";
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ OPNA2608 ];
    platforms   = with platforms; all;
  };
}
