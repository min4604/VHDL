--V13_I2C_driver2:eeprom I2C全功能版
--Creator by YHGL

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;

--------------------------------------------------------------------------
entity I2C2Wdriver2 is
   port(I2CCLK,RESET:in std_logic;					--系統時脈,系統重置
		  ID:in std_logic_vector(3 downto 0);		--裝置碼
		  CurrentADDR:in std_logic;					--要求命令:(0目前位址讀取),(1指定位址讀取)
		  ADDR:in std_logic_vector(7 downto 0);		--位置
		  A2A1A0:in std_logic_vector(2 downto 0);	--位置,最多8個位址並存
		  DATAin:in std_logic_vector(7 downto 0);	--資料輸入
		  DATAout:buffer std_logic_vector(7 downto 0);--資料輸出
		  RW:in std_logic;							--讀寫
		  RWN:in integer range 0 to 15;				--嘗試讀寫次數
		  D_W_R_N:in integer range 0 to 63;		 	--連續讀寫次數
		  D_W_R_Nok:buffer std_logic;				--讀寫1次數旗標
		  reWR:in std_logic;						--已寫入或讀出資料
		  I2Cok,I2CS:buffer std_logic;				--I2Cok,CS 狀態
		  SCL:out std_logic;						--介面IO:SCL,如有接提升電阻時可設成inout
		  SDA:inout std_logic						--介面IO:SDA
		 );
end I2C2Wdriver2;
--目前位址讀取:CurrentADDR='0'
--指定位址讀取:CurrentADDR='1'
--寫入:CurrentADDR=x
--單筆操作:D_W_R_N=1
--多筆操作:由D_W_R_N指定,每完成1筆回D_W_R_Nok,收到reWR後再進行下一筆

--------------------------------------------------------------------------
architecture YHGL of I2C2Wdriver2 is
	signal Wdata:std_logic_vector(29 downto 0);	--寫命令表
	signal Rdata:std_logic_vector(40 downto 0);	--讀命令表
	signal I2Creset,SCLs,SDAs,I2CoKs:std_logic;	--失敗,SCL,SDA,ACK載入別
	signal I:integer range 0 to 2;		 		--相位指標
	signal WN,WNend:integer range 0 to 29;		--寫命令指標
	signal RN,RNs:integer range 0 to 40;		--讀命令指標
	signal PN:integer range 0 to 29;			--錯誤暫停時間
	signal RWNS:integer range 0 to 15;			--嘗試讀寫次數計數器
	signal D_W_R_Ns:integer range 0 to 63;		--多筆操作
begin

-----------------------------------
SDA<='0' when SDAs='0' else 'Z';--SDA bus控制
SCL<='0' when SCLs='0' else '1';
--介面IO:SCL,如有接提升電阻時可設成inout
--SCL<='0' When SCLs='0' Else 'Z';
-----------------------------------
process(I2CCLK,RESET)
begin
	if RESET='0' then
		--Byte  Write: A2A1A0:1~2Kbit A2A1A0,4Kbit A2A1a8,8Kbit A2a9a8
		--      S 裝置碼    位址    /寫   ack   位址   ack   寫入資料   ack    P
		Wdata<='0' & ID & A2A1A0 & '0' & '1' & ADDR & '1' & DATAin & '1' & "00";	--(0)沒用到,結束碼
		--page write:D_W_R_Ns>1,WN再從10起,下一筆放入Wdata(10 downto 3)<=DATAin;
			
		--Random Read:
		--      S  裝置碼   位址    /寫   ack   位址   ack
		Rdata<='0' & ID & A2A1A0 & '0' & '1' & ADDR & '1' & 
		--		 Sr	  裝置碼 位址     讀    ack    讀出資料  			 	P
			    "10" & ID & A2A1A0 & '1' & '1' & "11111111" & '1' & "00";				--(0)沒用到,結束碼
		--																	ack(0,1)
		-- 目前位址讀取:Rn從20開始,指定位址讀取Rn從40開始,
		--	如還有下一筆(D_W_R_Ns/=1)且Rn=2時須回ack0(acknowledge), Rn再從10開始
		--	如已最後一筆(D_W_R_Ns=1)時,則回ack1 (not acknowledge)
		I<=0;--設0相位
		WN<=29;--設寫入執行點
		if CurrentADDR='1' then --指定位址讀取
			RN<=40;	--設讀取執行點
			RNs<=40;--設讀取錯誤覆回復執行點
		else		--目前位址讀取
			RN<=20;	--設讀取執行點
			RNs<=20;--設讀取錯誤回復執行點
		end if;
		WNend<=0;	--設寫入終點
		
		PN<=29;		--錯誤暫停時間
		I2CoK<='0';	--設未完成旗標
		I2CoKs<='1';--設ACK載入別
		SCLs<='1';	--設I2C為閒置
		SDAs<='1';	--設I2C為閒置
		I2CS<='0';	--設無狀態
		RWNS<=RWN;			--嘗試讀寫次數
		D_W_R_Ns<=D_W_R_N;	--連續讀取D_W_R_N次
		I2Creset<='0';	--設無錯誤旗標
		D_W_R_Nok<='0';	--page 作業旗標
	elsif rising_edge(I2CCLK) then
		if I2Cok='0' Then	--尚未完成
		--失敗再嘗試
			if I2Creset='1' then	--重新起始
				SCLs<='1';			--bus暫停
				SDAs<='1';			--bus暫停
				I<=0;RN<=RNs;WN<=29;--錯誤回復執行點
				if PN=0 then		--暫停時間
					PN<=29;			--重設錯誤暫停時間
					I2Creset<='0';	--取銷錯誤旗標
					RWNS<=RWNS-1;	--嘗試讀寫次數
					if RWNS<=1 then	--嘗試讀寫次數已用完
						I2Cok<='1';	--完成
						I2CS<='1';	--失敗
					end if;
				else
					PN<=PN-1;		--暫停時間倒數
				end if;

	--	RW='0':Byte Write or Page Write to EEPROM and check Write ok
			elsif RW='0' then	--寫作業
				if D_W_R_Nok='1' then			--等待
					D_W_R_Nok<=not reWR;		--繼續下一筆寫入
					Wdata(10 downto 3)<=DATAin;	--下一筆載入
				elsif reWR='1' then				--等待繼續
					null;
				elsif WN=WNend then 			--WNend結束點(正常時為0,MAXII_V erase非零)
					SDAs<='1';					--Stop
					I2CoK<=not I2CoKs;			--寫入完成?
					I2CoKs<='0';				--測寫入完成ack='0'?
					WNend<=18;					--測寫入完成WNend=18
					Wdata(19)<='0';				--造一個stop bit
					WN<=29;						--寫入如未完成,則換詢問是否完成?
					I<=0;						--回0相位
				else
					I<=I+1;			--下一相位
					case I is
						when 0 =>	--0相位
							SDAs<=Wdata(WN);--位元輸出
						when 1 =>	--1相位
							SCLs<='1';		--SCK拉高
							WN<=WN-1;		--下一bit
							if WN=20 or WN=11 or WN=2 then	--測ACK點
								if I2CoKs='1' then	--ACK載入
									I2Creset<=SDA;	--讀EEPROM發出的ACK(低態:正常,高態:錯誤)
								else
									I2CoKs<=SDA;	--測寫入完成ack='0'?
								end If;
							end If;
						when oThers =>--2相位
							SCLs<='0';	--SCK下拉
							I<=0;		--回0相位
							if D_W_R_Ns/=1 and WN=1 then--Page write
								D_W_R_Nok<='1';			--通知上層再給下一筆寫入資料
								D_W_R_Ns<=D_W_R_Ns-1;	--筆數減1
								WN<=10;					--新執行點
							end if;
					end case;
				end if;
				
	--	RW='1':Random Read EEPROM or squential read
	-- current or Random address
			else
				if D_W_R_Nok='1' then	--等待
					D_W_R_Nok<=not reWR;
				elsif reWR='1' then		--等待繼續
					null;
				elsIf RN=0 then			
					SDAs<='1';			--Stop
					I2CoK<='1';			--完成
				else
					I<=I+1;				--下一相位
					case I is
						when 0 =>--0相位
							SDAs<=Rdata(RN);--位元輸出
						when 1 =>--1相位
							SCLs<='1';	--SCK拉高
							RN<=RN-1;	--下一bit
							if RN=31 or RN=22 or RN=11 then	--測ACK點
								I2Creset<=SDA;		--讀EEPROM發出的ACK(低態:正常,高態:錯誤)	
							end if;
							if RN<11 and RN>2 then	--讀入bit
								DATAout<=DATAout(6 downto 0) & SDA;--讀EEPROM發出資料位元
							end if;
							if RN=21 then	--restart
								I<=0;		--回0相位
							end if;
						when others =>--2相位
							SCLs<='0';	--SCK下拉
							I<=0;		--回0相位
							if D_W_R_Ns/=1 then	--連續讀取D_W_R_Ns次
								Rdata(2)<='0';	--回0:acknowledge
								if RN=1 then	--結束點
									D_W_R_Nok<='1';--通知上層取走讀出資料
									D_W_R_Ns<=D_W_R_Ns-1;--筆數減1
									RN<=10;	--新執行點
								end if;
							else
								Rdata(2)<='1';	--回1:not acknowledge
							end if;
					end case;
				end if;
			end if;
		end if;
	end if;
end process;

--------------------------------------------------------------
end YHGL;