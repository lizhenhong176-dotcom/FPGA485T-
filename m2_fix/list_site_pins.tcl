open_checkpoint /data/lzh/v7re/work/probe_smoke/routed.dcp
set site [get_sites SLICE_X10Y10]
puts "SITE=$site"
puts "BELS:"
foreach bel [get_bels -of $site] { puts "  $bel" }
if {[catch {get_site_pins -of $site} pins]} {
    puts "SITE_PINS_ERROR=$pins"
} else {
    puts "SITE_PINS:"
    foreach pin $pins { puts "  $pin" }
}
exit
