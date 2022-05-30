library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SR_application is
port(	button 		:in  std_logic_vector(2 downto 0);
		sw 	   		:in  std_logic;
		seg1,seg2	:out std_logic_vector(7 downto 0); --seg1 LSB seg2 MSB
		LED			:out std_logic
	);
end SR_application;

architecture a of SR_application is

component SR_byNAND
port(	S,R,En:in std_logic;
		Q:buffer std_logic
	);
end component;

component seg7
port(	bcd : in  std_logic_vector(3 downto 0);
			RBI : in  std_logic;
			RBO : out std_logic;
			seg : out std_logic_vector(7 downto 0)
		);
end component;

signal conter_Lsb,conter_Msb:std_logic_vector(3 downto 0):="0000";
signal Q:std_logic;

begin
	SR1:SR_byNAND port map(button(2),button(1),sw,Q);
	LED<=Q;
	process(Q)
	begin
		if (sw and button(0))='0' then
			conter_Lsb<=(others=>'0');
			conter_Msb<=(others=>'0');
		elsif Q'event and Q='1' then
			if conter_Lsb="1001" then
				conter_Lsb<=(others=>'0');
				if conter_Msb ="1001" then
					conter_Msb<=(others=>'0');
				else
					conter_Msb<=conter_Msb+1;
				end if;
			else
				conter_Lsb<=conter_Lsb+1;
			end if;
		end if;
	end process;
	segA:seg7 port map( bcd=>conter_Lsb,
						RBI=>'1',
						seg=>seg1);
	segB:seg7 port map( bcd=>conter_Msb,
						RBI=>'0',
						seg=>seg2);
	
	
end a;