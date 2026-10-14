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

## dist（构建产物）的发布方式 —— 已裁决：不进 git

品牌前端 `dist/`（197 文件）**不纳入 git 跟踪**，而是作为**发行 tag 的 Release 资产**发布：
`mainsail-dist-woloong-1.0.0.zip`（3.0 MB）。设备/镜像从 Release 取用；
其关键标记哈希记录在 `assets.manifest.json` 的 `build_artifacts.markers` 中。

重新构建：在仓库根 `npm ci && npm run build`（或从 `Mainsail_Theme_Woloong/dist` 取现成产物）→ 打包为 zip → 上传到对应 tag 的 Release。

## 吸收上游更新（重新叠加）

1. 取官方新版（如 v2.19.x）源码；2. 用其整体替换工作区（保留 `.git/`、`woloong-release/`、`Mainsail_Theme_Woloong/`）；
3. 应用定制：`git apply woloong-release/patches/*.patch` + 复制新增文件；4. `tools/verify-assets.sh` 必须全绿；
5. 重新构建 `dist/`；6. 提交 + 打 tag `woloong-<上游版本>.1` 并推送。

> 注：仓库内的 `Mainsail_Theme_Woloong/patch/woloong-forge.patch`（22 KB）为**历史补丁**，经实测**不是可靠的 git 可应用补丁**（index.html 被当作新建、二进制 PNG 缺 index 行）→ 重放一律使用本目录 `patches/` 下的逐文件补丁。
