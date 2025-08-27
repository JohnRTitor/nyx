{
  callPackage,
  stdenvNoCC,
  lib,
  fetchurl,
  withUpdateScript ? true,
  toolTitle ? null,
  toolPattern ? "proton-.*",
  tarballPrefix ? "",
  tarballSuffix ? "",
  releasePrefix ? "proton-",
  releaseSuffix ? "",
  versionFilename,
  owner,
  repo,
  version ? lib.trivial.importJSON ./${versionFilename},
}:

let
  releaseVersion = "${releasePrefix}${version.base}-${version.release}${releaseSuffix}";
  homepage = "https://github.com/${owner}/${repo}";
  url = "${homepage}/releases/download/${releaseVersion}/${tarballPrefix}${releaseVersion}${tarballSuffix}";
in
stdenvNoCC.mkDerivation {
  name = repo;
  version = "${version.base}.${version.release}";

  src = fetchurl {
    inherit url;
    inherit (version) hash;
  };

  buildCommand = ''
    mkdir -p $out/bin
    tar -C $out/bin --strip=1 -x -f $src
  ''
  # Allow to keep the same name between updates
  + lib.strings.optionalString (toolTitle != null) ''
    sed -i -r 's|"${toolPattern}"|"${toolTitle}"|' $out/bin/compatibilitytool.vdf
  '';

  passthru =
    if withUpdateScript then
      {
        updateScript = callPackage ./update.nix {
          inherit
            tarballPrefix
            tarballSuffix
            releasePrefix
            releaseSuffix
            versionFilename
            owner
            repo
            ;
        };
      }
    else
      { };

  meta = with lib; {
    inherit homepage;
    description = "Compatibility tool for Steam Play based on Wine and additional components (patched and built by ${owner})";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [
      pedrohlc
    ];
  };
}
