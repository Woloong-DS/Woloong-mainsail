#!/bin/bash
# ============================================================================
# check-upstream.sh —— 审计「我们的发行树」与「上游发布」的对应关系
#   判定：woloong-release/upstream.json 里的 base_ref 是否等于上游最新 tag
#   若落后：**逐一列出所有未吸收的上游版本**（不遗漏任何一个），退出码 1
# 用法: bash woloong-release/tools/check-upstream.sh
# ============================================================================
set -u
cd "$(dirname "$0")/.." || exit 1        # → woloong-release/
root="$(cd .. && pwd)"
J="upstream.json"
[ -f "$J" ] || { echo "[FAIL] 缺少 $J（基线声明）"; exit 2; }
REPO=$(python3 -c "import json;print(json.load(open('$J',encoding='utf-8'))['repo'])")
BASE=$(python3 -c "import json;print(json.load(open('$J',encoding='utf-8'))['base_ref'])")
BASESHA=$(python3 -c "import json;print(json.load(open('$J',encoding='utf-8')).get('base_sha',''))")
git -C "$root" remote get-url upstream >/dev/null 2>&1 || git -C "$root" remote add upstream "https://github.com/$REPO.git"
# 不再对本地 tag 做 fetch：
#   我们的发行 tag 与上游同名但指向不同提交（v2.19.0 = 我们的定制提交），
#   `fetch --tags` 会因同名 tag 冲突直接失败，`--force` 则会把我们的 tag 覆盖掉。
#   审计只用 ls-remote 直读上游远端；真正需要本地对象的是 fork-sync，它自己会 fetch。
# ★ 上游最新版本必须取自「上游远端」的 tag，不能取本仓库的 tag：
#   本仓库同时存在我们自己的发行 tag（与上游同名，如 v2.19.0 指向定制提交），
#   用 `git tag` 取会把我们自己的 tag 当成"上游最新" → 版本号一对上就永远判"已最新"。
UPURL=$(git -C "$root" remote get-url upstream)
TAGS=$(git -C "$root" ls-remote --tags --refs "$UPURL" | sed 's#.*refs/tags/##' | grep -Ev '^woloong-' | sort -V)
LATEST=$(printf '%s\n' "$TAGS" | grep . | tail -1)
echo "上游仓库 : $REPO"
echo "我们的基线: $BASE  ($BASESHA)"
echo "上游最新  : $LATEST"
if [ -z "$LATEST" ]; then echo '[WARN] 上游没有任何 tag（可能改用分支发布）'; exit 1; fi
if [ "$BASE" = "$LATEST" ]; then
  echo '[OK] 上游无新版本（基线 = 上游最新 tag）'
  echo '[注] 这只说明"上游没有新版"；本仓库该版本是否已发布 Release，由 workflow 的「发布状态审计」判定'
  exit 0
fi
# TAGS 已按版本升序；取 base 之后的所有版本 → 逐个列出待吸收
MISSED=$(printf '%s\n' "$TAGS" | awk -v base="$BASE" '{ if (f) print; if ($0==base) f=1 }')
# 基线不在上游 tag 列表里（基线异常/被改名）→ 上游全部版本都算待吸收
if [ "$BASE" != "$LATEST" ] && [ -z "$MISSED" ]; then MISSED=$(printf '%s\n' "$TAGS"); fi
N=$(printf '%s\n' "$MISSED" | grep -c . || true)
echo "[BEHIND] 落后上游，未吸收的版本共 $N 个（逐一列出，确保不遗漏）:"
printf '%s\n' "$MISSED" | sed 's/^/  - /'
echo "处理：跑 upstream-sync 工作流（或本地 fork-sync）吸收到 $LATEST"
exit 1
