-------------------------------------------------------------------
--檔案名稱：uart_transmitter.vhd
--功    能：串列傳輸；1 start bit, 8 data bits, 1 stop bit
--日    期：2003.8.8  
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity uart_transmitter is
  port(
       sysclk     : in std_logic;  --system clock
       rst_n      : in std_logic;  --system reset; 
       bclk       : in std_logic;  --baud rate clock
       txd_startH : in std_logic;  --rxd start; active high
       DBUS       : in std_logic_vector(7 downto 0);--Data Bus
       txd_doneH  : out std_logic; --transmmit finished
       txd        : out std_logic  --txd
      );
end uart_transmitter;

architecture arch of uart_transmitter is
  type statetype is (idle, synch, tdata);
  signal state, nextstate : statetype;
  signal tsr : std_logic_vector (8 downto 0);	-- Transmit Shift Register
  signal bct: integer range 0 to 9; 		-- counts number of bits sent
  signal inc, clr, loadTSR, shftTSR, start: std_logic;
  signal bclk_rising, bclk_dlayed, txd_done: std_logic;
begin
  txd <= tsr(0);
  txd_doneH <= txd_done;
  bclk_rising <= bclk and (not bclk_dlayed);
  process(state,txd_startH, bct, bclk_rising)
  begin
    inc <= '0';
    clr <= '0';
    loadTSR <= '0';
    shftTSR <= '0';
    start <= '0';
    txd_done <= '0';
	case state is
      ----- idle state; wait until txd_startH = '1' -----
      when idle =>
          if (txd_startH = '1' ) then 
		    loadTSR <= '1';
            nextstate <= synch;
		  else
            nextstate <= idle;
          end if;
      ----- synch state; synchronize with the bit clock -----
      when synch =>				
          if (bclk_rising = '1') then 
            start <= '1';
            nextstate <= tdata;
          else
            nextstate <= synch;
          end if;
      ----- transmit data state -----
      when tdata =>
          if (bclk_rising = '0') then
            nextstate <= tdata;
          elsif (bct /= 9) then 
            shfttsr <= '1';
            inc <= '1';
            nextstate <= tdata;
		  else
            clr <= '1';
            txd_done <= '1';
            nextstate <= idle;
          end if;
      end case;
  end process;
  ----- update data -----
  process (sysclk, rst_n)
  begin
    if (rst_n = '0') then  
      TSR <= "111111111";
      state <= idle;
      bct <= 0;
      bclk_dlayed <= '0';
    elsif (sysclk'event and sysclk = '1') then
      state <= nextstate;
      --counter of transmit bit
      if (clr = '1') then
        bct <= 0;
      elsif (inc = '1') then
        bct <= bct + 1;
      end if;
      --TSR assignment
      if (loadTSR = '1') then 
        TSR <= DBUS & '1';
      elsif (start = '1') then
        TSR(0) <= '0';
      elsif (shftTSR = '1') then 
        TSR <= '1' & TSR(8 downto 1);
      end if;  
      -- Bclk delayed by 1 sysclk
      bclk_dlayed <= bclk;   
    end if;
  end process;
end arch;

