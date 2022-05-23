library ieee;

use ieee.std_logic_1164.all;

entity halfadder is
port(a,b :in std_logic;
	 s,c :out std_logic);
end halfadder;

architecture a of halfadder is
begin
	s<= a xor b;
	c<= a and b;
end a;

library ieee;

use ieee.std_logic_1164.all;

entity or_2 is
port(a,b :in std_logic;
	 c :out std_logic);
end or_2;

architecture a of or_2 is
begin
	
	c<= a or b;
end a;








library ieee;
use ieee.std_logic_1164.all;

entity FA_1bit is
port(x,y,z :in std_logic;
	 sum ,carry : out std_logic );
end FA_1bit;


architecture a of FA_1bit is
component halfadder
port( a,b : in std_logic;
	  s,c : out std_logic );
end component;

component or_2
port( a,b : in std_logic;
	  c : out std_logic );
end component;

signal s1,s2,s3 :std_logic;

begin
	u1 :halfadder port map(x,y,s1,s3);
	u2 :halfadder port map(s1,z,sum,s2);
	u3 :or_2      port map(s2,s3,carry);
end a;