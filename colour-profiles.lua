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
