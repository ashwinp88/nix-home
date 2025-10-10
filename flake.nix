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
      lib = nixpkgs.lib;
      # Systems we support
      darwinSystem = "aarch64-darwin";  # Apple Silicon, change to x86_64-darwin for Intel
      linuxSystemX86 = "x86_64-linux";  # Standard Linux x86_64
      linuxSystemArm = "aarch64-linux"; # ARM64 Linux (e.g. Apple Silicon Docker, cloud VMs)

      # Helper to create package set for a system
      pkgsFor = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };

      defaultUsername =
        let envUser = builtins.getEnv "USER";
        in if envUser != "" then envUser else "ashwin";

      # Create home manager configuration with modules
      mkHomeConfig = { system, modules, username ? defaultUsername }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;

          modules = modules ++ [
            {
              home = {
                username = lib.mkDefault username;
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
            inherit system username;
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
          system = linuxSystemX86;
          modules = [
            ./modules/base/default.nix
          ];
        };

        "base-core-linux-x86_64" = mkHomeConfig {
          system = linuxSystemX86;
          modules = [
            ./modules/base/default.nix
          ];
        };

        "base-core-linux-aarch64" = mkHomeConfig {
          system = linuxSystemArm;
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
          system = linuxSystemX86;
          modules = [
            ./modules/base/default.nix
            ./modules/os/linux.nix
          ];
        };

        "base-linux-x86_64" = mkHomeConfig {
          system = linuxSystemX86;
          modules = [
            ./modules/base/default.nix
            ./modules/os/linux.nix
          ];
        };

        "base-linux-aarch64" = mkHomeConfig {
          system = linuxSystemArm;
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

        ${linuxSystemX86} = {
          default = self.homeConfigurations."base-linux".activationPackage;
        };

        ${linuxSystemArm} = {
          default = self.homeConfigurations."base-linux-aarch64".activationPackage;
        };
      };
    };
}
