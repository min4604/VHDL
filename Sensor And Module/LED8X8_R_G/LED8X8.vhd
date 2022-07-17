library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity LED8X8 is
port( reset,clk,r :in std_logic;
	  pwm_in:in std_logic;
	  ROW :out std_logic_vector(7 downto 0);
	  COL :out std_logic_vector(7 downto 0));
end LED8X8;

architecture a of LED8X8 is
signal div :std_logic_vector(23 downto 1);
signal scan_clk:std_logic;
signal text_clk:std_logic;
signal li:integer range 0 to 7;
signal char0 :std_logic_vector(7 downto 0);
signal char1 :std_logic_vector(7 downto 0);
signal char2 :std_logic_vector(7 downto 0);
signal char3 :std_logic_vector(7 downto 0);
signal char4 :std_logic_vector(7 downto 0);
signal char5 :std_logic_vector(7 downto 0);
signal char6 :std_logic_vector(7 downto 0);
signal char7 :std_logic_vector(7 downto 0);
signal temp  :std_logic_vector(7 downto 0);
signal row_d :std_logic_vector(7 downto 0);
begin
	process(clk,reset)
	begin
		if reset ='0' then
			div<="00000000000000000000000";
		elsif clk'event and clk ='1' then
			div <= div +1;
		end if;
	end process;
	scan_clk <=div(16);
	text_clk <=div(23);
	process(scan_clk,reset)
	begin
		if reset ='0' then
			li <=0;
		elsif ( scan_clk'event and scan_clk ='1') and pwm_in='1' then
			if li =7 then
				li <=0;
			else
				li<=li+1;
			end if;
		end if;
	end process;
	
	process(text_clk,reset,r)
	begin
		if reset ='0' then
			char0 <="10111110";
			char1 <="01011101";
			char2 <="10111011";
			char3 <="11110111";
			char4 <="11101111";
			char5 <="11011101";
			char6 <="10111010";
			char7 <="01111101";
			
		elsif text_clk'event and text_clk ='1' then
			if r= '1' then
				--temp <=char0;
				--char0<=char1;
				--char1<=char2;
				--char2<=char3;
				--char3<=char4;
				--char4<=char5;
				--char5<=char6;
				--char6<=char7;
				--char7<=temp;
			else
				char0<=char0(0)& char0(7 downto 1) ;
				char1<=char1(0)& char1(7 downto 1) ;
				char2<=char2(0)& char2(7 downto 1) ;
				char3<=char3(0)& char3(7 downto 1) ;
				char4<=char4(0)& char4(7 downto 1) ;
				char5<=char5(0)& char5(7 downto 1) ;
				char6<=char6(0)& char6(7 downto 1) ;
				char7<=char7(0)& char7(7 downto 1) ;
			end if;
			
		end if;
	end process;
	
	with li select
		COL <= "10000000" when 0,
			   "01000000" when 1,
			   "00100000" when 2,
			   "00010000" when 3,
			   "00001000" when 4,
			   "00000100" when 5,
			   "00000010" when 6,
			   "00000001" when 7,
			   "11111111" when others;
			   
	with li  select
		ROW_d <= char0 when 0,
			     char1 when 1,
			     char2 when 2,
			     char3 when 3,
			     char4 when 4,
			     char5 when 5,
			     char6 when 6,
			     char7 when 7,
			     "11111111" when others;
	
end a;