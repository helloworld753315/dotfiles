# Homebrew から Nix への移行計画

## 目的

既存のHomebrew環境を壊さずに、段階的にNixへ移行する。

### 移行の目標

- **宣言的なパッケージ管理**: 設定ファイルで環境を管理
- **再現性の向上**: 複数マシンで同じ環境を構築
- **バージョン管理**: Git で環境の変更履歴を管理
- **安全性**: いつでもロールバック可能

## 現在の構成（移行前）

### パッケージ管理
- **Homebrew**: 134個のformulae（CLIツール） + 4個のcask（GUIアプリ）
- **Nix**: 未インストール

### 主要なツール

#### バージョン管理ツール
- Node.js: nvm (v20.11.0)
- Python: pyenv (3.9, 3.10, 3.13)
- Ruby: rbenv
- Flutter: fvm
- Go: Homebrew

#### 開発ツール
- git: システム標準
- gh: GitHub CLI
- bun: JavaScriptランタイム
- yarn: パッケージマネージャー

#### GUIアプリ (Homebrew Cask)
- ghostty: ターミナル
- warp: ターミナル
- gcloud-cli / google-cloud-sdk: GCP CLI

### dotfiles管理
- **chezmoi**: Git設定、Zsh設定、Claude Code設定を管理
- 管理場所: `~/.local/share/chezmoi/`

## 移行戦略

### 基本方針

**段階的移行**: 一度に全てを変更せず、3つのフェーズに分けて移行

```
Phase 1: Nix経由でHomebrew管理（既存環境そのまま）
   ↓
Phase 2: 一部をNixパッケージに移行（試験的）
   ↓
Phase 3: 本格的なNix活用（最終目標）
```

### dotfiles管理方針

**chezmoi継続**: 当面はchezmoiでdotfilesを管理し続ける

将来的な選択肢：
- **併用**: Nixで基本設定、chezmoiでClaude設定など
- **完全移行**: すべてHome Managerへ
- **現状維持**: chezmoiのみで管理

## Phase 1: Nix経由でHomebrewを宣言的に管理

### 目的
既存のHomebrew環境はそのまま使い続けるが、Nixで宣言的に管理する

### リスク
**ほぼゼロ**
- Homebrewパッケージはそのまま
- パスも変わらない（`/opt/homebrew/bin/`）
- dotfilesも変更不要

### 実施内容

#### 1. Nixのインストール
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**選択理由**: Determinate Systems版
- オリジナルNixを使用（安定性）
- アンインストールが簡単
- macOS対応が良好

#### 2. nix-darwinのインストール
```bash
nix run nix-darwin -- switch --flake ~/.config/nix-darwin
```

#### 3. Homebrewパッケージリストの取得
```bash
brew list --formula > ~/brew-formulae.txt
brew list --cask > ~/brew-casks.txt
```

#### 4. nix-darwin設定ファイルの作成

**ファイル構成**:
```
~/.config/nix-darwin/
├── flake.nix          # Nix Flakes設定
└── configuration.nix  # システム設定
```

**configuration.nix**:
```nix
{ pkgs, ... }:
{
  # Homebrewを宣言的に管理
  homebrew = {
    enable = true;

    # 主要なパッケージ
    brews = [
      "chezmoi"
      "gh"
      "jq"
      "tree"
      "go"
      "nvm"
      "pyenv"
      "rbenv"
      "fvm"
      # 他は徐々に追加
    ];

    casks = [
      "ghostty"
      "warp"
      "google-cloud-sdk"
    ];

    # Phase 1ではクリーンアップは無効
    # onActivation.cleanup = "zap";
  };

  # macOS設定（オプション）
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
  };

  system.stateVersion = 5;
}
```

#### 5. 設定の適用
```bash
darwin-rebuild switch --flake ~/.config/nix-darwin
```

### この時点での状態
- ✅ Homebrewパッケージは今まで通り動作
- ✅ パスは変わらない
- ✅ dotfilesも変わらない
- ✅ Nixで宣言的に管理されている

### 学べること
- Nix言語の基本
- `darwin-rebuild`の使い方
- 設定ファイルのGit管理
- 宣言的な設定の便利さ

## Phase 2: 一部パッケージをNixに移行

### 目的
シンプルなCLIツールから試験的にNixパッケージに移行

### リスク
**低**（いつでもロールバック可能）

### 実施内容

#### 移行しやすいパッケージ
```nix
{ pkgs, ... }:
{
  # Nixパッケージで管理
  environment.systemPackages = with pkgs; [
    git
    jq
    tree
    ripgrep  # 新規追加もできる
    fd
    fzf
    bat
  ];

  homebrew = {
    enable = true;
    brews = [
      # "jq"     # <- Nixに移行したので削除
      # "tree"   # <- Nixに移行したので削除
      "chezmoi"  # まだHomebrew
      "go"
      "nvm"      # バージョン管理ツールは後回し
      "pyenv"
      "rbenv"
      "fvm"
    ];
  };
}
```

#### 移行の優先順位

**すぐ移行できる**:
- git
- jq
- tree
- ripgrep
- fd
- fzf
- bat

**後回し（複雑）**:
- nvm → Nixのnodejs or direnv
- pyenv → Nixのpython
- rbenv → Nixのruby
- fvm → 要検討
- cocoapods → 要検討

### 動作確認

```bash
# Nixパッケージのパスを確認
which jq
# /nix/store/...-jq-1.7/bin/jq

# 動作確認
jq --version
```

問題があればロールバック：
```bash
darwin-rebuild switch --rollback
```

## Phase 3: Home Managerでdotfiles管理（将来）

### 目的
dotfilesもNixで宣言的に管理

### リスク
**中**（既存のchezmoi設定と競合の可能性）

### 実施内容

#### Home Managerの統合

**flake.nix**に追加:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nix-darwin, nixpkgs, home-manager }: {
    darwinConfigurations."your-hostname" = nix-darwin.lib.darwinSystem {
      modules = [
        ./configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.users.helloworld = import ./home.nix;
        }
      ];
    };
  };
}
```

#### home.nix

```nix
{ pkgs, ... }:
{
  home.stateVersion = "24.05";

  # Git設定
  programs.git = {
    enable = true;
    userName = "helloworld";
    userEmail = "your-email@example.com";
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
    };
    extraConfig = {
      core.editor = "vim";
      init.defaultBranch = "main";
      pull.rebase = false;
      push.default = "simple";
    };
  };

  # Zsh設定
  programs.zsh = {
    enable = true;
    enableCompletion = true;  # 補完は自動
    shellAliases = {
      ll = "ls -l";
    };
    initExtra = ''
      # カスタム設定
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  # その他のパッケージ
  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
  ];
}
```

#### chezmoiとの併用

```
Home Manager: Git、Zsh基本設定
chezmoi:      Claude設定、マシン固有設定

~/.config/nix-darwin/
  └── home.nix          # Git、Zsh設定

~/.local/share/chezmoi/
  ├── dot_claude/       # Claude設定（継続）
  └── dot_zshrc.local   # マシン固有設定（継続）
```

### メリット

- ✅ Git、Zshの補完が自動設定される
- ✅ 手動での補完スクリプトダウンロード不要
- ✅ 環境の再現性が向上

## ロールバック方法

### 設定の世代を戻す
```bash
# 前の世代に戻す
darwin-rebuild switch --rollback

# 世代一覧を表示
darwin-rebuild list-generations

# 特定の世代に戻す
darwin-rebuild switch --switch-generation 3
```

### Nixを完全にアンインストール
```bash
/nix/nix-installer uninstall
```

これで完全に元の環境に戻ります。

## タイムライン

### Phase 1（完了）
- [x] Nixインストール (Determinate Systems)
- [x] nix-darwinセットアップ
- [x] Homebrewパッケージを宣言的に管理 (22 formulae, 4 casks)
- [x] 動作確認
- [x] 設定をGitで管理

**完了日**: 2026-02-23
**所要時間**: 約2時間

### Phase 2（数週間後）
- [ ] 慣れてからシンプルなCLIツールを移行
- [ ] 動作確認とフィードバック
- [ ] 徐々にパッケージを増やす

**所要時間**: 数週間〜数ヶ月

### Phase 3（数ヶ月後）
- [ ] Home Manager導入の検討
- [ ] dotfiles移行の検討
- [ ] chezmoiとの併用 or 完全移行

**所要時間**: 数ヶ月

## リスク管理

### リスクレベル

| フェーズ | リスク | 理由 |
|---------|-------|------|
| Phase 1 | ほぼゼロ | 既存環境そのまま |
| Phase 2 | 低 | ロールバック可能 |
| Phase 3 | 中 | dotfiles競合の可能性 |

### 緊急時の対処

**問題が発生した場合**:
1. `darwin-rebuild switch --rollback`で前の状態に戻す
2. それでもダメなら`/nix/nix-installer uninstall`
3. Homebrewは影響を受けないので通常通り使える

## 参考資料

### 参考記事
- [Homebrewユーザー向けのNix入門](https://zenn.dev/iota/articles/nix-intro-for-homebrew-users)
- [HomebrewからNixへの移行](https://mizunashi-mana.github.io/blog/posts/2025/06/migrate-homebrew-to-nix/)

### 公式ドキュメント
- [Nix公式サイト](https://nixos.org/)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [Home Manager](https://github.com/nix-community/home-manager)

## メモ・疑問点

### 未解決の課題
- [ ] nvmの移行方法（direnv? 複数バージョンのnodejs?）
- [ ] pyenvの移行方法
- [ ] fvmの扱い（Flutter）
- [ ] cocoapodsの扱い

### 学習リソース
- [ ] Nix言語の基本を学ぶ
- [ ] Flakesの仕組みを理解する
- [ ] direnvの使い方を学ぶ

---

**最終更新**: 2026-02-23
**ステータス**: Phase 1 完了 ✅
