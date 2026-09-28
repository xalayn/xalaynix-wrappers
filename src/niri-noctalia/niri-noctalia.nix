{ inputs, ... }:
{
  flake.wrappers.niri-noctalia = 
  { pkgs, wlib, lib, config, ... }: 
  {
    imports = [ wlib.wrapperModules.niri ];

    options = {

      uniqueName = lib.mkOption {
        type = lib.types.str;
        default = "8d434089-f79f-4da4-b199-b235d6dfcfe4";
      };

      profileParentDirectory = lib.mkOption {
        type = lib.types.str;
        default = "$HOME/.config";
      };

      niri = lib.mkOption {
        type = lib.types.package;
        default = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.niri;
      };

      noctalia-shell = lib.mkOption {
        type = wlib.types.subWrapperModule ({name, ...}: {
          imports = [ inputs.self.wrapperModules.noctalia-wrapped ];
          config = {
            pkgs = pkgs;
            outOfStoreConfig = lib.mkForce "${config.profileParentDirectory}/${config.uniqueName}/.config/noctalia";
            user-templates.templates = {
              gtk3.output_path = "${config.profileParentDirectory}/${config.uniqueName}/.config/gtk-3.0/noctalia.css";
              gtk4.output_path = "${config.profileParentDirectory}/${config.uniqueName}/.config/gtk-4.0/noctalia.css";
            };
          };
        });
        default = {

        };
      };

      thunar = lib.mkOption {
        type = wlib.types.subWrapperModule ({name, ...}: {
          imports = [ inputs.self.wrapperModules.thunar ];
          config = {
            pkgs = pkgs;
            env = {
              XDG_CONFIG_HOME = {
                data = "${config.profileParentDirectory}/${config.uniqueName}/.config";
                esc-fn = toString;
              };
            };
          };
        });
        default = {

        };
      };

      wezterm = lib.mkOption {
        type = wlib.types.subWrapperModule ({name, ...}: {
          imports = [ inputs.self.wrapperModules.wezterm ];
          config = {
            pkgs = pkgs;
            colorScheme = "Noctalia";
          };
        });
        default = {

        };
      };

    };


    config = {
      package = lib.mkForce config.niri;

      env = {
        GDK_BACKEND = "wayland";
        TESTVAR = "Hello from Niri-Noctalia wrapper! :D";
      };

      prefixVar = [
        # Make our wrapped Wezterm always show up in launchers

        [
          "XDG_DATA_DIRS"
          ":"
          "${config.thunar.wrapper}/share"
        ]
        [
          "XDG_DATA_DIRS"
          ":"
          "${config.wezterm.wrapper}/share"
        ]
        [
          "PATH"
          ":"
          "${config.thunar.wrapper}/bin"
        ]
        [
          "PATH"
          ":"
          "${config.wezterm.wrapper}/bin"
        ]

      ];

      "config.kdl".content = /* kdl */ ''
        binds {
          Mod+Shift+Slash { show-hotkey-overlay; }

          // Open launcher
          Mod+D hotkey-overlay-title="Run an Application: fuzzel" { spawn "${pkgs.fuzzel}/bin/fuzzel"; }

          // Open overview
          Mod+Tab repeat=false { toggle-overview; }

          // Spawn Applications
          Mod+T hotkey-overlay-title="Open a Terminal: wezterm" { spawn "${config.wezterm.wrapper}/bin/wezterm"; }
          Mod+E hotkey-overlay-title="Open a File Browser: wezterm" { spawn "${config.thunar.wrapper}/bin/thunar" "-w"; }
          Mod+Shift+C { spawn "${pkgs.wl-color-picker}/bin/wl-color-picker"; }
        
          // Discord Muting
          Mod+M { spawn "${pkgs.xdotool}/bin/xdotool" "key" "Alt_R"; }
          Mod+Space { spawn "${pkgs.xdotool}/bin/xdotool" "key" "Alt_R"; }

          // Dynamic Cast Target
          Mod+X { set-dynamic-cast-window; }
          Mod+Shift+X { set-dynamic-cast-monitor; }
          Mod+Ctrl+X { clear-dynamic-cast-target; }

          // Media Keys
          XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"; }
          XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
          XF86AudioMicMute     allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

          // Window actions
          Mod+Q { close-window; }

          Mod+Left  { focus-column-left; }
          Mod+Down  { focus-window-down; }
          Mod+Up    { focus-window-up; }
          Mod+Right { focus-column-right; }
          Mod+H     { focus-column-left; }
          Mod+J     { focus-window-down; }
          Mod+K     { focus-window-up; }
          Mod+L     { focus-column-right; }

          Mod+Ctrl+Left  { move-column-left; }
          Mod+Ctrl+Down  { move-window-down; }
          Mod+Ctrl+Up    { move-window-up; }
          Mod+Ctrl+Right { move-column-right; }
          Mod+Ctrl+H     { move-column-left; }
          Mod+Ctrl+J     { move-window-down; }
          Mod+Ctrl+K     { move-window-up; }
          Mod+Ctrl+L     { move-column-right; }

          Mod+Shift+Left  { focus-monitor-left; }
          Mod+Shift+Down  { focus-monitor-down; }
          Mod+Shift+Up    { focus-monitor-up; }
          Mod+Shift+Right { focus-monitor-right; }
          Mod+Shift+H     { focus-monitor-left; }
          Mod+Shift+J     { focus-monitor-down; }
          Mod+Shift+K     { focus-monitor-up; }
          Mod+Shift+L     { focus-monitor-right; }

          Mod+Shift+Ctrl+Left  { move-workspace-to-monitor-left; }
          Mod+Shift+Ctrl+Down  { move-workspace-down; }
          Mod+Shift+Ctrl+Up    { move-workspace-up; }
          Mod+Shift+Ctrl+Right { move-workspace-to-monitor-right; }
          Mod+Shift+Ctrl+H     { move-workspace-to-monitor-left; }
          Mod+Shift+Ctrl+J     { move-workspace-down; }
          Mod+Shift+Ctrl+K     { move-workspace-up; }
          Mod+Shift+Ctrl+L     { move-workspace-to-monitor-right; }

          Mod+Home      { focus-column-first; }
          Mod+End       { focus-column-last; }
          Mod+Ctrl+Home { move-column-to-first; }
          Mod+Ctrl+End  { move-column-to-last; }
          
          Mod+Page_Down      { focus-workspace-down; }
          Mod+Page_Up        { focus-workspace-up; }
          Mod+U              { focus-workspace-down; }
          Mod+I              { focus-workspace-up; }
          Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
          Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
          Mod+Ctrl+U         { move-column-to-workspace-down; }
          Mod+Ctrl+I         { move-column-to-workspace-up; }

          Mod+Shift+Page_Down { move-workspace-down; }
          Mod+Shift+Page_Up   { move-workspace-up; }
          Mod+Shift+U         { move-workspace-down; }
          Mod+Shift+I         { move-workspace-up; }

          Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
          Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
          Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
          Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

          Mod+WheelScrollRight      { focus-column-right; }
          Mod+WheelScrollLeft       { focus-column-left; }
          Mod+Ctrl+WheelScrollRight { move-column-right; }
          Mod+Ctrl+WheelScrollLeft  { move-column-left; }

          Mod+Shift+WheelScrollDown      { focus-column-right; }
          Mod+Shift+WheelScrollUp        { focus-column-left; }
          Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
          Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

          // Workspaces
          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }
          Mod+Ctrl+1 { move-column-to-workspace 1; }
          Mod+Ctrl+2 { move-column-to-workspace 2; }
          Mod+Ctrl+3 { move-column-to-workspace 3; }
          Mod+Ctrl+4 { move-column-to-workspace 4; }
          Mod+Ctrl+5 { move-column-to-workspace 5; }
          Mod+Ctrl+6 { move-column-to-workspace 6; }
          Mod+Ctrl+7 { move-column-to-workspace 7; }
          Mod+Ctrl+8 { move-column-to-workspace 8; }
          Mod+Ctrl+9 { move-column-to-workspace 9; }

          Mod+BracketLeft  { consume-or-expel-window-left; }
          Mod+BracketRight { consume-or-expel-window-right; }

          Mod+Comma  { consume-window-into-column; }
          Mod+Period { expel-window-from-column; }

          Mod+R { switch-preset-column-width; }
          Mod+Shift+R { switch-preset-window-height; }
          Mod+Ctrl+R { reset-window-height; }
          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }

          Mod+Ctrl+F { expand-column-to-available-width; }
          Mod+C { center-column; }
          Mod+Ctrl+C { center-visible-columns; }

          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }

          Mod+V       { toggle-window-floating; }
          Mod+Shift+V { switch-focus-between-floating-and-tiling; }

          Mod+W { toggle-column-tabbed-display; }

          Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

          Mod+Shift+E { quit; }
          Ctrl+Alt+Delete { quit; }

          Mod+Shift+P { power-off-monitors; }
        }

        // Noctalia Shell
        spawn-at-startup "${config.noctalia-shell.wrapper}/bin/noctalia-shell"
        include optional=true "~/.config/niri/noctalia.kdl"

      '';

      

      extraPackages = [ config.noctalia-shell.wrapper config.niri config.wezterm.wrapper ];

      filesToExclude = lib.mkForce [ "share/wayland-sessions/niri.desktop" "bin/niri-session" ];
      filesToPatch = lib.mkForce [ ];
      passthru.providedSessions = lib.mkForce ["niri-noctalia"];
      disableConfigHotReload = true;
      
      constructFiles.niri-desktop = {
        relPath = "share/wayland-sessions/niri-noctalia.desktop";
        content = ''
          [Desktop Entry]
          Name=Niri Noctalia
          Comment=A scrollable-tiling Wayland compositor
          Exec=${placeholder "out"}/bin/niri-session
          Type=Application
          DesktopNames=niri-noctalia
        '';
      };

      buildCommand.patchNiriSession = {
        after = [ "symlinkScript" "patchSelfReferences" ];
        data = ''
          # Remove the symlink to the original
          rm -f "$out/bin/niri-session"
          # Copy the original script
          cp ${config.niri}/bin/niri-session "$out/bin/niri-session"
          chmod +w "$out/bin/niri-session"
          # Replace all bare 'niri' with absolute path to wrapped binary
          substituteInPlace "$out/bin/niri-session" \
            --replace-fail ' niri ' ' ${placeholder "out"}/bin/niri '
          substituteInPlace "$out/bin/niri-session" \
            --replace-fail 'niri.service' 'niri-noctalia.service'
          substituteInPlace "$out/bin/niri-session" \
            --replace-fail 'niri-shutdown.target' 'niri-noctalia-shutdown.target'
          chmod +x "$out/bin/niri-session"
        '';
      };

      buildCommand.patchNiriService = {
        after = [ "symlinkScript" "patchSelfReferences" ];
        data = ''
          # Remove the symlink to the original
          rm -f "$out/share/systemd/user/niri.service"
          # Copy the original script
          cp ${config.niri}/share/systemd/user/niri.service "$out/share/systemd/user/niri-noctalia.service"
          chmod +w "$out/share/systemd/user/niri-noctalia.service"
          # Replace all bare 'niri' with absolute path to wrapped binary
          sed -i 's|^ExecStart=.*|ExecStart=${placeholder "out"}/bin/niri --session|' "$out/share/systemd/user/niri-noctalia.service"
        '';
      };

      buildCommand.patchNiriShutdownTarget = {
        after = [ "symlinkScript" "patchSelfReferences" ];
        data = ''
          # Remove the symlink to the original
          rm -f "$out/share/systemd/user/niri-shutdown.target"
          # Copy the original script
          cp ${config.niri}/share/systemd/user/niri-shutdown.target "$out/share/systemd/user/niri-noctalia-shutdown.target"
        '';
      };
    };

  };
}