library ieee;
use ieee.std_logic_1164.all;


entity DMUX is
port(	D	: in  std_logic;
		S	: in  std_logic_vector(2 downto 0);
		Y	: out std_logic_vector(7 downto 0)
	);
end DMUX;

architecture DMUX1_8 of DMUX is
begin
	with S select
	Y<=	(0=>D,others=>'0') when "000",
		(1=>D,others=>'0') when "001",
		(2=>D,others=>'0') when "010",
		(3=>D,others=>'0') when "011",
		(4=>D,others=>'0') when "100",
		(5=>D,others=>'0') when "101",	
		(6=>D,others=>'0') when "110",
		(7=>D,others=>'0') when "111";
end DMUX1_8;
