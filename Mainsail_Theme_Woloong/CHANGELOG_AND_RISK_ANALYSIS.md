# Mainsail 更新影响与风险评估记录

> 记录日期：2025年
> 记录人：Woloong Forge 主题维护
> 用途：追踪 Mainsail 版本更新对 Woloong Forge 主题及 Patch 的影响

---

## 一、背景

当前主题基于 Mainsail **v2.18.2** 构建。通过 `deploy.sh` 将预构建的 `dist/` 文件直接复制到 `/home/pi/mainsail` 目录实现部署。

每次 Mainsail 通过 KIAUH 或 Moonraker 更新后，需要重新运行 `deploy.sh` 恢复主题。但这会带来**版本回退风险**（用旧版 dist 覆盖新版 dist）。

---

## 二、Mainsail 2025年更新方向总览

从 GitHub Releases 和 CHANGELOG 整理：

| 版本 | 日期 | 核心更新方向 |
|------|------|------------|
| **v2.12.0** | 2024-07 | 内置主题系统正式引入，新增 Voron/LDO/YUMI 等赞助商主题 |
| **v2.13.0** | 2024-12 | **每主题专用 CSS 文件机制** (#1958)、Editor 文件结构 sidebar |
| **v2.14.0** | 2025-04 | Console 多行输入、Temperature 传感器扩展、依赖升级 |
| **v2.15.0** | 2025-11 | AFC / HappyHare 多色打印支持、Webcam 旋转 |
| **v2.16.0** | 2025-12 | AFC 完善、Flowguard 堵料检测、温度传感器 AHT 系列 |
| **v2.16.1** | 2025-12 | **Sidebar 模板重构** (#2355)、大量 Bug 修复 |
| **v2.17.0** | 2026-01 | LED Effects 面板、Dialog 现代化、HappyHare 完善 |
| **v2.18.0** | 2026-06 | Vite v7 升级、ESLint 规则更新、AI 贡献指南 |

**2025年至今更新集中在：**
- 多色打印（AFC + HappyHare 多色换料系统）
- 温度传感器扩展（AHT1X/2X/3X、SGP40、temperature_combined）
- Webcam 改进（旋转、iframe、ICE 服务）
- UI 重构（Sidebar 模板、Dialog 现代化）
- 依赖升级（Vite v7、Gcode-Viewer v3.7+）
- 本地化（20+ 语言翻译更新）

---

## 三、Patch 修改的具体内容

我们的 Patch 修改了以下三个源码文件：

### 1. `src/store/types.ts`
- 在 `Theme` 接口中添加 `logoExtension?: string`
- 目的：支持 PNG 格式 Logo（其他主题都是 SVG）

### 2. `src/store/variables.ts`
- `defaultTheme = 'woloongforge'`（原为 'mainsail'）
- `defaultLogoColor = '#fc0000'`（原为 '#D41216'）
- `defaultPrimaryColor = '#fc0000'`（原为 '#2196f3'）
- `mainsail` 主题 colorLogo 固定为 '#D41216'（避免被 defaultLogoColor 影响）
- 在 `themes` 数组中注册 `woloongforge` 主题：
  - `logoExtension: 'png'`
  - `sidebarBackground: { show: true }`
  - `mainBackground: { show: true }`
  - `css: true`

### 3. `src/components/mixins/theme.ts`
- `sidebarLogo` getter 支持 `logoExtension` 字段
- 从 `this.theme.logoExtension ?? 'svg'` 决定 Logo 文件扩展名

---

## 四、风险分析矩阵

| 风险项 | 风险等级 | 触发条件 | 影响范围 | 当前状态 |
|--------|---------|---------|---------|---------|
| **版本回退（旧 dist 覆盖新版）** | 🔴 **高** | KIAUH 更新后运行 deploy.sh | 全部功能 | 持续存在 |
| **Sidebar 模板重构导致 CSS 失效** | 🟡 **中** | v2.16.1+ 的 Sidebar 结构变更 | 按钮悬浮/激活效果 | 目前正常 |
| **Vuetify 依赖升级导致 CSS 类名变化** | 🟡 **中** | Vuetify 2.x 版本变更 | 所有 Vuetify 组件样式覆盖 | 目前正常 |
| **Patch 文件在源码中冲突** | 🟡 **中** | `variables.ts` 或 `theme.ts` 被官方修改 | 默认主题/Logo 格式 | 目前正常 |
| **主题 CSS 文件机制被移除** | 🟢 **低** | 官方取消 per-theme CSS 支持 | 全部自定义样式 | 极不可能 |
| **Logo/背景图片路径变更** | 🟢 **低** | 官方更改图片加载逻辑 | 背景/Logo 不显示 | 极不可能 |
| **新增功能与旧版前端不兼容** | 🟡 **中** | Moonraker API 变更 | 新功能缺失/报错 | 暂未发现 |

---

## 五、详细风险说明

### 🔴 风险 1：版本回退（最重要）

**问题描述：**
`deploy.sh` 将基于 v2.18.2 的 `dist/` 覆盖到 `/home/pi/mainsail`。如果 Mainsail 已被 KIAUH 更新到更高版本（如 v2.19.0），前端会回退到 v2.18.2，而 Moonraker 期望的是 v2.19.0 的 API。

**可能后果：**
- 新版 Moonraker API 变更，旧前端不兼容 → 功能报错或缺失
- 新功能（如 LED Effects 面板、HappyHare 更新）在前端中不存在
- Bug 修复和性能优化不会生效
- 极端情况下，如果 Moonraker 删除了旧 API，前端可能无法加载

**缓解措施：**
1. Mainsail 更新后，先不急着运行 deploy.sh，确认新版正常工作
2. 如果新版功能不需要，直接用 deploy.sh 覆盖（可接受）
3. 如果新版功能需要，需要从新版源码重新构建 dist/
4. 长期方案：将 Woloong Forge 主题作为独立资源注入，不覆盖整个 dist/

---

### 🟡 风险 2：Sidebar 模板重构影响 CSS

**问题描述：**
v2.16.1 (#2355) 对 Sidebar 进行了模板重构：
> "Sidebar: Simplify template structure and active state handling"

我们的 CSS 大量依赖以下选择器：
```css
.v-navigation-drawer .v-list-item          /* 按钮默认 */
.v-navigation-drawer .v-list-item:hover  /* 悬浮效果 */
.v-navigation-drawer .v-list-item--active /* 激活状态 */
.v-navigation-drawer .v-list-item .v-icon /* 图标 */
.v-navigation-drawer .v-list-item__title /* 文字 */
```

**如果触发：**
- 如果 Vuetify 的 `v-list-item` DOM 结构变化（如新增 wrapper 层），选择器可能失效
- 按钮的悬浮/激活效果消失，恢复为默认样式

**当前状态：** v2.16.1 已发布，但我们当前的 v2.18.2 构建已包含此版本。目前主题正常，说明 v2.16.1 的重构未影响这些选择器。

---

### 🟡 风险 3：Vuetify 依赖升级

**问题描述：**
v2.14.0 (#2168) 更新了 Vuetify 依赖。如果未来 Vuetify 升级到 3.x（Mainsail 是 Vue 2.7，Vuetify 2.x），CSS 类名可能变更。

**实际评估：**
- Mainsail 使用 Vue 2.7 + Vuetify 2，Vuetify 2.x 已停止 major 更新
- Vuetify 3 是 Vue 3 专用，Mainsail 短期内不会迁移到 Vue 3
- 因此 Vuetify 2.x 的 CSS 类名在可预见未来保持稳定

---

### 🟡 风险 4：Patch 文件冲突

**问题描述：**
如果官方修改了 `variables.ts` 或 `theme.ts`，Patch 可能无法干净应用。

**易冲突位置：**
- `variables.ts` 中 `themes` 数组末尾（我们在此插入 woloongforge 主题）
- `variables.ts` 中 `defaultTheme` 默认值（我们改为 'woloongforge'）
- `theme.ts` 中 `sidebarLogo` getter 的 return 语句（我们插入 logoExtension 逻辑）

**当前状态：** 查看 v2.17.0 和 v2.18.0 的 CHANGELOG，这些文件未被官方修改。但未来如果官方也添加 `logoExtension` 支持，Patch 可能冲突。

---

### 🟢 风险 5/6：主题机制被移除或路径变更

**问题描述：**
每主题 CSS 文件是 v2.13.0 官方引入的正式功能 (#1958)，v2.16.1 仍在维护（Yumi logo 更新）。

**评估：** 极不可能被移除，这是官方推荐的主题扩展方式。

---

## 六、已知问题清单

| 编号 | 问题 | 发现时间 | 状态 | 备注 |
|------|------|---------|------|------|
| 1 | 首次打开页面时动态 Logo 位置不居中 | 部署初期 | 已修复 | 通过 CSS 动画起始位置调整 |
| 2 | 悬浮按钮背景透明度过高 | 调试中 | 已修复 | 改为不透明实心背景 |
| 3 | 动态 Logo 碰到边缘反弹不均匀 | 调试中 | 已修复 | 统一为 60s linear 动画 |
| 4 | 动态 Logo 大小不一致 | 调试中 | 已修复 | 统一为 215px |
| 5 | Mainsail 更新后主题消失 | 预期问题 | 未触发 | 重新运行 deploy.sh 可恢复 |

---

## 七、应急处理预案

### 情况 A：Mainsail 更新后，deploy.sh 导致页面异常

**步骤：**
1. SSH 到 Orange Pi
2. 检查浏览器控制台是否有 API 错误
3. 如果确认是版本不匹配：
   ```bash
   # 恢复 Mainsail 默认（从 KIAUH 重新更新）
   cd ~/kiauh
   ./kiauh.sh
   # 选择 Update Mainsail
   
   # 然后需要从新版源码重新构建主题
   ```
4. 如果仅 CSS 失效：
   - 检查 `.v-navigation-drawer .v-list-item` 选择器是否仍匹配 DOM
   - 在浏览器 DevTools 中验证选择器
   - 调整 CSS 选择器后重新构建

### 情况 B：Patch 在新版本中冲突

**步骤：**
1. 查看最新 `variables.ts` 和 `theme.ts` 的结构
2. 手动将修改合并到新版源码中
3. 重新生成 `woloong-forge.patch`
4. 运行 `npm run build` 构建新的 dist/

### 情况 C：Sidebar 样式完全失效

**步骤：**
1. 在浏览器 DevTools 中检查实际 DOM 结构
2. 对比当前 CSS 选择器是否匹配
3. 更新 CSS 选择器后重新构建

---

## 八、长期建议

### 方案 1：维持现状（当前采用）
- 优点：简单，无需维护源码
- 缺点：每次更新后可能版本不匹配，需手动验证
- 适用：Mainsail 使用稳定，不频繁更新的场景

### 方案 2：分离主题资源（未来方向）
- 将 `woloongforge.css` 和主题图片作为独立文件，不覆盖整个 dist/
- 但 `defaultTheme` 和 `logoExtension` 是编译到 JS 中的，无法完全分离
- 需要官方支持运行时主题加载，目前不具备

### 方案 3：提交官方 PR（最佳但复杂）
- 将 Woloong Forge 作为内置主题提交到 Mainsail 仓库
- 需要 SVG 格式 Logo（当前是 PNG）
- 需要签署 DCO，遵循 PR 流程
- 优点是：每次更新自动包含，零维护成本

---

## 九、参考链接

- Mainsail Releases: https://github.com/mainsail-crew/mainsail/releases
- Mainsail CHANGELOG: https://github.com/mainsail-crew/mainsail/blob/develop/CHANGELOG.md
- 主题系统 PR: https://github.com/mainsail-crew/mainsail/pull/1958
- Sidebar 重构 PR: https://github.com/mainsail-crew/mainsail/pull/2355

---

## 十、更新记录

| 日期 | 版本 | 说明 |
|------|------|------|
| - | v2.18.2 | 首次构建主题，基于此版本 |
| - | - | 后续更新时在此处追加记录 |

---

*本文件为调研记录，如后续使用过程中出现问题，应根据实际变化情况进行修复。*
