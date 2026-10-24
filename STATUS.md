# FPGA 姣旂壒娴侀€嗗悜 鈥?椤圭洰鐜扮姸锛堟瘡涓换鍔″紑濮嬪墠鍏堣鏈枃浠讹級

鏈€鍚庢洿鏂帮細2026-10-24

鐩爣锛歑C7VX485T-2FFG1761锛圴C707锛夋瘮鐗规祦閫嗗悜銆?璺嚎锛?*鎷撴墤锛圧apidWright 瀵煎嚭锛夆啋 PIP鈫抌it 宸垎 鈫?frame/bit 鏁版嵁搴?鈫?瀹屾暣 bit鈫攆eature 鏄犲皠**銆?
---

## 1. 浣嶇疆

| 鍐呭 | 浣嶇疆 |
|---|---|
| 椤圭洰浠ｇ爜锛堟湰鍦帮級 | `E:\DEEPSEEK\FPGA姣旂壒娴侀€嗗悜\v7re` |
| STEP03 瀹為獙鑴氭湰 | `E:\DEEPSEEK\FPGA姣旂壒娴侀€嗗悜\step03_pip` |
| 鏈湴宸ヤ綔鏁版嵁锛圖B銆乥it锛?| `E:\v7work`锛坄routing\v7_routing.db`銆乣routing\out_routing`銆乣m2\`銆乣bits\`锛?|
| 杩滅鏈哄櫒 | `172.17.70.41`锛圖HCP锛岄噸鍚彲鑳藉彉锛夛紝鐢ㄦ埛 `s.tschai`锛岀閽?`C:\Users\i\.ssh\v7remote` |
| 杩滅 WSL | Ubuntu 20.04锛宍/opt/lzh/v7re`銆乣/opt/lzh/Xilinx/Vivado/2017.2`銆乣/opt/lzh/venv` |
| STEP03 瀹為獙鐩綍 | 杩滅 `/opt/lzh/step03/pip1`銆乣pip2` |

**杩滅瀹炴祴鏍稿锛?026-10-24 鍙 SSH 楠岃瘉锛岄潪鎺ㄦ祴锛夛細**

| 鍐呭 | 杩滅鏉冨▉浣嶇疆 | 瀹炴祴 |
|---|---|---|
| 妯″瀷搴擄紙鍚?M1锛?| `/opt/lzh/v7re/data/model/v7_model.sqlite` | 635,047,936 B / 2026-10-21 22:09锛泂ites 86,022銆乻ite_pins 5,489,706銆乼iles 150,380銆乼ile_types 115銆?*probes 72 / probe_bits 1248 / region_bases 14 / column_offsets 420**锛沗site_frames`/`bit_map`/`pip_bits` 浠?**0** |
| 妯″瀷搴撳壇鏈?| `/opt/lzh/v7re/work/refs_20261021/model/v7_model.sqlite` | 鍚屼笂锛?2:10锛岄€愬瓧鑺傚悓灏哄锛墊
| 鏃?M0 probe 搴?| `/opt/lzh/v7re/work/refs_20261021/db/v7.sqlite` | 8,179,712 B锛泂ites 75,900 / probes 47 / probe_bits 784锛? 鏈満闀滃儚閭ｄ唤锛墊
| P0 杈圭晫搴?| `/opt/lzh/v7re/work/refs_20261021/p0/v7_p0.sqlite` | 361,844,736 B |
| 閫愮珯鐐?probe | `/opt/lzh/v7re/data/m1/probe`銆乣work/probe_smoke`銆乣work/refs_20261021/probe` | 鍏ㄧ墖 `result.json` 鍏?**31** |
| v7re 娴嬭瘯 | `/opt/lzh/v7re/tests`锛? 涓?`test_*.py`锛墊 pytest **18 collected**锛堜笌 搂2銆?8 passed銆嶄竴鑷达級|
| Vivado | `/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado` | 瀛樺湪锛?017.06 wrapper锛墊

> **鍚屾锛堝凡瀹屾垚 2026-10-24锛?*锛氭湰鏈?`E:\v7work\model\v7_model.sqlite` 宸蹭粠杩滅 `data/model/v7_model.sqlite` 瑕嗙洊鍚屾锛岄€愬瓧鑺備竴鑷达紙sha256 `eec0473f鈥?351`锛沺robes 72 / probe_bits 1248 / region_bases 14 / column_offsets 420锛夈€傛棫 M0 鏋勫缓锛?39,430,656 B锛夊浠戒负 `v7_model.sqlite.preM1.bak`銆俙site_frames`/`pip_bits` 涓ゅ紶绌鸿〃鏄?STEP04/M2 瑕佸～鐨勶紝涓よ竟閮借繕娌℃湁銆?
---

## 2. 杩滅鐜鎬庝箞鐢?
```bash
# WSL 鍏ュ彛锛圫ystem32 涓嬬殑 wsl.exe 鏄?stub锛屽繀椤荤敤鍏ㄨ矾寰勶級
"C:\Program Files\WSL\wsl.exe" -d Ubuntu -u root -- bash -lc "<鍛戒护>"

# Vivado
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C          # 涓嶈浼氭姤 locale::facet::_S_create_c_locale
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source x.tcl

# Python / RapidWright
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
/opt/lzh/venv/bin/python ...
```

娉ㄦ剰锛?
- **SSH 榛樿 shell 鏄?cmd.exe**锛屽祵濂楀紩鍙锋瀬鏄撹鍚冦€傚鏉傚懡浠や竴寰嬨€屾湰鍦板啓 `.sh`锛圠F 鎹㈣锛夆啋 `scp` 鈫?`bash /mnt/c/Users/S.tschai/x.sh`銆嶃€?- PowerShell 鐨?`Set-Content` 浼氬啓 CRLF锛宐ash 鑴氭湰蹇呴』鐢?`[IO.File]::WriteAllText(..., ($lines -join "`n"))`銆?- RapidWright 鐨?pip 鍖呬細鍘?github.com 涓?400MB jar锛堣繛涓嶉€氾級锛屽凡鏀圭敤鏈満 `rapidwright-2026.1.1-standalone-win64.jar` 澶嶅埗鎴?`lin64` 鍚嶅瓧鏀捐繘 site-packages锛?*Java 璺ㄥ钩鍙帮紝瀹炴祴鍙敤**銆?- 杩滅 `pytest tests`锛坴7re锛夊綋鍓?**18 passed**銆?
---

## 3. 宸插畬鎴?
### STEP01 鎷撴墤瀵煎嚭

- RapidWright 閬嶅巻鍏ㄧ墖锛?50,380 tiles / 115 绫诲瀷 / 56,847,864 wires / 207,253,149 PIPs銆?- 鍙戠幇 `Tile.getWireConnections` 鎻愪緵璺?tile 杩炴帴锛圧W 鍐呯疆 tileconn锛夈€?- 浜х墿锛歚out_routing`锛?41 鏂囦欢锛?.7MB锛? `v7_routing.db`銆?
### STEP02 璺?tile 杩炴帴瑙勮寖鍖?
- corridor 瑙勫垯锛坱ile 绫诲瀷搴忓垪 鈫?杩炴帴瑙勫垯锛夛紝鍏ㄨ澶囬獙璇?0 conflicts銆?- 鍚庣户鏀瑰仛**绮剧‘杈硅〃**锛歚edges_exact` 39,923,710 琛岋紝150,380 tiles锛?  11,857,917 鏉℃湁澶栬繛 wire锛涘叏閲忔牎楠?bad_wires=0 / missing=0 / extra=0銆?- 瑙勫垯锛氬悓 (grid_x, grid_y) 鍞竴锛宍INT_R_X145Y180` 涓?`CLBLM_R_X145Y180` 鏄笉鍚?grid 鍗曞厓锛?  tile **鍚嶅瓧**閲岀殑 X/Y 浼氭挒鍙凤紝涓嶈兘鐢ㄥ悕瀛楅敭銆?
### STEP03 PIP鈫抌it锛堣繘琛屼腑锛屽凡鏈夌粨璁猴級

鏂规硶锛歊apidWright 璇?DCP 鈫?鍒犱竴鏉?PIP 鈫?鍐欏洖 DCP 鈫?Vivado 閲嶆柊 bitgen 鈫?閫愪綅宸垎銆?
**宸茬‘璁ょ殑涓夋潯纭粨璁猴細**

1. **甯у彿 = 绾挎€у簭鍙?*锛堟寜 config row锛屾瘡琛屾湯灏捐ˉ 2 涓?overhead 甯э級銆?   楠岃瘉锛氬潡鍩哄潃 `0x420300` 鈫?甯?31,680锛沗0x4203A0` 鈫?31,748銆?2. **word 50 鏄?ECC**锛屼笉鏄厤缃綅銆備换浣曟暟鎹綅鍙樺寲閮戒細甯﹀嚭涓€缁?word50 浣嶅彉鍖栵紙6~10 浣嶏級銆?3. **绔欑偣鍐呴儴 PIP锛圕LB 鐨?A鈫扡OGIC_OUTS銆両MUX鈫扐锛夋敼 DCP 鏃犳晥**锛歜itgen 鏄粠缃戣〃+甯冨眬
   閲嶆柊鎺ㄥ绔欑偣璺敱鐨勶紝涓嶇湅 DCP 鐨?route 灞炴€с€傝 fuzz 绔欑偣鍐呬綅鍙兘鏀圭綉琛?甯冨眬銆?
**PIP 浣嶄綅缃疄娴嬶紙鍒?X6锛宍LOGIC_OUTS_L20->>NR1BEG2`锛夛細**

| Y | 鍙樺寲甯?| 閰嶇疆浣?|
|---|---|---|
| 20 | 31688, 31694 | (w41, b7) |
| 22 | 31688, 31694 | (w45, b7) |
| 30 | 31688, 31694 | (w62, b7) |
| 31 | 31688, 31694 | (w64, b7) |
| 32 | 31688, 31694 | (w66, b7) |
| 40 | 31688, 31694 | (w82, b7) |
| 41 | 31688, 31694 | (w84, b7) |
| 42 | 31688, 31694 | (w86, b7) |
| 50 | **26442, 26448** | (w1, b7) |
| 52 | 26442, 26448 | (w5, b7) |
| 60 | 26442, 26448 | (w21, b7) |

瑙勫緥锛?
- 甯у鐢?**(鍒? clock region, PIP 鍙樹綋)** 鍐冲畾锛涘悓鍖哄煙鍐呮亽瀹氾紝鍧楀唴鍋忕Щ鎭掍负 8 鍜?14銆?  region 0锛圷0~49锛夊潡鍩哄潃 `0x420300`锛宺egion 1锛圷50~99锛夊潡鍩哄潃 `0x400300`銆?- **word 鈮?2 脳 (Y 鈭?region 璧峰琛? + k**锛宬 瀹炴祴涓?1 鎴?2锛圷20/22/50/52/60 鏄?1锛?  Y30/31/32/40/41/42 鏄?2锛?*寰呭鏍?*锛夈€?- bit 浣嶇敱 PIP 鍙樹綋鍦?tile 鍐呯殑浣嶇疆鍐冲畾锛堣繖缁勫叏鏄?b7锛夈€?- 鍙︿竴鍙樹綋 `LOGIC_OUTS_L12->>NR1BEG0`锛圷10锛夆啋 甯?31690/31693銆亀ord 20锛岃鏄庡抚瀵逛笌 word
  閮戒緷璧栧彉浣擄紝涓嶅彧鏄潗鏍囥€?
**FAR 浣嶅煙锛?6 浣嶏級锛?*

| 浣?| 瀛楁 |
|---|---|
| [25:23] | block type锛?=閫昏緫锛?=BRAM/DSP锛?|
| [22] | top/bottom |
| [21:17] | config row |
| [16:7] | column |
| [6:0] | minor |

**甯ф暟璐︼細** ConfigArray 14 琛?/ 1,183 blocks / 50,148 甯э紱姣忚鏈熬 2 涓?overhead 甯?鈫?14脳2=28 鈫?50,176锛屼笌 `.bit` 閲?FDRI 鐨?5,067,776 words 梅 101 瀹屽叏涓€鑷淬€?
### 澶嶆牳鐘舵€侊紙2026-10-24锛実pt-6.1-sol 瀵规姉寮忥級

瀹屾暣鎶ュ憡锛歔codex_review_step03_20261024/REVIEW.md](E:/DEEPSEEK/FPGA姣旂壒娴侀€嗗悜/codex_review_step03_20261024/REVIEW.md)

| 涓诲紶 | 鍒ゅ畾 | 澶囨敞 |
|---|---|---|
| C1 甯у彿 = 绾挎€у簭鍙?| INCONCLUSIVE | 闇€瑕佷粠 `.bit` 鍖呮祦鐙珛瑙?FAR 浜ゅ弶楠岃瘉 |
| C2 姣忚鏈熬 2 涓?overhead | INCONCLUSIVE | 鍚屼笂锛岀洰鍓嶆槸鈥滅敤鍋囪楠岃瘉鍋囪鈥?|
| C3 word 50 = ECC | **闄嶇骇**锛歸ord 50 鏄牎楠?杈呭姪鍖?| 鍒嗙被寰幆锛岄渶澶氶」寮?鏍￠獙瀛愯瘉鎹?|
| C4 site PIP 鏀?DCP 鏃犳晥 | PASS锛堥檺宸叉祴妗堜緥锛?| 0 甯у樊寮傝瘉鏄?bitgen 涓嶇収鎶?site route |
| C5 浣嶄綅缃ā鍨?| INCONCLUSIVE | 鎷熷悎鍙敤锛屼絾 k鈭坽1,2} 鏄弿杩版€х粨璁?|
| C6 鍙樹綋鍐冲畾甯у | INCONCLUSIVE | 闇€鍚屼綅缃彧鏀瑰彉浣撶殑瀵圭収 |

## 4. 寰呭姙

0. ~~**[鍚屾 杩滅鈫掓湰鏈篯**~~ 鉁?**宸插畬鎴?2026-10-24**锛氳繙绔?`data/model/v7_model.sqlite`锛圡1锛歳egion_bases 14 / column_offsets 420 / probes 72 / probe_bits 1248锛夊凡瑕嗙洊鍚屾鍒版湰鏈?`E:\v7work\model\v7_model.sqlite`锛坰ha256 鏍￠獙涓€鑷达級锛屾棫 M0 鏋勫缓澶囦唤涓?`v7_model.sqlite.preM1.bak`銆?
0b. ~~**[prjxray 鏍煎紡瀵归綈]**~~ 鉁?**宸插畬鎴?2026-10-24锛堟嫇鎵戦儴鍒嗭級**锛歚v7re/export/prjxray_db.py`
   瀵煎嚭鍒?`E:\v7work\db\prjxray\xc7vx485t\`锛歚tilegrid.json`锛?50,380 tiles锛夈€?   `tileconn.json`锛?7,928 鏉?/ 148,622 wire pair锛夈€?15 涓?`tile_type_<T>.json`锛?5,126 pips锛夈€?   `manifest.json`銆乣README.md`銆傚樊寮傦細鍧愭爣绯绘槸 RapidWright 鍏ㄥ眬缃戞牸锛堥潪 prjxray 鍒楃綉鏍硷級锛?   tileconn 绮掑害鏇寸粏锛沗segbits_*/ppips_*/mask_*` 浠嶇己锛堥渶 fuzz 缁撴灉锛宲pips 闇€ site鈫抰ile 鏄犲皠锛夈€?
> **STEP03 宸叉湁缁撹浣嗗皻鏈叆搴?*锛氳繙绔ā鍨嬪簱 `pip_bits`/`bit_map` 浠嶄负 **0**锛沗step03_pip/RESULTS.md` 閲岀殑 (鍙樹綋鈫掑抚瀵?word,bit) 杩樻病鍐欒繘 DB銆傚～ `pip_bits` 鏄?STEP04 鐨勮緭鍏ャ€?
1. **STEP04锛歠rame/bit 鏁版嵁搴撶敓鎴愬櫒** 鈥斺€?鐢?(鍒? region, 琛? 鍙樹綋) 鈫?(甯? word, bit) 鍏紡锛涘厛鎶?`RESULTS.md` 鐨勮娴嬪～杩?`pip_bits`銆?2. **琛?C1/C2 鐨勭嫭绔嬭瘉鎹?*锛堝鏍告剰瑙佺 1 鏉★級锛氳В鏋?`.bit` 鐨?FAR/FDRI 鍖呮祦锛岀嫭绔嬬粺璁¤鍒囨崲涓庢瘡琛屾湯绔?2 甯э紝鍜?`ConfigArray` 瀵圭収銆?3. **琛?C3 鐨勭嫭绔嬭瘉鎹?*锛氭煡 7 绯诲垪 ECC 鐨勫椤瑰紡/鏍￠獙瀛愶紝瀵瑰凡鐭ュ崟 bit 缈昏浆楠岃瘉 word 50锛涘苟娴嬧€滄暟鎹笉鍙樻椂 word 50 鏄惁鍙樷€濄€?4. **瑙ｅ喅 k 鐨勬姈鍔?*锛堝鏍哥 3 鏉★級锛氬悓涓€鍙樹綋鍦ㄦ洿澶?Y銆佹瘡涓?clock region銆佸绉?tile 涓婂彇鐐癸紝璁板綍 wire/PIP 韬唤銆?5. **C6 瀵圭収瀹為獙**锛氬浐瀹氫綅缃紝鍙敼鍙樹綋锛屾瘮杈冨抚瀵逛笌 bit銆?6. **鎵归噺 PIP 琛?*锛氬浐瀹氫竴涓?tile锛屾妸鎵€鏈?PIP 鍙樹綋璺戜竴閬嶏紙鑴氭湰宸叉湁闆忓舰锛夈€?7. **绔欑偣鍐呴儴浣?fuzz**锛氭敼缃戣〃/寮曡剼锛堜笉鏄敼 route锛夈€?
---

## 5. 甯哥敤鍛戒护

```bash
# 寤轰竴涓?PIP 瀹為獙锛堣繙绔級
cd /opt/lzh/step03/pip2
bash /mnt/c/Users/S.tschai/run_ymore.sh     # 妯℃澘锛歜uild 鈫?a.bit 鈫?鍒?PIP 鈫?b.bit 鈫?diff

# 鏈湴鐪嬬粨鏋?type E:\DEEPSEEK\FPGA姣旂壒娴侀€嗗悜\step03_pip\RESULTS.md
```

