# luci-app-immstore

OpenWrt LuCI应用 - 应用商店

## 功能特点

- 🎨 **卡片式界面**: 类似iStore的现代化应用商店设计
- 📦 **应用管理**: 一键安装/卸载常用OpenWrt应用
- 🏷️ **分类筛选**: 按系统工具、网络服务、NAS等分类浏览
- 🔄 **自动安装**: 自动安装应用及其中文语言包
- ✨ **简单维护**: 仅需在控制器中添加应用配置即可

## 界面预览

查看 `preview.html` 文件可以预览界面效果

## 已内置应用

- 💾 磁盘管理 (Disk Manager)
- 📥 Aria2下载
- 🗂️ 网络共享 (Samba)
- 🐳 Docker容器
- 💻 Web终端 (TTYd)
- 🔌 UPnP
- 🌐 动态DNS (DDNS)
- ⚡ SQM QoS
- 💤 网络唤醒 (WOL)
- 📊 统计图表

## 添加新应用

编辑 `luasrc/controller/immstore.lua` 文件中的 `apps_data` 表，添加应用信息:

```lua
{
    id = "应用ID",
    name = "应用名称",
    name_en = "English Name",
    icon = "📦",  -- Emoji图标
    package = "luci-app-xxx",  -- 主包名
    i18n = "luci-i18n-xxx-zh-cn",  -- 中文包(可选)
    description = "应用描述",
    category = "system"  -- 分类: system/network/nas/services
}
```

## 安装方法

1. 将此目录复制到OpenWrt源码的 `package/luci-app-immstore/` 目录下

2. 在OpenWrt编译环境中执行:
```bash
make menuconfig
# 选择: LuCI -> Applications -> luci-app-immstore
```

3. 编译:
```bash
make package/luci-app-immstore/compile V=s
```

4. 生成的IPK文件位于: `bin/packages/<arch>/luci/luci-app-immstore_*.ipk`

## 使用方法

1. 安装后在OpenWrt的LuCI界面中进入: **系统 -> 应用商店**

2. 功能说明:
   - **更新软件源**: 点击右上角"更新软件源"按钮执行 opkg update
   - **分类浏览**: 点击顶部标签筛选不同类别的应用
   - **安装应用**: 点击应用卡片的"安装"按钮,自动安装应用及中文包
   - **卸载应用**: 已安装的应用会显示"已安装"标记,可点击"卸载"按钮移除

## 设计理念

- **简单维护**: 不需要复杂的元数据库,只需在Lua代码中维护应用列表
- **快速部署**: 添加新应用只需几行配置代码
- **用户友好**: 现代化的卡片式UI,直观易用
- **自动化**: 自动处理依赖包和语言包安装

## 与iStore的区别

- iStore需要维护完整的元数据仓库
- 本项目直接在代码中配置应用列表,更简单直接
- 适合个人使用或小型团队维护常用应用集合

## 技术栈

- LuCI Framework
- Lua (后端逻辑)
- HTML/CSS/JavaScript (前端界面)
- opkg (软件包管理)

## 许可证

MIT
