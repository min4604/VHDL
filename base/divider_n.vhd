library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity divider_n is
--除N計數器
--Clk_in=50MHZ
--Clk_out=250HZ
generic(N:integer:=10000000);--Clk_in/Clk_out=N
port
(Clk_50M       :in std_logic;
 Clk_out       :out std_logic);
end divider_n;

architecture ARCH of divider_n is
signal cnt2:std_logic;
begin
	process(Clk_50M)
		variable cnt1:integer range 0 to N:=1;
		variable N2:integer range 0 to N; 
	begin
		N2:=N/2;
		if rising_edge(Clk_50M) then
			if cnt1=N then
				cnt1:=1;
			else
				cnt1:=cnt1+1;
			end if;
		end if;
		if rising_edge(Clk_50M)then
			if cnt1=N2 or cnt1=N then
				cnt2<=not cnt2;
			end if;
		end if;
		Clk_out<=cnt2;
	end process;
end ARCH;