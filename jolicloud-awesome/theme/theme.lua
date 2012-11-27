---------------------------
-- Default awesome theme --
---------------------------
local util = require("awful.util")
local prefix = "/usr/share/jolicloud-awesome"

theme = {}

theme.font          = "sans 8"

theme.bg_normal     = "#000000"
theme.bg_focus      = "#000000"
theme.bg_urgent     = "#000000"
theme.bg_minimize   = "#000000"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#ffffff"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = 1
theme.border_normal = "#38393b"
theme.border_focus  = "#38393b"
theme.border_marked = "#38393b"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel   = "/usr/local/share/awesome/themes/default/taglist/squarefw.png"
theme.taglist_squares_unsel = "/usr/local/share/awesome/themes/default/taglist/squarew.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = "/usr/local/share/awesome/themes/default/submenu.png"
theme.menu_height = 15
theme.menu_width  = 100

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = prefix .. "/theme/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = prefix .. "/theme/titlebar/close_normal.png"

theme.titlebar_maximized_button_normal_inactive = prefix .. "/theme/titlebar/maximize_normal.png"
theme.titlebar_maximized_button_focus_inactive  = prefix .. "/theme/titlebar/maximize_normal.png"
theme.titlebar_maximized_button_normal_active = prefix .. "/theme/titlebar/maximize_normal.png"
theme.titlebar_maximized_button_focus_active  = prefix .. "/theme/titlebar/maximize_normal.png"

theme.titlebar_minimized_button_normal_inactive = prefix .. "/theme/titlebar/minimize_normal.png"
theme.titlebar_minimized_button_focus_inactive  = prefix .. "/theme/titlebar/minimize_normal.png"
theme.titlebar_minimized_button_normal_active = prefix .. "/theme/titlebar/minimize_normal.png"
theme.titlebar_minimized_button_focus_active  = prefix .. "/theme/titlebar/minimize_normal.png"

-- You can use your own layout icons like this:
theme.layout_fairh = "/usr/local/share/awesome/themes/default/layouts/fairhw.png"
theme.layout_fairv = "/usr/local/share/awesome/themes/default/layouts/fairvw.png"
theme.layout_floating  = "/usr/local/share/awesome/themes/default/layouts/floatingw.png"
theme.layout_magnifier = "/usr/local/share/awesome/themes/default/layouts/magnifierw.png"
theme.layout_max = "/usr/local/share/awesome/themes/default/layouts/maxw.png"
theme.layout_fullscreen = "/usr/local/share/awesome/themes/default/layouts/fullscreenw.png"
theme.layout_tilebottom = "/usr/local/share/awesome/themes/default/layouts/tilebottomw.png"
theme.layout_tileleft   = "/usr/local/share/awesome/themes/default/layouts/tileleftw.png"
theme.layout_tile = "/usr/local/share/awesome/themes/default/layouts/tilew.png"
theme.layout_tiletop = "/usr/local/share/awesome/themes/default/layouts/tiletopw.png"
theme.layout_spiral  = "/usr/local/share/awesome/themes/default/layouts/spiralw.png"
theme.layout_dwindle = "/usr/local/share/awesome/themes/default/layouts/dwindlew.png"

theme.awesome_icon = prefix .. "/theme/icon.png"
-- theme.wallpaper = util.getdir("config") .. "/theme/bg.png"

-- Define the icon theme for application icons. If not set then the icons 
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
