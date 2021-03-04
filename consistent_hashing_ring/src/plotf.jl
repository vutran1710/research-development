layout_setup() = begin
    set_default_plot_size(20cm, 20cm)
    coord = Coord.cartesian(xmin=-1.5, xmax=1.5, ymin=-1.5, ymax=1.5, aspect_ratio=1)
    circle_funcs = [x -> sqrt(1 - x^2), x -> -sqrt(1 - x^2)]
    p = plot(circle_funcs, -1, 1, coord, color=["ring", "ring"])
    return p
end

plot_cache_labels(cache_hash_table::Table) = begin
    """ Using cache hash table to plot labels over the ring
    Cache-hash-table::TypedTables to be used
    _______________________________________
    | label  | angle  | server   | online  |
    ----------------------------------------
    | String | Degree | ServerID | Boolean |
    """
    groups = group(getproperty(:server), cache_hash_table)
    layers = []
    color_generator = Iterators.Stateful(distinguishable_colors(length(cache_hash_table)))
    color_map = Dict(r.server => popfirst!(color_generator) for r ∈ cache_hash_table)

    for id in keys(groups)
        table = groups[id]
        labels = table.label
        angles = table.angle
        rad_angles = map(deg2rad, angles)
        xes = map(cos, rad_angles)
        yes = map(sin, rad_angles)
        color = color_map[id]
        points = layer(x=xes, y=yes, color=[color], Geom.point)
        push!(layers, points)
    end
    layers
end


function distance(p1::Point, p2::Point)::Float64
    dx = (p1.x - p2.x) ^ 2
    dy = (p1.y - p2.y) ^ 2
    sqrt(dx + dy)
end


function find_center(p1::Point, p2::Point)::Point
    x = (p1.x + p2.x) / 2
    y = (p1.y + p2.y) / 2
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
