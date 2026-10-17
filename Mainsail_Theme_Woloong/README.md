# Woloong Forge Theme for Mainsail

为 Mainsail 定制的 Woloong Forge 专属主题包。

## 特性

- **默认主题**：Woloong Forge 设为默认主题，无需在 UI 设置中手动选择
- **专属 Logo**：使用 Woloong Forge Logo（支持 PNG 格式）
- **科技感背景**：自定义 Sidebar 和主区域背景
- **红色主色调**：#fc0000 红色主题装饰
- **动态 Logo**：Sidebar 背景中 Logo 图标慢速碰撞反弹动画
- **悬浮按钮**：左侧导航按钮具有科技感的悬浮效果
- **无亮色模式**：仅暗色模式，保持统一风格

## 文件结构

```
woloong-forge-theme/
├── deploy.sh                  # 零依赖部署脚本
├── patch/
│   └── woloong-forge.patch    # 源码修改 Patch
├── assets/
│   ├── css/
│   │   └── woloongforge.css   # 主题自定义样式
│   └── img/
│       ├── sidebarLogo-woloongforge.png
│       ├── sidebarBackground-woloongforge.png
│       └── mainBackground-woloongforge.png
├── dist/                      # 预构建的 Mainsail 文件（包含主题）
│   ├── index.html
│   ├── css/
│   ├── img/
│   └── ...
└── README.md                  # 本文件
```

## 安装方式：零依赖部署

**适用场景**：Orange Pi / Raspberry Pi 等已安装 Mainsail 但**没有 Node.js 环境**的设备。

**不需要安装任何环境依赖**，只需 `bash` 即可运行。

### 步骤：

1. 将整个 `woloong-forge-theme/` 目录传输到目标机器：

```bash
# 在 Windows 开发机上使用 scp
scp -r woloong-forge-theme pi@192.168.X.XXX:/home/pi/

# 或者使用 U 盘 / 其他方式复制到目标机器
```

2. 在目标机器上运行部署脚本：

```bash
ssh pi@192.168.X.XXX

# 进入主题包目录
cd /home/pi/woloong-forge-theme

# 运行部署脚本（默认部署到 /home/pi/mainsail）
bash deploy.sh

# 或指定自定义路径
bash deploy.sh /var/www/mainsail
```

### deploy.sh 做了什么？

- 检查 `dist/` 目录存在
- 将 `dist/` 下的文件复制到目标 Web 目录（默认 `/home/pi/mainsail`）
- **保留 `.version` 文件**（不会被覆盖）
- 可选：备份目标目录现有文件

**注意**：deploy.sh **不会**先删除目标目录。它会覆盖现有文件，但保留 `.version`。这确保 Mainsail 的版本信息不被破坏。

---

## Mainsail 更新后如何重新应用主题？

当 Mainsail 通过 KIAUH 或 Moonraker 更新后，主题文件会被覆盖。重新运行 `deploy.sh` 即可恢复：

```bash
ssh pi@192.168.X.XXX
cd /home/pi/woloong-forge-theme
bash deploy.sh
```

只要 `dist/` 目录还在，重新运行 `deploy.sh` 即可。

---

## 部署路径说明

| 安装方式         | 常见部署路径                  |
| ------------ | ----------------------- |
| KIAUH 安装     | `/home/pi/mainsail`     |
| 手动安装         | `/var/www/mainsail`     |
| Moonraker 默认 | `~/moonraker/mainsail/` |

**deploy.sh 默认路径**：`/home/pi/mainsail`（KIAUH 标准路径）

如需其他路径，请运行：

```bash
bash deploy.sh /your/custom/path
```

---

## 关于 Patch 文件

`patch/woloong-forge.patch` 是一个**真正的 `.patch` 文件**，包含以下源码修改：

- `src/store/types.ts` — 添加 `logoExtension` 字段到 Theme 接口
- `src/store/variables.ts` — 修改默认主题为 `woloongforge`，注册主题配置
- `src/components/mixins/theme.ts` — 支持 `logoExtension` 的 `sidebarLogo` getter

Patch 文件可以用标准 `patch` 命令应用：

```bash
cd /path/to/mainsail-source
patch -p1 < /path/to/woloong-forge.patch
```

如需重新构建 `dist/`（例如 Mainsail 大版本更新后），可以在开发 PC 上手动应用 patch 并运行 `npm run build`，然后将新的 `dist/` 替换到本主题包中。

---

## 恢复原始主题

如需恢复 Mainsail 默认主题：

```bash
# 如果 deploy.sh 运行时创建了备份
sudo cp -r /home/pi/mainsail.backup.YYYYMMDD_HHMMSS/* /home/pi/mainsail/

# 或者从 Mainsail 官方重新更新
# 通过 KIAUH 或 Moonraker 更新 Mainsail 即可恢复默认
```

---

## 技术细节

### 源码修改摘要

1. **src/store/types.ts**：Theme 接口添加 `logoExtension?: string`
2. **src/store/variables.ts**：
   
   - `defaultTheme = 'woloongforge'`
   
   - `defaultLogoColor = '#fc0000'`
   
   - `defaultPrimaryColor = '#fc0000'`
   
   - 注册 `woloongforge` 主题（含 `logoExtension: 'png'`）
3. **src/components/mixins/theme.ts**：`sidebarLogo` getter 支持 `logoExtension`
4. **public/css/themes/woloongforge.css**：主题自定义样式

### 动态 Logo 动画参数

- 大小：215px
- 动画时长：60s（线性匀速）
- 运动模式：4 方向碰撞反弹（X/Y 速度一致）
- 范围：以左侧红色横线为上边沿，Sidebar 两侧为左右边沿，Sidebar 底部为下边沿

---

## 问题排查

### Q: 部署后页面没有变化？

- 强制刷新浏览器（Ctrl+F5 或 Cmd+Shift+R）
- 清除浏览器缓存

### Q: 部署脚本提示权限不足？

```bash
chmod +x deploy.sh
bash deploy.sh
```

### Q: Mainsail 更新后主题消失？

- 正常行为，更新会覆盖 Web 目录
- 重新运行 `deploy.sh` 即可恢复

### Q: 是否可以将主题设为默认主题？

- 已经是默认主题！`src/store/variables.ts` 中 `defaultTheme = 'woloongforge'`
- 用户首次访问即显示 Woloong Forge 主题，无需在 UI Settings 中选择

---

## 作者

Woloong Forge
