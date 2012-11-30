-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

local util = require("awful.util")
local cairo = require("lgi").cairo
local os = require("os")
local posix = require("posix")

local capi = { screen = screen,
               client = client }

local prefix = "/usr/share/jolicloud-awesome"

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- The systray is a bit complex. We need to configure it to display
-- the right colors. Here is a link with more background about this:
--  http://thread.gmane.org/gmane.comp.window-managers.awesome/9028
xprop = assert(io.popen("xprop -root _NET_SUPPORTING_WM_CHECK"))
wid = xprop:read():match("^_NET_SUPPORTING_WM_CHECK.WINDOW.: window id # (0x[%S]+)$")
xprop:close()
if wid then
   wid = tonumber(wid) + 1
   os.execute("xprop -id " .. wid .. " -format _NET_SYSTEM_TRAY_COLORS 32c " ..
        "-set _NET_SYSTEM_TRAY_COLORS " ..
        "65535,65535,65535,65535,8670,8670,65535,32385,0,8670,65535,8670")
end

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(prefix .. "/theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", "gnome-terminal" }, { "open nm", "nm-applet" }, { "open eog", "eog" }, { "open gedit", "gedit" }

                                  }
                        })

--mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
--                                     menu = mymainmenu })

mylauncher = awful.widget.button({ image = beautiful.awesome_icon })
local function call_launcher()
    local hidding = false
    for k, c in ipairs(capi.client.get()) do
      if c.type == 'normal' then
        if not c.minimized then
          hidding = true
          -- break
        end
      end
    end
    if hidding then
      for k, c in ipairs(capi.client.get()) do
        awful.client.property.set(c, 'hidden', false)
        awful.client.property.set(c, 'had_focus', false)
        if c.type == 'normal' then
          if not c.minimized then
            if c == client.focus then
              awful.client.property.set(c, 'had_focus', true)
            end
            awful.client.property.set(c, 'hidden', true)
            c.minimized = true
          end
        end
      end
    else
      for k, c in ipairs(capi.client.get()) do
        if awful.client.property.get(c, 'hidden') then
          c.minimized = false
        end
        if awful.client.property.get(c, 'had_focus') then
          client.focus = c
          c:raise()
        end
      end
    end
end
mylauncher:buttons(awful.button({}, 1, function () end, call_launcher))

local launcher_m = wibox.layout.margin(mylauncher, 1, 4)

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
-- mytextclock = awful.widget.textclock()
mytextclock = awful.widget.textclock("  %R  ")

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              client.focus = c
                                              c:raise()
                                          end))

for s = 1, screen.count() do
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 24, bg = '#000000' })

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist_icon(s, mywibox[s], awful.widget.tasklist.filter.currenttags, mytasklist.buttons, { bg_normal = '#000000', bg_focus = '#000000', bg_urgent = '#000000', bg_minimized = '#000000' })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(launcher_m)


    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- -- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ 'Any',  }, "Super_L", call_launcher),
    awful.key({ 'Mod1', }, "F1",      function () awful.util.spawn(terminal) end ),
    awful.key({ 'Mod1', }, "F2",      function () awful.util.spawn("gexec") end ),

    awful.key({ 'Mod1', }, "Tab",     function ()
        awful.client.focus.byidx(-1)
        if client.focus then
            client.focus:raise()
        end
    end),
    awful.key({ 'Mod1', 'Shift'   }, "Tab", function ()
        awful.client.focus.byidx(1)
        if client.focus then
            client.focus:raise()
        end
    end),

    -- Temporary
    -- awful.key({ 'Mod1', }, "r", awesome.restart),
    -- awful.key({ 'Mod1', }, "q", awesome.quit)
)

clientkeys = awful.util.table.join(
    awful.key({ 'Mod1',           }, 'F4',      function (c) c:kill() end)
)

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

local function do_rounded_corners(c)
  local geom = c:geometry()
  local width, height = geom.width, geom.height

  if c.maximized_horizontal or c.maximized_vertical or (c.type ~= 'normal' and c.type ~= 'dialog') then
    c.shape_clip = nil
    c.shape_bounding = nil
  elseif width > 0 and height > 0 then
    local shape = cairo.ImageSurface(cairo.Format.A1, width, height)
    local cr = cairo.Context(shape)

    cr:set_operator(cairo.Operator.SOURCE)
    cr:set_source_rgba(1, 1, 1, 1)
    cr:paint()

    cr:rectangle(0, 0, 2, 1);
    cr:set_source_rgba(0, 0, 0, 0)
    cr:fill()
    cr:rectangle(0, 1, 1, 1);
    cr:set_source_rgba(0, 0, 0, 0)
    cr:fill()

    cr:rectangle(width - 2, 0, 2, 1);
    cr:set_source_rgba(0, 0, 0, 0)
    cr:fill()
    cr:rectangle(width - 1, 1, 1, 1);
    cr:set_source_rgba(0, 0, 0, 0)
    cr:fill()

    c.shape_clip = shape._native

    width = width + (c.border_width * 2)
    height = height + (c.border_width * 2)

    local bounding_shape = cairo.ImageSurface(cairo.Format.A1, width, height)
    local bounding_cr = cairo.Context(bounding_shape)

    bounding_cr:set_operator(cairo.Operator.SOURCE)
    bounding_cr:set_source_rgba(1, 1, 1, 1)
    bounding_cr:paint()

    bounding_cr:rectangle(0, 0, 5, 1);
    bounding_cr:set_source_rgba(0, 0, 0, 0)
    bounding_cr:fill()
    bounding_cr:rectangle(0, 1, 3, 1);
    bounding_cr:set_source_rgba(0, 0, 0, 0)
    bounding_cr:fill()
    bounding_cr:rectangle(0, 2, 2, 1);
    bounding_cr:set_source_rgba(0, 0, 0, 0)
    bounding_cr:fill()
    bounding_cr:rectangle(0, 3, 1, 1);
    bounding_cr:set_source_rgba(0, 0, 0, 0)
    bounding_cr:fill()
    bounding_cr:rectangle(0, 4, 1, 1);
    bounding_cr:set_source_rgba(0, 0, 0, 0)
    bounding_cr:fill()

    bounding_cr:rectangle(width - 5, 0, 5, 1);
    bounding_cr:set_source_rgba(0, 0, 0, 0)
    bounding_cr:fill()
    bounding_cr:rectangle(width - 3, 1, 3, 1);
    bounding_cr:set_source_rgba(0, 0, 0, 0)
    bounding_cr:fill()
    bounding_cr:rectangle(width - 2, 2, 2, 1);
    bounding_cr:set_source_rgba(0, 0, 0, 0)
    bounding_cr:fill()
    bounding_cr:rectangle(width - 1, 3, 1, 1);
    bounding_cr:set_source_rgba(0, 0, 0, 0)
    bounding_cr:fill()
    bounding_cr:rectangle(width - 1, 4, 1, 1);
    bounding_cr:set_source_rgba(0, 0, 0, 0)
    bounding_cr:fill()

    c.shape_bounding = bounding_shape._native
  end
end

local function handle_titlebar_buttons(c, button, name)
  local button_m = wibox.layout.margin(button, 4, 5, 7, 7)
  button:connect_signal("mouse::enter", function(c)
    button:set_image(prefix .. "/theme/titlebar/" .. name .. "_hover.png")
  end)
  button:connect_signal("mouse::leave", function(c)
    button:set_image(prefix .. "/theme/titlebar/" .. name .. "_normal.png")
  end)
  c:connect_signal("mouse::leave", function(c)
    button:set_image(prefix .. "/theme/titlebar/" .. name .. "_normal.png")
  end)
  return button_m
end

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Google-chrome" },
      properties = { border_width = 0 } },
    { rule = { class = "my.jolicloud.com" },
      properties = { border_width = 0 } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  -- left_layout:add(awful.titlebar.widget.iconwidget(c))

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()

  local minimized_button = awful.titlebar.widget.minimizedbutton(c)
  local maximized_button = awful.titlebar.widget.maximizedbutton(c)
  local closed_button = awful.titlebar.widget.closebutton(c)


  right_layout:add(handle_titlebar_buttons(c, minimized_button, "minimize"))
  right_layout:add(handle_titlebar_buttons(c, maximized_button, "maximize"))
  right_layout:add(wibox.layout.margin(handle_titlebar_buttons(c, closed_button, "close"), 0, 3))

  -- The title goes in the middle
  local title = awful.titlebar.widget.titlewidget(c)
  local prvious_click = 0
  title:buttons(awful.util.table.join(
          awful.button({ }, 1, function()
              local now = os.time()
              if prvious_click == now then
                awful.titlebar(c, { size = 0 })
                c.border_width = 0
                c.maximized_horizontal = true
                c.maximized_vertical = true
              else
                client.focus = c
                c:raise()
                awful.mouse.client.move(c)
              end
              prvious_click = now
          end),
          awful.button({ }, 3, function()
              client.focus = c
              c:raise()
              awful.mouse.client.resize(c)
          end)
          ))

  -- Now bring it all together
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_right(right_layout)
  layout:set_middle(title)

  local need_maximize = true
  local area = capi.screen[mouse.screen].workarea
  local h = c.size_hints

  if h.max_width and h.max_width < area.width then
    need_maximize = false
  end
  if h.max_height and h.max_height < area.height then
    need_maximize = false
  end
  if c.type ~= 'normal' then
    need_maximize = false
  end

  if c.type == 'desktop' then
    c.border_width = 0
    awful.titlebar(c, { size = 0 }):set_widget(layout)
    do_rounded_corners(c)
  elseif need_maximize then
    c.border_width = 0
    c.maximized_horizontal = true
    c.maximized_vertical = true
    awful.titlebar(c, { size = 0 }):set_widget(layout)
  else
    local geometry = c:geometry()
    if geometry.y == 0 then
      geometry.y = 24
    end
    c:geometry(geometry)
    awful.titlebar(c, { size = 24 }):set_widget(layout)
    do_rounded_corners(c)
  end
end)



client.connect_signal("property::width", do_rounded_corners)
client.connect_signal("property::height", do_rounded_corners)
client.connect_signal("property::type", do_rounded_corners)
-- client:connect_signal("mouse::enter", function(c)

-- end)

-- client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
-- client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- function run_once(prg, arg_string, pname, screen)
--     if not prg then
--         do return nil end
--     end

--     if not pname then
--        pname = prg
--     end

--     if not arg_string then 
--         awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")", screen)
--     else
--         awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. " " .. arg_string .. ")", screen)
--     end
-- end

function run_once(prg)
  awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. prg .. "' || (" .. prg .. ")")
end

-- posix.setenv("GTK2_RC_FILES", util.getdir("config") .. "/gtkrc-2.0")
-- posix.setenv("GTK3_RC_FILES", util.getdir("config") .. "/gtkrc-3.0")

run_once("/usr/bin/python /usr/bin/jolicloud-daemon")
run_once("/usr/lib/nickel-browser/nickel-browser --app=http://my.jolicloud.com --desktop --no-default-browser-check --no-first-run")
-- run_once("gnome-settings-daemon")
run_once("python /usr/bin/jupiter")
run_once("gnome-power-manager")
run_once("bluetooth-applet")
run_once("nm-applet")
run_once("gnome-sound-applet")
