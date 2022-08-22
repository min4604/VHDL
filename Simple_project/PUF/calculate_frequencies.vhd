library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity calculate_frequencies is
port( 	res 	: in  std_logic;
		clk_1Hz : in  std_logic;
		clk_nHz	: in  std_logic;
		nHz 	: out std_logic_vector(63 downto 0)

	);
end calculate_frequencies;

architecture a of calculate_frequencies is

signal counter,counter_buf:std_logic_vector(63 downto 0);
signal flag : std_logic;

begin
	process(clk_1Hz)
	begin
		if res ='0' then
			flag <='0';
		elsif clk_1Hz'event and clk_1Hz ='1' then
			flag <= not flag;
		end if;
	end process;
	
	process(flag,clk_nHz)
	begin
		if res ='0' then
			counter<=(others=>'0');
			counter_buf<=(others=>'0');
		elsif flag ='0' then
			counter<=(others=>'0');
			nHz<=counter_buf;
		elsif clk_nHz'event and clk_nHz ='1' then
			counter<=counter+1;
			counter_buf<=counter;
		end if;
	end process;
			
	
end a;
