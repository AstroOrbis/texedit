{
  pkgs ? import <nixpkgs> { },
}:

let
  version = "v0.0.0";
in
pkgs.stdenv.mkDerivation rec {
  pname = "texedit";
  inherit version;

  src = ./.;

  tecomp = pkgs.callPackage pkgs.rustPlatform.buildRustPackage rec {
    name = "tecomp";
    inherit version;

    src = ./tecomp;

    postInstallPhase = ''
      cp $src/texpdfc.sh $out/bin/
    '';

    cargoHash = "sha256-39svAwEiqttN/Jk7hqyw7dhxYDVSqrkWXNZ73iRFkPQ=";
  };

  cmakeFlags = [
    "-DTEXEDIT_VERSION=${version}"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
  ];

  nativeBuildInputs = with pkgs; [
    cmake
    wxGTK32
    gtk3
    poppler
    pkg-config
    wrapGAppsHook3
    gsettings-desktop-schemas
    pango
  ];
  buildInputs = with pkgs; [
    wxGTK32
    poppler
    gtk3
  ];

  prePatchPhase = ''
    patchShebangs .
  '';

  installPhase = ''
    mkdir -p $out/bin/tex
    cp $src/tecomp/texpdfc.sh $out/bin/
    cp ${tecomp}/bin/tecomp $out/bin/
    cp texedit $out/bin/
    ${pkgs.lib.getExe pkgs.gnutar} -xJf $src/vendored-tex/tex.tar.xz -C $out/bin/tex
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "A simple LaTeX editor with live preview";
    homepage = "https://github.com/astroorbis/texedit";
    license = licenses.mit;
  };
}
