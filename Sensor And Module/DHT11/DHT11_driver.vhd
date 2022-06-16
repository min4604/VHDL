--DHT11_driver
--Data format:
--DHT11_DBo(std_logic_vector:8bit):由DHT11_RDp選取輸出項
--RDp=5:chK_SUM
--RDp=4							   3							   2								1								  0					
--The 8bit humidity integer data + 8bit the Humidity decimal data +8 bit temperature integer data + 8bit fractional temperature data +8 bit parity bit.
--直接輸出濕度(DHT11_DBoH)及溫度(DHT11_DBoT):integer(0~255:8bit)
--七段顯示器採用共陰-共陽互補掃瞄顯示
--105.11.03
--creator by YHGL
Library IEEE;
	Use IEEE.std_logic_1164.all;
	Use IEEE.std_logic_unsigned.all;
-- ----------------------------------------------------
Entity DHT11_driver is
	port(DHT11_CLK,DHT11_RESET:in std_logic;		--DHT11_CLK:781250Hz(50MHz/2^6:1.28us:FD(5))操作速率,重置
		 DHT11_D_io:inout std_logic;				--DHT11 i/o
		 DHT11_DBo:out std_logic_vector(7 downto 0);--DHT11_driver 資料輸出
		 DHT11_RDp:in integer range 0 to 7;			--資料讀取指標
		 DHT11_tryN:in integer range 0 to 7;		--錯誤後嘗試幾次
		 DHT11_ok,DHT11_S:buffer std_logic;			--DHT11_driver完成作業旗標,錯誤信息
		 DHT11_DBoH,DHT11_DBoT:buffer integer range 0 to 255;--直接輸出濕度及溫度
		 DHT11_DBoH_8bit,DHT11_DBoT_8bit:buffer std_logic_vector(7 downto 0);
		 DHT11_DBoH1,DHT11_DBoH0,DHT11_DBoT1,DHT11_DBoT0:out integer range 0 to 9);--直接輸出濕度及溫度
end DHT11_driver;
-- -----------------------------------------------------
architecture YHGL of DHT11_driver is
	signal S_B,bit01,response:std_logic;				--start bit,接收位元
	signal ss:std_logic_vector(1 downto 0);	--執行狀態
	signal isdata:integer range 0 to 3;		--資料狀態
	signal dp,d8:integer range 0 to 7;		--資料位元操作指標
	signal dbit:std_logic_vector(6 downto 0);--byte
	signal chK_SUM:std_logic_vector(7 downto 0);
	type DDataT is array(0 to 4) of std_logic_vector(7 downto 0);
	signal dd:DDataT;
	signal tryNN:integer range 0 to 7;				--錯誤後嘗試幾次
	signal Timeout:std_logic_vector(21 downto 0);	--timeout計時器
	signal tryDelay:integer range 0 to 31;
begin
DHT11_DBoH_8bit<=dd(4);
DHT11_DBoT_8bit<=dd(2);
DHT11_DBoH<=conv_integer(dd(4));--直接輸出濕度(integer)
DHT11_DBoT<=conv_integer(dd(2));--直接輸出溫度(integer)
--轉BCD碼直接輸出
DHT11_DBoH1<=DHT11_DBoH/10;
DHT11_DBoH0<=DHT11_DBoH mod 10;
DHT11_DBoT1<=DHT11_DBoT/10;
DHT11_DBoT0<=DHT11_DBoT mod 10;

--DHT11_DBo由DHT11_RDp選取輸出項
DHT11_DBo<=dd(DHT11_RDp) when DHT11_RDp<5 else
		   chK_SUM 		 when DHT11_RDp=5 else (others=>'1');	--上傳資料

DHT11_D_io<='Z' when DHT11_RESET='0' or S_B='1' else '0';	--DHT11 data io 操作

DHT11:process(DHT11_CLK,DHT11_RESET)
begin
	if DHT11_RESET='0' then
		S_B<='0';				--start bit
		dp<=4;					--讀取5byte
		d8<=7;					--讀取8bit
		isdata<=2;				--資料狀態
		DHT11_ok<='0';			--未完成作業
		DHT11_S<='0';			--解除作業失敗
		tryNN<=DHT11_tryN;		--錯誤後嘗試幾次
		ss<="00";				--執行狀態由1開始
		Timeout<=(others=>'0');	--timeout計時器歸零
		tryDelay<=14;			--11:約2.5ms,12:約5ms,13:約10ms,14:約21ms>18ms,15:約42ms>18ms
	elsif Rising_Edge(DHT11_CLK) and DHT11_ok='0' then
		Timeout<=Timeout+1;
		case ss is
			----------------------------------------------------------
			--restart or Send request
			when "00"=>	--重啟 (restart:D_io->'Z')or(start bit:D_io->'0')
				if Timeout(tryDelay)='1' then	--start bit (最好能在2ms以上較穩定) Request DHT11  15
					tryDelay<=11;	--11:約2.5ms,12:約5ms,13:約10ms,14:約21ms>18ms,15:約42ms>18ms
					S_B<=not S_B;
					Timeout<=(others=>'0');
					ss<="0" & not S_B;		--執行狀態下一步
					chK_SUM<=(others=>'0'); --查和歸零
					response<='0';
				end if;

			----------------------------------------------------------
			--(Read response)
			--(Read each data segment and save it to a buffer)
			--end all stages

			--wait DHT11 Response pull low
			when "01"=>
				if DHT11_D_io='0' then
					Timeout<=(others=>'0');
					if isdata=0 then	--reciver bit
						d8<=d8-1;
						if d8=0 then	--已收到8bit
							dp<=dp-1;
							dd(dp)<=dbit & bit01;
							if dp<4 then
								chK_SUM<=chK_SUM+dd(dp+1); --計算查和
							end if;
							ss<="10";		--執行狀態下一步pull high
						else
							dbit<=dbit(5 downto 0) & bit01;
							ss<="10";		--執行狀態下一步pull high
						end if;
					else
						isdata<=isdata-1;
						ss<="10";			--執行狀態下一步pull high
					end if;
				elsif Timeout=38 then		--約49us
					bit01<='1';				--接收位元0-->1
					--約Response(error)21ms>11~13ms	or DHT11 No data Response(error) --約164us
				elsif (Timeout(14)='1'and response='0')or(Timeout(7)='1'and response='1')  then
					ss<="11";				--執行狀態下一步(錯誤處理)
				end if;		

			--wait DHT11 Response pull high
			when "10"=>
				if DHT11_D_io='1' then
					Timeout<=(others=>'0');
					bit01<='0';				--接收位元預設0
					if dp=7 then --(已讀取40bit)stop bit
						if chK_SUM=dd(0) then
							DHT11_ok<='1';	--作業已正確完成
						else
							ss<="11";		--執行狀態下一步(錯誤處理)
						end if;
					else
						ss<="01";			--執行狀態下一步
					end if;
				elsif Timeout(7)='1' then	--DHT11 No Response(error) 7
					ss<="11";				--執行狀態下一步(錯誤處理) --約164us
				end if;

			----------------------------------------------------------
			--"11"錯誤處理
			when oThers=>					--"11"錯誤處理
				if tryNN/=0 then
					tryNN<=tryNN-1;
					Timeout<=(others=>'0');
					dp<=4;
					d8<=7;
					isdata<=2;
					tryDelay<=20;			--約暫停1.4s
					ss<="00";				--restart
				else
					DHT11_ok<='1';			--作業已完成
					DHT11_S<='1';			--作業失敗
				end if;
		end case;
	end if;
end process DHT11;
--------------------------------------------
end YHGL;