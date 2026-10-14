# woloong-release —— 发行树元数据（Woloong-mainsail）

仓库 `main` = **官方 Mainsail v2.18.2 + woloong 定制**的合并体（自有发行树，D20）。**版本控制与跟踪的对象是本仓库。**

## 定制清单（8 项，逐项见 assets.manifest.json）

| 类别 | 路径 |
| --- | --- |
| 受控文件（打补丁） | `index.html`、`src/components/mixins/theme.ts`、`src/store/types.ts`、`src/store/variables.ts` |
| 新增文件（复制） | `public/css/themes/woloongforge.css`、`public/img/themes/{mainBackground,sidebarBackground,sidebarLogo}-woloongforge.png` |
| 资产容器 | `Mainsail_Theme_Woloong/`（assets、deploy.sh、README、patch、**已构建 dist**） |

## 目录

| 路径 | 作用 |
| --- | --- |
| `assets.manifest.json` / `.tsv` | 定制文件逐项 SHA256（校验与重放依据） |
| `baseline/` | 官方 v2.18.2 的 4 个原始受控文件（打补丁基线） |
| `patches/` | 逐文件统一差异补丁（共 85 行） |
| `tools/verify-assets.sh` | 按清单校验定制完整性 |

## 吸收上游更新（重新叠加）

1. 取官方新版（如 v2.19.x）源码；2. 用其整体替换工作区（保留 `.git/`、`woloong-release/`、`Mainsail_Theme_Woloong/`）；
3. 应用定制：`git apply woloong-release/patches/*.patch` + 复制新增文件；4. `tools/verify-assets.sh` 必须全绿；
5. 重新构建 `dist/`；6. 提交 + 打 tag `woloong-<上游版本>.1` 并推送。

> 注：仓库内的 `Mainsail_Theme_Woloong/patch/woloong-forge.patch`（22 KB）为**历史补丁**，经实测**不是可靠的 git 可应用补丁**（index.html 被当作新建、二进制 PNG 缺 index 行）→ 重放一律使用本目录 `patches/` 下的逐文件补丁。
