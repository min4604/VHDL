-------------------------------------------------------------------
--檔案名稱：br_gen.vhd
--功    能：鮑率產生器
--日    期：2003.8.8
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

entity br_gen is
  generic(divisor: integer := 3); --if sysclk=1.8432M then divisor=3
port(
     sysclk:in std_logic;                    --system clock
     sel   :in std_logic_vector(2 downto 0); --baud rate select
     bclkx8:buffer std_logic;                --baud rate X 8
     bclk  :out std_logic                    --baud rate
    );
end br_gen;

architecture arch of br_gen is
  signal cnt2,clkdiv: std_logic;
  signal ctr1: std_logic_vector (7 downto 0):= "00000000";
  signal ctr2: std_logic_vector (2 downto 0):= "000";
begin
  ----- clk divider -----
  process (sysclk)
    variable cnt1     : integer range 0 to divisor;
    variable divisor2 : integer range 0 to divisor;
  begin
    divisor2 := divisor/2;
    if (sysclk'event and sysclk='1') then
      if cnt1=divisor then
        cnt1 := 1;
      else
        cnt1 := cnt1 + 1;
      end if;	
    end if;
    if (sysclk'event and sysclk='1') then
      if (( cnt1=divisor2) or (cnt1=divisor)) then	
        cnt2 <= not cnt2;
      end if;
    end if;
  end process;
  clkdiv<=  cnt2 ;
  ----- 8 bits counter -----
  process (clkdiv)	
  begin
    if(rising_edge(clkdiv)) then
      ctr1 <= ctr1+1;
    end if;
  end process;
  ----- MUX -----
  bclkx8<=ctr1(CONV_INTEGER(sel));
  ----- clkdiv8 -----
  process (bclkx8)
  begin
    if(rising_edge(bclkx8)) then
      ctr2 <= ctr2+1;
    end if;
  end process;
  bclk <= ctr2(2);    
end arch;
