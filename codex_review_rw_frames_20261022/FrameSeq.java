import com.xilinx.rapidwright.device.*;
import com.xilinx.rapidwright.bitstream.*;

public class FrameSeq {
    public static void main(String[] args) {
        Device d = Device.getDevice("xc7vx485t");
        ConfigArray ca = new ConfigArray(d);
        int idx = 0;
        int firstFar = -1, lastFar = -1;
        int i420380 = -1, i4203a0 = -1;
        for (ConfigRow r : ca.getConfigRows()) {
            for (Block b : r.getBlocks()) {
                Frame[] fs = b.getFrames();
                if (fs == null) continue;
                for (Frame f : fs) {
                    if (f == null) continue;
                    int a = f.getAddress();
                    if (firstFar < 0) firstFar = a;
                    lastFar = a;
                    if (a == 0x420380) i420380 = idx;
                    if (a == 0x4203a0) i4203a0 = idx;
                    if (idx < 5 || idx > 50170)
                        System.out.println("idx=" + idx + " far=0x" + Integer.toHexString(a)
                            + " block=" + b + " col=" + b.getColumn(d.getSeries())
                            + " row=" + b.getRow(d.getSeries()));
                    idx++;
                }
            }
        }
        System.out.println("total=" + idx + " first=0x" + Integer.toHexString(firstFar)
            + " last=0x" + Integer.toHexString(lastFar));
        System.out.println("idx(0x420380)=" + i420380 + " idx(0x4203a0)=" + i4203a0);
        Tile t = d.getTile("CLBLM_R_X7Y10");
        Block b = ca.getConfigBlock(t);
        System.out.println("tile block=" + b + " addr=0x" + Integer.toHexString(b.getAddress()));
        Frame[] fs = b.getFrames();
        for (int i = 0; i < fs.length; i++)
            System.out.println("  f" + i + "=0x" + Integer.toHexString(fs[i].getAddress()));
    }
}
