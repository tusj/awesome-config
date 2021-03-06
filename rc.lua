-- Standard awesome library
                               require("awful.autofocus")
                               require("eminent")
local awful                  = require("awful")
      awful.rules            = require("awful.rules")
local beautiful              = require("beautiful") -- Theme handling library
local blingbling             = require("blingbling")
local gears                  = require("gears")
local menubar                = require("menubar")
local naughty                = require("naughty") -- Notification library
local persistence            = require("persistence")
local revelation             = require("revelation")
local ror                    = require("aweror")
local util                   = require("util")
local vicious                = require("vicious")
local wibox                  = require("wibox") -- Widget and layout library
local temp                   = require("temp")




-- Error handling
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
	awesome.connect_signal("debug::error",
		function (err)
			-- Make sure we don't go into an endless error loop
			if in_error then return end
			in_error = true

			naughty.notify({ preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = err })
			in_error = false
		end)
end

-- Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init("/home/s/.config/awesome/theme.lua")
revelation.init() -- after beatuiful.init(), init revelation

-- to change wallpaper randomly
wallpaper_path         = "/home/s/.config/awesome/backgrounds/" -- has to end with /
wallpaper_timeout      = 1350 -- seconds interval to change wallpaper

-- This is used later as the default terminal and editor to run.
terminal    = "terminology"
filemanager = "pcmanfm"
webbrowser  = "chromium"
editor      = "vim"
editor_cmd  = terminal .. " -e " .. editor

modkey = "Mod4"

-- Naughty configuration
naughty.config.padding                   = 15
naughty.config.spacing                   = 15
naughty.config.gap                       = 20
naughty.config.presets.low.bg            = "00000000"
naughty.config.presets.low.fg            = beautiful.fg_focus
naughty.config.presets.normal.bg         = "00000000"
naughty.config.presets.normal.fg         = beautiful.fg_focus
naughty.config.presets.critical.bg       = beautiful.bg_urgent .. "70"
naughty.config.presets.critical.fg       = beautiful.fg_urgent
naughty.config.defaults.timeout          = 10
naughty.config.defaults.margin           = 10
naughty.config.defaults.hover_timeout    = 1
naughty.config.defaults.border_color     = "00000000"

-- Table of layouts to cover with awful.layout.inc, order matters
tile_index = 1
local tiles = {
	awful.layout.suit.tile,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	-- awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
}

local layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.floating,
	-- awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier
}


-- Display
widget_rounded_size = 0.2
screen_height          = io.popen("bash -c \"xrandr | grep '*' | grep -oh \"[0-9]\\+x[0-9]\\+\" | cut -d \"x\" -f2\""):read()
bar_height          = 40
margin              = bar_height / 20
widget_width        = bar_height - 2 * margin
widget_height       = widget_width
icon_dir            = "/home/s/Dropbox/pictures/icons"
icon_filter         = function(s) return string.match(s,"%.png$") or string.match(s,"%.jpg$") or string.match(s, "%.svg") end
icon_files          = util.scandir(icon_dir, icon_filter)
launcher_icon       = icon_dir .. '/' .. icon_files[math.random( 1, #icon_files)]

-- Menubar configuration
menubar.menu_gen.all_menu_dirs = {"/home/s/.local/share/applications/", "/usr/share/applications/" }
menubar.utils.terminal         = terminal -- Set the terminal for applications that require it
menubar.geometry               = { height = bar_height * 2 }
-- Tags
-- Define a tag table which hold all screen tags.
la = awful.layout.suit
blobs = {
	names   = { "1 web", "2 prg", "3 chat", "4 mail", "5 music", 6,       7,       8,       9 },
	layouts = { la.tile, la.tile, la.tile,  la.max,   la.max,    la.tile, la.tile, la.tile, la.tile }
}
tags = {}
for s = 1, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = awful.tag(blobs.names, s, blobs.layouts)
end

-- Menu
mymainmenu = awful.menu({ items = {
	{ "edit config" , editor_cmd .. " " .. awesome.conffile },
	{ "restart awesome"     , awesome.restart },
	{ "logout"        , awesome.quit },
	{ "reboot"        , "reboot" }
}})

mylauncher = awful.widget.launcher({
	image = launcher_icon,
	menu = mymainmenu
})


--  Wibox

-- Create a wibox for each screen and add it
mywibox     = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist   = {}
mytag       = {}
mytaglist.buttons = awful.util.table.join(
	awful.button({        } , 1, awful.tag.viewonly),
	awful.button({ modkey } , 1, awful.client.movetotag),
	awful.button({        } , 3, awful.tag.viewtoggle),
	awful.button({ modkey } , 3, awful.client.toggletag),
	awful.button({        } , 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
	awful.button({        } , 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			-- Without this, the following
			-- :isvisible() makes no sense
			c.minimized = false
			if not c:isvisible() then
				awful.tag.viewonly(c:tags()[1])
			end
			-- This will also un-minimize
			-- the client, if needed
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ }, 3, function ()
		if instance then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({
				theme = { width = 250 }
			})
		end
	end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end))

for s = 1, screen.count() do
	-- create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
		awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
		awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
		awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
		awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
	))

    -- Create a taglist widget
    mytag[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

	clock = awful.widget.textclock("%a %b %d")

	-- Memory
	memwidget     = blingbling.wlourf_circle_graph({
		show_text    = true,
		radius       = widget_height / 2 - 3,
		show_text    = true,
		v_margin     = 0,
		label        = "",
		height       = widget_height,
		-- graph_color  = beautiful.fg_widget,
		graph_colors = {
			{ beautiful.fg_widget, 0 },
			{ beautiful.fg_widget_attention, 0.60 },
			{ beautiful.fg_widget_critical,  0.70 }
		}
	})

	vicious.register(memwidget, vicious.widgets.mem, '$1', 5)

	-- Temperature
	tempwidget                  = blingbling.value_text_box({
		width                  = widget_width,
		height                 = widget_height,
		rounded_size           = widget_rounded_size,
		v_margin               = 0,
		font_size              = theme.font_size,
		label                  = "$percent °C",
		graph_background_color = beautiful.bg_widget,
		graph_line_color       = beautiful.border_focus_widget,
		values_text_color = {
			{ beautiful.fg_normal, 0 },
			{ beautiful.fg_attention, 0.7 },
			{ beautiful.fg_critical,  0.75 }
		}
	})
	vicious.register(tempwidget, temp, '$1', 1)

	-- CPU
	cpuwidget                  = blingbling.line_graph({
		width                  = widget_width,
		height                 = widget_height,
		rounded_size           = widget_rounded_size,
		v_margin               = 0,
		graph_background_color = beautiful.bg_widget,
		graph_color            = beautiful.bg_focus_widget,
		graph_line_color       = beautiful.border_focus_widget
	})

	vicious.register(cpuwidget, vicious.widgets.cpu, '$1', 1)

	-- NET
	netwidget = blingbling.net({
		background_color       = beautiful.bg_widget,
		graph_color            = beautiful.bg_focus_widget,
		graph_line_color       = beautiful.border_focus_widget,
		text_background_color  = "#ffffff00",
		text_color             = beautiful.fg_normal,
		interface              = io.popen('bash -c \'ip l | grep wlp | cut -d " " -f 2\' | cut -d : -f 1'):read(),
		show_text              = true,
		v_margin               = 0,
	})



    -- Create the wibox
	-- uncommented for other panel
	mywibox[s] = awful.wibox({ position = "top", height = bar_height, screen = s })

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(mylauncher)
	left_layout:add(mytag[s])
	left_layout:add(mypromptbox[s])

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	if s == 1 then
		right_layout:add(wibox.widget.systray())
	end

	right_layout:add(memwidget)
	right_layout:add(cpuwidget)
	right_layout:add(tempwidget)
	right_layout:add(netwidget)
	right_layout:add(clock)
	right_layout:add(mylayoutbox[s])

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(  wibox.layout.margin(left_layout,   margin, margin, margin, margin))
	layout:set_middle(wibox.layout.margin(mytasklist[s], margin, margin, margin, margin))
	layout:set_right( wibox.layout.margin(right_layout,  margin, margin, margin, margin))

	-- If running with gnome panel
	mywibox[s]:set_widget(wibox.layout.margin(layout,    margin, margin, margin, margin))
end

-- Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))

-- Key bindings

function rename_tag()
	awful.prompt.run({
			prompt = "Rename tag: ",
			text   = "",
		},
		mypromptbox[mouse.screen].widget,
		function (s)
			local index = awful.tag.getidx()
			for screen = 1, screen.count() do
				tag = awful.tag.gettags(screen)[index]
				tag.name = index .. ' ' .. s
			end
			-- tag      = awful.tag.selected()
			-- tag.name = awful.tag.getidx() .. ' ' .. s
		end)
end

function cycle_client_forwards()
	awful.client.focus.history.previous()
	if client.focus then
		client.focus:raise()
	end
end

function cycle_client_backwards()
	awful.client.focus.history.next()
	if client.focus then
		client.focus:raise()
	end
end

function next_client()
	awful.client.focus.byidx( 1)
	if client.focus then client.focus:raise() end
end

function previous_client()
	awful.client.focus.byidx(-1)
	if client.focus then client.focus:raise() end
end

function cycle_tiles_forwards()
	tile_index = tile_index + 1
	if tile_index > #tiles then
		tile_index = 1
	end
	awful.layout.set(tiles[tile_index])
end

function cycle_tiles_backwards()
	tile_index = tile_index - 1
	if tile_index == 0 then
		tile_index = #tiles
	end
	awful.layout.set(tiles[tile_index])
end

function first_free_tag()
	tags = awful.tag.gettags(mouse.screen)
	for i = 1, #tags do
		if #tags[i]:clients() == 0 then
			return tags[i]
		end
	end
	return nil
end

-- Run or raise
function rr_cal()
	local matcher = function(c) return awful.rules.match(c, { name = "Google Kalender" }) end
	awful.client.run_or_raise("chromium --app='http://calendar.google.com'", matcher)
end

function rr_mail()
	local matcher = function(c) return awful.rules.match(c, { name = "Geary" }) end
	awful.client.run_or_raise("geary", matcher)
end

function rr_dev()
	local matcher = function(c) return awful.rules.match(c, { name = "Eclipse" }) end
	awful.client.run_or_raise("eclipse", matcher)
end

function rr_browser()
	local matcher = function(c) return awful.rules.match(c, { name = "Chromium" }) end
	awful.client.run_or_raise("chromium", matcher)
end

function rr_term()
	local matcher = function(c) return awful.rules.match(c, { name = "Terminology" }) end
	awful.client.run_or_raise("terminology", matcher)
end

-- Prompts
function prompt_lua()
	awful.prompt.run({ prompt = "Run Lua code: " },
	mypromptbox[mouse.screen].widget,
	awful.util.eval, nil,
	awful.util.getdir("cache") .. "/history_eval")
end

function prompt_dict()
	local word = io.popen("xsel -o")
	local text = ""
	for l in word:lines() do
		text = text .. l
	end

	local lookup = io.popen("dict -fd english " .. text .. " 2>&1")

	local resp = ""
	for l in lookup:lines() do
		resp = resp .. l .. '\n'
	end

	local file   = io.open("/home/s/words", "a")
	file:write(text .. '\n' .. resp .. '\n')

	-- index 3 contains the return code
	local returncode = {file:close()}

	-- os.execute('bash -c "dict -fd english ' .. text .. ' | zenity --text-info &"')
	-- os.execute('bash -c "echo \"' .. resp .. '\" | zenity --text-info &"')
	naughty.notify({ text = resp })

	word:close()
	lookup:close()
end

function prompt_calc()
	awful.prompt.run({ prompt = "Calc: " },
	mypromptbox[mouse.screen].widget,
	function(expr)
		local val = awful.util.eval("return " .. expr)

		naughty.notify({ text = expr .. " = " .. val })
	end, nil,
	awful.util.getdir("cache") .. "/calc")
end

function toggle_maximize(c)
	c.maximized_horizontal = not c.maximized_horizontal
	c.maximized_vertical   = not c.maximized_vertical

	-- Remove border from windows that are maximized in both
	-- directions, and then re-add the default theme border when
	-- the window is restored.
	if c.maximized then
		c.border_width = 0
	else
		c.border_width = beautiful.border_width
	end
end

function move_to_screen(i)
	return function(c)
		awful.client.movetoscreen(c, i)
	end
end

globalkeys = awful.util.table.join(
	awful.key({ modkey,           }, "F1",     move_to_screen(1)),
	awful.key({ modkey,           }, "F2",     move_to_screen(2)),
	awful.key({ modkey,           }, "Right",  function() awful.tag.incmwfact(0.035) end),
	awful.key({ modkey,           }, "Left",   function() awful.tag.incmwfact(-0.035) end),
	awful.key({ modkey,           }, "Up",     function() awful.client.incwfact(0.035) end),
	awful.key({ modkey,           }, "Down",   function() awful.client.incwfact(-0.035) end),
	awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
	awful.key({ modkey,           }, "e",      revelation),
	awful.key({ modkey,           }, "j",      next_client),
	awful.key({ modkey,           }, "k",      previous_client),


-- XKB
	awful.key({ modkey            }, "i ",     function () kbdcfg.switch() end),
	awful.key({ modkey, "Shift"   }, "f",      function () awful.util.spawn("setxkbmap -layout fr") end),
	awful.key({ modkey, "Shift"   }, "e",      function () awful.util.spawn("setxkbmap -layout us") end),
	awful.key({ modkey, "Shift"   }, "n",      function () awful.util.spawn("setxkbmap -layout no") end),

-- Layout manipulation
	awful.key({ modkey,           }, "h ",     awful.tag.viewprev),
	awful.key({ modkey,           }, "l",      awful.tag.viewnext),
	awful.key({ modkey, "Control" }, "j",      function () awful.screen.focus_relative( 1) end),
	awful.key({ modkey, "Control" }, "k",      function () awful.screen.focus_relative(-1) end),
	awful.key({ modkey,           }, "u",      awful.client.urgent.jumpto),
	awful.key({ modkey,           }, "Tab",    cycle_tag_forwards),
	awful.key({ modkey, "Shift"   }, "Tab",    cycle_tag_backwards),
	awful.key({ modkey,           }, "F2",     rename_tag),

-- Standard program
	awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal)    end),
	awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(filemanager) end),
	awful.key({ modkey,           }, "b",      function () awful.util.spawn(webbrowser)  end),
	awful.key({ modkey, "Control" }, "r",      awesome.restart),
	awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

	--                       awful .key({ modkey,             }, "l ",   function () awful.tag.incmwfact( 0.05)    end),
	--                       awful .key({ modkey,             }, "h",    function () awful.tag.incmwfact(-0.05)    end),
	awful.key({ modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)      end),
	awful.key({ modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)      end),
	awful.key({ modkey, "Control" }, "h",      function () awful.tag.incncol( 1)         end),
	awful.key({ modkey, "Control" }, "l",      function () awful.tag.incncol(-1)         end),
	awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1) end),
	awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1) end),
	awful.key({ modkey,           }, "m",      function () awful.layout.set(awful.layout.suit.max) end),
	awful.key({ modkey,           }, "f",      function () awful.layout.set(awful.layout.suit.max.fullscreen) end),

-- Set and cycle between the tiling layouts
	awful.key({ modkey            }, "t", cycle_tiles_forwards),
	awful.key({ modkey, "Shift"   }, "t", cycle_tiles_backwards),

-- Menubar
	awful.key({ modkey, "Control" }, "c", rr_cal),
	awful.key({ modkey, "Control" }, "m", rr_mail),
	awful.key({ modkey, "Control" }, "e", rr_dev),
	awful.key({ modkey, "Control" }, "b", rr_browser),
	awful.key({ modkey, "Control" }, "t", rr_term),

-- Launchers
	awful.key({ modkey,           }, "p", function() menubar.show() end),
	awful.key({ modkey, "Control" }, "p", function() os.execute("synapse &") end),
	awful.key({ modkey, "Control" }, "f", function() os.execute("catfish &") end),

-- Prompts
	awful.key({ modkey,           }, "r", function () mypromptbox[mouse.screen]:run() end),
	awful.key({ modkey,           }, "x", run_lua_code),
	awful.key({ modkey, "Control" }, "k", prompt_calc),
	awful.key({ modkey            }, "d", prompt_dict)
)

clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
	awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
	awful.key({ modkey,           }, "y",      toggle_maximize)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = awful.util.table.join(globalkeys,
	-- View tag only.
	awful.key({ modkey                     }, "#" .. i + 9,
		function ()
			for screen = 1, screen.count() do
				local tag = awful.tag.gettags(screen)[i]
				if tag then
					awful.tag.viewonly(tag)
				end
			end
		end),
	-- Toggle tag.
	awful.key({ modkey, "Control"          }, "#" .. i + 9,
		function ()
			for screen = 1, screen.count() do
				local tag = awful.tag.gettags(screen)[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end
		end),
	-- Move client to tag.
	awful.key({ modkey, "Shift"            }, "#" .. i + 9,
		function ()
			if client.focus then
				local tag = awful.tag.gettags(client.focus.screen)[i]
				if tag then
					awful.client.movetotag(tag)
				end
			end
		end),
	-- Toggle tag.
	awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
		function ()
			if client.focus then
				local tag = awful.tag.gettags(client.focus.screen)[i]
				if tag then
					awful.client.toggletag(tag)
				end
			end
		end))
end

clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1,
		function(c)
			c.maximized = false
			awful.mouse.client.move(c)
		end),
	awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)


function move_to_active_screen_and_center(c)
	move_timer = timer { timeout = 0.4 }

	move_timer:connect_signal("timeout",
		function()
			awful.client.movetoscreen(c, mouse.screen)
			awful.placement.centered(c)
			move_timer:stop()
		end)

	move_timer:start()
end

-- Rules
-- Rules to apply to new clients (through the "manage" signal).
floating_no_border = {
	floating     = true,
	border_width = 0
}
max_layout = {
	layout = awful.layout.suit.max
}
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus        = awful.client.focus.filter,
			raise        = true,
			keys         = clientkeys,
			buttons      = clientbuttons
		}
	},
	-- { rule = { class = "Gloobus-preview"               }, properties = floating_no_border  } ,
	{ rule = { class = "Catfish"                       }, properties = floating_no_border  } ,
	{ rule = { class = "Docky"                         }, properties = floating_no_border  } ,
	{ rule = { class = "Ftjerm"                        }, properties = floating_no_border  } ,
	{ rule = { class = "Galculator"                    }, properties = floating_no_border  } ,
	{ rule = { class = "Gimp"                          }, properties = floating_no_border  } ,
	{ rule = { class = "Gloobus-preview-configuration" }, properties = floating_no_border  } ,
	{ rule = { class = "Guake"                         }, properties = floating_no_border  } ,
	{ rule = { class = "MPlayer"                       }, properties = floating_no_border  } ,
	{ rule = { class = "Pavucontrol"                   }, properties = floating_no_border  } ,
	{ rule = { class = "Pinentry"                      }, properties = floating_no_border  } ,
	{ rule = { class = "Stjerm"                        }, properties = floating_no_border  } ,
	{ rule = { class = "Sushi-start"                   }, properties = floating_no_border  } ,
	-- { rule = { class = "Synapse"                       }, properties = floating_no_border  } ,
	-- { rule = { class = "synapse"                       }, properties = floating_no_border  } ,
	{ rule = { class = "Xfce4-panel"                   }, properties = floating_no_border  } ,
	{ rule = { class = "Yakuake"                       }, properties = floating_no_border  } ,
	{ rule = { class = "guake"                         }, properties = floating_no_border  } ,
	{ rule = { name  = "Error messages"                }, properties = floating_no_border  } ,
	{ rule = { name  = "erythrina"                     }, properties = { height = 20, floating = true, sticky = true, ontop = true}  } ,

	{ rule = { class = "Dartium"                       }, properties = max_layout          } ,
	{ rule = { class = "Eclipse"                       }, properties = max_layout          } ,
	{ rule = { class = "Meld"                          }, properties = max_layout          } ,

	{ rule = { class = "Chromium"                      }, properties = { maximized = false } },

	{ rule = { class = "Gloobus-preview"               }, properties = floating_no_border
                                                        , callback = move_to_active_screen_and_center },

	{ rule = { class = "Dartium"                       }, properties = { tag = tags[1][2]  } } ,
	{ rule = { class = "Eclipse"                       }, properties = { tag = tags[1][2]  } } ,

	{ rule = { class = "Hexchat"                       }, properties = { tag = tags[1][3]  } } ,
	{ rule = { class = "Skype"                         }, properties = { tag = tags[1][3]  } } ,
	{ rule = { class = "Smuxi"                         }, properties = { tag = tags[1][3]  } } ,

	{ rule = { class = "Geary"                         }, properties = { tag = tags[1][4]  } } ,
	{ rule = { class = "Liferea"                       }, properties = { tag = tags[1][4]  } } ,

	{ rule = { class = "Gmpc"                          }, properties = { tag = tags[1][5]  } } ,
	{ rule = { class = "cantata"                       }, properties = { tag = tags[1][5]  } } ,
	{ rule = { class = "Ario"                          }, properties = { tag = tags[1][5]  } } ,
	{ rule = { class = "Sonata"                        }, properties = { tag = tags[1][5]  } }
}



function set_titlebar(c)
	if c.type == "normal"
	or c.type == "dialog" then
		-- buttons for the titlebar
		local buttons = awful.util.table.join(
			awful.button({}, 1,
				function()
					client.focus = c
					c:raise()
					awful.mouse.client.move(c)
				end),
			awful.button({}, 3,
				function()
					client.focus = c
					c:raise()
					awful.mouse.client.resize(c)
				end)
		)

		-- Widgets that are aligned to the left
		local left_layout = wibox.layout.fixed.horizontal()
		left_layout:add(awful.titlebar.widget.iconwidget(c))
		left_layout:buttons(buttons)

		-- Widgets that are aligned to the right
		local right_layout = wibox.layout.fixed.horizontal()
		right_layout:add(awful.titlebar.widget.floatingbutton(c))
		right_layout:add(awful.titlebar.widget.maximizedbutton(c))
		right_layout:add(awful.titlebar.widget.stickybutton(c))
		right_layout:add(awful.titlebar.widget.ontopbutton(c))
		right_layout:add(awful.titlebar.widget.closebutton(c))

		-- The title goes in the middle
		local middle_layout = wibox.layout.flex.horizontal()
		local title = awful.titlebar.widget.titlewidget(c)
		title:set_align("center")
		middle_layout:add(title)
		middle_layout:buttons(buttons)

		-- Now bring it all together
		local layout = wibox.layout.align.horizontal()
		layout:set_left(left_layout)
		layout:set_right(right_layout)
		layout:set_middle(middle_layout)

		awful.titlebar(c):set_widget(layout)
		awful.titlebar.hide(c)
	end
end
-- Signals
-- When a client disappears
client.connect_signal("unmanage",
	function(c)
		local next = awful.client.next(1)
		if next and
		   next == awful.client.next(1) then
			next.border_width = 0
		end
	end)

-- When a client appears
client.connect_signal("manage",
	function (c, startup)

		if awful.client.floating.get(c) then
			c.border_width = 0
		end
		-- Enable sloppy focus
		c:connect_signal("mouse::enter",
			function(c)
				if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
					and awful.client.focus.filter(c) then
					client.focus = c
				end
			end)

		if not startup then
			-- Set the windows at the slave,
			-- i.e. put it at the end of others instead of setting it master.
			-- awful.client.setslave(c)

			-- Put windows in a smart way, only if they does not set an initial position.
			if not c.size_hints.user_position and not c.size_hints.program_position then
				-- awful.placement.under_mouse(c)
				-- awful.placement.no_offscreen(c)
				awful.placement.centered(c)
			end
		end

		set_titlebar(c)

	end)

function focused_client()
	return tags[mouse.screen][awful.tag.getidx()]:clients()[1]
end

function is_empty(tag)
	count = 0
	for _, c in pairs(tag:clients()) do
		-- client is used so that won't match against self
		-- if client.class ~= c.class then
		count = count + 1
		-- end
	end
	return count == 0
end

function single_client_on_tag()
	-- There is a period where no tag is selected
	local tags = awful.tag.gettags(mouse.screen)
	local tag = awful.tag.getidx()
	if not tag then
		return false
	end
	return #tags[tag]:clients() == 1
end

function is_single_layout()
	local layoutname = awful.layout.getname(awful.layout.get(mouse.screen))
	if     layoutname == "max"
		or layoutname == "fullscreen" then
		return true
	end
	return false
end

function toggle_border(b, c)
	if b then
		c.border_width = 0
	else
		c.border_width = beautiful.border_width
	end
end


function on_client_focus_change(c)
	toggle_border(
		c.maximized or
		single_client_on_tag() or
		is_single_layout(), c)
end

client.connect_signal("focus",
	function(c)
		local tag = awful.tag.getidx()
		c.border_color = beautiful.border_focus
		on_client_focus_change(c)
		awful.client.focus.byidx(0, c)
	end)

client.connect_signal("unfocus",
	function(c)
		c.border_color = beautiful.border_normal
		on_client_focus_change(c)
	end)

client.connect_signal("property::maximized",
	function(c)
		toggle_border(c.maximized, c)
	end)

client.connect_signal("property::floating",
	function(c)
		toggle_border(true, c)
		if awful.client.floating.get(c) then
			if not awful.titlebar then
				set_titlebar(c)
			end
			awful.titlebar.show(c)
		else
			awful.titlebar.hide(c)
		end
	end)

tag.connect_signal("property::layout",
	function(t)
		local layoutname = awful.layout.getname(awful.layout.get(mouse.screen))
		local c = client.focus
		toggle_border(c and is_single_layout(), c)
	end)


wallpaper_files = {}
local i = 1
for l in io.popen('bash -c "find ' .. wallpaper_path .. ' -type f -name \'*.jpg\'"'):lines() do
	wallpaper_files[i] = l
	i = i + 1
end

wallpaper_indexes = {}
for i = 1, #wallpaper_files do
	wallpaper_indexes[i] = i
end
for i = 1, #wallpaper_files do
	j = math.random(1, #wallpaper_indexes)
	tmp = wallpaper_indexes[i]
	wallpaper_indexes[i] = wallpaper_indexes[j]
end

function setbg(wallpaper)
	for s = 1, screen.count() do
		gears.wallpaper.maximized(wallpaper, s)
		-- gears.wallpaper.fit(wallpaper, s)
		-- gears.wallpaper.tiled(wallpaper, s)
		-- gears.wallpaper.centered(wallpaper, s)
		-- util.setbg(wallpaper)
	end
end


i = 1
-- setup the timer
wallpaper_timer = timer { timeout = wallpaper_timeout }
wallpaper_timer:connect_signal("timeout",
	function()
		-- set wallpaper to current index for all screens
		-- util.setbg(wallpaper_files[wallpaper_index])
		-- stop the timer (we don't need multiple instances running at the same time)
		wallpaper_timer:stop()
		setbg(wallpaper_files[wallpaper_indexes[i]])

		-- get next random index
		if i == #wallpaper_indexes then
			i = 1
		else
			i = i + 1
		end

		--restart the timer
		wallpaper_timer.timeout = wallpaper_timeout
		wallpaper_timer:start()
	end)

-- initial start when rc.lua is first run
wallpaper_timer:start()
setbg(wallpaper_files[wallpaper_indexes[i]])


os.execute("ftjerm -m windows -k f12 -o 0 -fn Mono 12 -bg white -w 60% -h 50% \"tmux -2\" &")
os.execute("/home/s/bin/setup_notify_send")

-- TODO
-- fix cairo bug
-- name clients by letter
-- set keyboard layout for applications
-- rotate through all clients on a tag, not per screen
-- add possibility to search for window

-- vim: set foldmethod=indent:
