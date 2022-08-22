library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MUX8_1 is
  port (
    I0,I1,I2,I3,I4,I5,I6,I7    	: in  std_logic;
    S    						: in  std_logic_vector(2 downto 0);
    F 							: out std_logic);
end entity MUX8_1;

architecture a of MUX8_1 is
begin
  with S select
  F<= 	I0 when "000",
		I1 when "001",
		I2 when "010",
		I3 when "011",
		I4 when "100",
		I5 when "101",
		I6 when "110",
		I7 when "111";
end  a;