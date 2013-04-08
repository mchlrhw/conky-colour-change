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

conky_dir = os.getenv("HOME") .. "/.conky/"
local aux = assert(loadfile(conky_dir .. "aux.lua"))
aux()

--====== Colour presets ======================================================--
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

--====== Custom colours ======================================================--
-- Feel free to add your own custom colours here
-- colour = Colour:new(red, green, blue between 0 and 1)


--===== Alpha presets ========================================================--
on        = Alpha:new(1)
off       = Alpha:new(0)
half      = Alpha:new(0.5)
fifth     = Alpha:new(0.2)
tenth     = Alpha:new(0.1)

--====== Custom alphas =======================================================--
-- Feel free to add your own custom alphas here
-- alpha  = Alpha:new(transparency between 0 and 1)


--====== rgb_set =============================================================--
-- Define your colour profiles in this function
function rgb_set(clr_chng, profile, arc_perc)
    local r, g, b = 0, 0, 0
    if clr_chng then
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
        -- The profile below has been extensively commented to provide you with
        -- a starting point for profile creation
        -- Change 'custom' to the name you would like to use in the global
        -- settings table
        elseif profile == 'custom' then
            -- num_trans = the number of colour transitions in your profile
            local num_trans = 6
            -- num_cycles = the number of times your profile will cycle through
            -- its transitions in one revolution, increase this value to make
            -- your indicators flash or pulse
            local num_cycles = 6
            -- No need to alter the following settings
            local num_sctrs = num_trans * num_cycles
            local arc_len = arc_perc * num_sctrs
            local sector = math.ceil(arc_len)
            local progress = arc_len - sector
            local transition = sector % num_trans
            
            -- The if-elseif statement below is a list of your transitions
            -- Make sure the number of transitions matches the value of
            -- num_trans
            
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
        -- The following profiles are examples for you to use and adapt
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
                r, g, b = cyan:trans(yellow, progress)
            elseif transition == 4 then
                r, g, b = yellow:trans(red, progress)
            elseif transition == 0 then
                r, g, b = red:rgb()
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
    else
        r, g, b = profile:rgb()
    end
    return r, g, b
end

--====== alpha_set ===========================================================--
-- Define your alpha profiles in this function
function alpha_set(alp_chng, profile, arc_perc)
    local a = 1
    if alp_chng then
        if profile == 'default' then
            local num_trans = 2
            local num_cycles = 60
            local num_sctrs = num_trans * num_cycles
            local arc_len = arc_perc * num_sctrs
            local sector = math.ceil(arc_len)
            local progress = arc_len - sector
            local transition = sector % num_trans
            if transition == 1 then
                a = half:trans(fifth, progress)
            elseif transition == 0 then
                a = fifth:trans(half, progress)
            end
        elseif profile == 'pulse' then
            local num_trans = 6
            local num_cycles = 60
            local num_sctrs = num_trans * num_cycles
            local arc_len = arc_perc * num_sctrs
            local sector = math.ceil(arc_len)
            local progress = arc_len - sector
            local transition = sector % num_trans
            if transition == 1 then
                a = half.a
            elseif transition == 2 then
                a = half:trans(fifth, progress)
            elseif transition == 3 then
                a = fifth.a
            elseif transition == 4 then
                a = fifth.a
            elseif transition == 5 then
                a = fifth.a
            elseif transition == 0 then
                a = fifth:trans(half, progress)
            end
        end
    else
        a = profile.a
    end
    return a
end

--====== Global settings table ===============================================--
-- Change these values to alter the appearance of your indicators
settings_table = {
    {
        -- Year of the century indicator
        -- This indicator's settings have been extensively commented to provide
        -- you with a starting point for indicator customisation
        name = 'smooth_time', ------------ The name of the conky variable used
                                        -- for this indicator. Smooth time
                                        -- motion in clocks is achieved by using
                                        -- 'smooth_time', which is not a conky
                                        -- variable, but behaves like the 'time'
                                        -- variable for the purposes of this
                                        -- script
        arg = '%y', ---------------------- Any arguments that the conky variable
                                        -- can take. 'smooth_time' takes the %y,
                                        -- %m, %j, %d, %u, %I, %H, %M and %S
                                        -- arguments of the 'time' variable
        shape = 'arc', ------------------- The shape of the indicator. Choose
                                        -- between arc and bar. Each shape has a
                                        -- different set of customisation
                                        -- options
        clockwise = true, ---------------- Whether arc indicators run clockwise
                                        -- or anticlockwise
        -- horizontal = true ------------- Whether bar indicators are horizontal
                                        -- or vertical
        -- inverted = false -------------- Whether to display left to right or
                                        -- right to left on horizontal bars, or
                                        -- bottom to top or top to bottom on
                                        -- vertical bars 
        max = 100, ----------------------- The maximum value that the indicator
                                        -- can display
        x = 180, y = 180, ---------------- The x and y coordinates to position
                                        -- the indicator within the conky window
        thickness = 4, ------------------- The line thickness of the indicator
                                        -- (applies to both arcs and rectangles)
        radius = 160, -------------------- The radius of arc indicators
        start_angle = -60, --------------- The starting angle of arc indicators
        end_angle = 60, ------------------ The ending angle of arc indicators
                                        -- NB. The order of these matters. For
                                        -- clockwise arcs the end angle must be
                                        -- bigger than the start angle, and
                                        -- vice-versa for anticlockwise arcs
        -- length = 100 ------------------ The length of bar indicators                  
        bg_clr_change  = true, ----------- Whether to allow colour changing on
                                        -- the background indicator
        bg_clr_profile = 'default', ------ The colour profile for the background
                                        -- indicator. If bg_clr_change is set to
                                        -- false then this should be the name of
                                        -- one of the colours defined above, eg.
                                        -- turquoise, or white
        bg_alp_change  = false, ---------- Whether to allow alpha changing on
                                        -- the background indicator
        bg_alp_profile = tenth, ---------- The alpha profile for the background
                                        -- indicator. If bg_alp_change is set to
                                        -- true then this should be the name of
                                        -- one of the alpha change profiles
                                        -- defined in the alpha_set function
                                        -- above, eg. default, or pulse
        fg_clr_change  = true, ----------- Same as for bg_clr_change
        fg_clr_profile = 'default', ------ Same as for bg_clr_profile
        fg_alp_change  = false, ---------- Same as for bg_alp_change
        fg_alp_profile = half, ----------- Same as for bg_alp_profile
    },
    {
        -- Day of the year indicator
        name = 'smooth_time',
        arg = '%j',
        shape = 'arc',
        clockwise = true,
        max = 365,
        x = 180, y = 180,
        thickness = 6,
        radius = 150,
        start_angle = -60,
        end_angle = 60,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },
    {
        -- Day of the month indicator
        name = 'smooth_time',
        arg = '%d',
        shape = 'arc',
        clockwise = true,
        -- max for %d is reset in the smooth_time function depending on the
        -- month
        max = 31,
        x = 180, y = 180,
        thickness = 4,
        radius = 160,
        start_angle = 120,
        end_angle = 240,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },
    {
        -- Day of the week indicator
        name = 'smooth_time',
        arg = '%u',
        shape = 'arc',
        clockwise = true,
        max = 7,
        x = 180, y = 180,
        thickness = 6,
        radius = 150,
        start_angle = 120,
        end_angle = 240,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },
    {
        -- Hour indicator
        name = 'smooth_time',
        arg = '%I',
        shape = 'arc',
        clockwise = true,
        max = 12,
        x = 180, y = 180,
        thickness = 12,
        radius = 75,
        start_angle = 0,
        end_angle = 360,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },
    -- Uncomment below and comment out above for 24 hour clock
    --[[{
        -- 24 hour indicator
        name = 'smooth_time',
        arg = '%H',
        shape = 'arc',
        clockwise = true,
        max = 24,
        x = 180, y = 180,
        thickness = 12,
        radius = 75,
        start_angle = 0,
        end_angle = 360,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },]]
    {
        -- Minute indicator
        name = 'smooth_time',
        arg = '%M',
        shape = 'arc',
        clockwise = true,
        max = 60,
        x = 180, y = 180,
        thickness = 7,
        radius = 90,
        start_angle = 0,
        end_angle = 360,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },
    {
        -- Second indicator
        name = 'smooth_time',
        arg = '%S',
        shape = 'arc',
        clockwise = true,
        max = 60,
        x = 180, y = 180,
        thickness = 4,
        radius = 120,
        start_angle = 0,
        end_angle   = 360,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },
    {
        -- CPU indicator
        name = 'cpu',
        arg = 'cpu0',
        shape = 'bar',
        horizontal = false,
        inverted = false,
        max = 100,
        x = 350, y = 350,
        thickness = 12,
        length = 320,
        bg_clr_change = false,  bg_clr_profile = white,
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'traffic_light',
        fg_alp_change = false, fg_alp_profile = half,
    },
}

--====== conky_colour_change_main ============================================--
function conky_colour_change_main()
    if conky_window == nil then
        return
    end
    
    local surface = cairo_xlib_surface_create(conky_window.display,
        conky_window.drawable, conky_window.visual,
        conky_window.width, conky_window.height)
    local cairo = cairo_create(surface) 
    
    local updates = conky_parse('${updates}')
    update_num = tonumber(updates)
    
    if update_num > 5 then
        for i in pairs(settings_table) do
            -- the setup_indicators function can be found in the aux.lua file
            -- along with the other auxiliary functions 
            setup_indicators(cairo, settings_table[i])
        end
    end
end
