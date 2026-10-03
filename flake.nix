{
  description = "D2R Terror Zones plugin development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/64c08a7ca051951c8eae34e3e3cb1e202fe36786";
    noctalia.url = "github:noctalia-dev/noctalia/8b0a3f61673123ee65e6eaab8b8cd8620034d690";
  };

  outputs =
    {
      self,
      nixpkgs,
      noctalia,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      tools = [
        pkgs.luau
        pkgs.python3
        noctalia.packages.${system}.default
        pkgs.nixfmt
        pkgs.curl
        pkgs.xdg-utils
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell { packages = tools; };
      checks.${system} = {
        tests =
          pkgs.runCommand "d2r-tz-tests"
            {
              nativeBuildInputs = tools;
              src = self;
            }
            ''
              cp -r "$src" source
              chmod -R u+w source
              cd source
              python3 -B tests/run.py
              mkdir "$out"
            '';
        lint =
          pkgs.runCommand "d2r-tz-lint"
            {
              nativeBuildInputs = tools;
              src = self;
            }
            ''
              cd "$src"
              noctalia plugins lint d2r-tz
              mkdir "$out"
            '';
        format =
          pkgs.runCommand "d2r-tz-format"
            {
              nativeBuildInputs = [ pkgs.nixfmt ];
              src = self;
            }
            ''
              cd "$src"
              nixfmt --check flake.nix
              mkdir "$out"
            '';
      };
    };
}
