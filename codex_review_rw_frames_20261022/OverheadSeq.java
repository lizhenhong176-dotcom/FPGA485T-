import com.xilinx.rapidwright.device.*;
import com.xilinx.rapidwright.bitstream.*;
public class OverheadSeq {
  public static void main(String[] a) {
    Device d = Device.getDevice("xc7vx485t");
    ConfigArray ca = new ConfigArray(d);
    int idx = 0, rows = 0;
    int targetBlock = 0x420380;
    int start380 = -1, start3a0 = -1, start314 = -1;
    for (ConfigRow r : ca.getConfigRows()) {
      rows++;
      for (Block b : r.getBlocks()) {
        if (b.getAddress() == targetBlock) start380 = idx;
        if (b.getAddress() == 0x420314) start314 = idx;
        idx += b.getFrameCount();
      }
      // two documented overhead frames at the end of this config row
      idx += ConfigArray.FRAME_OVERHEAD_COUNT_PER_ROW;
      if (start380 >= 0 && start3a0 < 0) start3a0 = start380 + 32;
    }
    System.out.println("rows="+rows+" total_with_overhead="+idx);
    System.out.println("idx380="+start380+" idx3a0="+start3a0+" idx314="+start314);
  }
}
