import com.xilinx.rapidwright.device.*;
import com.xilinx.rapidwright.bitstream.*;

public class FrameMap {
    public static void main(String[] args) {
        Device d = Device.getDevice("xc7vx485t");
        System.out.println("device=" + d.getName() + " rows=" + d.getRows() + " cols=" + d.getColumns());
        ConfigArray ca = new ConfigArray(d);
        for (String name : args) {
            Tile t = d.getTile(name);
            if (t == null) { System.out.println(name + " NOT FOUND"); continue; }
            Block b = ca.getConfigBlock(t);
            System.out.println("tile=" + name + " type=" + t.getTileTypeEnum()
                + " block=" + b);
            if (b == null) continue;
            System.out.println("  addr=0x" + Integer.toHexString(b.getAddress())
                + " frames=" + b.getFrameCount()
                + " col=" + b.getColumn(d.getSeries())
                + " row=" + b.getRow(d.getSeries())
                + " topbot=" + b.getTopBotBit(d.getSeries())
                + " btype=" + b.getBlockType(d.getSeries()));
            Frame[] fs = b.getFrames();
            for (int i = 0; i < fs.length; i++) {
                if (fs[i] != null)
                    System.out.println("  frame[" + i + "]=0x" + Integer.toHexString(fs[i].getAddress()));
            }
        }
    }
}
