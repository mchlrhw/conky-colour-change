--===== Global settings table ================================================--
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
        max = 100, ----------------------- The maximum value that the indicator
                                        -- can display
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
                                        -- below, eg. default, or pulse
        fg_clr_change  = true, ----------- Same as for bg_clr_change
        fg_clr_profile = 'default', ------ Same as for bg_clr_profile
        fg_alp_change  = false, ---------- Same as for bg_alp_change
        fg_alp_profile = half, ----------- Same as for bg_alp_profile
        x = 180, y = 180, ---------------- The x and y coordinates to position
                                        -- the indicator within the conky window
        radius = 160, -------------------- The radius of arc/ring indicators
        thickness = 4, ------------------- The line thickness of the indicator
        start_angle = -60, --------------- The starting angle of arc/ring
                                        -- indicators
        end_angle = 60 ------------------- The ending angle of arc/ring
                                        -- indicators
    },
    {
        -- Day of the year indicator
        name = 'smooth_time',
        arg = '%j',
        max = 365,
        bg_clr_change  = true,
        bg_clr_profile = 'default',
        bg_alp_change  = false,
        bg_alp_profile = tenth,
        fg_clr_change  = true,
        fg_clr_profile = 'default',
        fg_alp_change  = false,
        fg_alp_profile = half,
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
        -- max for %d is reset in the smooth_time function depending on the
        -- month
        max = 31,
        bg_clr_change  = true,
        bg_clr_profile = 'default',
        bg_alp_change  = false,
        bg_alp_profile = tenth,
        fg_clr_change  = true,
        fg_clr_profile = 'default',
        fg_alp_change  = false,
        fg_alp_profile = half,
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
        bg_clr_change  = true,
        bg_clr_profile = 'default',
        bg_alp_change  = false,
        bg_alp_profile = tenth,
        fg_clr_change  = true,
        fg_clr_profile = 'default',
        fg_alp_change  = false,
        fg_alp_profile = half,
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
        bg_clr_change  = true,
        bg_clr_profile = 'default',
        bg_alp_change  = false,
        bg_alp_profile = tenth,
        fg_clr_change  = true,
        fg_clr_profile = 'default',
        fg_alp_change  = false,
        fg_alp_profile = half,
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
        bg_clr_change  = true,
        bg_clr_profile = 'default',
        bg_alp_change  = false,
        bg_alp_profile = tenth,
        fg_clr_change  = true,
        fg_clr_profile = 'default',
        fg_alp_change  = false,
        fg_alp_profile = half,
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
        bg_clr_change  = true,
        bg_clr_profile = 'default',
        bg_alp_change  = false,
        bg_alp_profile = tenth,
        fg_clr_change  = true,
        fg_clr_profile = 'default',
        fg_alp_change  = false,
        fg_alp_profile = half,
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
        bg_clr_change  = true,
        bg_clr_profile = 'default',
        bg_alp_change  = false,
        bg_alp_profile = tenth,
        fg_clr_change  = true,
        fg_clr_profile = 'default',
        fg_alp_change  = false,
        fg_alp_profile = half,
        x = 180, y = 180,
        radius = 120,
        thickness = 4,
        start_angle = 0,
        end_angle = 360
    },
}
