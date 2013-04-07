--[[
    Conky Colour Change by mrmrwat
    A fork of Ring Meters v1.2.1 by londonali1010
    Inspired by PolarClock by pixelbreaker
    
    Features:
    -- Support for colour changing background and foreground indicators
    -- Support for transparency changing background and foreground indicators
    -- Colour profiles of background and foreground indicators can be set
       independently, allowing one indicator to display two different colour
       profiles
    -- Alpha profiles are independent of colour profiles, allowing foreground
       and background indicators to change colour independently and change alpha
       independently 
    -- Can define own custom colours
    -- Can transition from any colour to any other colour
    -- Can turn colour change and alpha change functionality off and define a
       single colour and transparency to be used instead
    -- Supports smooth time indicators up to year of the century with
       millisecond precision for smooth second indicator movement
--]]

require 'cairo'
require 'socket'

--===== Colour and Alpha classes and associated functions ====================--
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
    local object = {a = a}
    setmetatable(object, {__index = Alpha})
    return object
end
function Alpha:cmp(alpha)
    return alpha.a - self.a
end
function Alpha:trans(alpha, factor)
    local diffa = self:cmp(alpha)
    local newa
    if diffa ~= 0 then
        newa = self.a + diffa + (factor * diffa)
    else
        newa = self.a
    end
    return newa
end

--===== Load colours, settings and profiles files ============================--
home_dir = os.getenv("HOME")
local colours = assert(loadfile(home_dir .. "/.conky/colours.lua"))
colours()

local settings = assert(loadfile(home_dir .. "/.conky/settings.lua"))
settings()

local profiles = assert(loadfile(home_dir .. "/.conky/profiles.lua"))
profiles()

--===== smooth_time ==========================================================--
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

--===== draw_ring ============================================================--
function draw_ring(cr, t, pt)
    local w, h = conky_window.width, conky_window.height
    
    local xc, yc, ring_r, ring_w, sa, ea =
        pt['x'], pt['y'],
        pt['radius'], pt['thickness'],
        pt['start_angle'], pt['end_angle']
    local bgcc, bgcp, bgac, bgap, fgcc, fgcp, fgac, fgap =
        pt['bg_clr_change'], pt['bg_clr_profile'],
        pt['bg_alp_change'], pt['bg_alp_profile'],
        pt['fg_clr_change'], pt['fg_clr_profile'],
        pt['fg_alp_change'], pt['fg_alp_profile']
    local r, g, b, a = 0, 0, 0, 1

    local angle_0 = sa * (2 * math.pi / 360) - math.pi / 2
    local angle_f = ea * (2 * math.pi / 360) - math.pi / 2
    local t_arc = t * (angle_f - angle_0)

    -- Draw background ring
    cairo_arc(cr, xc, yc, ring_r, angle_0, angle_f)
    r, g, b = rgb_set(bgcc, bgcp, t)
    a = alpha_set(bgac, bgap, t)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_set_line_width(cr, ring_w)
    cairo_stroke(cr)
    
    -- Draw indicator ring
    cairo_arc(cr, xc, yc, ring_r, angle_0, angle_0 + t_arc)
    r, g, b = rgb_set(fgcc, fgcp, t)
    a = alpha_set(fgac, fgap, t)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_stroke(cr)
end

--===== setup_rings ==========================================================--
function setup_rings(cr, pt)
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
  
--===== conky_ring_stats =====================================================--
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
