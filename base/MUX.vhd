library ieee;
use ieee.std_logic_1164.all;

entity MUX is
port(	D	:in	 std_logic_vector(7 downto 0);
		S	:in  std_logic_vector(2 downto 0);
		Y	:out std_logic
	);
end MUX;

architecture MUX8_1 of MUX is
begin
	with S select
	Y<=	D(0) when "000",
		D(1) when "001",
		D(2) when "010",
		D(3) when "011",
		D(4) when "100",
		D(5) when "101",
		D(6) when "110",
		D(7) when "111";
end MUX8_1;

