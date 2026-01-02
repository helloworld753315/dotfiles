#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 dotfilesをインストール中..."
echo ""

# Git
echo "📝 Git設定..."
ln -sf "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig
ln -sf "$DOTFILES_DIR/git/.gitignore_global" ~/.gitignore_global

# .gitconfig.localがなければ作成を促す
if [ ! -f ~/.gitconfig.local ]; then
    echo ""
    echo "⚠️  ~/.gitconfig.local が見つかりません"
    echo "   個人設定を追加してください："
    echo ""
    echo "   git config --file ~/.gitconfig.local user.name \"Your Name\""
    echo "   git config --file ~/.gitconfig.local user.email \"your@email.com\""
    echo ""
fi

# Claude
echo "🤖 Claude設定..."
mkdir -p ~/.config
ln -sf "$DOTFILES_DIR/config/claude" ~/.config/claude

echo "✅ インストール完了！"