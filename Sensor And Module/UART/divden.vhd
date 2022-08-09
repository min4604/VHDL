--任意除頻器
--假設輸入11.059MHz頻率,可任意除N倍頻率 N=6頻率=1.8432MHz  
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity divden is 
generic(N:integer :=6);--除N=6倍頻率 
port (
       Pinclk,rst:in  std_logic;
       clkout    :out  std_logic
      );
end divden;
architecture a of divden is
signal clktemp :std_logic;
signal cnt:integer range 1 to N/2;--N/2計數反相輸出訊號
begin
  process(Pinclk,rst)
    begin
      if rst='0' then
        cnt<=1;
        clktemp<='0';
      elsif Pinclk'event and Pinclk='1'then
        if cnt=N/2 then         --
           cnt<=1;
           clktemp<=not clktemp;
        else
           cnt<=cnt+1;
        end if;
      end if;
      clkout<=clktemp;
   end process;
   
end a;
