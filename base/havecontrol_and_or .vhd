library ieee;
use ieee.std_logic_1164.all;

entity havecontrol_and_or is
port(	A: IN BIT_VECTOR(1 downto 0);
		C: IN BIT;
		X: OUT BIT;
		Y: OUT BIT);
end havecontrol_and_or ;

architecture a of havecontrol_and_or  is

begin
	X <= A(1) and A(0) and (not C);
	Y <= (A(1) or A(0)) and (not C);
end a;
