open_checkpoint /data/lzh/v7re/work/probe_smoke/routed.dcp
foreach name {A6LUT B6LUT A5LUT B5LUT} {
    set bel [get_bels SLICE_X10Y10/$name]
    puts "BEL=$name SITE_PINS=[get_site_pins -of $bel]"
    puts "BEL_PINS=[get_bel_pins -of $bel]"
}
exit
