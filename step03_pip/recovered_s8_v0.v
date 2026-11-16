// recovered from /opt/lzh/step03/s8/s8_v0.bit
// structural netlist: physical INIT order, pin nets named by their INT wire
module recovered ();
  wire o_SLICE_X47Y51;   // no driver resolved (IO/undriven) unless assigned below
  wire o_SLICE_X8Y11;   // no driver resolved (IO/undriven) unless assigned below
  wire w_GFAN0_INT_L_X6Y11;   // no driver resolved (IO/undriven) unless assigned below
  wire w_SR1END1_INT_L_X6Y11;   // no driver resolved (IO/undriven) unless assigned below
  wire w_SW2END3_INT_L_X6Y11;   // no driver resolved (IO/undriven) unless assigned below
  wire w_WL1END0_INT_L_X6Y11;   // no driver resolved (IO/undriven) unless assigned below
  wire w_WL1END1_INT_L_X6Y11;   // no driver resolved (IO/undriven) unless assigned below
  wire w_WW2END0_INT_L_X6Y11;   // no driver resolved (IO/undriven) unless assigned below
  LUT6 #(.INIT(64'hc0c0c0c0c0c0c0c0)) u_SLICE_X47Y51 (.I0(1'bx), .I1(1'bx), .I2(1'bx), .I3(1'bx), .I4(1'bx), .I5(1'bx), .O(o_SLICE_X47Y51));
  // SLICE_X47Y51 pins: {}
  // SLICE_X47Y51 active IMUX (inst1 needs its own pin map): {'INT_R_X31Y51': {'IMUX0': 'NW2END0', 'IMUX3': 'ER1END1'}}
  LUT6 #(.INIT(64'h937b7471e799fac5)) u_SLICE_X8Y11 (.I0(w_SW2END3_INT_L_X6Y11), .I1(w_WW2END0_INT_L_X6Y11), .I2(w_WL1END0_INT_L_X6Y11), .I3(w_SR1END1_INT_L_X6Y11), .I4(w_GFAN0_INT_L_X6Y11), .I5(w_WL1END1_INT_L_X6Y11), .O(o_SLICE_X8Y11));
  // SLICE_X8Y11 pins: {'A1': 'SW2END3@INT_L_X6Y11', 'A2': 'WW2END0@INT_L_X6Y11', 'A3': 'WL1END0@INT_L_X6Y11', 'A4': 'SR1END1@INT_L_X6Y11', 'A5': 'GFAN0@INT_L_X6Y11', 'A6': 'WL1END1@INT_L_X6Y11'}
  // SLICE_X8Y11 FF: {'AFF': 'ZINI+ZRST'} (ZRST=1 => reset family, ZINI=1 => INIT=0)
endmodule