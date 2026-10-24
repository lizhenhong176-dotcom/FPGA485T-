import com.xilinx.rapidwright.device.*;
import com.xilinx.rapidwright.bitstream.*;
import java.io.*;
import java.util.*;
public class DumpExpectedRuns {
 public static void main(String[] a) throws Exception {
  Device d=Device.getDevice("xc7vx485t"); ConfigArray ca=new ConfigArray(d);
  try(PrintWriter w=new PrintWriter(new BufferedWriter(new FileWriter(a[0])))){
   w.println("run_id,start_frame_index,length,row,block_addr,block_type");
   int idx=0,row=0,run=0;
   for(ConfigRow r: ca.getConfigRows()){
    row++;
    for(Block b: r.getBlocks()){
     int n=b.getFrameCount();
     int bt=(b.getAddress()>>23)&0x7;
     w.printf("%d,%d,%d,%d,0x%x,FAR_BLOCK_%d%n",run,idx,n,row,b.getAddress(),bt);
     run++; idx+=n;
    }
    idx+=2; // two overhead frames at end of every row
   }
   System.err.println("runs="+run+" total="+idx);
  }
 }
}
