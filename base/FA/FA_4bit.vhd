library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity FA_4bit is
port(	A,B :in  std_logic_vector(3 downto 0);
		LED :out std_logic_vector(4 downto 0)
	);
end FA_4bit;

architecture FA of FA_4bit is
begin
	LED<=('0'&A)+B;
end FA;