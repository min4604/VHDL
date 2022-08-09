-------------------------------------------------------------------
--檔案名稱：uart_receiver.vhd
--功    能：串列傳輸接收器；1 start bit, 8 data bits, 1 stop bit
--日    期：2003.8.8
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity uart_receiver is
port(
       sysclk    :in  std_logic;         --system clock
       rst_n     :in  std_logic;         --system rest
       bclkx8    :in  std_logic;         --detection baud rate
       rxd       :in  std_logic;         --rx of uart  
       rxd_readyH:out std_logic;         --rxd_readyH; rising edge
       RDR       :out std_logic_vector(7 downto 0)--receive data 1
    ); 
end uart_receiver;

architecture arch of uart_receiver is
  type statetype is (idle,start_detected,recv_data);
  signal state,nextstate:statetype;
  signal inc1,inc2,clr1,clr2:std_logic;         --increse and clear
  signal shftRSR,load_RDR:std_logic;            --load data signal
  signal bclkx8_dlayed,bclkx8_rising:std_logic; --baud rate message
  signal RSR:std_logic_vector(7 downto 0); --receive shift register
  signal ct1:integer range 0 to 7;  --detect the determination clk
  signal ct2:integer range 0 to 8;  --detect receivability #data bit
  signal ok_en: std_logic;
begin
bclkx8_rising<=bclkx8 and(not bclkx8_dlayed);
---------- FSM of UART receiver ---------
process(state,rxd,ct1,ct2,bclkx8_rising)
begin
  ----- initial value -----
  inc1<='0';inc2<='0';clr1<='0';clr2<='0';
  shftRSR<='0';load_RDR<='0';ok_en<='0';
  ----- state machine -----
  case state is
    ----- idle state; standby, wait until rxd='0' -----
    when idle=>
      if (rxd='0') then            --detect start bit signal '0'
        nextstate<=start_detected;
      else
        nextstate<=idle;
      end if;
    ----- start_detected state; determine whether start bit -----
    when start_detected=>
      if (bclkx8_rising='0') then
        nextstate<=start_detected;
      elsif (rxd='1') then          --not start bit;
        clr1<='1';                  --clear counter 1
        nextstate<=idle;            --back to idle state
      elsif (ct1=3) then --after 3 bclkx8; confirm it be the start bit
        clr1<='1';                  --clear counter 1
        nextstate<=recv_data;       --go on receive data
      else
        inc1<='1';                  --cnt+1
        nextstate<=start_detected;  --go on confirm the start bit
      end if;
    ----- receive data state; receive series data from rxd -----
    when recv_data=>
      if (bclkx8_rising='0') then
        nextstate<=recv_data;
      else
        inc1<='1';
        if (ct1/=7) then         --detect data every 8 times of bclkx8
          nextstate<=recv_data;
        elsif (ct2/=8) then      --receive 8 times
          shftRSR<='1';          --receive 1bit data
          inc2<='1';             --ct2+1
          clr1<='1';             --ct1=0
          nextstate<=recv_data;  
        elsif (rxd='0') then     --error
          nextstate<=idle;       --do nothing and back
          clr1<='1';             --ct1=0
          clr2<='1';             --ct2=0
        else                     --detect end bit '1'
          load_RDR<='1';         --RDR<=RSR ; receive 1bytes data finished
          ok_en<='1';
          clr1<='1';             --ct1=0
          clr2<='1';             --ct2=0
          nextstate<=idle;       --finish receive 1 bytes data
        end if;
      end if;
    end case; 
  end  process;
  ---------- update state and value of register ----------
  process(sysclk,rst_n)
  begin
    if (rst_n='0') then
      state<=idle;
      bclkx8_dlayed<='0';
      ct1<=0;
      ct2<=0;
      RDR<="00000000";
    elsif (sysclk'event and sysclk='1') then
      state<=nextstate;
    
      if(clr1='1')then ct1<=0;elsif(inc1='1')then ct1<=ct1+1;end if;

      if(clr2='1')then ct2<=0;elsif(inc2='1')then ct2<=ct2+1;end if;   
    
      if(shftRSR='1')then RSR<=rxd & RSR(7 downto 1);end if;

      if(load_RDR='1')then RDR<=RSR;end if;

      if(ok_en='1')then rxd_readyH<='1';else rxd_readyH<='0';end if;
      ----- generator bclk delay signal for determine bclkx8 rising -----
      bclkx8_dlayed<=bclkx8;
    end if;
  end process;
end arch;
