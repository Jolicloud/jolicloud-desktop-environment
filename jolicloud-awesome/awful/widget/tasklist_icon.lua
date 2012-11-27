---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008-2009 Julien Danjou
-- @release v3.4-799-g4711354
---------------------------------------------------------------------------

-- Grab environment we need
local capi = { screen = screen,
               client = client }
local ipairs = ipairs
local setmetatable = setmetatable
local table = table
local common = require("awful.widget.common")
local beautiful = require("beautiful")
local client = require("awful.client")
local util = require("awful.util")
local tag = require("awful.tag")
local flex = require("wibox.layout.flex")
local wibox = require("wibox")

--- Tasklist widget module for awful
-- awful.widget.tasklist_icon
local tasklist_icon = { mt = {} }

-- Public structures
tasklist_icon.filter = {}

local function tasklist_icon_label(c, args)
    local name = util.escape(c.name) or util.escape("Untitled")
    local font = args.font or theme.tasklist_font or theme.font or ""
    local text = "<span font_desc='" .. font .. "'><span color='#ffffff'>" .. name .. "</span></span>"
    return text, bg, nil, c.icon, (c.maximized_horizontal or c.maximized_vertical), (capi.client.focus == c)
end

local function tasklist_icon_update(s, _wibox, w, buttons, filter, data, style)
    local clients = {}
    for k, c in ipairs(capi.client.get()) do
        if not (c.skip_taskbar or c.hidden
            or c.type == "splash" or c.type == "dock" or c.type == "desktop")
            and filter(c, s) then
            table.insert(clients, 1, c)
        end
    end

    local function label(c) return tasklist_icon_label(c, style) end

    common.list_update(w, buttons, label, data, clients, _wibox)
end

--- Create a new tasklist_icon widget.
-- @param screen The screen to draw tasklist_icon for.
-- @param filter Filter function to define what clients will be listed.
-- @param buttons A table with buttons binding to set.
-- @param style The style overrides default theme.
-- bg_normal The background color for unfocused client.
-- fg_normal The foreground color for unfocused client.
-- bg_focus The background color for focused client.
-- fg_focus The foreground color for focused client.
-- bg_urgent The background color for urgent clients.
-- fg_urgent The foreground color for urgent clients.
-- bg_minimize The background color for minimized clients.
-- fg_minimize The foreground color for minimized clients.
-- floating Symbol to use for floating clients.
-- ontop Symbol to use for ontop clients.
-- maximized_horizontal Symbol to use for clients that have been horizontally maximized.
-- maximized_vertical Symbol to use for clients that have been vertically maximized.
-- font The font.
function tasklist_icon.new(screen, _wibox, filter, buttons, style)
    local w = flex.horizontal()
    -- local w = wibox.layout.align.horizontal()


    local data = setmetatable({}, { __mode = 'k' })
    local u = function () tasklist_icon_update(screen, _wibox, w, buttons, filter, data, style) end
    tag.attached_connect_signal(screen, "property::selected", u)
    tag.attached_connect_signal(screen, "property::activated", u)
    capi.client.connect_signal("property::urgent", u)
    capi.client.connect_signal("property::sticky", u)
    capi.client.connect_signal("property::ontop", u)
    capi.client.connect_signal("property::floating", u)
    capi.client.connect_signal("property::maximized_horizontal", u)
    capi.client.connect_signal("property::maximized_vertical", u)
    capi.client.connect_signal("property::minimized", u)
    capi.client.connect_signal("property::name", u)
    capi.client.connect_signal("property::icon_name", u)
    capi.client.connect_signal("property::icon", u)
    capi.client.connect_signal("property::skip_taskbar", u)
    capi.client.connect_signal("property::screen", u)
    capi.client.connect_signal("property::hidden", u)
    capi.client.connect_signal("tagged", u)
    capi.client.connect_signal("untagged", u)
    capi.client.connect_signal("unmanage", u)
    capi.client.connect_signal("list", u)
    capi.client.connect_signal("focus", u)
    capi.client.connect_signal("unfocus", u)
    u()
    return w
end

--- Filtering function to include all clients.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @return true
function tasklist_icon.filter.allscreen(c, screen)
    return true
end

--- Filtering function to include the clients from all tags on the screen.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @return true if c is on screen, false otherwise
function tasklist_icon.filter.alltags(c, screen)
    -- Only print client on the same screen as this widget
    return c.screen == screen
end

--- Filtering function to include only the clients from currently selected tags.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @return true if c is in a selected tag on screen, false otherwise
function tasklist_icon.filter.currenttags(c, screen)
    -- Only print client on the same screen as this widget
    if c.screen ~= screen then return false end
    -- Include sticky client too
    if c.sticky then return true end
    local tags = tag.gettags(screen)
    for k, t in ipairs(tags) do
        if t.selected then
            local ctags = c:tags()
            for _, v in ipairs(ctags) do
                if v == t then
                    return true
                end
            end
        end
    end
    return false
end

--- Filtering function to include only the minimized clients from currently selected tags.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @return true if c is in a selected tag on screen and is minimized, false otherwise
function tasklist_icon.filter.minimizedcurrenttags(c, screen)
    -- Only print client on the same screen as this widget
    if c.screen ~= screen then return false end
    -- Include sticky client
    if c.sticky then return true end
    -- Check client is minimized
    if not c.minimized then return false end
    local tags = tag.gettags(screen)
    for k, t in ipairs(tags) do
        -- Select only minimized clients
        if t.selected then
            local ctags = c:tags()
            for _, v in ipairs(ctags) do
                if v == t then
                    return true
                end
            end
        end
    end
    return false
end

--- Filtering function to include only the currently focused client.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @return true if c is focused on screen, false otherwise
function tasklist_icon.filter.focused(c, screen)
    -- Only print client on the same screen as this widget
    return c.screen == screen and capi.client.focus == c
end

function tasklist_icon.mt:__call(...)
    return tasklist_icon.new(...)
end

return setmetatable(tasklist_icon, tasklist_icon.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
