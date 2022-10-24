{ lib, stdenv, fetchFromGitHub, fira-mono, wallpaper ? null }:
with lib;
stdenv.mkDerivation rec {
  pname = "materia-kde-theme";
  version = "20190530";

  src = fetchFromGitHub {
    owner = "eayus";
    repo = "sddm-theme-clairvoyance";
    rev = "dfc5984ff8f4a0049190da8c6173ba5667904487";
    sha256 = "sha256-AcVQpG6wPkMtAudqyu/iwZ4N6a2bCdfumCmdqE1E548=";
  };

  buildInputs = [ fira-mono ];

  installPhase = ''
    mkdir -p $out/usr/share/sddm/themes/
    cp -a . $out/usr/share/sddm/themes/clairvoyance
  '' + optionalString (wallpaper != null) ''
    cp ${wallpaper} $out/usr/share/sddm/themes/clairvoyance/Assets/Background.jpg
  '';

  meta = with lib; {
    description = "Clairvoyance theme for SDDM";
    homepage = "https://github.com/eayus/sddm-theme-clairvoyance";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.bertof ];
    platforms = platforms.all;
  };
}
