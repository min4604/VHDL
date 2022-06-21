library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity bintobcd is
port(clk ,reset: in std_logic;
	 --indate : in std_logic_vector(9 downto 0);
	 ck:out std_logic;
	 outdate :out std_logic_vector(15 downto 0 ) );
end bintobcd;


architecture a of bintobcd is
signal N : integer range 0 to 15 :=9;
signal indate :std_logic_vector(9 downto 0):="1001001101";
--signal bcd1 :std_logic_vector(15 downto 0);
begin
	process(clk,reset)
	
	begin
		if reset ='0' then
			N<=9;
		elsif clk'event and clk ='1' then 
			if N>=0 and N<=9 then 
				N <= N-1;
				
			 else 
				N<= 15;
			end if;
		end if;
	end process;
	
	process(clk,reset)
	variable bcd :std_logic_vector(15 downto 0);
	begin
		if reset ='0' then
			
			bcd:="0000000000000000";
		elsif clk'event and clk ='1' then
			if N>=0 and N<=9 then 
				
				
				
				if bcd(15 downto 12) > 4 then
					bcd(15 downto 12) := bcd(15 downto 12) +3;
				else
					--bcd(15 downto 12) <= bcd(15 downto 12);
				end if;
				
				if bcd(11 downto 8) > 4 then
					bcd(11 downto 8) := bcd(11 downto 8) +3;
				else
					--bcd(11 downto 8) <= bcd(11 downto 8);
				end if;
				
				if bcd(7 downto 4) > 4 then
					bcd(7 downto 4) := bcd(7 downto 4) +3;
				else
					--bcd(7 downto 4) <= bcd(7 downto 4);
				end if;
				
				if bcd(3 downto 0) > 4 then
					bcd(3 downto 0) := bcd(3 downto 0) +3;
				else
					--bcd(3 downto 0) <= bcd(3 downto 0);
				end if;
				bcd := bcd(14 downto 0) & '0';
				bcd(0) := indate(N);
			else 
				--bcd <= bcd;
			end if;
			
			outdate <= bcd ;
		end if;
	    ck<=clk;
	end process;
end a;