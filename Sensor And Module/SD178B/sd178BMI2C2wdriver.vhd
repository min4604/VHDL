--sd178BMI2C2wdriver
--此driver只適用於SD178BMI2C模組
--Creator by YHGL 107.07.xx

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;

--------------------------------------------------------------------------
entity sd178BMI2C2wdriver is
   port(  I2CCLK,RESET:in std_logic;				--系統時脈,系統重置
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
end sd178BMI2C2wdriver;

--單筆操作:D_W_R_N=1
--多筆操作:由D_W_R_N指定,每完成1筆回D_W_R_Nok,收到reWR後再進行下一筆

--------------------------------------------------------------------------
architecture YHGL of sd178BMI2C2wdriver is
	signal Wdata:std_logic_vector(20 downto 0);	--寫命令表
	signal Rdata:std_logic_vector(31 downto 0);	--讀命令表
	signal I2Creset,SCLs,SDAs:std_logic;		--失敗,SCL,SDA
	signal I:integer range 0 to 2;		 		--相位指標
	signal WN,WNs,WNend:integer range 0 to 20;	--寫命令指標
	signal RN,RNs:integer range 0 to 31;		--讀命令指標
	signal PN:integer range 0 to 29;			--錯誤暫停時間
	signal RWNS:integer range 0 to 15;			--嘗試讀寫次數計數器
	signal D_W_R_Ns:integer range 0 to 255;		--多筆操作
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
		if D_W_R_N=1 and DATAin=0 then
			--Byte  Write  由睡眠省電模式喚醒SD178BM-I2C
			--      S  裝置碼 /寫    S  寫入資料     ack    P
			Wdata<='0' & ID & '0' & '0' & ID & '0' & '1' & "00";	--(0)沒用到,結束碼
			--page write:D_W_R_Ns>1,WN再從10起,下一筆放入Wdata(10 downto 3)<=DATAin;
			WN<=11;		--設寫入執行點
			WNs<=11;
		else
			--Byte  Write
			--      S  裝置碼 /寫   ack  寫入資料  ack    P
			Wdata<='0' & ID & '0' & '1' & DATAin & '1' & "00";	--(0)沒用到,結束碼
			--page write:D_W_R_Ns>1,WN再從10起,下一筆放入Wdata(10 downto 3)<=DATAin;
			WN<=20;		--設寫入執行點
			WNs<=20;
		end if;	
			
		--Random Read:
		--      S  裝置碼 /寫   ack 
		Rdata<='0' & ID & '0' & '1' & 
		--		Sr	裝置碼 讀    ack    讀出資料  		   P
			   "10" & ID & '1' & '1' & "11111111" & '1' & "00";				--(0)沒用到,結束碼
		--																	ack(0,1)
		
		--	如還有下一筆(D_W_R_Ns/=1)且Rn=2時須回ack0(acknowledge), Rn再從10開始
		--	如已最後一筆(D_W_R_Ns=1)時,則回ack1 (not acknowledge)
		
		I<=0;		--設0相位
		WNend<=0;	--設寫入終點
		RN<=31;		--設讀取執行點
		RNs<=31;	--設讀取錯誤覆回復執行點
		
		PN<=29;		--錯誤暫停時間
		I2CoK<='0';	--設未完成旗標
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
				I<=0;RN<=RNs;WN<=WNs;--錯誤回復執行點
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
					--stop bit
					if PN=29 then
						SDAs<='0';
					else
						SDAs<='1';	--stop bit
					end if;
				end if;
	-- Write
	-- RW='0':Byte Write or Page Write
			elsif RW='0' then	--寫作業
				if D_W_R_Nok='1' then			--等待
					D_W_R_Nok<=not reWR;		--繼續下一筆寫入
					Wdata(10 downto 3)<=DATAin;	--下一筆載入
				elsif reWR='1' then				--等待繼續
					null;
				elsif WN=WNend then 			--WNend結束點(正常時為0,MAXII_V erase非零)
					SDAs<='1';					--Stop bit
					I2CoK<='1';					--寫入完成?
				else
					I<=I+1;			--下一相位
					case I is
						when 0 =>	--0相位
							SDAs<=Wdata(WN);--位元輸出
						when 1 =>	--1相位
							SCLs<='1';		--SCK拉高
							WN<=WN-1;		--下一bit
							if WN=11 or WN=2 then	--測ACK點
								I2Creset<=SDA;	--讀裝置發出的ACK(低態:正常,高態:錯誤)
							end If;
						when oThers =>--2相位
							SCLs<='0';	--SCK下拉
							I<=0;		--回0相位
							if D_W_R_Ns>1 and WN=1 then--Page write
								D_W_R_Nok<='1';			--通知上層再給下一筆寫入資料
								D_W_R_Ns<=D_W_R_Ns-1;	--筆數減1
								WN<=10;					--新執行點
							end if;
					end case;
				end if;
	--Read			
	--RW='1':squential read
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
							if RN=22 or RN=11 then	--測ACK點
								I2Creset<=SDA;		--讀裝置發出的ACK(低態:正常,高態:錯誤)	
							end if;
							if RN<11 and RN>2 then	--讀入bit
								DATAout<=DATAout(6 downto 0) & SDA;--讀裝置發出資料位元
							end if;
							if RN=21 then	--restart
								I<=0;		--回0相位
							end if;
						when others =>--2相位
							SCLs<='0';	--SCK下拉
							I<=0;		--回0相位
							if D_W_R_Ns>1 then	--連續讀取D_W_R_Ns次
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