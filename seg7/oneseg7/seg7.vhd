library ieee;
use ieee.std_logic_1164.all;

entity seg7 is
	port(	bcd : in  std_logic_vector(3 downto 0);
			dot : in  std_logic;
			RBI : in  std_logic;
			RBO : out std_logic;
			seg : out std_logic_vector(7 downto 0)
		);
end seg7;

architecture a of seg7 is

begin
	seg<= 	"0000001" & dot when (bcd = "0000")and RBI ='1' else
			"1001111" & dot when bcd="0001" else
			"0010010" & dot when bcd="0010" else
			"0000110" & dot when bcd="0011" else
			"1001100" & dot when bcd="0100" else
			"0100100" & dot when bcd="0101" else
			"0100000" & dot when bcd="0110" else
			"0001111" & dot when bcd="0111" else
			"0000000" & dot when bcd="1000" else
			"0000100" & dot when bcd="1001" else
			"1111111" & dot ;
	RBO<= '0' when (RBI='0' and bcd ="0000") else
		  '1' ;
end a;