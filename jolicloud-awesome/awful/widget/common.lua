---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008-2009 Julien Danjou
-- @release v3.4-799-g4711354
---------------------------------------------------------------------------

-- Grab environment we need
local math = math
local type = type
local ipairs = ipairs
local pairs = pairs
local pcall = pcall
local setmetatable = setmetatable
local capi = { button = button, client = client }
local awful_button = require("awful.button")
local awful_titlebar = require("awful.titlebar")
local util = require("awful.util")
local wibox = require("wibox")
local imagebox = require("wibox.widget.imagebox")
local textbox = require("wibox.widget.textbox")
local wbutton = require("awful.widget.button")


local common = {}

local print = print

local prefix = "/usr/share/jolicloud-awesome"

local os = require("os")
local tasklist_background = require("jolicloud.tasklist_background")
local cairo = require("lgi").cairo
local surface = require("gears.surface")

local application_default_icon = surface.load(prefix .. "/theme/application-default-icon.png")
local tb_close = surface.load(prefix .. "/theme/taskbar/close.png")

local function handle_buttons(w, buttons, o)
  local t_btns = {}
  for kb, b in ipairs(buttons) do
    -- Create a proxy button object: it will receive the real
    -- press and release events, and will propagate them the the
    -- button object the user provided, but with the object as
    -- argument.
    local t_btn = capi.button { modifiers = b.modifiers, button = b.button }
    t_btn:connect_signal("press", function () b:emit_signal("press", o) end)
    t_btn:connect_signal("release", function () b:emit_signal("release", o) end)
    t_btns[#t_btns + 1] = t_btn
  end
  w:buttons(t_btns)
end

-- Recursively processes a template, replacing the tables representing the icon and
-- the title with the widgets ib and tb
local function replace_in_template(t, ib, tb)
    for i, v in ipairs(t) do
        if type(t[i]) == "table" then
            if v.item == "icon" then
                t[i] = ib
            elseif v.item == "title" then
                t[i] = tb
            else
                replace_in_template(v, ib, tb)
            end
        end
    end
end

function common.list_update(w, buttons, label, data, objects, _wibox)
    local layout = wibox.layout.align.horizontal()
    local left_layout = wibox.layout.fixed.horizontal()
    local middle_layout = wibox.layout.flex.horizontal()
    -- local middle_layout = wibox.layout.fixed.horizontal()

    -- update the widgets, creating them if needed
    w:reset()
    for i, o in ipairs(objects) do
        local cache = data[o]
        local ib, tb, bgb, m, l
        if cache then
            ib = cache.ib
            tb = cache.tb
            bgb = cache.bgb
        else
            ib = wibox.widget.imagebox()
            local ibm = wibox.layout.margin(ib, 2, 2, 2, 2)
            --tb = wibox.widget.textbox()
            bgb = wibox.widget.background()
            --m = wibox.layout.margin(tb, 4, 4)
            l = wibox.layout.fixed.horizontal()

            -- All of this is added in a fixed widget
            l:fill_space(true)
            l:add(ibm)
            -- l:add(m)

            -- And all of this gets a background
            bgb:set_widget(l)

            if buttons then
                local btns = {}
                for kb, b in ipairs(buttons) do
                    -- Create a proxy button object: it will receive the real
                    -- press and release events, and will propagate them the the
                    -- button object the user provided, but with the object as
                    -- argument.
                    local btn = capi.button { modifiers = b.modifiers, button = b.button }
                    btn:connect_signal("press", function () b:emit_signal("press", o) end)
                    btn:connect_signal("release", function () b:emit_signal("release", o) end)
                    btns[#btns + 1] = btn
                end
                bgb:buttons(btns)
            end

            data[o] = {
                ib = ib,
                tb = tb,
                bgb = bgb
            }
        end

        local text, bg, bg_image, icon, maximized, focused = label(o)
        -- The text might be invalid, so use pcall
        -- if not pcall(tb.set_markup, tb, text) then
        --     tb:set_markup("<i>&lt;Invalid text&gt;</i>")
        -- end
        -- bgb:set_bg("#0000ff")
        -- bgb:set_bgimage(bg_image)
        -- local icon_surface = cairo.Surface(icon, true)
        -- print("icon_surface", icon_surface)
        -- local cr = cairo.Context(icon_surface)
        -- cr:set_operator(cairo.Operator.SOURCE)
        -- cr:set_source_rgba(0, 0, 0, 0.2)
        -- cr:paint()
        -- ib:set_image(icon_surface)
        if not focused then
          local icon_surface
          if not icon then
            icon_surface = application_default_icon
          else
            icon_surface = cairo.Surface(icon, true)
          end
          local m_icon = icon_surface:create_similar(cairo.Content.COLOR_ALPHA, icon_surface.width, icon_surface.height)
          local cr = cairo.Context(m_icon)
          cr:set_source_rgba(0, 0, 0, 1)
          cr:paint()
          cr:set_source_surface(icon_surface)
          cr:set_operator(cairo.Operator.HSL_LUMINOSITY)
          cr:paint()
          cr:set_operator(cairo.Operator.OVER)
          cr:set_source_rgba(0, 0, 0, 0.5)
          cr:paint()
          ib:set_image(m_icon)
        else
          if not icon then
            ib:set_image(application_default_icon)
          else
            ib:set_image(icon)
          end
        end

        -- ib:set_image(icon)
        -- w:add(bgb)



        if maximized and focused then

            local _margin = wibox.layout.margin()
            local _inmargin = wibox.layout.margin()
            local _background = tasklist_background()
            local tb = wibox.widget.textbox()

            local prvious_click = 0
            _background:buttons(awful_button({ }, 1, function()
                            local c = o
                            local now = os.time()
                            if prvious_click == now then
                              c.border_width = 1
                              c.maximized_horizontal = false
                              c.maximized_vertical = false
                              local geometry = c:geometry()
                              if geometry.y == 0 then
                                geometry.y = 24
                              end
                              c:geometry(geometry)
                              awful_titlebar(c, { size = 24 })
                              client.focus = c
                              c:raise()
                            else
                              prvious_click = now
                            end
                      end))

            _inmargin:set_left(8)
            _inmargin:set_right(8)

            local close_button = wbutton({ image = tb_close })

            close_button:buttons(awful_button({}, 1, nil, function() o:kill() end))

            local close_button_m = wibox.layout.margin(close_button, 2, 1, 6, 6)
            local t_layout = wibox.layout.align.horizontal()
            local t_left_layout = wibox.layout.fixed.horizontal()
            local t_right_layout = wibox.layout.fixed.horizontal()

            t_left_layout:add(tb)
            t_right_layout:add(close_button_m)

            t_layout:set_left(t_left_layout)
            t_layout:set_right(t_right_layout)

            _inmargin:set_widget(t_layout)

            _background:set_widget(_inmargin)

            _margin:set_left(8)
            _margin:set_right(8)
            _margin:set_widget(_background)

            if not pcall(tb.set_markup, tb, text) then
              tb:set_markup("<i>&lt;Invalid text&gt;</i>")
            end
            middle_layout:add(_margin)

        end
        left_layout:add(bgb)
   end
   layout:set_left(left_layout)
   layout:set_middle(middle_layout)
   w:add(layout)
end

return common

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
