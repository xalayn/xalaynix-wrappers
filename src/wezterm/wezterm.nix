{ inputs, ... }:
let
  zshPkg = system: inputs.self.packages.${system}.zsh;
in
{
  flake.wrappers.wezterm = 
  { pkgs, lib, wlib, config, ... }: {
    imports = [ wlib.wrapperModules.wezterm ];

    options = {
      colorScheme = lib.mkOption {
        type = lib.types.str;
        default = "Seafoam Pastel (Gogh)";
        description = ''
          Defines the theme used by Wezterm.
          Specifically, it is what config.color_scheme will be
          set to in wezterm.lua.
        '';
      };

      window_background_opacity = lib.mkOption {
        type = lib.types.float;
        default = 0.65;
        description = ''
          Defines the opacity of the Wezterm window background.
          Specifically, it is what config.window_background_opacity will be
          set to in wezterm.lua.
        '';
      };
    };

    config = {

      package = pkgs.wezterm;

      env = {
        TESTVAR = "Hello :D";
        WRAPPED_ZSH = "${zshPkg pkgs.system}/bin/zsh";
      };

      "wezterm.lua".path = "${./wezterm.lua}";

      luaInfo = {
        color_scheme = config.colorScheme;
        window_background_opacity = config.window_background_opacity;
      };

      constructFiles.wezterm-desktop = {
        relPath = "share/applications/org.wezfurlong.wezterm.desktop";
        content = ''
          [Desktop Entry]
          Name=WezTerm
          Comment=Wez's Terminal Emulator
          Keywords=shell;prompt;command;commandline;cmd;
          Icon=${placeholder "out"}/share/icons/hicolor/128x128/apps/org.wezfurlong.wezterm.png
          StartupWMClass=org.wezfurlong.wezterm
          TryExec=${placeholder "out"}/bin/wezterm
          Exec=${placeholder "out"}/bin/wezterm start --cwd .
          Type=Application
          Categories=System;TerminalEmulator;Utility;
          Terminal=false
        '';
      };

    };
    
  };
}