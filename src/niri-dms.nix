{ inputs, ... }:
{
  flake.wrappers.niri-dms = 
  { pkgs, wlib, lib, ... }: 
  let
    dmsPkg = inputs.dms.packages.${pkgs.system}.dms-shell;
    alacrittyPkg = inputs.self.packages.${pkgs.system}.alacritty-example;
    niriPkg = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.niri;
  in
  {
    imports = [ wlib.wrapperModules.niri ];
    config.package = lib.mkForce niriPkg;
    config.settings.binds = {
      "Mod+T".spawn-sh = "${alacrittyPkg}/bin/alacritty";
      "Mod+D".spawn-sh = "${dmsPkg}/bin/dms run --session";
    };
    config.settings.spawn-at-startup = [
      ["${dmsPkg}/bin/dms" "run" "--session"]
    ];
    config.extraSettings = [
      { include = [ { optional = true; } "~/.config/niri/noctalia.kdl" ]; }
    ];
    config.env = {
      GDK_BACKEND = "wayland";
    };
    config.extraPackages = [ dmsPkg ];
  };
}