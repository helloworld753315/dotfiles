# dotfiles

chezmoiで管理する個人的なdotfilesリポジトリです。

## 管理対象のファイル

- **Git設定**
  - `.gitconfig`: Git全体設定
  - `.gitignore_global`: グローバルなgitignore設定

- **Zsh設定**
  - `.zshrc`: Zshの基本設定
  - `.zshenv`: 環境変数設定

- **Claude Code設定**
  - `.claude/CLAUDE.md`: Claude Codeのグローバル開発ガイドライン
  - `.claude/settings.json`: Claude Codeの設定ファイル
  - `.claude/agents/code-review.md`: コードレビューエージェント
  - `.claude/agents/docs-writer.md`: ドキュメント作成エージェント
  - `.claude/agents/test-generator.md`: テスト生成エージェント

- **Nix/nix-darwin設定**
  - `.config/nix-darwin/flake.nix`: Homebrewパッケージの宣言的管理設定

## セットアップ

### 初回インストール

```bash
# chezmoiのインストール（Homebrew）
brew install chezmoi

# このリポジトリからdotfilesを初期化
chezmoi init https://github.com/{YOUR_USERNAME}/dotfiles.git

# 変更内容を確認
chezmoi diff

# dotfilesを適用
chezmoi apply
```

### 既存の環境に追加

```bash
# このリポジトリをchezmoiのソースディレクトリとして使用
chezmoi init --apply https://github.com/{YOUR_USERNAME}/dotfiles.git
```

## 使い方

### ファイルの編集

```bash
# chezmoiのエディタで編集
chezmoi edit ~/.zshrc

# または、ソースディレクトリで直接編集
cd ~/.local/share/chezmoi
# ファイルを編集後
chezmoi apply
```

### 新しいファイルの追加

```bash
# 既存のdotfileをchezmoiで管理
chezmoi add ~/.vimrc
```

### 変更の確認と適用

```bash
# 差分確認
chezmoi diff

# 変更を適用
chezmoi apply

# 変更を適用せず確認だけ（ドライラン）
chezmoi apply --dry-run
```

### リポジトリの更新

```bash
# ソースディレクトリに移動
cd ~/.local/share/chezmoi

# 変更をコミット
git add .
git commit -m "Update dotfiles"
git push
```

## Nix/nix-darwin によるパッケージ管理

このdotfilesでは、Homebrewパッケージをnix-darwinで宣言的に管理しています。

### 仕組み

- **パッケージ**: Homebrewを使用（既存環境そのまま）
- **管理方法**: `.config/nix-darwin/flake.nix`で宣言的に管理
- **メリット**: 設定ファイルで環境を再現可能

### パッケージの追加・削除

```bash
# 1. flake.nixを編集
vim ~/.local/share/chezmoi/dot_config/nix-darwin/flake.nix

# 2. chezmoiで適用
chezmoi apply

# 3. nix-darwinで反映
darwin-rebuild switch --flake ~/.config/nix-darwin#helloworldnoMBP
```

### 詳細

移行計画や詳細は `docs/nix-migration-plan.md` を参照してください。

## Claude Codeカスタムエージェント

このdotfilesには、Claude Code用のカスタムエージェント設定が含まれています。

### code-review.md
コード品質、セキュリティ、保守性を重視したコードレビューエージェント。
- セキュリティ脆弱性の検出
- パフォーマンス問題のチェック
- コードの可読性と保守性の評価
- テストカバレッジの確認

### docs-writer.md
明確で包括的なドキュメント作成エージェント。
- README、ブログ記事、技術ガイド、API docなど各種ドキュメントに対応
- 構造化された読みやすいフォーマット
- 実用的なコード例の提供

### test-generator.md
包括的で保守性の高いユニットテスト生成エージェント。
- AAA（Arrange, Act, Assert）パターンに準拠
- ハッピーパス、エッジケース、エラーケースのカバー
- 明確で自己文書化されたテスト名

## 注意事項

- `.chezmoiignore`に記載されたファイルは管理対象外です
  - `.zshrc.local`: マシン固有のzsh設定
  - `.zprofile`: マシン固有のプロファイル設定
