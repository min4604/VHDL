library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity PUF  is
port( 	clk_50M	: in	std_logic;
		res 	: in 	std_logic;
		sw 		: in 	std_logic_vector(2 downto 0);
		LED		: out	std_logic;
		Ring_OScillator_out: out std_logic_vector(1 downto 0)

	);
end PUF;

architecture a of PUF is

component Ring_OScillator_n
generic(n:integer :=31);--N?�環形�???
port( 	EN 		: in 	std_logic;
		ck_out	: out  	std_logic

	);
end component;

component MUX8_1
port (
    I0,I1,I2,I3,I4,I5,I6,I7    	: in  std_logic;
    S    						: in  std_logic_vector(2 downto 0);
    F 							: out std_logic);
end component;

component calculate_frequencies
port( 	res 	: in  std_logic;
		clk_1Hz : in  std_logic;
		clk_nHz	: in  std_logic;
		nHz 	: out std_logic_vector(63 downto 0)

	);
end component;

component comparator
generic (WIDTH : integer := 64);
port (
		val_a    : in  std_logic_vector(WIDTH-1 downto 0);
		val_b    : in  std_logic_vector(WIDTH-1 downto 0);
		solution : out std_logic
	);
end component;

component divider_n
generic(N:integer:=50000000);--Clk_in/Clk_out=N
port(	Clk_50M       :in std_logic;
		Clk_out       :out std_logic
	);
end component;

signal clk_Ring 	:std_logic_vector(7 downto 0);
signal nHz_a,nHz_b	:std_logic_Vector(63 downto 0);
signal clk_a,clk_b,clk_1Hz	:std_logic;
begin
	Ring_OScillator_out<=clk_Ring(0)&clk_Ring(7);
	divider_50000000	:divider_n
	generic	map(N=>50000000)
	port	map(clk_50M,clk_1Hz);

	Ring_OScillator_7		:Ring_OScillator_n
	generic	map(n=>7) 
	port	map(res,clk_Ring(0));
	
	Ring_OScillator_9		:Ring_OScillator_n
	generic	map(n=>9) 
	port	map(res,clk_Ring(1));
	
	Ring_OScillator_11		:Ring_OScillator_n
	generic	map(n=>11) 
	port	map(res,clk_Ring(2));
	
	Ring_OScillator_13		:Ring_OScillator_n
	generic	map(n=>13) 
	port	map(res,clk_Ring(3));
	
	Ring_OScillator_15		:Ring_OScillator_n
	generic	map(n=>15) 
	port	map(res,clk_Ring(4));
	
	Ring_OScillator_17		:Ring_OScillator_n
	generic	map(n=>17) 
	port	map(res,clk_Ring(5));
	
	Ring_OScillator_19		:Ring_OScillator_n
	generic	map(n=>19) 
	port	map(res,clk_Ring(6));
	
	Ring_OScillator_21		:Ring_OScillator_n
	generic	map(n=>21) 
	port	map(res,clk_Ring(7));
	--01010010
	MUX8_1_a				:MUX8_1
	port	map(clk_Ring(0),clk_Ring(2),clk_Ring(1),clk_Ring(7),clk_Ring(4),clk_Ring(5),clk_Ring(6),clk_Ring(3),sw,clk_a);
	
	MUX8_1_b				:MUX8_1
	port	map(clk_Ring(1),clk_Ring(0),clk_Ring(2),clk_Ring(3),clk_Ring(5),clk_Ring(6),clk_Ring(4),clk_Ring(7),sw,clk_b);
	
	calculate_frequencies_a	:calculate_frequencies
	port	map(res,clk_1Hz,clk_a,nHz_a);
	
	calculate_frequencies_b	:calculate_frequencies
	port	map(res,clk_1Hz,clk_b,nHz_b);
	
	comparator_1		:comparator
	generic	map(WIDTH=>64)
	port	map(nHz_a,nHz_b,Led);
end a;
