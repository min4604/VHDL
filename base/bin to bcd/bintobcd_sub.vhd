library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bintobcd_sub is
port( clk     : in std_logic;
	  start   : in std_logic;
	  bin_in  : in std_logic_vector(7 downto 0);
	  bcd_out : buffer std_logic_vector(11 downto 0);
	  busy    : buffer std_logic );
end bintobcd_sub;

architecture beh of bintobcd_sub is
begin 
	process(clk)
	variable bin :std_logic_vector(7 downto 0);
	begin 
		if(clk'event and clk ='1') then
			if start ='1' and busy ='0' then
				bin := bin_in;
				bcd_out <="000000000000";
				busy <='1';
			elsif busy ='1' then
				if(bin>=200) then
					bin :=bin-200;
					bcd_out(11 downto 8) <=bcd_out(11 downto 8) +2;
				elsif (bin>=100) then
					bin :=bin-100;
					bcd_out(11 downto 8) <=bcd_out(11 downto 8) +1;
				elsif (bin>=50) then
					bin :=bin-50;
					bcd_out(7 downto 4) <=bcd_out(7 downto 4) +5;
				elsif (bin>=10) then
					bin :=bin-10;
					bcd_out(7 downto 4) <=bcd_out(7 downto 4) +1;
				else
					bcd_out(3 downto 0) <=bin(3 downto 0);
					busy <='0';
				end if;
			end if;
		end if;
	end process;
end beh;