library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- -----------------------------------------------------
entity TSL2561 is
port( clk50M,reset_in:in std_logic;

	  TSL2561_SCL:out std_logic;			--介面IO:SCL,如有接提升電阻時可設成inout
	  TSL2561_SDA:inout std_logic;		--介面IO:SDA,有接提升電阻
	 
	  int_out:out std_logic;
	  dtout:out integer range 0 to 65535
	  
	);
end TSL2561;

architecture a of TSL2561 is

--I2C_Driver--for TSL2561--------------------------------------------------------------
	component i2c2wdriver2
	Port(I2CCLK,RESET:in std_logic;					--系統時脈,系統重置
		ID:in std_logic_vector(3 downto 0);			--裝置碼
		CurrentADDR:in std_logic;					--要求命令:(0目前位址讀取),(1指定位址讀取)
		ADDR:in std_logic_vector(7 downto 0);		--位置(COMMAND)
		A2A1A0:in std_logic_vector(2 downto 0);		--位置,最多8個位址並存
		DATAin:in std_logic_vector(7 downto 0);		--資料輸入
		DATAout:buffer std_logic_vector(7 downto 0);--資料輸出
		RW:in std_logic;							--讀寫
		RWN:in integer range 0 to 15;				--嘗試讀寫次數
		D_W_R_N:in integer range 0 to 63;		 	--連續讀寫次數
		D_W_R_Nok:buffer std_logic;					--讀寫1次數旗標
		reWR:in std_logic;							--已寫入或讀出資料
		I2Cok,I2CS:buffer std_logic;				--I2Cok,CS 狀態
		SCL:out std_logic;							--介面IO:SCL,如有接提升電阻時可設成inout
		SDA:inout std_logic							--介面IO:SDA
		);
	end component;
	
	--TSL2561
	signal TSL2561_ID:std_logic_vector(3 downto 0):="0111";--TSL2561 ADDR SEL :(Float:0111,GND:0101,VDD:1001),24LCxx裝置碼:"1010"
	signal TSL2561_DATAin,TSL2561_DATAout:std_logic_vector(7 downto 0);
			--I2C時脈	,	啟動 	,I2C完成	,狀態		,讀寫
	signal TSL2561_CLK,TSL2561_RESET,TSL2561_ok,TSL2561_CS,TSL2561_RW:std_logic;--
	constant TSL2561_RWN:integer range 0 to 15 :=3;		--嘗試讀寫1次設定
	signal TSL2561_COMMAND:std_logic_vector(7 Downto 0);--位址(ADDR:COMMAND)
	signal TSL2561_D_W_R_N:integer range 0 to 63;		--page 長度
	signal TSL2561_reWR,TSL2561_D_W_R_Nok:std_logic;	--繼續,通知處理
	
	
	--TSL2561-----------------------------------------------------------------------------
	
	signal TSL2561_INT: std_logic;		--TSL2561 INT
	signal int_counter: integer range 0 to 200;
	
	signal TSL2561P_reset,TSL2561P_ok:std_logic;
	signal TSL2561_DP:integer range 0 to 3;
	type TSL2561_DATA01_T is array (0 to 3) of std_logic_vector(7 downto 0);
	signal TSL2561_DATA01:TSL2561_DATA01_T;
	signal CH0,CH1:integer range 0 to 65535;
	signal Tint:integer range 0 to 3:=2;
	signal iGain,iType:integer range 0 to 1:=0;
	signal chScale0:std_logic_vector(15 downto 0);	--16bit
	signal chScale1:std_logic_vector(19 downto 0);	--20bit
	signal chScale:integer range 0 to 1048575;		--20bit 2^20-1
	type chScale_T is array (0 to 2) of std_logic_vector(15 downto 0);
	constant chScale_TS:chScale_T:=(X"7517",X"0FE7",X"0400");
	signal channe0:integer range 0 to 67108863;		--26bit 2^26-1
	signal channe1:std_logic_vector(25 downto 0);	--26bit
	signal ratio1:integer range 0 to 4095;			--12bit 2^12-1
	signal ratio:std_logic_vector(11 downto 0);		--12bit
	signal BM:integer range 0 to 7;
	type KTC_T is array (0 to 7) of std_logic_vector(11 downto 0);
	constant KT_T_FN_CL:KTC_T:=(X"040",X"080",X"0c0",X"100",X"138",X"19a",X"29a",X"29a");
	constant BT_T_FN_CL:KTC_T:=(X"1f2",X"214",X"23f",X"270",X"16f",X"0d2",X"018",X"000");
	constant MT_T_FN_CL:KTC_T:=(X"1be",X"2d1",X"37b",X"3fe",X"1fc",X"0fb",X"012",X"000");
	constant KT_CS:KTC_T:=(X"043",X"085",X"0c8",X"10a",X"14d",X"19a",X"29a",X"29a");
	constant BT_CS:KTC_T:=(X"204",X"228",X"253",X"282",X"177",X"101",X"037",X"000");
	constant MT_CS:KTC_T:=(X"1ad",X"2c1",X"363",X"3df",X"1dd",X"127",X"02b",X"000");
	signal KTC,BTC,MTC:KTC_T;
	signal tempb,tempm,temp0,temp:integer range 0 to 520093695;		--32bit :0~2^32-1
	signal LUXS,LUXS1,LUXS2,LUXS3,LUXS4:integer range 0 to 65535;	--16bit:0~2^16-1
	signal LUXSx,LUXSx1,LUXSx2:integer range 0 to 65535;	--16bit:0~2^16-1
	type LUX_T is array (0 to 3) of integer range 0 to 15;
	type LLUx is array (0 to 4) of integer range 0 to 9;
	Signal LUX : LLUx;	--顯示資料
	Signal LUXDP:integer range 0 to 7;	--小數點位置
	
	signal S_RESET:std_logic;
	signal FD:std_logic_vector(25 downto 0);					 --除頻器
	signal LUXall:integer range 0 to 9999;
	signal times:integer range 0 to 90000; 
begin

	TSL2561driver:i2c2wdriver2 port map(I2CCLK=>TSL2561_CLK,			--系統時脈,系統重置
									RESET=>TSL2561_RESET,			--系統時脈,系統重置
									ID=>TSL2561_ID,					--裝置碼
									CurrentADDR=>'1',				--要求命令:(0目前位址讀取),(1指定位址讀取)
									ADDR=>TSL2561_COMMAND,			--TSL2561:COMMAND
									A2A1A0=>"001",					--ID&A2A1A0:Slave Address:0x29,0x39,0x49
									DATAin=>TSL2561_DATAin,			--資料輸入:DATA write to TSL2561
									DATAout=>TSL2561_DATAout,		--資料輸出:TSL2561 DATA read to FPGA
									RW=>TSL2561_RW,					--讀寫0:w,1:R
									RWN=>TSL2561_RWN,				--嘗試讀寫次數
									D_W_R_N=>TSL2561_D_W_R_N,		--連續讀寫次數
									D_W_R_Nok=>TSL2561_D_W_R_Nok,	--讀寫1次數旗標
									reWR=>TSL2561_reWR,				--已寫入或讀出資料
									I2Cok=>TSL2561_ok,				--TSL2561_ok 狀態
									I2CS=>TSL2561_CS,				--TSL2561_CS 狀態
									SCL=>TSL2561_SCL,				--介面IO:SCL,如有接提升電阻時可設成inout
									SDA=>TSL2561_SDA				--介面IO:SDA,有接提升電阻
									);
									
									
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	Freq_Div:process(clk50M)
begin
	if RESET_in='0' then
		FD<=(others=>'0');
	elsif rising_edge(clk50M) then
		FD<=FD+1;	--除頻器
	end if;
end process Freq_Div;
	
	process(FD(17))
	begin
		if TSL2561P_reset ='0' then
			int_counter<=0;
		elsif rising_edge(FD(17)) then
			int_counter<=int_counter+1;
		end if;
	end process;
	
	process(int_counter)
	begin
		if int_counter<100 then
			TSl2561_INT<='1';
			TSL2561P_reset<='1';
		elsif int_counter>190 then
			TSL2561P_reset<='0';
		else
			TSl2561_INT<='0';
		end if;
	end process;
	int_out<=TSL2561_INT;
--=====================================================================================
--TSL2561--------------------------------------
TSL2561_CLK<=FD(8);	--I2C時脈
TSL2561_P:process(FD(9))
variable TSL2561P_case:integer range 0 to 7;
variable TSL_time:integer range 0 to 63;
begin
	if  TSL2561P_reset='0' then
		TSL2561P_case:=0;
		TSL2561P_ok<='0';		--TSL2561_P 完成指標
		TSL2561_RESET<='0';		--i2c2wdriver2重置
		TSL2561_reWR<='0';		--繼續
		TSL2561_COMMAND<="11000000";	--clear
		TSL2561_DATAin<=(others=>'0');	--power down
		TSL2561_RW<='0';		--write
		TSL2561_D_W_R_N<=1;		--單獨操作1筆
		TSL_time:=31;			--delay
		TSL2561_DP<=0;
	elsif rising_edge(FD(9)) then
		if TSL2561P_ok='0' then
			if TSL2561_reWR='1' then
				TSL2561_reWR<='0';		--page作業:繼續
			elsif TSL2561_RESET='0' then
				TSL2561_RESET<='1';		--啟動i2c2wdriver2
			elsif TSL2561_ok='1' then	--完成
				case TSL2561P_case is
					when 0=>	--clera INT and power off -> clera INT and power up
						TSL_time:=TSL_time-1;
						if TSL_time=0 then
							TSL2561_DATAin<=X"03";	--power on
							TSL2561_RESET<='0';		--i2c2wdriver2重置
							TSL2561P_case:=1;		--next step
						end if;

					when 1=>	--set INT:clera INT and level interrupt enable
							TSL2561_COMMAND<="11000110";	--clear and 06
							TSL2561_DATAin<=X"10";			--level interrupt enable
							TSL2561_RESET<='0';				--i2c2wdriver2重置
							TSL2561P_case:=2;				--next step

					when 2=>	--read DATA0LOW,DATA0HIGH,DATA1LOW,DATA1HIGH
						if TSL2561_INT='0' then
							TSL2561_COMMAND<="10001100";	--DATA0LOW:C
							TSL2561_RW<='1';				--read
							TSL2561_D_W_R_N<=4;				--操作4筆
							TSL2561_RESET<='0';				--i2c2wdriver2重置
							TSL2561P_case:=3;				--next step
						end if;

					when 3=>	--clera INT and power off
						TSL2561_DATA01(TSL2561_DP)<=TSL2561_DATAout;--輸出資料
						TSL2561_COMMAND<="11000000";	--clear INT
						TSL2561_DATAin<=(others=>'0');	--power down
						TSL2561_RW<='0';				--write
						TSL2561_D_W_R_N<=1;				--操作1筆
						TSL2561_RESET<='0';				--i2c2wdriver2重置
						TSL2561P_case:=4;				--next step

					when others=>	--TSL2561_P 完成
						TSL2561P_ok<='1';		--TSL2561_P 完成指標
						TSL2561_RESET<='0';		--i2c2wdriver2重置

				end case;
			elsif TSL2561_D_W_R_Nok='1' then		--page作業通知
				TSL2561_DATA01(TSL2561_DP)<=TSL2561_DATAout;--輸出資料
				TSL2561_DP<=TSL2561_DP+1;			--下一筆
				TSL2561_reWR<='1';					--回收到
			end if;
		end if;
	end if;
end process TSL2561_P;

---------------------------------------------------------------------------------------------------
--計算TSL2561照度值
--iGain 0:=1X 1:16X ,Tint 0:=13.7ms, 1:101ms, 2:402ms ,iType 0:T,FN,CL 1:CS
--default
--iGain:0			,Tint:2							  ,iType:0
CH0<=conv_integer(TSL2561_DATA01(1)&TSL2561_DATA01(0));	--16bit
CH1<=conv_integer(TSL2561_DATA01(3)&TSL2561_DATA01(2));	--16bit

chScale0<=chScale_TS(Tint);	--16bit
--			X16								X1
chScale1<=chScale0&"0000" when iGain=0 else "0000"&chScale0;	--20bit
chScale<=conv_integer(chScale1);	--20bit

channe0<=conv_integer(CONV_STD_LOGIC_VECTOR(CH0*chScale,36)(35 downto 10));	--26bit (ch0*chScale)/2^10
channe1<=CONV_STD_LOGIC_VECTOR(CH1*chScale,36)(35 downto 10);				--26bit  (ch1*chScale)/2^10
							--RATIO_SCALE9+1
ratio1<=conv_integer(channe1&"0000000000")/channe0 when channe0/=0 else 0;	--12bit (channe1*2^10)/channe0
ratio<=CONV_STD_LOGIC_VECTOR(ratio1+1,13)(12 downto 1);						--12bit (ratio1+1)/2

--iType:0
KTC<=KT_T_FN_CL when iType=0 else KT_CS;--12bit
BTC<=BT_T_FN_CL when iType=0 else BT_CS;--12bit
MTC<=MT_T_FN_CL when iType=0 else MT_CS;--12bit
BM<=0 when ratio>=0 and ratio<=KTC(0) else
	1 when ratio<=KTC(1) else
	2 when ratio<=KTC(2) else
	3 when ratio<=KTC(3) else
	4 when ratio<=KTC(4) else
	5 when ratio<=KTC(5) else
	6 when ratio<=KTC(6) else
	7 ;

tempb<=channe0*conv_integer(BTC(BM));				--32bit channe0*b
tempm<=conv_integer(channe1)*conv_integer(MTC(BM));	--32bit channe1*m
temp0<=0 when tempb<tempm else tempb-tempm;			--32bit

--將小數第2位進位到小數第1位round
temp<=temp0+8192;	--2^13  --LUX_SCALE-1=13
LUXS<=conv_integer(CONV_STD_LOGIC_VECTOR(temp,33)(32 downto 14));	--16bit/2^14

LUXDP<=1 when LUXS<10000 else 5;	--小數點位置

LUXS1<=LUXS/10;
--		小數1位						  個位數
LUX(0)<=LUXS mod 10 when LUXDP=1 else LUXS1 mod 10;

LUXS2<=LUXS1/10;
--		個位數						  十位數
LUX(1)<=LUXS1 mod 10 when LUXDP=1 else LUXS2 mod 10;

LUXS3<=LUXS2/10;
--		十位數						  百位數
LUX(2)<=LUXS2 mod 10 when LUXDP=1 else LUXS3 mod 10;

LUXS4<=LUXS3/10;
--		百位數						  千位數
LUX(3)<=LUXS3 mod 10 when LUXDP=1 else LUXS4 mod 10;

--dtout<= conv_integer(CH1);
dtout<=LUXS;
end a;