-- Standard awesome library
local gears                  = require("gears")
local awful                  = require("awful")
                               require("eminent")
awful.rules                  = require("awful.rules")
                               require("awful.autofocus")
local wibox                  = require("wibox") -- Widget and layout library
local beautiful              = require("beautiful") -- Theme handling library
local naughty                = require("naughty") -- Notification library
local menubar                = require("menubar")
local vicious                = require("vicious")
local revelation             = require("revelation")
local ror                    = require("aweror")
local blingbling             = require("blingbling")




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

-- Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init("/home/s/.config/awesome/theme.lua")
revelation.init() -- after beatuiful.init(), init revelation

-- to change wallpaper randomly
theme.wallpaper = "/usr/share/backgrounds/hawaii/Arancio.jpg"
wp_path         = "/usr/share/backgrounds/hawaii/" -- has to end with /
wp_timeout      = 3600 -- seconds interval to change wallpaper

-- This is used later as the default terminal and editor to run.
terminal    = "terminology"
filemanager = "nautilus"
webbrowser  = "chromium"
editor      = "vim"
editor_cmd  = terminal .. " -e " .. editor

modkey = "Mod4"

-- Naughty configuration
naughty.config.padding                   = 15
naughty.config.spacing                   = 5
naughty.config.presets.low.bg            = beautiful.bg_focus_darker
naughty.config.presets.low.fg            = beautiful.fg_focus
naughty.config.presets.normal.bg         = beautiful.bg_focus_darker
naughty.config.presets.normal.fg         = beautiful.fg_focus
naughty.config.presets.critical.bg       = beautiful.bg_urgent
naughty.config.presets.critical.fg       = beautiful.fg_urgent
naughty.config.defaults.timeout          = 10
naughty.config.defaults.margin           = 10
naughty.config.defaults.hover_timeout    = 1

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
local layouts =
{
	awful.layout.suit.tile,
	-- awful.layout.suit.floating,
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
bar_height          = 30
margin              = bar_height / 20
widget_width        = bar_height - 2 * margin
widget_height       = widget_width
launcher_icon       = "/home/s/Dropbox/icons/skilpadde-3.png"

-- Wallpaper
if beautiful.wallpaper then
	for s = 1, screen.count() do
		gears.wallpaper.maximized(beautiful.wallpaper, s, true)
	end
end


-- Menubar configuration
menubar.menu_gen.all_menu_dirs = {"/home/s/.local/share/applications/", "/usr/share/applications/" }
menubar.utils.terminal         = terminal -- Set the terminal for applications that require it
menubar.geometry               = {
	height = 30
}
-- Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = awful.tag({ "web", "prg", "chat", "mail", "music", 6, 7, 8, 9 }, s, layouts[1])
end

-- Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
	{ "manual"      , terminal .. " -e man awesome" }         ,
	{ "edit config" , editor_cmd .. " " .. awesome.conffile } ,
	{ "restart"     , awesome.restart }                       ,
	{ "quit"        , awesome.quit }
}

mymainmenu = awful.menu({ items = {
	{ "awesome"       , myawesomemenu , launcher_icon } ,
	{ "open terminal" , terminal }}
})

mylauncher = awful.widget.launcher({
	image = launcher_icon,
	menu = mymainmenu
})


--  Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock("%a %b %d")

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

	-- Memory
	memwidget     = blingbling.wlourf_circle_graph({
		show_text = true,
		radius    = widget_width / 3,
		show_text = true,
		label     = "",
		height    = widget_height
	})
	memwidget:set_graph_color(beautiful.fg_widget)


	vicious.register(memwidget, vicious.widgets.mem, '$1', 5)

	-- CPU
	cpuwidget                  = blingbling.line_graph({
		width                  = widget_width,
		height                 = widget_height - 2,
		rounded_size           = 0,
		graph_background_color = "#ffffff00",
		-- graph_background_color = beautiful.bg_widget,
		graph_color            = beautiful.bg_focus_widget,
		graph_line_color       = beautiful.border_focus_widget
	})
	vicious.register(cpuwidget, vicious.widgets.cpu, '$1', 1)

	-- NET
	netwidget = blingbling.net({
		graph_color           = beautiful.bg_focus_widget,
		graph_line_color      = beautiful.border_focus_widget,
		text_background_color = "#ffffff00",
		interface             = "wlp12s0",
		show_text             = true,
	})


	-- MPD
	-- Initialize widget
	mpdwidget = wibox.widget.textbox()
	-- Register widget
	vicious.register(mpdwidget, vicious.widgets.mpd,
		function (mpdwidget, args)
			if args["{state}"] == "Stop" then
				return " - "
			else
				return args["{Artist}"]..' - '.. args["{Title}"]
			end
		end, 10)

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
	right_layout:add(netwidget)
	right_layout:add(mytextclock)
	right_layout:add(mylayoutbox[s])

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(wibox.layout.margin(left_layout, margin, margin, margin, margin))
	layout:set_middle(wibox.layout.margin(mytasklist[s], margin, margin, margin, margin))
	layout:set_right(wibox.layout.margin(right_layout, margin, margin, margin, margin))

	-- If running with gnome panel
	mywibox[s]:set_widget(wibox.layout.margin(layout, margin, margin, margin, margin))
end

-- Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))

-- Key bindings

globalkeys = awful.util.table.join(
	awful.key({ modkey,               }, "Left",   awful.tag.viewprev       ),
	awful.key({ modkey,               }, "Right",  awful.tag.viewnext       ),
	awful.key({ modkey,               }, "Escape", awful.tag.history.restore),
	awful.key({ modkey,               }, "e",      revelation),

	awful.key({ modkey,               }, "j",
		function ()
			awful.client.focus.byidx( 1)
			if client.focus then client.focus:raise() end
		end),
	awful.key({ modkey,               }, "k",
		function ()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end),

	awful.key({ modkey,            }, "q",
		function()
			local p = os.execute("pgrep ftjerm")
			if not p then
<<<<<<< HEAD
				os.execute("ftjerm -o 70 -w 100% -h 100% -fn Mono 13 -k f11 &")
=======
				os.execute("ftjerm -o 70 -w 90% -h 90% -fn Mono 13 -k f11 &")
>>>>>>> 36dd65fe0d958b097b53a91ed1930e430e66e5f7
			end
			os.execute("ftjerm --toggle &")
		end),

	-- XKB
	awful.key({ modkey            }, "i", function() kbdcfg.switch() end),
	awful.key({ modkey, "Shift"   }, "f", function() awful.util.spawn("setxkbmap -layout fr") end),
	awful.key({ modkey, "Shift"   }, "e", function() awful.util.spawn("setxkbmap -layout us") end),
	awful.key({ modkey, "Shift"   }, "n", function() awful.util.spawn("setxkbmap -layout no") end),

	-- Layout manipulation
	awful.key({ modkey,               }, "h", awful.tag.viewprev ),
	awful.key({ modkey,               }, "l", awful.tag.viewnext ),
	awful.key({ modkey, "Control"     }, "j", function () awful.screen.focus_relative( 1) end),
	awful.key({ modkey, "Control"     }, "k", function () awful.screen.focus_relative(-1) end),
	awful.key({ modkey,               }, "u", awful.client.urgent.jumpto),
	awful.key({ modkey,           }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end),
	awful.key({ modkey,           }, "F2", function ()
			awful.prompt.run({ prompt = "Rename tab: ", text = "", },
			mypromptbox[mouse.screen].widget,
			function (s) awful.tag.selected().name = s end)
		end),

	-- Standard program
	awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal)    end),
	awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(filemanager) end),
	awful.key({ modkey,           }, "b",      function () awful.util.spawn(webbrowser)  end),
	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit),

	--awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
	--awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
	awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
	awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
	awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
	awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
	awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
	awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
	awful.key({ modkey,           }, "m",     function () awful.layout.set(awful.layout.suit.max) end),
	awful.key({ modkey,           }, "f",     function () awful.layout.set(awful.layout.suit.max.fullscreen) end),
	awful.key({ modkey            }, "t",
		function()
			tile_index = tile_index + 1
			if tile_index > #tiles then
				tile_index = 1
			end
			awful.layout.set(tiles[tile_index])
		end),
	-- awful.key({ modkey, "Control" }, "n", awful.client.restore),

	-- Prompt
	awful.key({ modkey,           }, "r", function () mypromptbox[mouse.screen]:run() end),

	awful.key({ modkey,           }, "x",
		function ()
			awful.prompt.run({ prompt = "Run Lua code: " },
			mypromptbox[mouse.screen].widget,
			awful.util.eval, nil,
			awful.util.getdir("cache") .. "/history_eval")
		end),
		-- Menubar
	awful.key({ modkey,           }, "p", function() menubar.show() end),
	awful.key({ modkey, "Control" }, "c", function()
		local matcher = function(c) return awful.rules.match(c, { name = "Google Kalender" }) end
		awful.client.run_or_raise("chromium --app='http://calendar.google.com'", matcher)
	end),
	awful.key({ modkey, "Control" }, "g", function()
		local matcher = function(c) return awful.rules.match(c, { name = "Geary" }) end
		awful.client.run_or_raise("geary", matcher)
	end),
	awful.key({ modkey, "Control" }, "e", function()
		local matcher = function(c) return awful.rules.match(c, { name = "Eclipse" }) end
		awful.client.run_or_raise("eclipse", matcher)
	end),
	awful.key({ modkey, "Control" }, "b", function()
		local matcher = function(c) return awful.rules.match(c, { name = "Chromium" }) end
		awful.client.run_or_raise("chromium", matcher)
	end),
	awful.key({ modkey, "Control" }, "t", function()
		local matcher = function(c) return awful.rules.match(c, { name = "Terminology" }) end
		awful.client.run_or_raise("terminology", matcher)
	end),
	awful.key({ modkey            }, "d",
		function()
			local word = io.popen("xsel -o")
			local text = ""
			for l in word:lines() do
				text = text .. l
			end

			local lookup = io.popen("dict -d wn " .. text .. " 2>&1")

			local resp = ""
			for l in lookup:lines() do
				resp = resp .. l .. '\n'
			end

			local file   = io.open("/home/s/words", "a")
			file:write(text .. '\n' .. resp .. '\n')
			file:close()

			naughty.notify({ text = resp })

			word:close()
			lookup:close()
		end),
	awful.key({ modkey, "Control"   }, "p", function() os.execute("synapse") end),
	awful.key({ modkey, "Control"   }, "f", function() os.execute("catfish") end),

	awful.key({ modkey, "Control"   }, "k",
		function()
			awful.prompt.run({ prompt = "Calc: " },
			mypromptbox[mouse.screen].widget,
			function(expr)
				local val = awful.util.eval("return " .. expr)

				naughty.notify({ text = expr .. " = " .. val })
			end, nil,
			awful.util.getdir("cache") .. "/calc")
		end)
)

clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
	awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
	awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
	-- awful.key({ modkey,           }, "n",
	--     function (c)
	--         -- The client currently has the input focus, so it cannot be
	--         -- minimized, since minimized clients can't have the focus.
	--         c.minimized = true
	--     end),
	awful.key({ modkey,           }, "y",
		function (c)
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
		end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = awful.util.table.join(globalkeys,
	-- View tag only.
	awful.key({ modkey }, "#" .. i + 9,
		function ()
			local screen = mouse.screen
			local tag = awful.tag.gettags(screen)[i]
			if tag then
				awful.tag.viewonly(tag)
			end
		end),
	-- Toggle tag.
	awful.key({ modkey, "Control" }, "#" .. i + 9,
		function ()
			local screen = mouse.screen
			local tag = awful.tag.gettags(screen)[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end),
	-- Move client to tag.
	awful.key({ modkey, "Shift" }, "#" .. i + 9,
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

-- Rules
-- Rules to apply to new clients (through the "manage" signal).
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
	}, {
		rule_any = { class = {
			-- "ftjerm"                        , "Ftjerm"                        ,
			-- "stjerm"                        , "Stjerm"                        ,
			"docky"                         , "Docky"                         ,
			"xfce4-panel"                   , "Xfce4-panel"                   ,
			"mplayer"                       , "MPlayer"                       ,
			"yakuake"                       , "Yakuake"                       ,
			"pinentry"                      , "Pinentry"                      ,
			"gimp"                          , "Gimp"                          ,
			"sushi-start"                   , "Sushi-start"                   ,
			"gloobus-preview"               , "Gloobus-preview"               ,
			"gloobus-preview-configuration" , "Gloobus-preview-configuration"
		} },
		properties = {
			floating     = true ,
			border_width = 0
		}
	}, {
		rule_any = { class = {
			"ftjerm", "Ftjerm",
			"stjerm", "Stjerm"
		} },
		properties = {
			floating = true, -- works
			border_width = 0, -- doesn't work
		}
	}, {
		rule_any = { class = {
			"chromium", "Chromium"
		} },
		properties = {
			maximized = false
		}
	}, {
		rule_any = { class = {
			"meld", "Meld",
			"eclipse", "Eclipse",
			"dartium", "Dartium"
		} },
		properties = {
			layout = awful.layout.suit.max
		}
	}, {
		rule_any = { class = {
			"eclipse", "Eclipse",
			"dartium", "Dartium"
		} },
		properties = {
			tag = tags[1][2],
		}
	}, {
		rule_any = { class = {
			"skype"   , "Skype"   ,
			"smuxi"   , "Smuxi"   ,
			"hexchat" , "Hexchat"
		} },
		properties = {
			tag = tags[1][3]
		}
	}, {
		rule_any = { class = {
			"geary", "Geary"
		} },
		properties = {
			tag = tags[1][4]
		}
	}, {
		rule_any = { class = {
			"gmpc", "Gmpc", "sonata", "Sonata"
		} },
		properties = {
			tag = tags[1][5]
		}
	}
}

-- Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
	-- Enable sloppy focus
	c:connect_signal("mouse::enter", function(c)
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

	local titlebars_enabled = false
	if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
		-- buttons for the titlebar
		local buttons = awful.util.table.join(
			awful.button({ }, 1, function()
				client.focus = c
				c:raise()
				awful.mouse.client.move(c)
			end),
			awful.button({ }, 3, function()
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
	end
end)

function single_client_on_tag()
	local current_tag = tags[mouse.screen][awful.tag.getidx()]
	return #current_tag:clients() == 1
end

function is_single_layout()
	local layoutname = awful.layout.getname(awful.layout.get(mouse.screen))
	if     layoutname == "max"
		or layoutname == "full" then
		return true
	end
	return false
end


function on_client_focus(c)
	if c.maximized_horizontal == true and c.maximized_vertical == true
	or single_client_on_tag()
	or is_single_layout() then
		c.border_width = 0
	else
		c.border_width = beautiful.border_width
	end

	c.border_color = beautiful.border_focus
end
client.connect_signal("focus", on_client_focus)

client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

client.connect_signal("unmanage", function(c)
		local next = awful.client.next(1)
		if next and
		   next == awful.client.next(1) then
			next.border_width = 0
		end
	end)

tag.connect_signal("property::layout",
	function(t)
		local layoutname = awful.layout.getname(awful.layout.get(mouse.screen))
		if layoutname == "max" or layoutname == "full" then
			local c = client.focus
			c.border_width = 0
		end
	end)


-- scan directory, and optionally filter outputs
function scandir(directory, filter)
	local i, t, popen = 0, {}, io.popen
	if not filter then
		filter = function(s) return true end
	end
	print(filter)
	for filename in popen('ls -a "'..directory..'"'):lines() do
		if filter(filename) then
			i = i + 1
			t[i] = filename
		end
	end
	return t
end


-- configuration - edit to your liking
wp_index  = 1
wp_filter = function(s) return string.match(s,"%.png$") or string.match(s,"%.jpg$") end
wp_files  = scandir(wp_path, wp_filter)

-- setup the timer
wp_timer = timer { timeout = wp_timeout }
wp_timer:connect_signal("timeout", function()

	-- set wallpaper to current index for all screens
	for s = 1, screen.count() do
		gears.wallpaper.maximized(wp_path .. wp_files[wp_index], s, true)
	end

	-- stop the timer (we don't need multiple instances running at the same time)
	wp_timer:stop()

	-- get next random index
	wp_index = math.random( 1, #wp_files)

	--restart the timer
	wp_timer.timeout = wp_timeout
	wp_timer:start()
end)

-- initial start when rc.lua is first run
wp_timer:start()

