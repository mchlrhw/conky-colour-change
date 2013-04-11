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
    -- Indicators can be either arcs or bars
    -- Arcs can increase clockwise or anticlockwise
    -- Bars can be oriented horizontally or vertically and can increase right to
    -- left, left to right, bottom to top, or top to bottom
--]]
require 'cairo'
require 'socket'

conky_dir = os.getenv("HOME") .. "/.conky/"
local aux = assert(loadfile(conky_dir .. "aux.lua"))
aux()
local colours = assert(loadfile(conky_dir .. "colours.lua"))
colours()
local colour_profiles = assert(loadfile(conky_dir .. "colour-profiles.lua"))
colour_profiles()

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
        -- horizontal = true, ------------ Whether bar indicators are horizontal
                                        -- or vertical
        -- inverted = false, ------------- Whether to display left to right or
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
        -- length = 100, ----------------- The length of bar indicators               
        bg_clr_change  = true, ----------- Whether to allow colour changing on
                                        -- the background indicator
        bg_clr_profile = 'default', ------ The colour profile for the background
                                        -- indicator. If bg_clr_change is set to
                                        -- true then this should be the name of
                                        -- one of the colour change profiles
                                        -- defined in the rgb_set function in
                                        -- the colour-profile.lua file, eg.
                                        -- default, or traffic_light. If
                                        -- bg_clr_change is set to false then
                                        -- this should be the name of one of the
                                        -- colours defined in the colours.lua
                                        -- file, eg. turquoise, or white
        bg_alp_change  = false, ---------- Whether to allow alpha changing on
                                        -- the background indicator
        bg_alp_profile = tenth, ---------- The alpha profile for the background
                                        -- indicator. If bg_alp_change is set to
                                        -- true then this should be the name of
                                        -- one of the alpha change profiles
                                        -- defined in the alpha_set function in
                                        -- the colour-profile.lua file, eg.
                                        -- default, or pulse. If bg_alp_change
                                        -- is set to false then this should be
                                        -- the name of an alpha setting defined
                                        -- in the colours.lua file, eg. on, off,
                                        -- or tenth
        fg_clr_change  = true, ----------- Same as for bg_clr_change
        fg_clr_profile = 'default', ------ Same as for bg_clr_profile
        fg_alp_change  = false, ---------- Same as for bg_alp_change
        fg_alp_profile = half, ----------- Same as for bg_alp_profile
    },
    {
        -- Day of the year indicator
        name          = 'smooth_time',
        arg           = '%j',
        shape         = 'arc',
        clockwise     = true,
        max           = 365,
        x             = 180,
        y             = 180,
        thickness     = 6,
        radius        = 150,
        start_angle   = -60,
        end_angle     = 60,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },
    {
        -- Day of the month indicator
        name          = 'smooth_time',
        arg           = '%d',
        shape         = 'arc',
        clockwise     = false,
        max           = 31,
        x             = 180,
        y             = 180,
        thickness     = 4,
        radius        = 160,
        start_angle   = 240,
        end_angle     = 120,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },
    {
        -- Day of the week indicator
        name          = 'smooth_time',
        arg           = '%u',
        shape         = 'arc',
        clockwise     = false,
        max           = 7,
        x             = 180,
        y             = 180,
        thickness     = 6,
        radius        = 150,
        start_angle   = 240,
        end_angle     = 120,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },
    {
        -- Hour indicator
        name          = 'smooth_time',
        arg           = '%I',
        shape         = 'arc',
        clockwise     = true,
        max           = 12,
        x             = 180,
        y             = 180,
        thickness     = 12,
        radius        = 75,
        start_angle   = 0,
        end_angle     = 360,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },
    -- Uncomment below and comment out above for 24 hour clock
    --[[{
        -- 24 hour indicator
        name          = 'smooth_time',
        arg           = '%H',
        shape         = 'arc',
        clockwise     = true,
        max           = 24,
        x             = 180,
        y             = 180,
        thickness     = 12,
        radius        = 75,
        start_angle   = 0,
        end_angle     = 360,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },]]
    {
        -- Minute indicator
        name          = 'smooth_time',
        arg           = '%M',
        shape         = 'arc',
        clockwise     = true,
        max           = 60,
        x             = 180,
        y             = 180,
        thickness     = 7,
        radius        = 90,
        start_angle   = 0,
        end_angle     = 360,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
        fg_alp_change = false, fg_alp_profile = half,
    },
    {
        -- Second indicator
        name          = 'smooth_time',
        arg           = '%S',
        shape         = 'arc',
        clockwise     = true,
        max           = 60,
        x             = 180,
        y             = 180,
        thickness     = 4,
        radius        = 120,
        start_angle   = 0,
        end_angle     = 360,
        bg_clr_change = true,  bg_clr_profile = 'default',
        bg_alp_change = false, bg_alp_profile = tenth,
        fg_clr_change = true,  fg_clr_profile = 'default',
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
