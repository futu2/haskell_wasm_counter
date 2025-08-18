{
  description = "A flake for building a Pages project with WASM tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ghc-wasm-meta.url = "gitlab:haskell-wasm/ghc-wasm-meta?host=gitlab.haskell.org";
  };

  outputs = { self, nixpkgs, flake-utils, ghc-wasm-meta, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        ghcWasmPkgs = ghc-wasm-meta.packages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "github-pages-dev";

          buildInputs = [
            # GHC-WASM tools (using the flake's outputs)
            ghcWasmPkgs.default  # or specify a specific version like ghcWasmPkgs.all_9_12
            # Other tools from nixpkgs
            pkgs.wabt
            pkgs.bun
            pkgs.live-server
            pkgs.inotify-tools
          ];

          shellHook = ''
            echo "  - ${ghcWasmPkgs.default.name}"
            echo "  - Bun $(bun --version)"
            echo "  - WABT $(wat2wasm --version)"
          '';
        };
      }
    );
}
