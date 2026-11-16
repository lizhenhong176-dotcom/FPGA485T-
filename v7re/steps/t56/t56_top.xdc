# T56 minimal PIP switchbox experiment — placement/pin constraints.
# 与 T1（step03_pip/top.xdc）逐字一致，仅把 SLICE_X8Y10/11 换成 SLICE_X8Y60/61。
# 关键：lut_b 的 I0 锁到 A5 -> 网络经 CLBLL_IMUX8 进入 -> 才能观测 NR1END0->>IMUX_L8。
set_property LOC SLICE_X8Y60 [get_cells lut_a]
set_property BEL A6LUT [get_cells lut_a]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells lut_a]
set_property LOC SLICE_X8Y61 [get_cells lut_b]
set_property BEL A6LUT [get_cells lut_b]
set_property LOCK_PINS {I0:A5 I1:A1 I2:A2 I3:A3 I4:A4 I5:A6} [get_cells lut_b]
