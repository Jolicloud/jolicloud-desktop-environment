local base = require("wibox.widget.base")
local layout_base = require("wibox.layout.base")
local cairo = require("lgi").cairo
local setmetatable = setmetatable
local pairs = pairs
local type = type

-- wibox.widget.background
local tasklist_background = { mt = {} }

local prefix = "/usr/share/jolicloud-awesome"

local util = require("awful.util")
local tb_left = cairo.ImageSurface.create_from_png(prefix .. "/theme/taskbar/left.png")
local tb_middle = cairo.ImageSurface.create_from_png(prefix .. "/theme/taskbar/middle.png")
local tb_right = cairo.ImageSurface.create_from_png(prefix .. "/theme/taskbar/right.png")
local pattern = cairo.Pattern.create_for_surface(tb_middle)

--- Draw this widget
function tasklist_background.draw(box, wibox, cr, width, height)
    if not box.widget then
        return
    end
    cr:save()
    cr:set_source(pattern)
    pattern.extend = 'REPEAT'
    cr:rectangle(0, 0, width, height)
    cr:fill()
    cr:set_source_surface(tb_left, 0, 0)
    cr:paint()
    cr:set_source_surface(tb_right, width - tb_right.width, 0)
    cr:paint()
    cr:restore()
    layout_base.draw_widget(wibox, cr, box.widget, 0, 0, width, height)
end

--- Fit this widget into the given area
function tasklist_background.fit(box, width, height)
    if not box.widget then
        return 0, 0
    end

    return box.widget:fit(width, height)
end

--- Set the widget that is drawn on top of the background
function tasklist_background.set_widget(box, widget)
    if box.widget then
        box.widget:disconnect_signal("widget::updated", box._emit_updated)
    end
    if widget then
        base.check_widget(widget)
        widget:connect_signal("widget::updated", box._emit_updated)
    end
    box.widget = widget
    box._emit_updated()
end

local function new()
    local ret = base.make_widget()

    for k, v in pairs(tasklist_background) do
        if type(v) == "function" then
            ret[k] = v
        end
    end

    ret._emit_updated = function()
        ret:emit_signal("widget::updated")
    end

    return ret
end

function tasklist_background.mt:__call(...)
    return new(...)
end

return setmetatable(tasklist_background, tasklist_background.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80