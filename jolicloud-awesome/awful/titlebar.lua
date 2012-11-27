---------------------------------------------------------------------------
-- @author Uli Schlachter
-- @copyright 2012 Uli Schlachter
-- @release v3.4-799-g4711354
---------------------------------------------------------------------------

local error = error
local type = type
local abutton = require("awful.button")
local aclient = require("awful.client")
local beautiful = require("beautiful")
local object = require("gears.object")
local drawable = require("wibox.drawable")
local base = require("wibox.widget.base")
local imagebox = require("wibox.widget.imagebox")
local textbox = require("wibox.widget.textbox")
local margin = require("wibox.layout.margin")

local capi = {
    client = client
}
local titlebar = {
    widget = {}
}

local prefix = "/usr/share/jolicloud-awesome"

local all_titlebars = setmetatable({}, { __mode = 'k' })

local print = print
local cairo = require("lgi").cairo
local util = require("awful.util")
local math = require("math")

local upper_left = cairo.ImageSurface.create_from_png(prefix .. "/theme/titlebar/upper-left.png")
local upper_middle = cairo.ImageSurface.create_from_png(prefix .. "/theme/titlebar/upper-middle.png")
local upper_right = cairo.ImageSurface.create_from_png(prefix .. "/theme/titlebar/upper-right.png")
local pattern = cairo.Pattern.create_for_surface(upper_middle)

-- Get a color for a titlebar, this tests many values from the array and the theme
local function get_color(name, c, args)
    local suffix = "_normal"
    if capi.client.focus == c then
        suffix = "_focus"
    end
    local function get(array)
        return array["titlebar_"..name..suffix] or array["titlebar_"..name] or array[name..suffix] or array[name]
    end
    return get(args) or get(beautiful)
end

--- Get a client's titlebar
-- @class function
-- @param c The client for which a titlebar is wanted.
-- @param args An optional table with extra arguments for the titlebar. The
-- "size" is the height of the titlebar. Available "position" values are top,
-- left, right and bottom. Additionally, the foreground and background colors
-- can be configured via e.g. "bg_normal" and "bg_focus".
-- @name titlebar
local function new(c, args)
    local args = args or {}
    local position = args.position or "top"
    local size = args.size or beautiful.get_font_height(args.font) * 1.5
    local d

    if position == "left" then
        d = c:titlebar_left(size)
    elseif position == "right" then
        d = c:titlebar_right(size)
    elseif position == "top" then
        d = c:titlebar_top(size)
    elseif position == "bottom" then
        d = c:titlebar_bottom(size)
    else
        error("Invalid titlebar position '" .. position .. "'")
    end

    -- Make sure that there is never more than one titlebar for any given client
    local bars = all_titlebars[c]
    if not bars then
        bars = {}
        all_titlebars[c] = bars
    end

    local ret
    if not bars[position] then
        ret = drawable(d, nil, function(cr, geom)
            -- We draw our titlebar
            cr.operator = cairo.Operator.OVER
            cr:set_source(pattern)
            pattern.extend = 'REPEAT'
            cr:rectangle(upper_left.width, 0, geom.width - upper_left.width - upper_right.width, geom.height)
            cr:fill()
            cr:set_source_surface(upper_left, 0, 0)
            cr:paint()
            cr:set_source_surface(upper_right, geom.width - upper_right.width, 0)
            cr:paint()
        end)

        bars[position] = {
            args = args,
            drawable = ret
        }
    else
        bars[position].args = args
        ret = bars[position].drawable
    end

    -- Make sure the titlebar is (re-)drawn
    ret.draw()

    return ret
end

--- Create a new titlewidget. A title widget displays the name of a client.
-- Please note that this returns a textbox and all of textbox' API is available.
-- This way, you can e.g. modify the font that is used.
-- @param c The client for which a titlewidget should be created.
-- @return The title widget.
function titlebar.widget.titlewidget(c)
    local ret = textbox()
    local function update()
        ret:set_text(c.name or "<unknown>")
        ret:set_align("center")
        ret:set_valign("center")
    end
    c:connect_signal("property::name", update)
    update()

    return ret
end

--- Create a new icon widget. An icon widget displays the icon of a client.
-- Please note that this returns an imagebox and all of the imagebox' API is
-- available. This way, you can e.g. disallow resizes.
-- @param c The client for which an icon widget should be created.
-- @return The icon widget.
function titlebar.widget.iconwidget(c)
    local ret = imagebox()
    local function update()
        ret:set_image(c.icon)
    end
    c:connect_signal("property::icon", update)
    update()

    return ret
end

--- Create a new button widget. A button widget displays an image and reacts to
-- mouse clicks. Please note that the caller has to make sure that this widget
-- gets redrawn when needed by calling the returned widget's update() function.
-- The selector function should return a value describing a state. If the value
-- is a boolean, either "active" or "inactive" are used. The actual image is
-- then found in the theme as "titlebar_[name]_button_[normal/focus]_[state]".
-- If that value does not exist, the focused state is ignored for the next try.
-- @param c The client for which a button is created.
-- @param name Name of the button, used for accessing the theme.
-- @param selector A function that selects the image that should be displayed.
-- @param action Function that is called when the button is clicked.
-- @return The widget
function titlebar.widget.button(c, name, selector, action)
    local ret = imagebox()
    local function update()
        local img = selector(c)
        if type(img) ~= "nil" then
            -- Convert booleans automatically
            if type(img) == "boolean" then
                if img then
                    img = "active"
                else
                    img = "inactive"
                end
            end
            -- First try with a prefix based on the client's focus state
            local prefix = "normal"
            if capi.client.focus == c then
                prefix = "focus"
            end
            if img ~= "" then
                prefix = prefix .. "_"
            end
            local theme = beautiful["titlebar_" .. name .. "_button_" .. prefix .. img]
            if not theme then
                -- Then try again without that prefix if nothing was found
                theme = beautiful["titlebar_" .. name .. "_button_" .. img]
            end
            if theme then
                img = theme
            end
        end
        ret:set_image(img)
    end
    if action then
        ret:buttons(abutton({ }, 1, nil, function() action(c, selector(c)) end))
    end

    ret.update = update
    update()

    -- We do magic based on whether a client is focused above, so we need to
    -- connect to the corresponding signal here.
    local function focus_func(o)
        if o == c then update() end
    end
    capi.client.connect_signal("focus", focus_func)
    capi.client.connect_signal("unfocus", focus_func)

    return ret
end

--- Create a new float button for a client.
-- @param c The client for which the button is wanted.
function titlebar.widget.floatingbutton(c)
    local widget = titlebar.widget.button(c, "floating", aclient.floating.get, aclient.floating.toggle)
    c:connect_signal("property::floating", widget.update)
    return widget
end

--- Create a new minimize button for a client.
-- @param c The client for which the button is wanted.
function titlebar.widget.minimizedbutton(c)
    local widget = titlebar.widget.button(c, "minimized", function(c)
        return c.minimized
    end, function(c, state)
        c.minimized = true
    end)
    c:connect_signal("property::minimized", widget.update)
    return widget
end

--- Create a new maximize button for a client.
-- @param c The client for which the button is wanted.
function titlebar.widget.maximizedbutton(c)
    local widget = titlebar.widget.button(c, "maximized", function(c)
        return c.maximized_horizontal or c.maximized_vertical
    end, function(c, state)
        if not state then
            titlebar(c, { size = 0 })
        end
        if not state then
            c.border_width = 0
        else
            c.border_width = 1
        end
        c.maximized_horizontal = not state
        c.maximized_vertical = not state
        if state then
            local geometry = c:geometry()
            if geometry.y == 0 then
              geometry.y = 24
              -- geometry.height = geometry.height - 24
            end
            c:geometry(geometry)
        end
    end)
    c:connect_signal("property::maximized_vertical", widget.update)
    c:connect_signal("property::maximized_horizontal", widget.update)
    return widget
end

--- Create a new closing button for a client.
-- @param c The client for which the button is wanted.
function titlebar.widget.closebutton(c)
    return titlebar.widget.button(c, "close", function() return "" end, function(c) c:kill() end)
end

--- Create a new ontop button for a client.
-- @param c The client for which the button is wanted.
function titlebar.widget.ontopbutton(c)
    local widget = titlebar.widget.button(c, "ontop", function(c) return c.ontop end, function(c, state) c.ontop = not state end)
    c:connect_signal("property::ontop", widget.update)
    return widget
end

--- Create a new sticky button for a client.
-- @param c The client for which the button is wanted.
function titlebar.widget.stickybutton(c)
    local widget = titlebar.widget.button(c, "sticky", function(c) return c.sticky end, function(c, state) c.sticky = not state end)
    c:connect_signal("property::sticky", widget.update)
    return widget
end

return setmetatable(titlebar, { __call = function(_, ...) return new(...) end})

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
