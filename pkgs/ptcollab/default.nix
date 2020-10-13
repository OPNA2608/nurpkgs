{ mkDerivation, lib, fetchFromGitHub, fetchpatch, fetchurl, fetchzip
, qmake
, qtbase, qtmultimedia, libvorbis
}:

let
  iconfile = fetchurl {
    url = "https://raw.githubusercontent.com/yuxshao/ptcollab/c335aa1e90156a021d07dcdd687ea801b623b3a4/res/ptcollab.png";
    sha256 = "1xflsbvbs8790qjvsgihbij97bdj6qqycq13ycjawhzlcaxsh1rw";
  };
  samples = fetchzip {
    url = "https://raw.githubusercontent.com/yuxshao/ptcollab/c335aa1e90156a021d07dcdd687ea801b623b3a4/res/sample.zip";
    sha256 = "0sxx7n00xfz8hc9234rk4bix326yz1mw2144yw5sifj656b4bq0n";
  };
in
mkDerivation rec {
  pname = "ptcollab";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "yuxshao";
    repo = "ptcollab";
    rev = "v${version}";
    sha256 = "0jrsnz7cjxnqxf881yw8nsmcbvf61miwhxa58q6qgfl862mamvgi";
  };

  # Fix install path, 
  patches = [(
    fetchpatch {
      url = "https://github.com/yuxshao/ptcollab/commit/c335aa1e90156a021d07dcdd687ea801b623b3a4.patch";
      sha256 = "15xd7zi1qh8kivakdjw9k1387zj7j42xghppsiyf5ahcy6jrr74z";
    }
  )];

  # add .desktop file & icon
  postPatch = ''
    substituteInPlace src/editor.pro \
      --replace '  icon.' '  '""'$'""'$'""'{icon}.'
    cp ${iconfile} res/ptcollab.png
  '';

  nativeBuildInputs = [ qmake ];

  buildInputs = [ qtbase qtmultimedia libvorbis ];

  postInstall = ''
    mkdir $out/share/ptcollab/
    cp -R ${samples} $out/share/ptcollab/sample_instruments/
  '';

  meta = with lib; {
    description = "Experimental pxtone editor where you can collaborate with friends";
    homepage = "https://yuxshao.github.io/ptcollab/";
    license = licenses.mit;
    maintainers = with maintainers; [ OPNA2608 ];
    platforms = platforms.all;
  };
}
