library ieee;
use ieee.std_logic_1164.all;

entity seg7 is
	port(	bcd : in  std_logic_vector(3 downto 0);
			RBI : in  std_logic;
			RBO : out std_logic;
			seg : out std_logic_vector(7 downto 0)
		);
end seg7;

architecture a of seg7 is

begin
	seg<= 	"00000011" when (bcd = "0000")and RBI ='1' else
			"10011111" when bcd="0001" else
			"00100101" when bcd="0010" else
			"00001101" when bcd="0011" else
			"10011001" when bcd="0100" else
			"01001001" when bcd="0101" else
			"01000001" when bcd="0110" else
			"00011111" when bcd="0111" else
			"00000001" when bcd="1000" else
			"00001001" when bcd="1001" else
			"11111111" ;
	RBO<= '0' when (RBI='0' and bcd ="0000") else
		  '1' ;
end a;