import com.xilinx.rapidwright.device.*;
import com.xilinx.rapidwright.bitstream.*;

public class FrameSeq3 {
    public static void main(String[] args) {
        Device d = Device.getDevice("xc7vx485t");
        ConfigArray ca = new ConfigArray(d);
        int idx = 0, extra = 0;
        int i380 = -1, i3a0 = -1, i314 = -1;
        for (ConfigRow r : ca.getConfigRows()) {
            for (Block b : r.getBlocks()) {
                Frame[] fs = b.getFrames();
                if (fs == null) continue;
                int n = fs.length;
                if (n == 30) { n = 31; extra++; }
                for (int i = 0; i < n; i++) {
                    int a = b.getAddress() + i;
                    if (a == 0x420380) i380 = idx;
                    if (a == 0x4203a0) i3a0 = idx;
                    if (a == 0x420314) i314 = idx;
                    idx++;
                }
            }
        }
        System.out.println("total=" + idx + " extra=" + extra + " idx380=" + i380 + " idx3a0=" + i3a0 + " idx314=" + i314);
    }
}
