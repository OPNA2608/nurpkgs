{ stdenv, fetchFromGitHub
, cmake, halide
, libpng, libjpeg, libtiff, libraw
}:

stdenv.mkDerivation rec {
  pname = "hdr-plus";
  version = "unstable-2020-05-10";

  src = fetchFromGitHub {
    owner = "timothybrooks";
    repo = "hdr-plus";
    rev = "09890d7302606adb4b740cca5334d1b46e16bae3";
    sha256 = "14a390b64a40gcv4wjb0cnnf6ssl9jwcl72jkls7pkmpr545wb9n";
  };

  patches = [
    ./0001-Update-to-Halide-10.0.0.patch
  ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [ halide libpng libjpeg libtiff libraw ];

  installPhase = ''
    for bin in hdrplus stack_frames; do
      install -Dm755 $bin $out/bin/$bin
    done
  '';

  meta = with lib; {
    description = "HDR+ Implementation";
    longDescription = ''
      A burst processing pipeline for photography based on Google's HDR+.
      
      The technique combines multiple, underexposed raw frames as a means of noise removal,
      and later applies tone mapping to maintain local contrast while brightening shadows.
      Initially underexposing images allows for more robust alignment and merging,
      in addition to lower motion blur and fewer blown highlights.
    '';
    homepage = "https://www.timothybrooks.com/tech/hdr-plus/";
    license = licenses.mit;
    maintainers = with maintainers; [ OPNA2608 ];
    platforms = platforms.all;
  };
}
