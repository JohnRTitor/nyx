{ scx
, scx-common
,
}:

# FIXME-SCX: change csheds to cscheds
# once https://github.com/NixOS/nixpkgs/pull/352811 is available in unstable
scx.csheds.overrideAttrs {
  inherit (scx-common) src version;
}
