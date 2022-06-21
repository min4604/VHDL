library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity bin8toseg7 is
port(clk ,reset: in std_logic;
	 indate : in std_logic_vector(7 downto 0);
	 seg7 :out std_logic_vector(6 downto 0 );
	 COL    : out std_logic_vector(3 downto 0);
	 busy   :buffer std_logic );
end bin8toseg7;


architecture a of bin8toseg7 is
signal N : integer range 0 to 15 :=7;
signal bcd_out :std_logic_vector(3 downto 0);
signal bcdall :std_logic_vector(15 downto 0);

signal div :std_logic_vector(23 downto 1);
signal COL_clk:std_logic;
signal run_clk:std_logic;
signal r : std_logic_vector(1 downto 0);
begin

	process(clk,reset)
	begin
		if reset ='0' then
			div <="00000000000000000000000";
		elsif clk'event and clk ='1' then
			div<=div+1;
		end if;
	end process;
	COL_clk <=div(17);
	run_clk <=div(1);
	process(run_clk,reset)
	begin
		if reset ='0' then
			N<=7;
		elsif run_clk'event and run_clk ='1' then 
			if N>=0 and N<=7 then 
				N <= N-1;
				busy<='1';
			 else 
				N<= 15;
				busy<='0';
			end if;
		end if;
	end process;
	 conv_std_logic_vector()
	 conv_integer;
	process(run_clk,reset)
	variable bcd :std_logic_vector(15 downto 0);
	begin
		if reset ='0' then
			bcd :="0000000000000000";
			bcdall<="0000000000000000";
		elsif run_clk'event and run_clk ='1' then
			
			if N>=0 and N<=7 then 
				
				
				
				if bcd(15 downto 12) > 4 then
					bcd(15 downto 12) := bcd(15 downto 12) +3;
				end if;
				
				if bcd(11 downto 8) > 4 then
					bcd(11 downto 8) := bcd(11 downto 8) +3;
				end if;
				
				if bcd(7 downto 4) > 4 then
					bcd(7 downto 4) := bcd(7 downto 4) +3;
				end if;
				
				if bcd(3 downto 0) > 4 then
					bcd(3 downto 0) := bcd(3 downto 0) +3;
				end if;
				bcd := bcd(14 downto 0) & '0';
				bcd(0) := indate(N);
			else
				bcd:=bcd;
			end if;
			 
		end if;
	bcdall<=bcd;
	end process;
	
	process(COL_clk)
	begin
		if reset ='0'then
			r<="00";
		elsif COL_clk'event and COL_clk ='1' then
			r<=r+1;
		end if;
	end process;
	
	with r select
		COL <= "0111" when "00",
			   "1011" when "01",
			   "1101" when "10",
			   "1110" when "11",
			   "1111" when others;
	with r select
		bcd_out <= bcdall(15 downto 12) when "00",
				   bcdall(11 downto 8) when "01",
			       bcdall(7 downto 4) when "10",
			       bcdall(3 downto 0) when "11",
			        "0000"  when others;
	with bcd_out select
		seg7<=  "1111110" when "0000",
				"0110000" when "0001",
				"1101101" when "0010",
				"1111001" when "0011",
				"0110011" when "0100",
				"1011011" when "0101",
				"1011111" when "0110",
				"1110000" when "0111",
				"1111111" when "1000",
				"1111011" when "1001",
				"1111111" when others;
	
end a;