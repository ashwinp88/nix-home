{
  description = "Ashwin's Personal Base Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For managing Homebrew declaratively
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-homebrew, ... }:
    let
      # Systems we support
      darwinSystem = "aarch64-darwin";  # Apple Silicon, change to x86_64-darwin for Intel
      linuxSystem = "x86_64-linux";     # Standard Linux x86_64

      # Helper to create package set for a system
      pkgsFor = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };

      # Create home manager configuration with modules
      mkHomeConfig = { system, modules, username ? "ashwin" }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;

          modules = modules ++ [
            {
              home = {
                inherit username;
                homeDirectory =
                  if system == darwinSystem then "/Users/${username}"
                  else "/home/${username}";
                stateVersion = "24.05";
              };

              # Let Home Manager manage itself
              programs.home-manager.enable = true;
            }
          ];

          extraSpecialArgs = {
            inherit system;
          };
        };
    in
    {
      homeConfigurations = {
        # Base-only configuration (no OS-specific modules)
        "base-core-darwin" = mkHomeConfig {
          system = darwinSystem;
          modules = [
            ./modules/base/default.nix
          ];
        };

        "base-core-linux" = mkHomeConfig {
          system = linuxSystem;
          modules = [
            ./modules/base/default.nix
          ];
        };

        # macOS configuration
        "base-darwin" = mkHomeConfig {
          system = darwinSystem;
          modules = [
            ./modules/base/default.nix
            ./modules/os/darwin.nix
          ];
        };

        # Linux configuration (headless)
        "base-linux" = mkHomeConfig {
          system = linuxSystem;
          modules = [
            ./modules/base/default.nix
            ./modules/os/linux.nix
          ];
        };
      };

      # Convenience outputs for activation
      packages = {
        ${darwinSystem} = {
          default = self.homeConfigurations."base-darwin".activationPackage;
        };

        ${linuxSystem} = {
          default = self.homeConfigurations."base-linux".activationPackage;
        };
      };
    };
}
