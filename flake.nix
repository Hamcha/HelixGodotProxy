{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs [
          "aarch64-darwin"
          "x86_64-darwin"
          "x86_64-linux"
        ] (system: function nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        default = helix_godot_proxy;
        helix_godot_proxy = pkgs.buildDotnetModule {
          name = "HelixGodotProxy";

          src = ./.;

          projectFile = "HelixGodotProxy.csproj";
          dotnet-sdk = pkgs.dotnetCorePackages.sdk_9_0;
          dotnet-runtime = pkgs.dotnetCorePackages.runtime_9_0;

          executables = [ "HelixGodotProxy" ];

          meta = {
            homepage = "https://github.com/Hamcha/HelixGodotProxy";
            description = "A lightweight LSP proxy for improving Godot GDScript development in the Helix editor.";
          };
        };
      });

      devShell = forAllSystems (
        pkgs:
        pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            dotnetCorePackages.sdk_9_0
          ];

          DOTNET_BIN = "${pkgs.dotnetCorePackages.sdk_9_0}/bin/dotnet";

        }
      );
    };
}
