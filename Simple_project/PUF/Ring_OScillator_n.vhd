library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Ring_OScillator_n is
generic(n:integer :=31);--N階環形震盪
port( 	EN 		: in 	std_logic;
		ck_out	: out  	std_logic

	);
end Ring_OScillator_n;

architecture Ring_OScillator of Ring_OScillator_n is
signal chain : std_logic_vector(n-1 downto 0);
attribute syn_keep: boolean;
attribute syn_keep of chain: signal is true;
begin
	genchain:
	for i in 1 to (n-1) generate
	  chain(i) <= not chain(i-1);
	end generate;
	chain(0)<= en and (not chain(n-1));
	ck_out<=chain(n-1);
end Ring_OScillator;
