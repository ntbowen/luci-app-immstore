# luci-app-immstore

OpenWrt/ImmortalWrt LuCI 应用商店

## 功能特点

- 🎨 **卡片式界面**: 现代化应用商店设计，支持暗黑模式
- 📦 **动态应用列表**: 自动从软件源获取所有 luci-app-* 包
- 🏷️ **分类筛选**: 按系统工具、网络服务、NAS、服务等分类浏览
- 🔍 **搜索功能**: 支持按名称、描述搜索应用
- ✏️ **自定义编辑**: 点击卡片可编辑应用名称、图标、描述
- 🖼️ **图标支持**: 内置 emoji 图标或自定义 URL 图标
- 💾 **缓存机制**: 应用列表缓存到本地，加快加载速度
- 🔄 **手动刷新**: 点击刷新按钮从软件源更新列表

## 界面预览

![应用商店界面](preview.png)

## 内置精选应用 (23个)

| 分类 | 应用 |
|------|------|
| 系统工具 | argon主题、磁盘管理、终端、文件管理、CPU调频 |
| 网络服务 | UPnP、DDNS-Go、网络唤醒、HomeProxy、PassWall、OpenClash |
| NAS | 网络共享、qBittorrent、Transmission、Aria2下载 |
| 服务 | Docker、内网穿透frps、Modem Band |

## 动态应用

除内置精选应用外，自动从软件源获取所有 `luci-app-*` 包（约 500+ 个），显示在"更多应用"分类中。

## 安装方法

### 方法一：编译安装

```bash
# 1. 克隆到 package 目录
git clone https://github.com/leesonaa/luci-app-immstore.git package/luci-app-immstore

# 2. 编译
make menuconfig  # 选择 LuCI -> Applications -> luci-app-immstore
make package/luci-app-immstore/compile V=s
```

### 方法二：IPK 安装

下载预编译的 IPK 文件，通过 LuCI 或命令行安装：

```bash
opkg install luci-app-immstore_*.ipk
# 或 APK (ImmortalWrt 24+)
apk add luci-app-immstore_*.apk
```

## 使用方法

1. 安装后进入 LuCI 界面：**应用商店**

2. 功能说明：
   - **分类标签**: 点击顶部标签筛选不同类别
   - **搜索框**: 输入关键词搜索应用
   - **刷新列表**: 点击"🔄 刷新列表"从软件源更新
   - **安装/卸载**: 点击卡片底部按钮
   - **编辑应用**: 点击卡片打开编辑对话框

3. 自定义应用信息：
   - 点击任意应用卡片
   - 修改名称、描述、图标、分类
   - 点击保存，信息存储在 `/etc/immstore_apps.json`

## 添加内置应用

编辑 `luasrc/controller/immstore.lua` 中的 `apps_data` 表：

```lua
{
    id = "myapp",
    name = "我的应用",
    name_en = "My App",
    icon = "🚀",  -- emoji 或 URL
    package = "luci-i18n-myapp-zh-cn",  -- 语言包名
    description = "应用描述",
    category = "system"  -- system/network/nas/services/other
}
```

## 技术架构

- **后端**: LuCI + Lua
- **前端**: HTML/CSS/JavaScript
- **包管理**: 兼容 opkg 和 apk (ImmortalWrt 24+)
- **缓存**: JSON 文件存储 (`/etc/immstore_apps.json`)

## 与 iStore 的区别

| 特性 | immstore | iStore |
|------|----------|--------|
| 元数据 | 代码内置 + 动态获取 | 独立仓库 |
| 维护成本 | 低 | 高 |
| 应用数量 | 软件源全部 luci-app | 手动维护 |
| 自定义 | 支持编辑 | 不支持 |
| 适用场景 | 个人/小团队 | 大型发行版 |

## 许可证

MIT License

## 致谢

- [OpenWrt](https://openwrt.org/)
- [ImmortalWrt](https://immortalwrt.org/)
- [LuCI](https://github.com/openwrt/luci)
