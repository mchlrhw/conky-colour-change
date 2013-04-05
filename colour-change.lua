--[[
    Conky Colour Change by mrmrwat
    A fork of Ring Meters v1.2.1 by londonali1010
    Inspired by PolarClock by pixelbreaker
    
    Features:
    -- Support for colour changing background and foreground indicators
    -- Colour profiles of background and foreground indicators can be set
       independently, allowing one indicator to display two different profiles
    -- Can define own custom colours
    -- Can transition from any colour to any other colour
    -- Supports smooth time indicators up to year of the century with
       millisecond precision for smooth second indicator movement
--]]

require 'cairo'
require 'socket'

-- Global settings table
-- Change these values to alter the appearance of your indicators
settings_table = {
    {
        -- Year of the century indicator
        name = 'smooth_time',
        arg = '%y',
        max = 100,
        bg_clr_chng = true, bg_colour = 'default', bg_alpha = 0.3,
        fg_clr_chng = true, fg_colour = 'default', fg_alpha = 0.8,
        x = 180, y = 180,
        radius = 160,
        thickness = 4,
        start_angle = -60,
        end_angle = 60
    },
    {
        -- Day of the year indicator
        name = 'smooth_time',
        arg = '%j',
        max = 365,
        bg_clr_chng = true, bg_colour = 'default', bg_alpha = 0.3,
        fg_clr_chng = true, fg_colour = 'default', fg_alpha = 0.8,
        x = 180, y = 180,
        radius = 150,
        thickness = 6,
        start_angle = -60,
        end_angle = 60
    },
    {
        -- Day of the month indicator
        name = 'smooth_time',
        arg = '%d',
        -- max is reset in the smooth_time function depending on the month
        max = 31,
        bg_clr_chng = true, bg_colour = 'default', bg_alpha = 0.3,
        fg_clr_chng = true, fg_colour = 'default', fg_alpha = 0.8,
        x = 180, y = 180,
        radius = 160,
        thickness = 4,
        start_angle = 120,
        end_angle = 240
    },
    {
        -- Day of the week indicator
        name = 'smooth_time',
        arg = '%u',
        max = 7,
        bg_clr_chng = true, bg_colour = 'default', bg_alpha = 0.3,
        fg_clr_chng = true, fg_colour = 'default', fg_alpha = 0.8,
        x = 180, y = 180,
        radius = 150,
        thickness = 6,
        start_angle = 120,
        end_angle = 240
    },
    {
        -- Hour indicator
        name = 'smooth_time',
        arg = '%I',
        max = 12,
        bg_clr_chng = true, bg_colour = 'default', bg_alpha = 0.3,
        fg_clr_chng = true, fg_colour = 'default', fg_alpha = 0.8,
        x = 180, y = 180,
        radius = 75,
        thickness = 12,
        start_angle = 0,
        end_angle = 360
    },
    -- Uncomment below and comment out above for 24 hour clock
    --[[{
        -- 24 hour indicator
        name = 'smooth_time',
        arg = '%H',
        max = 24,
        bg_clr_chng = true, bg_colour = 'default', bg_alpha = 0.1,
        fg_clr_chng = true, fg_colour = 'default', fg_alpha = 0.8,
        x = 180, y = 180,
        radius = 75,
        thickness = 12,
        start_angle = 0,
        end_angle = 360
    },]]
    {
        -- Minute indicator
        name = 'smooth_time',
        arg = '%M',
        max = 60,
        bg_clr_chng   = true,  bg_colour = 'default',
        bg_alpha_chng = false, bg_alpha = 0.3,
        fg_clr_chng   = true,  fg_colour = 'default',
        fg_alpha_chng = false, fg_alpha = 0.8,
        x = 180, y = 180,
        radius = 90,
        thickness = 7,
        start_angle = 0,
        end_angle = 360
    },
    {
        -- Second indicator
        name = 'smooth_time',
        arg = '%S',
        max = 60,
        bg_clr_chng   = true,  bg_colour = 'default',
        bg_alpha_chng = false, bg_alpha = 0.3,
        fg_clr_chng   = true,  fg_colour = 'default',
        fg_alpha_chng = false, fg_alpha = 0.8,
        x = 180, y = 180,
        radius = 120,
        thickness = 4,
        start_angle = 0,
        end_angle = 360
    },
}

-- Colour "class" and associated functions
-- No need to change any of this, see below for configurable sections
Colour = {}
function Colour:new(r, g, b)
    local object = {r = r, g = g, b = b}
    setmetatable(object, {__index = Colour})
    return object
end
function Colour:rgb()
    return self.r, self.g, self.b
end
function Colour:cmp(colour)
    return colour.r - self.r, colour.g - self.g, colour.b - self.b
end
function Colour:trans(colour, factor)
    local diffr, diffg, diffb = self:cmp(colour)
    local newr, newg, newb
    if diffr ~= 0 then
        newr = self.r + diffr + (factor * diffr)
    else
        newr = self.r
    end
    if diffg ~= 0 then
        newg = self.g + diffg + (factor * diffg)
    else
        newg = self.g
    end
    if diffb ~= 0 then
        newb = self.b + diffb + (factor * diffb)
    else
        newb = self.b
    end
    return newr, newg, newb
end

Alpha = {}
function Alpha:new(a)
    local object = {r = r, g = g, b = b, a = a}
    setmetatable(object, {__index = Alpha})
    return object
end
function Alpha:a()
    return self.a
end
function Alpha:cmp(colour)
    return colour.a - self.a
end
function Alpha:trans(alpha, factor)
    local diffa = self:cmp(colour)
    local newa
    if diffa ~= 0 then
        newa = self.a + diffa + (factor * diffa)
    else
        newa = self.a
    end
    return newa
end

-- Colour presets
-- NB. Transitions between some colours may or may not look good depending on
-- the properties of the colours involved
-- The most natural transitions occur between colours that share an rgb value,
-- such as red and orange, or red and yellow
-- Transitioning from blue directly to orange, for example, has to transition
-- through a brownish colour
white     = Colour:new(1,   1,   1)
black     = Colour:new(0,   0,   0)
red       = Colour:new(1,   0,   0)
orange    = Colour:new(1,   0.5, 0)
yellow    = Colour:new(1,   1,   0)
grass     = Colour:new(0.5, 1,   0)
green     = Colour:new(0,   1,   0)
turquoise = Colour:new(0,   1,   0.5)
cyan      = Colour:new(0,   1,   1)
ocean     = Colour:new(0,   0.5, 1)
blue      = Colour:new(0,   0,   1)
violet    = Colour:new(0.5, 0,   1)
magenta   = Colour:new(1,   0,   1)
raspberry = Colour:new(1,   0,   0.5)
-- Custom colours
-- Feel free to add your own custom colours here
dark_red  = Colour:new(0.4, 0,   0)

-- Alpha presets
on        = Alpha:new(1)
off       = Alpha:new(0)
half      = Alpha:new(0.5)
fifth     = Alpha:new(0.2)
tenth     = Alpha:new(0.1)
-- Custom alphas
-- Feel free to add your own custom alphas here

-- rgb_change
-- Define your colour profiles in this function
function rgb_change(profile, arc_perc)
    local r, g, b = 0, 0, 0
    if profile == 'default' then
        local num_trans = 6
        local num_cycles = 1
        local num_sctrs = num_trans * num_cycles
        local arc_len = arc_perc * num_sctrs
        local sector = math.ceil(arc_len)
        local progress = arc_len - sector
        local transition = sector % num_trans
        if transition == 1 then
            r, g, b = blue:trans(cyan, progress)
        elseif transition == 2 then
            r, g, b = cyan:trans(green, progress)
        elseif transition == 3 then
            r, g, b = green:trans(yellow, progress)
        elseif transition == 4 then
            r, g, b = yellow:trans(red, progress)
        elseif transition == 5 then
            r, g, b = red:trans(magenta, progress)
        elseif transition == 0 then
            r, g, b = magenta:trans(blue, progress)
        end
    -- The profile below has been extensively commented to provide you with a
    -- starting point for profile creation
    elseif profile == 'custom' then
        -- num_trans = the number of colour transitions in your profile
        local num_trans = 6
        -- num_cycles = the number of times your profile will cycle through its
        -- transitions in one revolution, increase this value to make your
        -- indicators flash or pulse
        local num_cycles = 2
        -- No need to alter the following settings
        local num_sctrs = num_trans * num_cycles
        local arc_len = arc_perc * num_sctrs
        local sector = math.ceil(arc_len)
        local progress = arc_len - sector
        local transition = sector % num_trans
        -- The if-elseif statement below is a list of your transitions
        -- Make sure the number of transitions matches the value of num_trans
        -- First transition
        if transition == 1 then
            r, g, b = cyan:trans(ocean, progress)
        -- Second transition
        elseif transition == 2 then
            r, g, b = ocean:trans(green, progress)
        -- Third transition
        elseif transition == 3 then
            r, g, b = green:trans(orange, progress)
        -- Fourth transition
        elseif transition == 4 then
            r, g, b = orange:trans(raspberry, progress)
        -- Fifth transition
        elseif transition == 5 then
            r, g, b = raspberry:trans(violet, progress)
        -- Sixth transition
        -- NB. The last transition should always end with == 0
        elseif transition == 0 then
            r, g, b = violet:trans(cyan, progress)
        end
    elseif profile == 'orange_pulse' then
        local num_trans = 2
        local num_cycles = 30
        local num_sctrs = num_trans * num_cycles
        local arc_len = arc_perc * num_sctrs
        local sector = math.ceil(arc_len)
        local progress = arc_len - sector
        local transition = sector % num_trans
        if transition == 1 then
            r, g, b = orange:trans(red, progress)
        elseif transition == 0 then
            r, g, b = red:trans(orange, progress)
        end
    elseif profile == 'traffic_light' then
        local num_trans = 6
        local num_cycles = 1
        local num_sctrs = num_trans * num_cycles
        local arc_len = arc_perc * num_sctrs
        local sector = math.ceil(arc_len)
        local progress = arc_len - sector
        local transition = sector % num_trans
        if transition == 1 then
            r, g, b = green:rgb()
        elseif transition == 2 then
            r, g, b = green:rgb()
        elseif transition == 3 then
            r, g, b = green:trans(yellow, progress)
        elseif transition == 4 then
            r, g, b = yellow:trans(orange, progress)
        elseif transition == 5 then
            r, g, b = orange:trans(red, progress)
        elseif transition == 0 then
            r, g, b = red:rgb()
        end
    elseif profile == 'traffic_light_rev' then
        local num_trans = 6
        local num_cycles = 1
        local num_sctrs = num_trans * num_cycles
        local arc_len = arc_perc * num_sctrs
        local sector = math.ceil(arc_len)
        local progress = arc_len - sector
        local transition = sector % num_trans
        if transition == 1 then
            r, g, b = red:rgb()
        elseif transition == 2 then
            r, g, b = red:trans(orange, progress)
        elseif transition == 3 then
            r, g, b = orange:rgb()
        elseif transition == 4 then
            r, g, b = orange:trans(yellow, progress)
        elseif transition == 5 then
            r, g, b = yellow:trans(green, progress)
        elseif transition == 0 then
            r, g, b = green:rgb()
        end
    elseif profile == 'cold_to_hot' then
        local num_trans = 5
        local num_cycles = 1
        local num_sctrs = num_trans * num_cycles
        local arc_len = arc_perc * num_sctrs
        local sector = math.ceil(arc_len)
        local progress = arc_len - sector
        local transition = sector % num_trans
        if transition == 1 then
            r, g, b = blue:trans(ocean, progress)
        elseif transition == 2 then
            r, g, b = ocean:trans(cyan, progress)
        elseif transition == 3 then
            r, g, b = cyan:trans(orange, progress)
        elseif transition == 4 then
            r, g, b = orange:trans(red, progress)
        elseif transition == 0 then
            r, g, b = red:trans(dark_red, progress)
        end
    elseif profile == 'rainbow_flash' then
        local num_trans = 6
        local num_cycles = 120
        local num_sctrs = num_trans * num_cycles
        local arc_len = arc_perc * num_sctrs
        local sector = math.ceil(arc_len)
        local progress = arc_len - sector
        local transition = sector % num_trans
        if transition == 1 then
            r, g, b = red:rgb()
        elseif transition == 2 then
            r, g, b = orange:rgb()
        elseif transition == 3 then
            r, g, b = yellow:rgb()
        elseif transition == 4 then
            r, g, b = green:rgb()
        elseif transition == 5 then
            r, g, b = blue:rgb()
        elseif transition == 0 then
            r, g, b = violet:rgb()
        end
    end
    return r, g, b
end

function alpha_change(profile, arc_perc)
    local a = 0
    if profile == 'pulse' then
        local num_trans = 6
        local num_cycles = 120
        local num_sctrs = num_trans * num_cycles
        local arc_len = arc_perc * num_sctrs
        local sector = math.ceil(arc_len)
        local progress = arc_len - sector
        local transition = sector % num_trans
        if transition == 1 then
            a = fifth:trans(tenth, progress)
        elseif transition == 0 then
            a = tenth:trans(fifth, progress)
        end
    end
    return a
end

function rgb_to_r_g_b(colour, alpha)
    return ((colour / 0x10000) % 0x100) / 255.,
        ((colour / 0x100) % 0x100) / 255.,
        (colour % 0x100) / 255.,
        alpha
end

function smooth_time(pt)
    local time = 0
    local yr   = conky_parse('${time %y}')
    local mon  = conky_parse('${time %m}')
    local doy  = conky_parse('${time %j}')
    local dom  = conky_parse('${time %d}')
    local dow  = conky_parse('${time %u}')
    local hr12 = conky_parse('${time %I}')
    local hr24 = conky_parse('${time %H}')
    local mins = conky_parse('${time %M}')
    local secs = conky_parse('${time %S}')
    local temp = os.time()
    local mils = socket.gettime() - temp
    
    if pt['arg'] == '%y' then
        -- Year of the century
        time = yr + (doy / 365)
    elseif pt['arg'] == '%j' then
        -- Day of the year
        time = (doy - 1) + (hr24 / 24)
    elseif pt['arg'] == '%d' then
        -- Day of the month
        if mon == 1 or mon == 3 or mon == 5 or mon == 7 or mon == 8
            or mon == 10 or mon == 12 then
                pt['max'] = 31
        elseif mon == 2 then
            pt['max'] = 28
        else
            pt['max'] = 30
        end
        time = (dom - 1) + (hr24 / 24)
    elseif pt['arg'] == '%u' then
        -- Day of the week
        time = (dow - 1) + (hr24 / 24) + (mins / 1440)
    elseif pt['arg'] == '%I' then
        -- Hours
        time = (hr12 % 12) + (mins / 60) + (secs / 3600)
    elseif pt['arg'] == '%H' then
        -- 24 hours
        time = hr24 + (mins / 60) + (secs / 3600)
    elseif pt['arg'] == '%M' then
        -- Minutes
        time = mins + ((secs + mils) / 60)
    elseif pt['arg'] == '%S' then
        -- Seconds
        time = secs + mils
    end
    return time
end

function draw_ring(cr, t, pt)
    local w, h = conky_window.width, conky_window.height
    
    local xc, yc, ring_r, ring_w, sa, ea = pt['x'], pt['y'],
        pt['radius'], pt['thickness'],
        pt['start_angle'], pt['end_angle']
    local bgc, bga, fgc, fga = pt['bg_colour'], pt['bg_alpha'],
        pt['fg_colour'], pt['fg_alpha']
    local bg_clr_chng, fg_clr_chng = pt['bg_clr_chng'], pt['fg_clr_chng']
    local bg_alpha_chng = pt['bg_alpha_chng']
    local fg_alpha_chng = pt['fg_alpha_chng']

    local angle_0 = sa * (2 * math.pi / 360) - math.pi / 2
    local angle_f = ea * (2 * math.pi / 360) - math.pi / 2
    local t_arc = t * (angle_f - angle_0)

    -- Draw background ring
    cairo_arc(cr, xc, yc, ring_r, angle_0, angle_f)
    if bg_clr_chng then
        local r, g, b = rgb_change(bgc, t)
    else
        cairo_set_source_rgba(cr, rgb_to_r_g_b(bgc, bga))
    end
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_set_line_width(cr, ring_w)
    cairo_stroke(cr)
    
    -- Draw indicator ring
    cairo_arc(cr, xc, yc, ring_r, angle_0, angle_0 + t_arc)
    if fg_clr_chng then
        local r, g, b = rgb_change(fgc, t)
        cairo_set_source_rgba(cr, r, g, b, fga)
    else
        cairo_set_source_rgba(cr, rgb_to_r_g_b(fgc, fga))
    end
    cairo_stroke(cr)
end

local function setup_rings(cr, pt)
    local str = ''
    local value = 0
    
    if pt['name'] == 'smooth_time' then
        -- New function holds smooth movement clock logic
        value = smooth_time(pt)
    else
        -- Original conky_parse code
        str = string.format('${%s %s}', pt['name'], pt['arg'])
        str = conky_parse(str)
        value = tonumber(str)
    end
    
    pct = value / pt['max']
    
    draw_ring(cr, pct, pt)
end
    
function conky_ring_stats()
    if conky_window == nil then return end
    
    local cs = cairo_xlib_surface_create(conky_window.display,
        conky_window.drawable, conky_window.visual,
        conky_window.width, conky_window.height)
    local cr = cairo_create(cs) 
    
    local updates = conky_parse('${updates}')
    update_num = tonumber(updates)
    
    if update_num > 5 then
        for i in pairs(settings_table) do
            setup_rings(cr, settings_table[i])
        end
    end
end