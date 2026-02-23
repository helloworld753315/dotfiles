{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # プライマリユーザーの設定（Homebrewを使うために必要）
      system.primaryUser = "helloworld";

      # Determinate Nixを使用しているため、nix-darwinのNix管理を無効化
      nix.enable = false;

      # Phase 1: Nixパッケージはまだ使わない（既存環境を維持）
      environment.systemPackages = [ ];

      # Homebrewを宣言的に管理
      homebrew = {
        enable = true;

        # brew leaves で取得した明示的にインストールしたパッケージ
        brews = [
          "chezmoi"
          "cocoapods"
          "ffmpeg"
          "gh"
          "go"
          "jq"
          "k1low/tap/runn"
          "leoafarias/fvm/fvm"
          "libxml2"
          "nkf"
          "nvm"
          "oven-sh/bun/bun"
          "pyenv"
          "python@3.10"
          "python@3.9"
          "qt"
          "rbenv"
          "sl"
          "tbls"
          "tree"
          "yarn"
          "zsh-completions"
        ];

        casks = [
          "gcloud-cli"
          "ghostty"
          "google-cloud-sdk"
          "warp"
        ];

        # Phase 1ではクリーンアップは無効にする（安全のため）
        # onActivation.cleanup = "zap";
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#helloworldnoMBP
    darwinConfigurations."helloworldnoMBP" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
