{ lib }:
rec {
  join = namespace: n:
    if namespace != "" then
      "${namespace}.${n}"
    else
      n
  ;

  # limit: integer
  # warnFn: k -> v -> message -> result
  # mapFn: k -> v -> result
  # root: attrset | derivation
  derivationsLimited = limit: warnFn: mapFn: root:
    let
      recursive = level: namespace: key: v:
        let
          fullKey = join namespace key;
        in
        if (builtins.tryEval v).success then
          (if lib.attrsets.isDerivation v then
            (if (v.meta.broken or true) then
              warnFn fullKey v "marked broken"
            else if (v.meta.unfree or true) then
              warnFn fullKey v "unfree"
            else
              mapFn fullKey v
            )
          else if (limit == null || level < limit)
            && builtins.isAttrs v
            && (v.recurseForDerivations or true) then
            lib.attrsets.mapAttrsToList (recursive (level + 1) fullKey) v
          else
            warnFn fullKey v "not a derivation"
          )
        else
          warnFn fullKey v "eval broken"
      ;
    in
    recursive 0 "" "" root;

  derivations = derivationsLimited null;

  # warnFn: k -> v -> message -> result
  # mapFn: k -> v -> result
  # root: module.options
  options = warnFn: mapFn: root:
    let
      recursive = namespace: key: v:
        let
          fullKey = join namespace key;
        in
        if lib.options.isOption v then
          mapFn fullKey v
        else if builtins.isAttrs v
          && (v.recurseForDerivations or true) then
          lib.attrsets.mapAttrsToList (recursive fullKey) v
        else
          warnFn fullKey v "not an option"
      ;
    in
    recursive "" "" root;
}