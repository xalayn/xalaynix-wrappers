{ inputs, ... }:
let
  zshPkg = system: inputs.self.packages.${system}.zsh;
in
{
  flake.wrappers.thunar = 
  { pkgs, lib, wlib, config, ... }: {
    imports = [ wlib.modules.default ];


    config = {

      package = pkgs.xfce.thunar;

      constructFiles.thunar-desktop = {
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

      buildCommand.patchDesktopFile = {
        after = [ "symlinkScript" "patchSelfReferences" ];
        data = ''
          # Replace all bare 'thunar' with absolute path to wrapped binary
          sed -i 's|^Exec=thunar|Exec=${config.package}/bin/thunar|g' "${placeholder "out"}/share/applications/thunar.desktop"
        '';
      };

    };
    
  };
}