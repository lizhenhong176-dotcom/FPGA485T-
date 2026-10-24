import com.xilinx.rapidwright.device.*;
import com.xilinx.rapidwright.bitstream.*;
import java.util.*;
public class RowBoundary {
  public static void main(String[] a) throws Exception {
    Device d = Device.getDevice("xc7vx485t");
    ConfigArray ca = new ConfigArray(d);
    int rnum = 0;
    for (ConfigRow r : ca.getConfigRows()) {
      rnum++;
      List<Block> bs = r.getBlocks();
      Block first = bs.get(0), last = bs.get(bs.size()-1);
      Frame[] ff = first.getFrames(), lf = last.getFrames();
      int firstFar = ff[0].getAddress();
      int lastFar = lf[lf.length-1].getAddress();
      FAR f = new FAR(ca); f.setFAR(lastFar);
      boolean isLast = f.isLastFrameInRow();
      int after = f.incrementFAR();
      int after2 = f.incrementFAR();
      FAR g = new FAR(ca); g.setFAR(firstFar);
      boolean isFirst = g.isFirstFrameInRow();
      System.out.printf("row=%d blocks=%d first=0x%08x last=0x%08x isFirst=%b isLast=%b after=0x%08x after2=0x%08x%n",
        rnum, bs.size(), firstFar, lastFar, isFirst, isLast, after, after2);
    }
  }
}
