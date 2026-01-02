{ config, pkgs, lib, ... }:

let
  cfg = config.languages.ruby;
  inherit (lib) mkEnableOption mkOption types mkIf mkMerge optionals mkAfter unique optional;
  isDarwin = pkgs.stdenv.isDarwin;
  defaultKegBin = "/opt/homebrew/opt/ruby/bin";
  defaultGemBin = "/opt/homebrew/lib/ruby/gems/4.0.0/bin";
  defaultUserGemBin = "${config.home.homeDirectory}/.gem/ruby/4.0.0/bin";
  defaultBrewPkg = "ruby";
  defaultProvider = "homebrew";
  defaultRubyBuild = if pkgs ? "ruby-build" then pkgs."ruby-build" else null;
in
{
  options = {
    homebrew.formulas = mkOption {
      description = "Homebrew formula packages to ensure are installed.";
      type = types.listOf types.str;
      default = [];
    };

    homebrew.casks = mkOption {
      description = "Homebrew cask packages to ensure are installed.";
      type = types.listOf types.str;
      default = [];
    };

    languages.ruby = {
      enable = mkEnableOption "Ruby tooling managed outside the Nix store" // {
        default = true;
      };

      provider = mkOption {
        type = types.enum [ "homebrew" "rbenv" ];
        default = defaultProvider;
        description = "Strategy for obtaining Ruby outside the Nix store.";
      };

      homebrewPackage = mkOption {
        type = types.str;
        default = defaultBrewPkg;
        description = "Name of the Homebrew formula that provides Ruby.";
      };

      kegBinPath = mkOption {
        type = types.str;
        default = defaultKegBin;
        description = "Path to the keg-only Ruby bin directory to prepend to PATH.";
      };

      gemBinPath = mkOption {
        type = types.str;
        default = defaultGemBin;
        description = "Directory where RubyGems places executables (e.g. rails).";
      };

      userGemBinPath = mkOption {
        type = types.str;
        default = defaultUserGemBin;
        description = "Directory for per-user gem installs (when GEM_HOME isn't writable).";
      };

      rbenvPackage = mkOption {
        type = types.package;
        default = pkgs.rbenv;
        description = "Which rbenv package to install when using the rbenv provider.";
      };

      rubyBuildPackage = mkOption {
        type = types.nullOr types.package;
        default = defaultRubyBuild;
        description = "ruby-build plugin used by rbenv for compiling Ruby versions.";
      };

      rbenvPlugins = mkOption {
        type = types.listOf types.attrs;
        default = [];
        description = "Additional rbenv plugins to install.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.provider == "homebrew") {
      homebrew.formulas = optionals isDarwin [ cfg.homebrewPackage ];

      home.sessionPath = optionals isDarwin (unique [ cfg.kegBinPath cfg.gemBinPath cfg.userGemBinPath ]);

      programs.zsh.initContent = mkIf isDarwin (mkAfter ''
        if [[ -d ${cfg.kegBinPath} ]]; then
          path=(${cfg.kegBinPath} $path)
        fi
        if [[ -d ${cfg.gemBinPath} ]]; then
          path=(${cfg.gemBinPath} $path)
        fi
        if [[ -d ${cfg.userGemBinPath} ]]; then
          path=(${cfg.userGemBinPath} $path)
        fi
      '');
    })

    (mkIf (cfg.provider == "rbenv") {
      programs.rbenv =
        let
          rubyBuildSrc =
            if cfg.rubyBuildPackage == null then null
            else if cfg.rubyBuildPackage ? src then cfg.rubyBuildPackage.src
            else cfg.rubyBuildPackage;
        in {
        enable = true;
        enableZshIntegration = true;
        package = cfg.rbenvPackage;
        plugins = (optional (rubyBuildSrc != null) {
          name = "ruby-build";
          src = rubyBuildSrc;
        }) ++ cfg.rbenvPlugins;
      };
    })
  ]);
}
