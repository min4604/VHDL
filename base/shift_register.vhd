library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity shift_register is
port ( 	clk_50M	:in  std_logic;
		sw		:in  std_logic_vector(9 downto 0 );
		bt		:in  std_logic_vector(1 downto 0);
		LED		:out std_logic_vector(9 downto 0)
		
		);
end shift_register;

architecture a of shift_register is
signal dt:std_logic_vector(9 downto 0);

signal DF:std_logic_vector(20 downto 1);
begin
	process(clk_50M)
	begin
		if clk_50M'event and clk_50M ='1' then
			DF<=DF+1;
		end if;
	end process;

	process(DF(20),bt)
	begin
		if DF(20)'event and DF(20) ='1' then
			case bt is
				when "00" =>
					dt<=sw;
				when "01" =>
					dt<=dt(8 downto 0)&'0';
				when "10" =>
					dt<='0'&dt(9 downto 1);
				when "11" =>
					null;
			end case;
		end if;
	end process;
	LED<=dt;
	
end a;