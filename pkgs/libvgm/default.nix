{ stdenv, lib, fetchFromGitHub, fetchpatch, cmake
, enableShared ? true
, withAudio ? true
, withWaveWrite ? true
, withWinMM ? stdenv.hostPlatform.isWindows
, withDirectSound ? stdenv.hostPlatform.isWindows
, withXAudio2 ? stdenv.hostPlatform.isWindows
, withWASAPI ? stdenv.hostPlatform.isWindows
, withOSS ? (stdenv.hostPlatform.isBSD && !stdenv.hostPlatform.isDarwin)
, withSADA ? stdenv.hostPlatform.isSunOS
, withALSA ? stdenv.hostPlatform.isLinux, alsaLib
, withPulse ? stdenv.hostPlatform.isLinux, libpulseaudio
, withCoreAudio ? stdenv.hostPlatform.isDarwin, darwin
, withLibao ? true, libao
, withEmulation ? true
, availableEmulators ? [ "_ALL" ]
, withLibplayer ? true
, withTools ? true
, zlib
}:

assert withTools -> withAudio && withEmulation && withLibplayer;
assert withALSA -> alsaLib != null;
assert withPulse -> libpulseaudio != null;
assert withCoreAudio -> darwin.CoreAudio != null;
let
  inherit (lib) optional optionals;
  onOff = val: if val then "ON" else "OFF";
in
stdenv.mkDerivation rec {
  pname = "libvgm";
  version = "unstable-2020-10-09";

  src = fetchFromGitHub {
    owner = "ValleyBell";
    repo = pname;
    rev = "27c84a629c53e70c443d714c3915f9ddd7fff86d";
    sha256 = "0gfsv2dz7045yyy2h4s0gmdvwk9r3h5km7gg9wxw9r506pqxz3r8";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/ValleyBell/libvgm/commit/c04f84f2ed5dd34a2ab844a36be7d97f5091bcbe.patch";
      sha256 = "09wa6aa9w8s63rdf8sy1d5kfvlpgggncv8wxb65gjc426sxvnxbh";
    })
  ];

  outputs = [ "out" "dev" ]
    ++ optional withTools "bin";

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = optionals withTools [ zlib ]
  # buildInputs = [ zlib ]
    ++ optional withALSA alsaLib
    ++ optional withPulse libpulseaudio
    ++ optional withCoreAudio darwin.CoreAudio
    ++ optional withLibao libao;

  cmakeFlags = [
    "-DBUILD_LIBAUDIO=${onOff withAudio}"
    "-DBUILD_LIBEMU=${onOff withEmulation}"
    "-DBUILD_LIBPLAYER=${onOff withLibplayer}"
    "-DBUILD_TESTS=${onOff withTools}"
    "-DBUILD_PLAYER=${onOff withTools}"
    "-DBUILD_VGM2WAV=${onOff withTools}"
    "-DLIBRARY_TYPE=${if enableShared then "SHARED" else "STATIC"}"
    "-DUSE_SANITIZERS=ON"
  ]
  ++ optionals withAudio ([
    "-DAUDIODRV_WAVEWRITE=${onOff withWaveWrite}"
    "-DAUDIODRV_WINMM=${onOff withWinMM}"
    "-DAUDIODRV_DSOUND=${onOff withDirectSound}"
    "-DAUDIODRV_XAUDIO2=${onOff withXAudio2}"
    "-DAUDIODRV_WASAPI=${onOff withWASAPI}"
    "-DAUDIODRV_OSS=${onOff withOSS}"
    "-DAUDIODRV_SADA=${onOff withSADA}"
    "-DAUDIODRV_ALSA=${onOff withALSA}"
    "-DAUDIODRV_PULSE=${onOff withPulse}"
    "-DAUDIODRV_APPLE=${onOff withCoreAudio}"
    "-DAUDIODRV_LIBAO=${onOff withLibao}"
  ])
  ++ optionals (withEmulation && (lib.lists.findFirst (x: x == "_ALL") 0 availableEmulators) == 0) [
    "-DSNDEMU__ALL=OFF"
  ]
  ++ optionals withEmulation (lib.lists.forEach availableEmulators (x: "-DSNDEMU_${x}=ON"))
  ++ optionals withTools [
    "-DUTIL_CHARCNV_ICONV=ON"
    "-DUTIL_CHARCNV_WINAPI=${onOff stdenv.hostPlatform.isWindows}"
  ];

  meta = with lib; {
    description = "A more modular rewrite of most components from VGMPlay";
    homepage = "https://github.com/ValleyBell/libvgm";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ OPNA2608 ];
    platforms = platforms.all;
  };
}
