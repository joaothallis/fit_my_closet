{
  description = "A flake for Phoenix";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-22.11";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (pkgs.lib) optional optionals;
        pkgs = import nixpkgs { inherit system; };
        elixir = pkgs.beam.packages.erlang.elixir;
      in
      with pkgs;
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            elixir
            elixir_ls
            glibcLocales
          ]
          ++ optional stdenv.isLinux inotify-tools
          ++ optional stdenv.isDarwin terminal-notifier
          ++ optional stdenv.isDarwin (
            with darwin.apple_sdk.frameworks;
            [
              CoreFoundation
              CoreServices
            ]
          );
        };
      }
    );
}
