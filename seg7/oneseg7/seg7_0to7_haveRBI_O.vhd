library ieee;
use ieee.std_logic_1164.all;

entity seg7_0to7_haveRBI_O is
	port(	bcd : in  std_logic_vector(2 downto 0);
			RBI : in  std_logic;
			RBO : out std_logic;
			seg : out std_logic_vector(7 downto 0)
		);
end seg7_0to7_haveRBI_O;

architecture a of seg7_0to7_haveRBI_O is

begin
	seg<= 	"00000011" when (bcd = "000")and RBI ='1' else
			"10011111" when bcd="001" else
			"00100101" when bcd="010" else
			"00001101" when bcd="011" else
			"10011001" when bcd="100" else
			"01001001" when bcd="101" else
			"01000001" when bcd="110" else
			"00011111" when bcd="111" else
			"11111111" ;
	RBO<= '0' when (RBI='0' and bcd ="0000") else
		  '1' ;
end a;