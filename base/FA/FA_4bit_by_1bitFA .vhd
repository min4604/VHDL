library ieee;
use ieee.std_logic_1164.all;
entity FA is
port(	a, b, c_in : in STD_LOGIC;
		c_out, sum : out STD_LOGIC);
end FA;

architecture FA_1bit of FA is
begin
c_out <=((a xor b) and c_in) or (a and b);
sum <= (a xor b) xor c_in;
end FA_1bit;


library ieee ;
use ieee.std_logic_1164.all;

entity FA_4bit_by_1bitFA is
port(	A,B :in  std_logic_vector(3 downto 0);
		LED :out std_logic_vector(4 downto 0)
	);
end FA_4bit_by_1bitFA ;

architecture FAdd of FA_4bit_by_1bitFA is

component FA 
port(	a, b, c_in : in STD_LOGIC;
		c_out, sum : out STD_LOGIC);
end component;
signal c:std_logic_vector(4 downto 0):="00000";
signal A1,B1,sum:std_logic_vector(4 downto 1);
begin
	A1<=A;
	B1<=B;
	adders:
	for i in 1 to 4 generate
		adder:FA port map(A1(i),B1(i),c(i-1),c(i),sum(i));
	end generate adders;
	led(3 downto 0)<=sum;
	LED(4)<=c(4);
end FAdd;