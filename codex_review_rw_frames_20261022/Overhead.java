import com.xilinx.rapidwright.device.*;
import com.xilinx.rapidwright.bitstream.*;
public class Overhead {
  public static void main(String[] a) {
    Device d = Device.getDevice("xc7vx485t");
    ConfigArray ca = new ConfigArray(d);
    int total = 0, blocks = 0, rows = 0;
    for (ConfigRow r : ca.getConfigRows()) {
      rows++;
      int rf = 0;
      for (Block b : r.getBlocks()) { rf += b.getFrameCount(); blocks++; }
      System.out.println("row="+rows+" frames="+rf+" blocks="+r.getBlocks().size());
      total += rf;
    }
    System.out.println("rows="+rows+" blocks="+blocks+" block_frames="+total);
    System.out.println("overhead_per_row="+ConfigArray.FRAME_OVERHEAD_COUNT_PER_ROW);
    System.out.println("with_overhead="+(total + rows*ConfigArray.FRAME_OVERHEAD_COUNT_PER_ROW));
    System.out.println("word_size="+ca.getWordSize());
  }
}
