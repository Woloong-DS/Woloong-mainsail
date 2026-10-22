<p align="center">
  <img src="public/img/themes/sidebarLogo-woloongforge.png" alt="Woloong" height="120">
</p>

<h1 align="center">Woloong-mainsail</h1>

<p align="center">
  <b>官方 Mainsail + Woloong 定制</b><br>
  面向 Klipper 的响应式 Web 前端 · 内置 Woloong Forge 主题 · 随上游版本滚动更新
</p>

<p align="center">
  <a href="https://github.com/Woloong-DS/Woloong-mainsail/releases">Releases</a> ·
  <a href="woloong-release/README.md">定制说明</a> ·
  <a href="https://github.com/mainsail-crew/mainsail">上游仓库</a> ·
  <a href="https://docs.mainsail.xyz">上游文档</a>
</p>

---

## 这是什么

本仓库是 [mainsail-crew/mainsail](https://github.com/mainsail-crew/mainsail) 的**自有发行树**：

> `main` = 官方 Mainsail（当前基线 v2.19.0） + Woloong 定制

构建产物**不进 git**，以 **Release 资产** 的形式发布，供 Woloong-OS 镜像与 Moonraker 的
zip 更新器直接取用。本仓库只做「吸收上游 → 重放定制 → 门禁 → 构建 → 发布」，不向上游提交 PR。

| 项目 | 说明 |
| --- | --- |
| 上游 | `mainsail-crew/mainsail`（GPL-3.0，版权归上游作者） |
| 定制清单 | [`woloong-release/assets.manifest.tsv`](woloong-release/assets.manifest.tsv)（逐文件 SHA256） |
| 当前基线 | [`woloong-release/upstream.json`](woloong-release/upstream.json) 的 `base_ref` |
| 构建产物 | `dist/`（不进 git，发布为 Release 资产） |

---

## 版本与发布规则

版本号**直接采用上游发布版本**，加 `woloong-` 前缀，便于一一对照；不再与上游 tag 同名，避免同名 tag 指向不同提交而互相覆盖。

| 对象 | 规则 | 示例 |
| --- | --- | --- |
| git tag | `woloong-<上游 tag>` | `woloong-v2.19.0` |
| Release 标题 | 与 tag 完全一致 | `woloong-v2.19.0` |
| Release 资产 | `<tag>.zip`（唯一资产） | `woloong-v2.19.0.zip` |
| 包内 `release_info.json` | `version` 与 `asset_name` 均与上述一致 | — |

> Moonraker 判定「是否最新」用的是**字符串相等**（`release_info.json.version` vs Release `tag_name`），
> 所以这四个地方的版本串必须逐字一致。上游发布 v2.20.0 时，本仓库自动产出
> `woloong-v2.20.0` 与 `woloong-v2.20.0.zip`。

**当前发行：见 [Releases](https://github.com/Woloong-DS/Woloong-mainsail/releases)。**

---

## 安装 / 更新

### A. 交给 Moonraker 自动更新（推荐）

在 `moonraker.conf` 中：

```ini
[update_manager mainsail]
type: web
repo: Woloong-DS/Woloong-mainsail
path: ~/mainsail
```

保存后重启 Moonraker，之后在网页端的「机器 → 更新」里即可看到版本并一键更新。

### B. 手动更新（脚本）

```bash
tag=$(curl -fsSL https://api.github.com/repos/Woloong-DS/Woloong-mainsail/releases/latest | jq -r .tag_name)
tmp=$(mktemp -d)
curl -fsSL -o "$tmp/$tag.zip" \
  "https://github.com/Woloong-DS/Woloong-mainsail/releases/download/$tag/$tag.zip"
unzip -oq "$tmp/$tag.zip" -d ~/mainsail
rm -rf "$tmp"
echo "已更新到 $tag"
```

### C. 随镜像预装

Woloong-OS 镜像已内置本前端（`~/mainsail`），镜像烧录后无需手动安装，
后续更新走 A 或 B。

---

## 上游同步与发布（自动化）

由 [`.github/workflows/upstream-sync.yml`](.github/workflows/upstream-sync.yml) 承担，每周一 03:23 UTC 定时审计，也可手动触发。

```
上游版本审计 ──┬─ 无新版且已发布 ──────────────→ 结束（约 15 秒，零产出）
               ├─ 无新版但本版本尚无 Release ──→ 仅构建 + 补发布资产（不动 tag）
               └─ 有新版 ───────────────────→ 重叠加 → 门禁 → 构建 → 打包 → 发布 → 通知下游
```

- **重叠加**：上游整树替换 → 重放定制补丁 → 应用 `remove.list` → 更新基线声明；
  结果与当前树完全一致时**不产生任何提交、不移动 tag**（幂等）。
- **门禁**：定制文件 SHA256 全量校验 + 构建产物中必须含 `woloongforge` 标记，任一不过即拒绝发布。
- **漂移保护**：上游若改动了被打补丁的受控文件，流程会**停下来**并要求人工重锚定
  （更新 `woloong-release/baseline/` → 重新生成补丁 → 更新清单哈希），不会带着错补丁发布。
- **通知下游**：发布成功后以 `repository_dispatch`（事件 `component-released`）通知
  Woloong-OS 更新适配层（`pin` / `pin_ref` / 资产名）。

---

## 定制内容

受控文件（打补丁）与新增文件（直接复制）共 17 项，逐项记录在
[`woloong-release/assets.manifest.tsv`](woloong-release/assets.manifest.tsv)：

| 类别 | 路径 |
| --- | --- |
| 受控文件（打补丁） | `index.html`、`src/components/mixins/theme.ts`、`src/store/types.ts`、`src/store/variables.ts` |
| 新增主题 | `public/css/themes/woloongforge.css`、`public/img/themes/*-woloongforge.png` |
| 资产容器 | `Mainsail_Theme_Woloong/`（主题源文件、部署脚本、历史补丁） |
| 发行元数据 | `woloong-release/`（基线、补丁、清单、工具） |

定制细节与风险说明见 [`woloong-release/README.md`](woloong-release/README.md)。

---

## 仓库结构

| 路径 | 作用 |
| --- | --- |
| `src/`、`public/` | Mainsail 源码与静态资源（含 Woloong 定制） |
| `woloong-release/` | 发行元数据：基线、补丁、清单、`upstream.json`、工具脚本 |
| `Mainsail_Theme_Woloong/` | 主题资产容器（源文件 + 已构建 `dist`） |
| `.github/workflows/` | `upstream-sync`：审计 / 重叠加 / 门禁 / 构建 / 发布 / 通知 |
| `cypress/`、`tests/` | 上游的端到端与单元测试 |

---

## 本地开发

```bash
npm ci                 # 安装依赖
npm run serve          # 开发服务器 http://localhost:8080
npm run build          # 生产构建（产物在 dist/）
npm run lint           # ESLint
npm run test:unit      # Vitest
```

> 本仓库要求 **LF** 换行与 Vue Class Component 写法，提交前请跑 `npm run format`。
> 详见 [`AGENTS.md`](AGENTS.md) 与 [`agent_docs/`](agent_docs/)。

---

## 发布产物形态

`woloong-v2.19.0.zip` 解压后即为可直接托管的静态站点：

```
index.html  assets/  css/  img/  fonts/  config.json
manifest.webmanifest  sw.js  workbox-*.js  .version
release_info.json   # {"project_owner":"Woloong-DS","project_name":"Woloong-mainsail",
                    #  "version":"woloong-v2.19.0","asset_name":"woloong-v2.19.0.zip"}
```

---

## 维护者须知

- **改动任何定制文件后**，必须同步更新 `woloong-release/assets.manifest.tsv`（与 `.json`）中的
  `sha256` / `bytes`，否则 CI 的「定制资产完整性」门禁会失败：
  ```bash
  bash woloong-release/tools/verify-assets.sh    # 本地自检
  ```
- **修改本 README 也一样**（它本身是受清单保护的定制文件）。
- 手动重叠加：`bash woloong-release/tools/fork-sync.sh . --upstream-ref <上游 tag> --tag woloong-<上游 tag>`。
- 审计上游是否落后：`bash woloong-release/tools/check-upstream.sh`。

---

## 许可与致谢

本项目遵循上游 **GPL-3.0** 许可，Mainsail 的版权归 [mainsail-crew](https://github.com/mainsail-crew) 及其贡献者所有。
Woloong 定制部分由 [Woloong-DS](https://github.com/Woloong-DS) 维护。
