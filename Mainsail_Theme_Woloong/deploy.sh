#!/bin/bash
# Woloong Forge Theme - Deploy Script
# 零依赖部署脚本：将预构建的 dist/ 文件直接复制到 Mainsail Web 目录
#
# 使用方式：
#   1. 在包含 dist/ 和本脚本的目录中运行：
#      bash deploy.sh
#   2. 或指定自定义目标路径：
#      bash deploy.sh /home/pi/mainsail

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 默认目标路径（KIAUH 标准安装路径）
DEFAULT_TARGET="/home/pi/mainsail"
TARGET_DIR="${1:-$DEFAULT_TARGET}"

echo "========================================"
echo "  Woloong Forge Theme - Deploy"
echo "========================================"
echo ""

# 检查 dist/ 目录
if [ ! -d "$DIST_DIR" ]; then
    echo -e "${RED}Error: dist/ 目录不存在于 $SCRIPT_DIR${NC}"
    echo ""
    echo "请确保本脚本和 dist/ 目录在同一目录下。"
    echo "dist/ 目录应包含构建后的 Mainsail 文件（index.html, assets/, css/ 等）。"
    exit 1
fi

echo -e "Dist 目录: ${CYAN}$DIST_DIR${NC}"
echo -e "目标目录: ${CYAN}$TARGET_DIR${NC}"
echo ""

# 检查目标目录
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: 目标目录不存在: $TARGET_DIR${NC}"
    echo ""
    echo "请确认 Mainsail Web 目录路径正确。"
    echo "常见路径："
    echo "  - KIAUH 安装: /home/pi/mainsail"
    echo "  - 手动安装:   /var/www/mainsail"
    echo ""
    echo "如需指定其他路径，请运行："
    echo "  bash deploy.sh /your/custom/path"
    exit 1
fi

# 检查是否有 .version 文件需要保留
VERSION_BACKUP=""
if [ -f "$TARGET_DIR/.version" ]; then
    VERSION_BACKUP=$(cat "$TARGET_DIR/.version")
    echo -e "${YELLOW}检测到 .version 文件，将保留${NC}"
fi

# 备份目标目录中的现有文件（可选）
BACKUP_DIR=""
read -p "是否在复制前备份目标目录现有文件？ (y/N): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    BACKUP_DIR="$TARGET_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    echo ""
    echo -e "${YELLOW}正在备份到: $BACKUP_DIR${NC}"
    cp -r "$TARGET_DIR" "$BACKUP_DIR"
    echo -e "${GREEN}  备份完成${NC}"
fi
echo ""

# 执行部署
echo -e "${CYAN}正在部署文件...${NC}"

# 统计文件数量
FILE_COUNT=$(find "$DIST_DIR" -type f | wc -l)
echo "  将复制 $FILE_COUNT 个文件"

# 复制 dist/ 下的所有文件到目标目录
# 使用 rsync 如果可用，否则用 cp -r
if command -v rsync &> /dev/null; then
    rsync -a --exclude='.version' "$DIST_DIR/" "$TARGET_DIR/"
else
    # 遍历复制，跳过 .version
    for item in "$DIST_DIR"/*; do
        name=$(basename "$item")
        if [ "$name" = ".version" ]; then
            continue
        fi
        if [ -d "$item" ]; then
            rm -rf "$TARGET_DIR/$name" 2>/dev/null || true
            cp -r "$item" "$TARGET_DIR/"
        else
            cp "$item" "$TARGET_DIR/"
        fi
    done
fi

# 如果之前有 .version，确保它被保留（即使 dist/ 中也有 .version）
if [ -n "$VERSION_BACKUP" ]; then
    echo "$VERSION_BACKUP" > "$TARGET_DIR/.version"
    echo -e "  ${GREEN}✓ 保留 .version 文件${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Woloong Forge 主题已部署到: $TARGET_DIR"
echo ""
if [ -n "$BACKUP_DIR" ]; then
    echo "备份位置: $BACKUP_DIR"
    echo ""
fi
echo "请刷新浏览器查看效果。"
echo "  地址: http://192.168.X.XXX/"
echo ""
echo "如需恢复原始主题："
if [ -n "$BACKUP_DIR" ]; then
    echo "  cp -r $BACKUP_DIR/* $TARGET_DIR/"
else
    echo "  由于没有备份，请从 Mainsail 官方更新恢复。"
fi
