# 概要

個人用dotfiles設定

## 機能

- Gitのグローバル設定とignoreパターン
- Claudeのグローバル開発ガイドライン

## インストール
```bash
git clone https://github.com/helloworld753315/dotfiles ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## インストールされるもの

- `~/.gitconfig` - Git設定
- `~/.gitignore_global` - グローバルgitignoreパターン
- `~/.config/claude/Claude.md` - Claude開発ガイドライン

## 手動セットアップ

手動でインストールしたい場合：
```bash
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/git/.gitignore_global ~/.gitignore_global
mkdir -p ~/.config && ln -sf ~/dotfiles/config/claude ~/.config/claude
```

## 更新
```bash
cd ~/dotfiles
git pull
./install.sh
```

## アンインストール
```bash
rm ~/.gitconfig ~/.gitignore_global
rm -rf ~/.config/claude
```

## ディレクトリ構成
```
dotfiles/
├── install.sh                    # インストールスクリプト
├── git/
│   ├── .gitconfig               # Gitグローバル設定
│   └── .gitignore_global        # グローバルgitignore
└── config/
    └── claude/
        └── Claude.md            # Claudeガイドライン
```

## ライセンス

MIT