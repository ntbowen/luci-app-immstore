module("luci.controller.immstore", package.seeall)

local http = require "luci.http"
local json = require "luci.jsonc"

local CACHE_FILE = "/etc/immstore_apps.json"

function index()
    -- 直接显示应用商店，无二级菜单
    entry({"admin", "immstore"}, template("immstore/index"), _("App Store"), 60)
    entry({"admin", "immstore", "get_apps"}, call("action_get_apps"))
    entry({"admin", "immstore", "refresh_apps"}, call("action_refresh_apps"))
    entry({"admin", "immstore", "install_app"}, call("action_install_app"))
    entry({"admin", "immstore", "remove_app"}, call("action_remove_app"))
    entry({"admin", "immstore", "save_app_edit"}, call("action_save_app_edit"))
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

-- 缓存已安装包列表（一次性获取，避免多次调用）
local installed_packages_cache = nil

local function get_installed_packages()
    if installed_packages_cache then
        return installed_packages_cache
    end
    
    installed_packages_cache = {}
    local h = io.popen("apk list --installed 2>/dev/null | grep '^luci-'")
    if h then
        for line in h:lines() do
            -- 解析包名：luci-app-xxx-版本号 -> luci-app-xxx
            local full_name = line:match("^([^%s]+)")
            if full_name then
                local last_dash_pos = nil
                for i = #full_name, 1, -1 do
                    if full_name:sub(i, i) == "-" then
                        local next_char = full_name:sub(i + 1, i + 1)
                        if next_char:match("%d") then
                            last_dash_pos = i
                            break
                        end
                    end
                end
                if last_dash_pos and last_dash_pos > 1 then
                    local pkg_name = full_name:sub(1, last_dash_pos - 1)
                    installed_packages_cache[pkg_name] = true
                end
            end
        end
        h:close()
    end
    return installed_packages_cache
end

-- 检查软件包是否已安装（使用缓存）
local function is_installed(pkg_or_list)
    local installed = get_installed_packages()
    
    local function check_one(name)
        local check_name = name
        -- 语言包格式 luci-i18n-xxx-zh-cn -> 主包 luci-app-xxx
        local app_name = name:match("luci%-i18n%-(.+)%-zh%-cn")
        if app_name then
            check_name = "luci-app-" .. app_name
        end
        return installed[check_name] or false
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
    
    -- 执行更新（兼容 opkg 和 apk）
    if need_update then
        os.execute("(command -v opkg >/dev/null && opkg update || apk update) >/dev/null 2>&1")
        f = io.open(status_file, "w")
        if f then
            f:write(tostring(current_time))
            f:close()
        end
        return true
    end
    return false
end

-- 从软件源获取所有 luci-app-* 包
local function get_available_packages()
    local packages = {}
    local h = io.popen("apk search luci-app-* 2>/dev/null | head -600")
    if h then
        for line in h:lines() do
            local full_name = line:match("^([^%s]+)")
            if full_name and full_name:match("^luci%-app%-") then
                -- 找到最后一个 -数字 的位置来提取包名
                local last_dash_pos = nil
                for i = #full_name, 1, -1 do
                    if full_name:sub(i, i) == "-" then
                        local next_char = full_name:sub(i + 1, i + 1)
                        if next_char:match("%d") then
                            last_dash_pos = i
                            break
                        end
                    end
                end
                
                if last_dash_pos and last_dash_pos > 1 then
                    local pkg_name = full_name:sub(1, last_dash_pos - 1)
                    if pkg_name:match("^luci%-app%-") and not packages[pkg_name] then
                        packages[pkg_name] = true
                    end
                end
            end
        end
        h:close()
    end
    return packages
end

-- 构建内置应用的索引（按包名查找）
local function build_builtin_index()
    local index = {}
    for _, app in ipairs(apps_data) do
        -- 从语言包名提取主包名
        local pkg_name = app.package:match("luci%-i18n%-(.+)%-zh%-cn")
        if pkg_name then
            index["luci-app-" .. pkg_name] = app
        else
            -- 直接使用包名
            index[app.package] = app
        end
    end
    return index
end

-- 生成完整的应用列表（内置+动态）
local function generate_apps_list()
    local apps = {}
    local available_packages = get_available_packages()
    local added = {}
    
    -- 1. 先添加内置列表中的应用（保留图标、中文名、分类）
    for _, app in ipairs(apps_data) do
        local pkg_name = app.package:match("luci%-i18n%-(.+)%-zh%-cn")
        local main_pkg = pkg_name and ("luci-app-" .. pkg_name) or app.package
        
        local app_info = {
            id = app.id,
            name = app.name,
            name_en = app.name_en,
            icon = app.icon,
            description = app.description,
            category = app.category,
            package = app.package,
            available = available_packages[main_pkg] and true or false,
            builtin = true
        }
        table.insert(apps, app_info)
        added[main_pkg] = true
    end
    
    -- 2. 添加软件源中有但内置列表没有的应用
    for pkg_name, _ in pairs(available_packages) do
        if not added[pkg_name] then
            -- 生成友好名称：luci-app-xxx -> Xxx
            local short_name = pkg_name:match("luci%-app%-(.+)")
            local display_name = short_name and short_name:gsub("^%l", string.upper) or pkg_name
            
            local app_info = {
                id = pkg_name,
                name = display_name,
                name_en = display_name,
                icon = "📦",
                description = pkg_name,
                category = "other",
                package = pkg_name,
                available = true,
                builtin = false
            }
            table.insert(apps, app_info)
        end
    end
    
    return apps
end

-- 保存应用列表到缓存文件
local function save_cache(apps)
    local data = {
        apps = apps,
        total = #apps,
        builtin_count = #apps_data,
        dynamic_count = #apps - #apps_data,
        updated_at = os.time()
    }
    local f = io.open(CACHE_FILE, "w")
    if f then
        f:write(json.stringify(data))
        f:close()
        return true
    end
    return false
end

-- 从缓存文件读取应用列表
local function load_cache()
    local f = io.open(CACHE_FILE, "r")
    if f then
        local content = f:read("*a")
        f:close()
        if content and content ~= "" then
            return json.parse(content)
        end
    end
    return nil
end

-- 更新应用的安装状态
local function update_installed_status(apps)
    for _, app in ipairs(apps) do
        app.installed = is_installed(app.detect or app.package or app.id)
    end
end

-- 获取应用列表（优先读取缓存）
function action_get_apps()
    -- 重置已安装包缓存（每次请求重新获取一次）
    installed_packages_cache = nil
    
    local result = load_cache()
    
    -- 如果没有缓存，生成新列表
    if not result or not result.apps then
        local apps = generate_apps_list()
        save_cache(apps)
        result = {
            apps = apps,
            total = #apps,
            builtin_count = #apps_data,
            dynamic_count = #apps - #apps_data
        }
    end
    
    -- 更新安装状态（使用缓存，一次性获取所有已安装包）
    update_installed_status(result.apps)
    
    result.code = 0
    result.cached = true
    
    http.prepare_content("application/json")
    http.write(json.stringify(result))
end

-- 刷新应用列表（重新从软件源获取）
function action_refresh_apps()
    -- 重置已安装包缓存
    installed_packages_cache = nil
    
    local apps = generate_apps_list()
    save_cache(apps)
    update_installed_status(apps)
    
    local result = {
        code = 0,
        apps = apps,
        total = #apps,
        builtin_count = #apps_data,
        dynamic_count = #apps - #apps_data,
        cached = false,
        message = "列表已刷新"
    }
    
    http.prepare_content("application/json")
    http.write(json.stringify(result))
end

-- 安装应用
function action_install_app()
    local app_id = http.formvalue("app_id")
    local pkg_name = http.formvalue("package")
    local result = {}
    
    if not app_id then
        result.code = 1
        result.message = "No app specified"
        http.prepare_content("application/json")
        http.write(json.stringify(result))
        return
    end
    
    -- 查找应用配置（先从内置列表查找）
    local app_config = nil
    local install_package = nil
    
    for _, app in ipairs(apps_data) do
        if app.id == app_id then
            app_config = app
            install_package = app.package
            break
        end
    end
    
    -- 如果内置列表没有，使用传入的包名或 app_id（动态包）
    if not app_config then
        install_package = pkg_name or app_id
    end
    
    if not install_package then
        result.code = 1
        result.message = "App not found"
        http.prepare_content("application/json")
        http.write(json.stringify(result))
        return
    end
    
    -- 智能更新软件源（24小时内只更新一次）
    smart_update()
    
    -- 安装包（兼容 opkg 和 apk）
    local cmd = string.format("(command -v opkg >/dev/null && opkg install %s || apk add %s) 2>&1", install_package, install_package)
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
    local pkg_name = http.formvalue("package")
    local result = {}
    
    if not app_id then
        result.code = 1
        result.message = "No app specified"
        http.prepare_content("application/json")
        http.write(json.stringify(result))
        return
    end
    
    -- 查找应用配置（先从内置列表查找）
    local app_config = nil
    local remove_package = nil
    
    for _, app in ipairs(apps_data) do
        if app.id == app_id then
            app_config = app
            remove_package = app.package
            break
        end
    end
    
    -- 卸载包（支持 i18n 和直接包名）
    local packages_to_remove = {}
    
    if app_config then
        -- 内置应用：如果是语言包格式，提取主包名并同时卸载主包和语言包
        local app_name = app_config.package:match("luci%-i18n%-(.+)%-zh%-cn")
        if app_name then
            local main_package = "luci-app-" .. app_name
            table.insert(packages_to_remove, main_package)
            table.insert(packages_to_remove, app_config.package)
        else
            table.insert(packages_to_remove, app_config.package)
        end
    else
        -- 动态应用：直接使用包名
        remove_package = pkg_name or app_id
        table.insert(packages_to_remove, remove_package)
    end
    
    if #packages_to_remove == 0 then
        result.code = 1
        result.message = "App not found"
        http.prepare_content("application/json")
        http.write(json.stringify(result))
        return
    end
    
    local cmd = string.format("(command -v opkg >/dev/null && opkg remove %s || apk del %s) 2>&1", table.concat(packages_to_remove, " "), table.concat(packages_to_remove, " "))
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

-- 保存应用编辑信息
function action_save_app_edit()
    local app_id = http.formvalue("app_id")
    local name = http.formvalue("name")
    local name_en = http.formvalue("name_en")
    local description = http.formvalue("description")
    local icon = http.formvalue("icon")
    local category = http.formvalue("category")
    local result = {}
    
    if not app_id then
        result.code = 1
        result.message = "未指定应用"
        http.prepare_content("application/json")
        http.write(json.stringify(result))
        return
    end
    
    -- 读取缓存文件
    local cache_data = load_cache()
    if not cache_data or not cache_data.apps then
        result.code = 1
        result.message = "缓存文件不存在"
        http.prepare_content("application/json")
        http.write(json.stringify(result))
        return
    end
    
    -- 查找并更新应用信息
    local found = false
    for _, app in ipairs(cache_data.apps) do
        if app.id == app_id then
            if name and name ~= "" then app.name = name end
            if name_en and name_en ~= "" then app.name_en = name_en end
            if description and description ~= "" then app.description = description end
            if icon and icon ~= "" then app.icon = icon end
            if category and category ~= "" then app.category = category end
            found = true
            break
        end
    end
    
    if not found then
        result.code = 1
        result.message = "未找到应用"
        http.prepare_content("application/json")
        http.write(json.stringify(result))
        return
    end
    
    -- 保存到缓存文件
    local f = io.open(CACHE_FILE, "w")
    if f then
        f:write(json.stringify(cache_data))
        f:close()
        result.code = 0
        result.message = "保存成功"
    else
        result.code = 1
        result.message = "保存失败"
    end
    
    http.prepare_content("application/json")
    http.write(json.stringify(result))
end
