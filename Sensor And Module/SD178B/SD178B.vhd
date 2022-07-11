--SD178BMI2C 語音播放模組
--SD178B address = 0b0100 000 (7 bits)
--SD178BMI2C指令表
--80H:停止、結束(即時執行命令碼)(V2版會死當)
--81H:增加音量0.5db(即時執行命令碼)
--82H:減少音量0.5db(即時執行命令碼)
--送完每個即刻執行的命令碼後，須等20ms後，才能再傳送I2C資料
--===========================================================
--以下2019 02 12 V2.2 版(修正舊版錯誤及新增指令)
--新增8F xx 2byte 指令
--02 8F 00 --Pause暫停
--02 8F 01 --Resume取消暫停
--02 8F 02 --Skip 提前結束正執行的87H或88H指令，跳至下一指令
--02 8F 03 --Soft Reset 重新開機
--
--===========================================================
--83H U8:調整播放速度比原始速度快U8%(00H~28H=0~40%)
--86H U8:設定輸出音量大小為U8(FFH FEH~01H 00H:0db,-0.5db,...,-127db,靜音無聲)預設音量值為D2H
--87H U32:延遲U32 ms時間(單位:ms)(高byte~低byte 00H00H00H80H=128ms)
--88H U16A U16B:播放microSD卡的wave音檔(U16A為檔名:1001~9999.wav 03E9H~270FH ,U16B:為循環播放次數，0表示無限次)
--1001:03E9,2000:07D0,3000:0BB8,4000:0FA0,5000:1388,6000:1770,7000:1B58,8000:1F40,9000:2328
--8AH U8:控制輸出接腳MO2~MO0狀態(U8[b2:b0]對應MO2~MO0狀態)

--8BH U8:Audio Amplifier WM8960 輸出通道控制
--	        WM8960 Audio 輸出通道開/關表
--通道	 Line Out 	  耳機		      喇叭
--代號	HP_R  HP_L 	HP_R  HP_L	 SPK_RN  SPK_LN
--U8	   AGND	 	OUT3(HP_C)	 SPK_RP  SPK_LP
--01H 	...................................Ⅴ
--02H 	...........................Ⅴ
--03H 	...........................Ⅴ......Ⅴ
--04H 	.............Ⅴ....Ⅴ
--05H 	...................Ⅴ..............Ⅴ
--06H 	.............Ⅴ............Ⅴ
--07H(預設)..........Ⅴ....Ⅴ......Ⅴ......Ⅴ
--08H 	.Ⅴ...Ⅴ
--09H 	......Ⅴ...........................Ⅴ
--0AH 	.Ⅴ........................Ⅴ
--0BH 	.Ⅴ...Ⅴ...................Ⅴ......Ⅴ

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity SD178B is
port ( clk50M ,reset_in: in std_logic;
	   SD178BMI2C_SCL:out std_logic;			--介面IO:SCL,如有接提升電阻時可設成inout
	   SD178BMI2C_SDA:inout std_logic;		--介面IO:SDA,有接提升電阻
	   SD178BMI2Co_reset:buffer std_logic:='1';--/reset
	   number_in : in integer range 0 to 9999;
	   SD178BMI2Ci_MO0:in std_logic			--/MO0 )
	 ) ;
end SD178B;

architecture a of SD178B is

	component sd178BMI2C2wdriver
	 port(I2CCLK,RESET:in std_logic;				--系統時脈,系統重置
		  ID:in std_logic_vector(6 downto 0);		--裝置碼0100000
		  DATAin:in std_logic_vector(7 downto 0);	--資料輸入
		  DATAout:buffer std_logic_vector(7 downto 0);--資料輸出
		  RW:in std_logic;							--讀寫
		  RWN:in integer range 0 to 15;				--嘗試讀寫次數
		  D_W_R_N:in integer range 0 to 255;	 	--連續讀寫次數
		  D_W_R_Nok:buffer std_logic;				--讀寫1次數旗標
		  reWR:in std_logic;						--已寫入或讀出資料
		  I2Cok,I2CS:buffer std_logic;				--I2Cok,CS 狀態
		  SCL:out std_logic;						--介面IO:SCL,如有接提升電阻時可設成inout
		  SDA:inout std_logic						--介面IO:SDA
		 );
	end component;
	--單筆操作:D_W_R_N=1
	--多筆操作:由D_W_R_N指定,每完成1筆回D_W_R_Nok,收到reWR後再進行下一筆

	--SD178BMI2C
	signal SD178BMI2C_ID:std_logic_vector(6 downto 0):="0100000";
	signal SD178BMI2C_DATAin,SD178BMI2C_DATAout:std_logic_vector(7 downto 0);
			--I2C時脈,			啟動		,I2C完成	,狀態			,讀寫
	signal SD178BMI2C_CLK,SD178BMI2C_RESET,SD178BMI2C_ok,SD178BMI2C_CS,SD178BMI2C_RW:std_logic;--
	constant SD178BMI2C_RWN:integer range 0 to 15 :=1;		--嘗試讀寫1次設定
	signal SD178BMI2C_D_W_R_N:integer range 0 to 255;		--page 長度
	signal SD178BMI2C_reWR,SD178BMI2C_D_W_R_Nok:std_logic;	--繼續,通知處理
	
	
	-- -----------------------------------------------------
	--SD178BMI2C			 設語音表長度
	type SD178BMI2C_T is array (0 to 255) of std_logic_vector(7 downto 0);
	signal SD178BMI2C_sound:SD178BMI2C_T;			--(0:語音播放長度),....
	signal SD178BMI2CP_reseton_delay:integer range 0 to 255;--power on delay
	signal SD178BMI2C_IL:integer range 0 to 255;	--語音表取值指標
	signal SD178BMI2CP_reset,SD178BMI2CP_ok,SD178BMI2C_RWs:std_logic;--SD178BMI2CP 重置 ,完成 ,讀寫(1:read,0:write)
	signal SD178BMI2CP_powerdown,SD178BMI2CP_reseton:std_logic;--power on/off,RESET
	signal SD178BMI2C_P_end_t_onoff:std_logic:='0';				--是否啟動終止延遲計時
	signal SD178BMI2C_P_end_t_set:integer range 0 to 32767:=0;	--終止延遲計時次數(1:約1.004ms)
	type SD178BMI2C_rT is array (0 to 4) of std_logic_vector(7 downto 0);
	signal SD178BMI2C_DATA0_4:SD178BMI2C_rT;

	signal Sound86,Sound88,Sound8B:std_logic_vector(7 downto 0);
	constant Soundclr80:std_logic_vector(7 downto 0):=X"80";
	constant Soundup81:std_logic_vector(7 downto 0):=X"81";
	constant Sounddown82:std_logic_vector(7 downto 0):=X"82";

	--TSL2561 語音
	signal TSL2561_N3,TSL2561_N2,TSL2561_N1,TSL2561_N0:std_logic_vector(3 downto 0);
	signal TSL2561_Sound_DATA:std_logic_vector(79 downto 0);
	
	type M7_0T is array (0 to 4) of std_logic_vector(2 downto 0);
	signal M70s:M7_0T;
	signal M710,MMx,MM:std_logic_vector(1 downto 0);
	signal M776:std_logic_vector(1 downto 0);
	signal MMs,soundn:integer range 0 to 7;
	signal DHT11_DBoTPWM0,DHT11_DBoTPWM1:integer range 0 to 15;
	signal Mx:std_logic_vector(3 downto 0);

	-- -----------------------------------------------------
	constant number: std_logic_vector(7 downto 0):=x"30" ;
	
	signal FD :std_logic_vector(25 downto 0);
	signal S_RESET:std_logic;
	signal times:integer range 0 to 4095;
	signal times1:integer range 0 to 511;
	signal S0on:std_logic;
	signal mp3: std_logic_vector(15 downto 0):=X"03E9";
	begin
	
		SD178BMI2Cdriver1:sd178BMI2C2wdriver port map(I2CCLK=>SD178BMI2C_CLK,					--系統時脈
											  RESET=>SD178BMI2C_RESET,					--系統重置
											  ID=>SD178BMI2C_ID,						--裝置碼0100000
											  DATAin=>SD178BMI2C_DATAin,				--資料輸入
											  DATAout=>SD178BMI2C_DATAout,				--資料輸出
											  RW=>SD178BMI2C_RW,						--讀寫
											  RWN=>SD178BMI2C_RWN,						--嘗試讀寫次數
											  D_W_R_N=>SD178BMI2C_D_W_R_N,			 	--連續讀寫次數
											  D_W_R_Nok=>SD178BMI2C_D_W_R_Nok,			--讀寫1次數旗標
											  reWR=>SD178BMI2C_reWR,					--已寫入或讀出資料
											  I2Cok=>SD178BMI2C_ok,						--I2Cok
											  I2CS=>SD178BMI2C_CS,						--CS 狀態
											  
											  SCL=>SD178BMI2C_SCL,						--介面IO:SCL,如有接提升電阻時可設成inout
											  SDA=>SD178BMI2C_SDA						--介面IO:SDA
											 );
											 
											 
											 
											 
		Freq_Div:process(clk50M)
		begin
			if  S_RESET ='0' then
				FD<=(others=>'0');
			elsif rising_edge(clk50M) then
				FD<=FD+1;	--除頻器
			end if;
		end process Freq_Div;
	
	
	
	process(SD178BMI2Ci_MO0 )
	begin
		if reset_in ='0' then
			mp3<=X"03E9";
		elsif SD178BMI2Ci_MO0 ='1' and SD178BMI2Ci_MO0'event then
			mp3<=mp3+1;
		end if;
		
	end process;
	process(SD178BMI2CP_ok,reset_in)
	begin
		
		
		
		if SD178BMI2CP_ok='1' then
			
			SD178BMI2CP_reset<='0';	--off
			SD178BMI2C_P_end_t_onoff<='1';	--off 是否啟動終止延遲計時
			SD178BMI2C_P_end_t_set<=1000;	--0,終止延遲計時次數(1:約1.004ms)
			Sound86<=X"D9";               --音量最大FE
			--soundn<=soundn+1;
			
			--Sound8B<=X"07";
			
			--撥放”系統開機”
			if reset_in ='0' then
				SD178BMI2C_sound(0 to 3)<=(X"03",X"8A",X"07",X"80" );
			else
				if SD178BMI2Ci_MO0 ='1' then
					soundn<=1;
				else
					soundn<=0;
				end if;
				case soundn is
					when 0 =>
						SD178BMI2C_sound(0 to 3)<=(X"02",X"8A",X"07",X"80" );
					when 1 =>
						SD178BMI2C_sound(0 to 13)<=(X"12",X"86",X"EE",X"8B",X"04",--86:音量 5->D7 8B:RL聲道設定 
													X"8A",X"06",
													X"88",mp3(15 downto 8),mp3(7 downto 0),X"00",x"01",
													
													X"8A",X"07"
													);--等待撥音結束
					when 2 => 
						SD178BMI2C_sound(0 to 16)<=(X"14",X"86",X"FF",X"8B",X"07",--86:音量 5->D7 8B:RL聲道設定 
													 X"8A",X"06",
													 X"C1",X"C2",x"C1",X"C2",X"A5",X"FA",
													 X"C1",X"7B",
													
													X"8A",X"07"
													);--等待撥音結束
					when others => SD178BMI2C_sound(0 to 3)<=(X"03",X"8A",X"07",X"80" );
					
				end case;
			end if;
			
			
		else
			SD178BMI2CP_reset<='1';	--on
		end if;
	end process;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
											 
											 
											 
											 
--=====================================================================================
--SD178BMI2C--------------------------------------
--不同語音表所有計時皆由driver負責,使用者更方便
--增加語音表執行完,可選擇是否延遲一段時間後才結束
--SD178BMI2C_P_end_t_onoff='1'是'0'否啟動終止延遲計時
--SD178BMI2C_P_end_t_set:0~32767 終止延遲計時次數(1:約1.004ms)
--================================================
--00 00 xx --硬體reset
--00 01 xx --nop 立即回應結束
--01 00 xx --由睡眠省電模式中喚醒
--立即指令:
--以下2017  V1 版
--01 80 xx --清除SD178B buffer內的所有碼,停止正在執行的動作:轉成 "硬體reset" 操作(此版本80不會當機)
--01 81 xx --音量增1單位(+0.5dB)
--01 82 xx --音量減1單位(-0.5dB)

--以下2019 02 12 V2.2 版適用(此版本80會當機，是此模組本身的問題，越改越糟)
--01 80 xx --清除SD178B buffer內的所有碼,停止正在執行的動作,音量等已執行的設定不變:轉成 "硬體reset" 操作
--01 81 xx --音量增1單位(+0.5dB)
--01 82 xx --音量減1單位(-0.5dB)
--新增8F xx 2byte 指令
--02 8F 00 --Pause暫停
--02 8F 01 --Resume取消暫停
--02 8F 02 --Skip 提前結束正執行的87H或88H指令，跳至下一指令
--02 8F 03 --Soft Reset 重新開機
--================================================

											 
											 
		SD178BMI2C_CLK<=FD(8);	--I2C時脈
SD178BMI2C_DATAin<=SD178BMI2C_sound(SD178BMI2C_IL+1);
SD178BMI2C_D_W_R_N<=conv_integer(SD178BMI2C_sound(0));
SD178BMI2C_P:process(FD(8))
variable V1orV2:integer range 0 to 7:=2;--如使用V1版設1(80原功能)(請不要下V2新指令)，如使用V2版設2(80轉成 "硬體reset" 操作)
variable SD178BMI2C_mO0_1,t_start:std_logic;
variable t,end_delayt:integer range 0 to 20000;
variable t2:integer range 0 to 15;
variable end_t_start,SD178BMI2C_P_end_t_onoff_s:std_logic;
variable t3:integer range 0 to 100;
begin
	if 	SD178BMI2CP_reset='0' then
		SD178BMI2CP_ok<='0';			--完成指標
		SD178BMI2C_RESET<='0';			--sd178BMI2C2wdriver1重置
		SD178BMI2C_reWR<='0';			--繼續
		SD178BMI2C_RW<=SD178BMI2C_RWs;	--0write:1:read
		SD178BMI2C_IL<=0;
		SD178BMI2Co_reset<=SD178BMI2CP_reseton;	--硬體reset off or on
		--配合不同需求必要性延遲設定
		t_start:='0';
		t2:=11;		--reset time
		--選擇性延遲設定
		end_t_start:='0';										--off啟動終止延遲計時
		SD178BMI2C_P_end_t_onoff_s:=SD178BMI2C_P_end_t_onoff;	--是否啟動終止延遲計時
		end_delayt:=SD178BMI2C_P_end_t_set;						--終止延遲計時次數(1:約1.004ms)
		t3:=98;													--delay 0.001004s

	elsif rising_edge(FD(8)) then
		if SD178BMI2CP_ok='0' then
			if SD178BMI2C_IL<conv_integer(SD178BMI2C_sound(0)) then	--send data
				if SD178BMI2C_reWR='1' then
					SD178BMI2C_reWR<='0';		--page作業:繼續
				elsif SD178BMI2C_RESET='0' then
					SD178BMI2C_RESET<='1';		--啟動sd178BMI2C2wdriver1
				elsif SD178BMI2C_ok='1' or SD178BMI2C_D_W_R_Nok='1' then		--完成 or --下一筆作業通知
					if SD178BMI2C_RW='1' then
						SD178BMI2C_DATA0_4(SD178BMI2C_IL)<=SD178BMI2C_DATAout;	--輸出資料
					end if;
					SD178BMI2C_IL<=SD178BMI2C_IL+1;			--下一筆
					SD178BMI2C_reWR<=SD178BMI2C_D_W_R_Nok;	--page作業通知
				end if;

			elsif end_t_start='1' then--啟動終止計時延遲後結束
				t3:=t3-1;
				if end_delayt=0 then
					SD178BMI2CP_ok<='1';	--完成指標
				elsif t3=0 then
					t3:=98;--delay 0.001004s
					end_delayt:=end_delayt-1;
				end if;

			elsif t_start='1' then--啟動計時延遲後結束
				t:=t-1;
				if t=0 then
					end_t_start:=SD178BMI2C_P_end_t_onoff_s;		--是否啟動終止計時延遲後結束
					SD178BMI2CP_ok<=not SD178BMI2C_P_end_t_onoff_s;	--是否完成指標
				end if;

			else
				if SD178BMI2Co_reset='0' or t2=0 then
					if t2/=0 then
						t2:=t2-1;
					else
						SD178BMI2Co_reset<='1';		--硬體reset off
						t_start:=SD178BMI2Ci_MO0;	--啟動計時延遲後結束
					end if;

				elsif SD178BMI2C_sound(0)>0 then
					if SD178BMI2C_sound(0)>3 then	--X"8A",X"06",X"8A",X"07" -->等待播音結束:等待軟體結束:不做硬體reset
						if SD178BMI2C_sound(SD178BMI2C_IL-1)=X"8A" and SD178BMI2C_sound(SD178BMI2C_IL)(0)='1' and
						   SD178BMI2C_sound(SD178BMI2C_IL-3)=X"8A" and SD178BMI2C_sound(SD178BMI2C_IL-2)(0)='0'then--等待播音結束:等待軟體結束:不做硬體reset

							SD178BMI2CP_ok<=SD178BMI2C_mO0_1 and SD178BMI2Ci_MO0 and not SD178BMI2C_P_end_t_onoff_s;--結束
							end_t_start:=SD178BMI2C_mO0_1 and SD178BMI2Ci_MO0 and SD178BMI2C_P_end_t_onoff_s;--啟動終止計時延遲後結束
															  --X"8A",X"06" -->等待播音結束:--執行硬體reset on
						elsif SD178BMI2C_sound(SD178BMI2C_IL-1)=X"8A" and SD178BMI2C_sound(SD178BMI2C_IL)(0)='0' then--等待播音結束:--執行硬體reset on
							SD178BMI2Co_reset<=SD178BMI2Ci_MO0;--等待硬體reset on --delay 30.72ms
						else
							end_t_start:=SD178BMI2C_P_end_t_onoff_s;		--是否啟動終止計時延遲後結束
							SD178BMI2CP_ok<=not SD178BMI2C_P_end_t_onoff_s;	--是否啟動終止計時延遲後結束(播音時間自行控制)
						end if;

					elsif SD178BMI2C_sound(0)>1 then
						if SD178BMI2C_sound(SD178BMI2C_IL-1)=X"8A" and SD178BMI2C_sound(SD178BMI2C_IL)(0)='0' then--等待播音結束:--執行硬體reset on
							SD178BMI2Co_reset<=SD178BMI2Ci_MO0;--等待硬體reset on --delay 30.72ms
						--2019 02 12 V2 版 8F xx(0,1,2,3)立即指令 delay 30.72ms
						elsif SD178BMI2C_sound(SD178BMI2C_IL-1)=X"8F" and SD178BMI2C_sound(SD178BMI2C_IL)<4 then--2byte 立即指令
							if SD178BMI2C_sound(SD178BMI2C_IL)=3 then
								t:=17350;
							else
								t:=10;
							end if;							
							t_start:='1';	--啟動計時延遲後結束
						else
							end_t_start:=SD178BMI2C_P_end_t_onoff_s;		--是否啟動終止計時延遲後結束
							SD178BMI2CP_ok<=not SD178BMI2C_P_end_t_onoff_s;	--是否完成指標
						end if;

					else	--1byte 00(喚醒),(立即指令:80,81,82):delay 
						
						if SD178BMI2C_sound(1)=X"00" or SD178BMI2C_sound(1)=X"80" then --00(喚醒)、V2立即指令:80 轉成 "硬體reset" 操作
							if V1orV2=1 then
								--V1
								t:=10;
								t_start:='1';	--啟動計時延遲後結束
							else 
								--V2
								t:=20000;--delay 0.2048s
								SD178BMI2Co_reset<='0';	--硬體reset on
							end if;
							
						else
							t:=450;
							t_start:='1';		--啟動計時延遲後結束
						end if;
					end if;

				else
					if SD178BMI2C_sound(1)=0 then
						t:=20000;--delay 0.2048s
						SD178BMI2Co_reset<='0';	--硬體reset on
					else
						SD178BMI2CP_ok<='1'; --nop 立即回應結束
					end if;					
				end if;
			end if;
		end if;
	end if;

	if SD178BMI2Ci_MO0='1' then	--捕捉SD178BMI2Ci_MO0
		SD178BMI2C_mO0_1:='1';
	elsif rising_edge(FD(8)) then
		if SD178BMI2CP_reset='0' then
			SD178BMI2C_mO0_1:='0';
		end if;
	end if;
end process SD178BMI2C_P;

--=====================================================================================

end a;
