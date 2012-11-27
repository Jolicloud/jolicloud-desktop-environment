---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008-2009 Julien Danjou
-- @release v3.4-799-g4711354
---------------------------------------------------------------------------

--- Widget module for awful
-- awful.widget

return
{
    taglist = require("awful.widget.taglist");
    tasklist = require("awful.widget.tasklist");
    tasklist_icon = require("awful.widget.tasklist_icon");
    tasklist_text = require("awful.widget.tasklist_text");
    button = require("awful.widget.button");
    launcher = require("awful.widget.launcher");
    prompt = require("awful.widget.prompt");
    progressbar = require("awful.widget.progressbar");
    graph = require("awful.widget.graph");
    layoutbox = require("awful.widget.layoutbox");
    textclock = require("awful.widget.textclock");
}

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
