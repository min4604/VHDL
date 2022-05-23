library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity and_not_or is
port(
	 A,B,C : in  std_logic;
	 D     : out std_logic;
	 E	   : buffer std_logic);
end and_not_or;

architecture a of and_not_or is
signal w1 :std_logic;
begin
	w1<=A and B;
	E <=not c;
	D <=w1 or E;
end a;