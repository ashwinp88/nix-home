{ pkgs, ... }:

let
  rubyBuildVersion = "v20260110";
  # Pin ruby-build so rbenv can compile Rubies even when nixpkgs does not ship it.
  rubyBuildSrc = pkgs.fetchFromGitHub {
    owner = "rbenv";
    repo = "ruby-build";
    rev = rubyBuildVersion;
    sha256 = "0r291nbval2i06svzrl7p7hs5aj5yqq4q7id8a4953s8wwi3r4jw";
  };
in
{
  config.languages.ruby = {
    enable = true;
    provider = "rbenv";
    rubyBuildPackage = rubyBuildSrc;
  };
}
