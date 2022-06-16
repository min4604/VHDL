library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity key4_4 is
port( reset, clk : in std_logic;
	  ROW:in std_logic_vector(3 downto 0);
	  COL:out std_logic_vector(3 downto 0);
	  vail :out std_logic;
	  fre  :out std_logic;
	  bt_dt_out:out std_logic_vector(3 downto 0) );
end key4_4;

architecture a of key4_4 is
signal scan_clk :std_logic;
signal  div     :std_logic_vector(22 downto 1);
signal scan_code:std_logic_vector(3 downto 0);
signal Zero :std_logic_vector(2 downto 0);
signal One  :std_logic_vector(2 downto 0);
signal Press:std_logic;  --除彈跳前
signal Vaild:std_logic;  --除彈跳後
signal Free :std_logic;  --按鍵放開'1'
signal Bcdall  :std_logic_vector(15 downto 0);
signal bcd:std_logic_vector(3 downto 0);
signal bcd_out:std_logic_vector(3 downto 0);

begin
	process( clk,reset)
	begin 
		if reset ='0' then
			Div <="0000000000000000000000";
		elsif clk'event and clk ='1' then
			Div <=Div +1;
		end if;
	end process;
	scan_clk <=Div(18);
	
	--鍵盤掃描
	process(scan_clk)
	begin
		case scan_code(3 downto 2) is
			when "00" => COL <="1110";
			when "01" => COL <="1101";
			when "10" => COL <="1011";
			when "11" => COL <="0111";
			when others => null;
		end case;
		case scan_code(1 downto 0) is
			when "00" => Press <=ROW(0);
			when "01" => Press <=ROW(1);
			when "10" => Press <=ROW(2);
			when "11" => Press <=ROW(3);
			when others => null;
		end case;
		
		if reset ='0' then
			Zero <="000";
			One <="000";
			Vaild <='1';
		elsif scan_clk'event and scan_clk ='1' then
			if press ='1' then
				scan_code <=scan_code+1;
				Zero <="000";
				One <= One +1;
			elsif press ='0' then
				Zero <=Zero+1;
				One <="000";
			end if;
			
			if Zero ="101" and free ='1' then
				vaild <='0';
				free <='0';
			else
				vaild <='1';
			end if;
			
			if One ="101" then
				free <='1';
				Zero <="000";
			end if;
		end if;
	end process;
	vail<=vaild;
	fre<=free;
	bt_dt_out<=scan_code;

end a;