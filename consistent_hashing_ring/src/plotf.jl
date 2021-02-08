function distance(p1::Point, p2::Point)::Float64
    dx = (p1.x - p2.x) ^ 2
    dy = (p1.y - p2.y) ^ 2
    sqrt(dx + dy)
end


function find_center(p1::Point, p2::Point)::Point
    x = (p1.x + p2.x) * 0.5
    y = (p1.y + p2.y) * 0.5
    Point(x, y)
end


function make_arc(p1::Point, p2::Point)
    """
    (x - c.x)^2 + (y - c.y)^2 = r^2
    x = y -> sqrt(r^2 - (y - c.y)^2) + c.x
    y = x -> sqrt(r^2 - (x - c.x)^2) + c.y
    """
    c = find_center(p1, p2)
    d = distance(p1, p2)
    r = d / 2
    fx = y -> sqrt(r^2 - (y - c.y)^2) + c.x
    fy = x -> sqrt(r^2 - (x - c.x)^2) + c.y
    step_x = abs(p1.x - p2.x) * 0.2
    step_y = abs(p1.y - p2.y) * 0.2

    if step_x != 0
        minx, maxx = min(p1.x, p2.x), max(p1.x, p2.x)
        x_series = minx:step_x:maxx
        y_series = map(fy, x_series)
        return x_series, y_series
    end

    miny, maxy = min(p1.y, p2.y), max(p1.y, p2.y)
    y_series = miny:step_y:maxy
    x_series = map(fx, y_series)
    return x_series, y_series
end