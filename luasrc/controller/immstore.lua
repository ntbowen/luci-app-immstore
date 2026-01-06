module("luci.controller.immstore", package.seeall)

local http = require "luci.http"
local json = require "luci.jsonc"

function index()
    -- 直接显示应用商店，无二级菜单
    entry({"admin", "immstore"}, template("immstore/index"), _("App Store"), 60)
    entry({"admin", "immstore", "get_apps"}, call("action_get_apps"))
    entry({"admin", "immstore", "install_app"}, call("action_install_app"))
    entry({"admin", "immstore", "remove_app"}, call("action_remove_app"))
end

-- 应用列表配置（简单维护，只需添加应用信息）
-- 只需维护语言包名，opkg会自动安装依赖的主包
local apps_data = {
    {
        id = "argon",
        name = "argon主题",
        name_en = "Argon Theme",
        icon = "🎨",
        package = "luci-i18n-argon-config-zh-cn",
        description = "Argon主题",
        category = "system"
    },
    {
        id = "diskman",
        name = "磁盘管理",
        name_en = "Disk Manager",
        icon = "💾",
        package = "luci-i18n-diskman-zh-cn",
        description = "磁盘分区、格式化、挂载管理工具",
        category = "system"
    },
    {
        id = "samba",
        name = "网络共享",
        name_en = "Samba",
        icon = "🗂️",
        package = "luci-i18n-samba4-zh-cn",
        description = "Windows网络文件共享服务",
        category = "nas"
    },
    {
        id = "docker",
        name = "Docker",
        name_en = "Docker",
        icon = "🐳",
        package = "luci-i18n-dockerman-zh-cn",
        description = "Docker容器管理",
        category = "services"
    },
    {
        id = "ttyd",
        name = "终端",
        name_en = "Terminal",
        icon = "💻",
        package = "luci-i18n-ttyd-zh-cn",
        description = "Web终端访问工具",
        category = "system"
    },
    {
        id = "upnp",
        name = "UPnP",
        name_en = "UPnP",
        icon = "🔌",
        package = "luci-i18n-upnp-zh-cn",
        description = "UPnP端口自动映射",
        category = "network"
    },
    {
        id = "ddns",
        name = "DDNS-Go",
        name_en = "DDNS-Go",
        icon = "🌐",
        package = "luci-i18n-ddns-go-zh-cn",
        description = "动态域名解析服务",
        category = "network"
    },
    {
        id = "wol",
        name = "网络唤醒",
        name_en = "Wake on LAN",
        icon = "💤",
        package = "luci-i18n-wol-zh-cn",
        description = "远程唤醒局域网设备",
        category = "network"
    },
    {
        id = "HomeProxy",
        name = "HomeProxy",
        name_en = "HomeProxy",
        icon = "⚡",
        package = "luci-i18n-homeproxy-zh-cn",
        description = "科学上网代理工具",
        category = "network"
    },
    {
        id = "PassWall",
        name = "PassWall",
        name_en = "PassWall",
        icon = "🚀",
        package = "luci-i18n-passwall-zh-cn",
        description = "科学上网代理工具",
        category = "network"
    },
    {
        id = "OpenClash",
        name = "OpenClash",
        name_en = "OpenClash",
        icon = "🛡️",
        package = "luci-app-openclash",
        description = "科学上网代理工具",
        category = "network"
    },
    {
        id = "qBittorrent",
        name = "qBittorrent",
        name_en = "qBittorrent",
        icon = "📥",
        package = "luci-i18n-qbittorrent-zh-cn",
        description = "轻量级BT下载工具",
        category = "nas"
    },
    {
        id = "transmission",
        name = "Transmission",
        name_en = "Transmission",
        icon = "📡",
        package = "luci-i18n-transmission-zh-cn",
        description = "轻量级BT下载工具",
        category = "nas"
    },
    {
        id = "aria2",
        name = "Aria2下载",
        name_en = "Aria2",
        icon = "📥",
        package = "luci-i18n-aria2-zh-cn",
        description = "多协议下载工具",
        category = "nas"
    },
    {
        id = "frps",
        name = "内网穿透frps",
        name_en = "frps",
        icon = "🔓",
        package = "luci-i18n-frps-zh-cn",
        description = "内网穿透服务端",
        category = "network"
    },
    {
        id = "frpc",
        name = "内网穿透frpc",
        name_en = "frpc",
        icon = "🔓",
        package = "luci-i18n-frpc-zh-cn",
        description = "内网穿透客户端",
        category = "network"
    },
    {
        id = "zerotier",
        name = "ZeroTier",
        name_en = "ZeroTier",
        icon = "🌍",
        package = "luci-i18n-zerotier-zh-cn",
        description = "虚拟局域网服务",
        category = "network"
    },
    {
        id = "wireguard",
        name = "WireGuard",
        name_en = "WireGuard",
        icon = "🔐",
        package = "luci-proto-wireguard",
        detect = {"luci-proto-wireguard"},
        description = "高速VPN服务",
        category = "network"
    },
    {
        id = "cifs-mount",
        name = "CIFS挂载",
        name_en = "CIFS Mount",
        icon = "📂",
        package = "luci-i18n-cifs-mount-zh-cn",
        description = "网络共享挂载工具",
        category = "network"
    },
    {
        id = "watchcat",
        name = "Watchcat",
        name_en = "Watchcat",
        icon = "🛠️",
        package = "luci-i18n-watchcat-zh-cn",
        description = "系统监控工具,断网自动重启设备",
        category = "system"
    },
    {
        id = "quectel",
        name = "Quectel LTE",
        name_en = "Quectel LTE",
        icon = "📶",
        package = "luci-app-quectel",
        description = "Quectel LTE拨号模块管理",
        category = "network"
    },
    {
        id = "3ginfo",
        name = "3G/4G信息",
        name_en = "3G/4G Info",
        icon = "📡",
        package = "luci-i18n-3ginfo-lite-zh-cn",
        description = "查询模块信息",
        category = "network"
    },
    {
        id = "modemband",
        name = "Modem Band",
        name_en = "Modem Band",
        icon = "📶",
        package = "luci-i18n-modemband-zh-cn",
        description = "频段锁定工具",
        category = "network"
    }
}

-- 检查软件包是否已安装（支持单个或多个候选包名）
local function is_installed(pkg_or_list)
    local function check_one(name)
        local check_name = name
        -- 语言包格式 luci-i18n-xxx-zh-cn -> 主包 luci-app-xxx
        local app_name = name:match("luci%-i18n%-(.+)%-zh%-cn")
        if app_name then
            check_name = "luci-app-" .. app_name
        end
        local h = io.popen("opkg status " .. check_name .. " 2>/dev/null")
        if h then
            local s = h:read("*a")
            h:close()
            return s:match("Status:%s+install ok installed") ~= nil
        end
        return false
    end
    if type(pkg_or_list) == "table" then
        for _, n in ipairs(pkg_or_list) do
            if check_one(n) then return true end
        end
        return false
    else
        return check_one(pkg_or_list)
    end
end

-- 智能更新软件源（24小时内只更新一次）
local function smart_update()
    local status_file = "/tmp/immstore_last_update"
    local current_time = os.time()
    local need_update = true
    
    -- 检查上次更新时间
    local f = io.open(status_file, "r")
    if f then
        local last_update = tonumber(f:read("*a"))
        f:close()
        if last_update and (current_time - last_update) < 86400 then
            need_update = false
        end
    end
    
    -- 执行更新
    if need_update then
        os.execute("opkg update >/dev/null 2>&1")
        f = io.open(status_file, "w")
        if f then
            f:write(tostring(current_time))
            f:close()
        end
        return true
    end
    return false
end

-- 获取应用列表
function action_get_apps()
    local result = {}
    local apps = {}
    
    for _, app in ipairs(apps_data) do
        local app_info = {
            id = app.id,
            name = app.name,
            name_en = app.name_en,
            icon = app.icon,
            description = app.description,
            category = app.category,
            installed = is_installed(app.detect or app.package)
        }
        table.insert(apps, app_info)
    end
    
    result.code = 0
    result.apps = apps
    
    http.prepare_content("application/json")
    http.write(json.stringify(result))
end

-- 安装应用
function action_install_app()
    local app_id = http.formvalue("app_id")
    local result = {}
    
    if not app_id then
        result.code = 1
        result.message = "No app specified"
        http.prepare_content("application/json")
        http.write(json.stringify(result))
        return
    end
    
    -- 查找应用配置
    local app_config = nil
    for _, app in ipairs(apps_data) do
        if app.id == app_id then
            app_config = app
            break
        end
    end
    
    if not app_config then
        result.code = 1
        result.message = "App not found"
        luci.http.prepare_content("application/json")
        luci.http.write_json(result)
        return
    end
    
    -- 智能更新软件源（24小时内只更新一次）
    smart_update()
    
    -- 安装语言包（会自动安装主包作为依赖）
    local cmd = string.format("opkg install %s 2>&1", app_config.package)
    local handle = io.popen(cmd)
    local output = ""
    if handle then
        output = handle:read("*a")
        local success = handle:close()
        
        if success then
            result.code = 0
            result.message = "安装成功"
            result.output = output
        else
            result.code = 1
            result.message = "安装失败"
            result.output = output
        end
    else
        result.code = 1
        result.message = "无法执行安装命令"
    end
    
    http.prepare_content("application/json")
    http.write(json.stringify(result))
end

-- 卸载应用
function action_remove_app()
    local app_id = http.formvalue("app_id")
    local result = {}
    
    if not app_id then
        result.code = 1
        result.message = "No app specified"
        http.prepare_content("application/json")
        http.write(json.stringify(result))
        return
    end
    
    -- 查找应用配置
    local app_config = nil
    for _, app in ipairs(apps_data) do
        if app.id == app_id then
            app_config = app
            break
        end
    end
    
    if not app_config then
        result.code = 1
        result.message = "App not found"
        luci.http.prepare_content("application/json")
        luci.http.write_json(result)
        return
    end
    
    -- 卸载包（支持 i18n 和直接包名）
    local packages_to_remove = {}
    
    -- 如果是语言包格式，提取主包名并同时卸载主包和语言包
    local app_name = app_config.package:match("luci%-i18n%-(.+)%-zh%-cn")
    if app_name then
        local main_package = "luci-app-" .. app_name
        table.insert(packages_to_remove, main_package)
        table.insert(packages_to_remove, app_config.package)
    else
        -- 直接包名（如 luci-proto-wireguard），直接卸载
        table.insert(packages_to_remove, app_config.package)
    end
    
    local cmd = string.format("opkg remove %s 2>&1", table.concat(packages_to_remove, " "))
    local handle = io.popen(cmd)
    local output = ""
    if handle then
        output = handle:read("*a")
        local success = handle:close()
        
        if success then
            result.code = 0
            result.message = "卸载成功"
            result.output = output
        else
            result.code = 1
            result.message = "卸载失败"
            result.output = output
        end
    else
        result.code = 1
        result.message = "无法执行卸载命令"
    end
    
    http.prepare_content("application/json")
    http.write(json.stringify(result))
end


