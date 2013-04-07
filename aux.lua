--====== Colour and Alpha classes and associated functions ===================--
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

--====== smooth_time =========================================================--
function smooth_time(pt)
    local time = nil
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

--====== draw_indicator ======================================================--
function draw_indicator(cairo, indicator, percent)
    local x, y = indicator['x'], indicator['y']
    local thickness = indicator['thickness']
    local bgcc, bgcp, bgac, bgap, fgcc, fgcp, fgac, fgap =
        indicator['bg_clr_change'], indicator['bg_clr_profile'],
        indicator['bg_alp_change'], indicator['bg_alp_profile'],
        indicator['fg_clr_change'], indicator['fg_clr_profile'],
        indicator['fg_alp_change'], indicator['fg_alp_profile']
    local r, g, b, a = 0, 0, 0, 1
    
    local shape = indicator['shape']
    if shape == 'arc' then
        local radius, s_angle, e_angle = indicator['radius'],
            indicator['start_angle'], indicator['end_angle']
        local angle_0 = s_angle * (2 * math.pi / 360) - math.pi / 2
        local angle_f = e_angle * (2 * math.pi / 360) - math.pi / 2
        local arc_len = percent * (angle_f - angle_0)
        
        local direction = indicator['direction']
        if direction == 'clockwise' then
            -- Draw background arc
            cairo_arc(cairo, x, y, radius, angle_0, angle_f)
            r, g, b = rgb_set(bgcc, bgcp, percent)
            a = alpha_set(bgac, bgap, percent)
            cairo_set_source_rgba(cairo, r, g, b, a)
            cairo_set_line_width(cairo, thickness)
            cairo_stroke(cairo)
            
            -- Draw indicator arc
            cairo_arc(cairo, x, y, radius, angle_0, angle_0 + arc_len)
            r, g, b = rgb_set(fgcc, fgcp, percent)
            a = alpha_set(fgac, fgap, percent)
            cairo_set_source_rgba(cairo, r, g, b, a)
            cairo_stroke(cairo)
        elseif direction == 'anti-clockwise' then
            -- Draw background arc
            cairo_arc_negative(cairo, x, y, radius, angle_0, angle_f)
            r, g, b = rgb_set(bgcc, bgcp, percent)
            a = alpha_set(bgac, bgap, percent)
            cairo_set_source_rgba(cairo, r, g, b, a)
            cairo_set_line_width(cairo, thickness)
            cairo_stroke(cairo)
            
            -- Draw indicator arc
            cairo_arc_negative(cairo, x, y, radius, angle_0, angle_0 + arc_len)
            r, g, b = rgb_set(fgcc, fgcp, percent)
            a = alpha_set(fgac, fgap, percent)
            cairo_set_source_rgba(cairo, r, g, b, a)
            cairo_stroke(cairo)
        end
    elseif shape == 'bar' then
        
    end
end

--====== setup_indicators ====================================================--
function setup_indicators(cairo, indicator)
    local str = nil
    local value = nil
    local percent = nil
    
    if indicator['name'] == 'smooth_time' then
        value = smooth_time(indicator)
    else
        str = string.format('${%s %s}', indicator['name'], indicator['arg'])
        str = conky_parse(str)
        value = tonumber(str)
    end
    
    percent = value / indicator['max']
    
    draw_indicator(cairo, indicator, percent)
end
