conky.config = {
    use_xft                = true,
    font                   = '123:size=8',
    xftalpha               = 0.1,
    update_interval        = 1,
    total_run_times        = 0,
    own_window             = true,
    own_window_type        = 'normal',
    own_window_transparent = false,
    own_window_hints       = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    own_window_colour      = '000000',
    own_window_argb_visual = true,
    -- transparency level; value between 0 (0% opacity) and 255 (100% opacity)
    own_window_argb_value  = 100,
    double_buffer          = true,
    draw_shades            = false,
    draw_outline           = false,
    draw_borders           = false,
    draw_graph_borders     = false,
    default_color          = 'white',
    default_shade_color    = 'red',
    default_outline_color  = 'green',
    alignment              = 'top_left',
    gap_x                  = 150,
    gap_y                  = 40,
    no_buffers             = true,
    uppercase              = false,
    cpu_avg_samples        = 2,
    net_avg_samples        = 1,
    override_utf8_locale   = true,
    use_spacer             = 'right',
    minimum_height         = 200,
    maximum_width          = 700
}

conky.text = [[
${voffset 10}${color EAEAEA}${font GE Inspira:pixelsize=120}${time %H:%M}${font}${voffset -84}${offset 10}${color EAEAEA}${font GE Inspira:pixelsize=42}${time %d} ${voffset -15}${color EAEAEA}${font GE Inspira:pixelsize=22}${time  %B} ${time %Y}${font}${voffset 24}${font GE Inspira:pixelsize=58}${offset -148}${time %A}${font}
${voffset 10}${offset 12}${font Ubuntu:pixelsize=18}${color EAEAEA}ROOT ${offset 9}${color yellow}${fs_used_perc /}%${offset 30}${color EAEAEA}RAM ${offset 9}${color yellow}$memperc%${offset 30}${color EAEAEA}CPU ${offset 9}${color yellow}${cpu cpu0}%
]]
