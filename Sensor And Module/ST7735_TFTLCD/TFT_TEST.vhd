library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;



entity TFT_TEST is
port(
     SCLK : out std_logic;--SCL PIN
     MOSI : out std_logic;--SDA PIN
     CS   : out std_logic;--CS  PIN
     DC   : out std_logic;--DC  PIN
     RES  : out std_logic;--RES PIN
      LED  : out std_logic;--BL PIN �����]�i�H 
     reset,clk_50M :in  std_logic
);
end TFT_TEST;




architecture inside of TFT_TEST is   

    Signal delay_us_CLK   : Std_logic := '0';
    Signal delay_ms_CLK   : Std_logic := '0';
    Signal delay_40ns_CLK : Std_logic := '0';

    Signal SCLK_Buf     :   Std_logic := '0';
    Signal MOSI_Buf     :   Std_logic := '0';
    Signal CS_Buf       :   Std_logic := '0';
    Signal DC_Buf       :   Std_logic := '0';
    Signal RES_Buf      :   Std_logic := '0';
    Signal LED_Buf      :   Std_logic := '0';

    Constant BLACK      :   Std_logic_vector(15 downto 0):=x"0000";
    Constant BLUE       :   Std_logic_vector(15 downto 0):=x"001F";
    Constant RED        :   Std_logic_vector(15 downto 0):=x"F800";
    Constant GREEN      :   Std_logic_vector(15 downto 0):=x"07E0";
    Constant CYAN       :   Std_logic_vector(15 downto 0):=x"07FF"; 
    Constant MAGENTA    :   Std_logic_vector(15 downto 0):=x"F81F";
    Constant YELLOW     :   Std_logic_vector(15 downto 0):=x"FFE0";
    Constant WHITE      :   Std_logic_vector(15 downto 0):=x"FFFF";
    

    
     procedure Count_Data(BYTE_MAXVAL : in integer;
                                 BITS_MAXVAL : in integer;
                                 BYTE_Count  : inout integer;
                                 BITS_Count  : inout integer;
                                 Finish_F    : out Boolean) is ---------------------------------------Control ALL DATA Byte or Bits
     begin
         Finish_F := False;
         if(BITS_Count>=BITS_MAXVAL) then
            BITS_Count := 0;    
        if(BYTE_Count>=BYTE_MAXVAL) then
            BYTE_Count := 0;
                BITS_Count := 0;
            Finish_F := True;
        else
                BYTE_Count := BYTE_Count + 1;
        end if;
     else
        BITS_Count := BITS_Count + 1;
         end if;
     end Count_Data; --------------------------------------------------------------------------End
                                 
    
    procedure Write_Data(SPI_DATA_BUF : in Std_Logic_Vector(7 downto 0);
                         BITS_CLK : in integer range 0 to 32) is -----------------------------SPI Write Data
    begin
           DC_Buf <= '1';
      if(BITS_CLK=0) then         --Every 50 ns;
            SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(7);
      elsif(BITS_CLK=1) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(7);
        elsif(BITS_CLK=2) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(6);
        elsif(BITS_CLK=3) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(6);
        elsif(BITS_CLK=4) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(5);
        elsif(BITS_CLK=5) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(5);
        elsif(BITS_CLK=6) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(4);
        elsif(BITS_CLK=7) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(4);
        elsif(BITS_CLK=8) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(3);
      elsif(BITS_CLK=9) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(3);
        elsif(BITS_CLK=10) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(2);
        elsif(BITS_CLK=11) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(2);
        elsif(BITS_CLK=12) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(1);
        elsif(BITS_CLK=13) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(1);
        elsif(BITS_CLK=14) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(0);
        elsif(BITS_CLK=15) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(0);
        elsif(BITS_CLK=16) then
            SCLK_Buf <= '0';
        elsif(BITS_CLK>16) then
            SCLK_Buf <= '0';
         MOSI_Buf <= '0';
      end if;
            
    end Write_Data; ----------------------------------------------------------------------------------End

     procedure Write_Data16(SPI_DATA_BUF : in Std_Logic_Vector(15 downto 0);
                        BITS_CLK : in integer range 0 to 64) is --------------------------------------SPI Write Data 16bits
    begin
           DC_Buf <= '1';               --Every 50 ns;
        if(BITS_CLK=0) then         
            SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(15);
      elsif(BITS_CLK=1) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(15);
        elsif(BITS_CLK=2) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(14);
        elsif(BITS_CLK=3) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(14);
        elsif(BITS_CLK=4) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(13);
        elsif(BITS_CLK=5) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(13);
        elsif(BITS_CLK=6) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(12);
        elsif(BITS_CLK=7) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(12);
        elsif(BITS_CLK=8) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(11);
      elsif(BITS_CLK=9) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(11);
        elsif(BITS_CLK=10) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(10);
        elsif(BITS_CLK=11) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(10);
        elsif(BITS_CLK=12) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(9);
        elsif(BITS_CLK=13) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(9);
        elsif(BITS_CLK=14) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(8);
        elsif(BITS_CLK=15) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(8);
      elsif(BITS_CLK=16) then         
            SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(7);
      elsif(BITS_CLK=17) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(7);
        elsif(BITS_CLK=18) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(6);
        elsif(BITS_CLK=19) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(6);
        elsif(BITS_CLK=20) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(5);
        elsif(BITS_CLK=21) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(5);
        elsif(BITS_CLK=22) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(4);
        elsif(BITS_CLK=23) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(4);
        elsif(BITS_CLK=24) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(3);
      elsif(BITS_CLK=25) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(3);
        elsif(BITS_CLK=26) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(2);
        elsif(BITS_CLK=27) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(2);
        elsif(BITS_CLK=28) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(1);
        elsif(BITS_CLK=29) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(1);
        elsif(BITS_CLK=30) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_DATA_BUF(0);
        elsif(BITS_CLK=31) then
         SCLK_Buf <= '1';
         MOSI_Buf <= SPI_DATA_BUF(0);
        elsif(BITS_CLK=32) then
            SCLK_Buf <= '0';
        elsif(BITS_CLK>32) then
            SCLK_Buf <= '0';
         MOSI_Buf <= '0';
      end if;
            
    end Write_Data16; -------------------------------------------------------------------------End
     
     
    procedure Write_Cmd(SPI_Cmd_BUF : in Std_Logic_Vector(7 downto 0);
                        BITS_CLK : in integer range 0 to 32) is -------------------------------SPI Write Command
    begin
        DC_Buf <= '0';
      if(BITS_CLK=0) then         --Every 50 ns;
            SCLK_Buf <= '0';
            MOSI_Buf <= SPI_Cmd_BUF(7);
      elsif(BITS_CLK=1) then
         SCLK_Buf <= '1';
            MOSI_Buf <= SPI_Cmd_BUF(7);
        elsif(BITS_CLK=2) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_Cmd_BUF(6);
        elsif(BITS_CLK=3) then
         SCLK_Buf <= '1';
            MOSI_Buf <= SPI_Cmd_BUF(6);
        elsif(BITS_CLK=4) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_Cmd_BUF(5);
        elsif(BITS_CLK=5) then
         SCLK_Buf <= '1';
            MOSI_Buf <= SPI_Cmd_BUF(5);
        elsif(BITS_CLK=6) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_Cmd_BUF(4);
        elsif(BITS_CLK=7) then
         SCLK_Buf <= '1';
            MOSI_Buf <= SPI_Cmd_BUF(4);
        elsif(BITS_CLK=8) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_Cmd_BUF(3);
      elsif(BITS_CLK=9) then
         SCLK_Buf <= '1';
            MOSI_Buf <= SPI_Cmd_BUF(3);
        elsif(BITS_CLK=10) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_Cmd_BUF(2);
        elsif(BITS_CLK=11) then
         SCLK_Buf <= '1';
            MOSI_Buf <= SPI_Cmd_BUF(2);
        elsif(BITS_CLK=12) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_Cmd_BUF(1);
        elsif(BITS_CLK=13) then
         SCLK_Buf <= '1';
            MOSI_Buf <= SPI_Cmd_BUF(1);
        elsif(BITS_CLK=14) then
         SCLK_Buf <= '0';
            MOSI_Buf <= SPI_Cmd_BUF(0);
        elsif(BITS_CLK=15) then
         SCLK_Buf <= '1';
            MOSI_Buf <= SPI_Cmd_BUF(0);
        elsif(BITS_CLK=16) then
            SCLK_Buf <= '0';
        elsif(BITS_CLK>16) then
            SCLK_Buf <= '0';
         MOSI_Buf <= '0';
      end if;
    end Write_Cmd;  ----------------------------------------------------------------------------------End
    

    procedure TFT_Init( BYTE_CLK : in integer range 0 to 345;
                        BITS_CLK : in integer range 0 to 32) is --------------------------------------TFT_Init
    begin
        if(BYTE_CLK=0) then     
            CS_Buf <= '0';
                RES_Buf <= '1';
            Write_Cmd(x"01",BITS_CLK);   --  1: Software reset, 0 args, w/delay
        elsif(BYTE_CLK=150) then          --wait for 150 ms;         
            Write_Cmd(x"11",BITS_CLK);   --  2: Out of sleep mode, 0 args, w/delay
        elsif(BYTE_CLK=151) then
            Write_Cmd(x"B1",BITS_CLK);   --  3: Frame rate ctrl - normal mode, 3 args : Rate = fosc/(1x2+40) * (LINE+2C+2D)
        elsif(BYTE_CLK=152) then
            Write_Data(x"01",BITS_CLK);
        elsif(BYTE_CLK=153) then
            Write_Data(x"2C",BITS_CLK);
        elsif(BYTE_CLK=154) then
            Write_Data(x"2D",BITS_CLK);
        elsif(BYTE_CLK=155) then
            Write_Cmd(x"B2",BITS_CLK);   --  4: Frame rate control - idle mode, 3 args: Rate = fosc/(1x2+40) * (LINE+2C+2D)
        elsif(BYTE_CLK=156) then
            Write_Data(x"01",BITS_CLK);
        elsif(BYTE_CLK=157) then
            Write_Data(x"2C",BITS_CLK);
        elsif(BYTE_CLK=158) then
            Write_Data(x"2D",BITS_CLK);
        elsif(BYTE_CLK=159) then
            Write_Cmd(x"B3",BITS_CLK);   --  5: Frame rate ctrl - partial mode, 6 args:
        elsif(BYTE_CLK=160) then
            Write_Data(x"01",BITS_CLK);  --     Dot inversion mode
        elsif(BYTE_CLK=161) then
            Write_Data(x"2C",BITS_CLK);
        elsif(BYTE_CLK=162) then
            Write_Data(x"2D",BITS_CLK);
        elsif(BYTE_CLK=163) then
            Write_Data(x"01",BITS_CLK);  --     Line inversion mode
        elsif(BYTE_CLK=164) then
            Write_Data(x"2C",BITS_CLK);
        elsif(BYTE_CLK=165) then
            Write_Data(x"2D",BITS_CLK);
        elsif(BYTE_CLK=166) then
            Write_Cmd(x"B4",BITS_CLK);   --  6: Display inversion ctrl, 1 arg, no delay:
        elsif(BYTE_CLK=167) then
            Write_Data(x"07",BITS_CLK);  --     No inversion
        elsif(BYTE_CLK=168) then
            Write_Cmd(x"C0",BITS_CLK);   --  7: Power control, 3 args, no delay:
        elsif(BYTE_CLK=169) then
            Write_Data(x"A2",BITS_CLK);
        elsif(BYTE_CLK=170) then
            Write_Data(x"02",BITS_CLK);  --     -4.6V
        elsif(BYTE_CLK=171) then
            Write_Data(x"84",BITS_CLK);  --     AUTO mode
        elsif(BYTE_CLK=172) then
            Write_Cmd(x"C1",BITS_CLK);   --  8: Power control, 1 arg, no delay:
        elsif(BYTE_CLK=173) then
            Write_Data(x"C5",BITS_CLK);  --     VGH25 = 2.4C VGSEL = -10 VGH = 3 * AVDD
        elsif(BYTE_CLK=174) then
            Write_Cmd(x"C2",BITS_CLK);   --  9: Power control, 2 args, no delay:
        elsif(BYTE_CLK=175) then
            Write_Data(x"0A",BITS_CLK);  --     Opamp current small
        elsif(BYTE_CLK=176) then
            Write_Data(x"00",BITS_CLK);  --     Boost frequency
        elsif(BYTE_CLK=177) then
            Write_Cmd(x"C3",BITS_CLK);   -- 10: Power control, 2 args, no delay:
        elsif(BYTE_CLK=178) then
            Write_Data(x"8A",BITS_CLK);  --     BCLK/2, Opamp current small & Medium low
        elsif(BYTE_CLK=179) then
            Write_Data(x"2A",BITS_CLK);  
        elsif(BYTE_CLK=180) then
            Write_Cmd(x"C4",BITS_CLK);   -- 11: Power control, 2 args, no delay:
        elsif(BYTE_CLK=181) then
            Write_Data(x"8A",BITS_CLK);
        elsif(BYTE_CLK=182) then
            Write_Data(x"EE",BITS_CLK);  
        elsif(BYTE_CLK=183) then
            Write_Cmd(x"C5",BITS_CLK);   -- 12: Power control, 1 arg, no delay:
        elsif(BYTE_CLK=184) then
            Write_Data(x"0E",BITS_CLK);
        elsif(BYTE_CLK=185) then
            Write_Cmd(x"20",BITS_CLK);   -- 13: Don't invert display, no args, no delay
        elsif(BYTE_CLK=186) then
            Write_Cmd(x"36",BITS_CLK);   -- 14: Memory access control (directions), 1 arg:
        elsif(BYTE_CLK=187) then
            Write_Data(x"C0",BITS_CLK);  --     row addr/col addr, bottom to top refresh
        elsif(BYTE_CLK=188) then
            Write_Cmd(x"3A",BITS_CLK);   -- 15: set color mode, 1 arg, no delay:
        elsif(BYTE_CLK=189) then
            Write_Data(x"05",BITS_CLK);  --     16-bit color
        elsif(BYTE_CLK=190) then
            Write_Cmd(x"2A",BITS_CLK);   -- 16: Column addr set, 4 args, no delay:
        elsif(BYTE_CLK=191) then
            Write_Data(x"00",BITS_CLK);  --     XSTART = 0
        elsif(BYTE_CLK=192) then
            Write_Data(x"00",BITS_CLK);
        elsif(BYTE_CLK=193) then
            Write_Data(x"00",BITS_CLK);  --     XEND = 127
        elsif(BYTE_CLK=194) then
            Write_Data(x"7F",BITS_CLK);
        elsif(BYTE_CLK=195) then
            Write_Cmd(x"2B",BITS_CLK);   -- 17: Row addr set, 4 args, no delay:
        elsif(BYTE_CLK=196) then
            Write_Data(x"00",BITS_CLK);  --     XSTART = 0
        elsif(BYTE_CLK=197) then
            Write_Data(x"00",BITS_CLK);
        elsif(BYTE_CLK=198) then
            Write_Data(x"00",BITS_CLK);  --     XEND = 127
        elsif(BYTE_CLK=199) then
            Write_Data(x"7F",BITS_CLK);
        elsif(BYTE_CLK=200) then
            Write_Cmd(x"E0",BITS_CLK);   -- 18: Magical unicorn dust, 16 args, no delay:
        elsif(BYTE_CLK=201) then
            Write_Data(x"02",BITS_CLK);  
        elsif(BYTE_CLK=202) then
            Write_Data(x"1C",BITS_CLK);
        elsif(BYTE_CLK=203) then
            Write_Data(x"07",BITS_CLK);  
        elsif(BYTE_CLK=204) then
            Write_Data(x"12",BITS_CLK);
        elsif(BYTE_CLK=205) then
            Write_Data(x"37",BITS_CLK);
        elsif(BYTE_CLK=206) then
            Write_Data(x"32",BITS_CLK);
        elsif(BYTE_CLK=207) then
            Write_Data(x"29",BITS_CLK);  
        elsif(BYTE_CLK=208) then
            Write_Data(x"2D",BITS_CLK);
        elsif(BYTE_CLK=209) then
            Write_Data(x"29",BITS_CLK);
        elsif(BYTE_CLK=210) then
            Write_Data(x"25",BITS_CLK);
        elsif(BYTE_CLK=211) then
            Write_Data(x"2B",BITS_CLK);
        elsif(BYTE_CLK=212) then
            Write_Data(x"39",BITS_CLK);
        elsif(BYTE_CLK=213) then
            Write_Data(x"00",BITS_CLK);  
        elsif(BYTE_CLK=214) then
            Write_Data(x"01",BITS_CLK);
        elsif(BYTE_CLK=215) then
            Write_Data(x"03",BITS_CLK);  
        elsif(BYTE_CLK=216) then
            Write_Data(x"10",BITS_CLK);
        elsif(BYTE_CLK=217) then
            Write_Cmd(x"E1",BITS_CLK);   -- 19: Sparkles and rainbows, 16 args, no delay:
        elsif(BYTE_CLK=218) then
            Write_Data(x"03",BITS_CLK);  
        elsif(BYTE_CLK=219) then
            Write_Data(x"1D",BITS_CLK);
        elsif(BYTE_CLK=220) then
            Write_Data(x"07",BITS_CLK);
        elsif(BYTE_CLK=221) then
            Write_Data(x"06",BITS_CLK);
        elsif(BYTE_CLK=222) then
            Write_Data(x"2E",BITS_CLK);  
        elsif(BYTE_CLK=223) then
            Write_Data(x"2C",BITS_CLK);
        elsif(BYTE_CLK=224) then
            Write_Data(x"29",BITS_CLK);  
        elsif(BYTE_CLK=225) then
            Write_Data(x"2D",BITS_CLK);
        elsif(BYTE_CLK=226) then
            Write_Data(x"2E",BITS_CLK);
        elsif(BYTE_CLK=227) then
            Write_Data(x"2E",BITS_CLK);
        elsif(BYTE_CLK=228) then
            Write_Data(x"37",BITS_CLK);  
        elsif(BYTE_CLK=229) then
            Write_Data(x"3F",BITS_CLK);
        elsif(BYTE_CLK=230) then
            Write_Data(x"00",BITS_CLK);
        elsif(BYTE_CLK=231) then
            Write_Data(x"00",BITS_CLK);
        elsif(BYTE_CLK=232) then
            Write_Data(x"02",BITS_CLK);
        elsif(BYTE_CLK=233) then
            Write_Data(x"10",BITS_CLK);
        elsif(BYTE_CLK=234) then
            Write_Cmd(x"13",BITS_CLK);   -- 20: Normal display on, no args, w/delay
        elsif(BYTE_CLK=244) then          --wait for 10 ms;
            Write_Cmd(x"29",BITS_CLK);   -- 21: Main screen turn on, no args w/delay
        elsif(BYTE_CLK=344) then          --wait for 100 ms;
                --Write_Cmd(x"2C",BITS_CLK);
          --elsif(BYTE_CLK=345) then
            CS_Buf <= '1';
        end if;
    end TFT_Init;   -----------------------------------------------------------------------------------End
    

    

    procedure SetAddressWindow( x0 : in Integer ;  ----------------------------------------------------TFT Set Coordinate
                                y0 : in Integer ;
                                x1 : in Integer ;
                                y1 : in Integer ;
                                BYTE_CLK : in integer range 0 to 12;
                                BITS_CLK : in integer range 0 to 64) is
    begin 
        if(BYTE_CLK=1) then      --Every 1ms
            Write_Cmd(x"2A",BITS_CLK);   -- column address set
        elsif(BYTE_CLK=2) then
            Write_Data(x"00",BITS_CLK);
        elsif(BYTE_CLK=3) then
            Write_Data(std_logic_vector(to_unsigned(x0 + 2,8)),BITS_CLK);
        elsif(BYTE_CLK=4) then
            Write_Data(x"00",BITS_CLK);
        elsif(BYTE_CLK=5) then
            Write_Data(std_logic_vector(to_unsigned(x1 + 2,8)),BITS_CLK);
        elsif(BYTE_CLK=6) then
            Write_Cmd(x"2B",BITS_CLK);   -- row address set
        elsif(BYTE_CLK=7) then
            Write_Data(x"00",BITS_CLK);
        elsif(BYTE_CLK=8) then
            Write_Data(std_logic_vector(to_unsigned(y0 + 1,8)),BITS_CLK);
        elsif(BYTE_CLK=9) then
            Write_Data(x"00",BITS_CLK);
        elsif(BYTE_CLK=10) then
            Write_Data(std_logic_vector(to_unsigned(y1 + 1,8)),BITS_CLK);
        elsif(BYTE_CLK=11) then
            Write_Cmd(x"2C",BITS_CLK);   -- write to RAM
        end if;
    end SetAddressWindow;   --------------------------------------------------------------------------End
    
    
    procedure FillRectangle(x : Integer range 0 to 128;  ---------------------------------------------TFT FillRectangle
                            y : Integer range 0 to 160;
                            w : Integer range 0 to 128;
                            h : Integer range 0 to 160;
                            color : Std_Logic_Vector(15 downto 0);
                                     BYTE_CLK : integer range 0 to 25000;
                                     BITS_CLK : integer range 0 to 64)  is
        --Variable W_Temp : Integer range 0 to 128;
          --Variable H_Temp : Integer range 0 to 160;
     begin
        if(BYTE_CLK=0) then    
                CS_Buf <= '0';
                RES_Buf <= '1';
                --W_Temp := w;
                --H_Temp := h;
            --if((x + w - 1) >= 128) then W_Temp := 128 - x;  end if;
            --if((y + h - 1) >= 160) then H_Temp := 160 - y;  end if;
          elsif((BYTE_CLK>=1) and (BYTE_CLK<12)) then
                SetAddressWindow(x, y, x+w-1, y+h-1, BYTE_CLK, BITS_CLK);
        elsif(BYTE_CLK>=12 and BYTE_CLK<(12+(h*w))) then
            Write_Data16(color,BITS_CLK);
        elsif(BYTE_CLK=(1+(12+(h*w)))) then
            CS_Buf <= '1';
        end if;
    end FillRectangle;  ------------------------------------------------------------------------------End
begin
	process(reset,clk_50M)  ----------------------���W��                 
	Variable div_us_cnt : Integer range 0 to 100:= 0;
	Variable div_ms_cnt : Integer range 0 to 50000:= 0;
	begin
		if (reset ='0') then
			div_us_cnt := 0;
			div_ms_cnt := 0;
		elsif (reset ='1' and (clk_50M'event and clk_50M='0')) then      
			delay_40ns_CLK <= not delay_40ns_CLK;---50M/2=25M=>40ns_CLK  
			div_us_cnt := div_us_cnt + 1;
			if(div_us_cnt >= 25) then---50M/50=1M=>1us_CLK
				div_us_cnt := 0;
				delay_us_CLK <= not delay_us_CLK;
				div_ms_cnt := div_ms_cnt + 1;
			end if;
			if (div_ms_cnt >= 1000) then---1M/1000=1k=>1ms_CLK
				div_ms_cnt := 0;
				delay_ms_CLK <= not delay_ms_CLK;
			end if;			
		end if;
	end process; -------------------------------------------------------------------------------------End
     

   process(reset,delay_40ns_CLK)-----------------------�D�{��--
		Variable BITS_CLK : integer range 0 to 64 :=0;
		Variable BYTE_CLK : integer range 0 to 25000:=0;
		Variable delay_40ns_Cnt : integer range 0 to 50000:= 0; 
		Variable delay_ms_Cnt : integer range 0 to 50000000:= 0;
		Variable LCD_RES_f: Boolean:=True;
		Variable Init_f   : Boolean:=False;
		Variable Finish   : Boolean;
		Variable main_f : Boolean := False;
		Variable main_Cnt : integer range 0 to 8 := 0;
		Variable color_Change : Boolean := False;
	begin
		if (reset='0') then
			LCD_RES_f := True;
			Init_f := False;
			main_f := False;
			color_Change := False;
			main_Cnt := 0;
			BITS_CLK := 0;
			BYTE_CLK := 0;
			delay_40ns_Cnt := 0;
			CS_Buf <= '1';
			RES_Buf <= '0';
			LED_Buf <= '1';
		elsif (reset='1' and (delay_40ns_CLK'event and delay_40ns_CLK = '0')) then --25M�u�@�W�v
			if(LCD_RES_f=True and Init_f=False and main_f=False) then ----------------Hardware Reset for LCD => Takes 5ms
				if(delay_40ns_Cnt>=25000) then --delay for 5ms (25000*40ns)
					delay_40ns_Cnt := 0;
					RES_Buf <= '1';
					LCD_RES_f := False;
					Init_f := True;
				else
					delay_40ns_Cnt := delay_40ns_Cnt + 1;
				end if;
			elsif(LCD_RES_f=False and Init_f=True and main_f=False) then -------------Init Start => Takes 356*1.6us => about 0.55ms
				if(delay_40ns_Cnt>=1) then --delay for 80ns (2*40ns)
					delay_40ns_Cnt := 0;
					Count_Data(346,20,BYTE_CLK,BITS_CLK,Finish); --------Every 20*80ns => 1.6us
					if(Finish = True) then
						delay_40ns_Cnt := 0;
						Init_f := False;
						main_f := True;
						LED_Buf <= '0';
					end if;
				else
					delay_40ns_Cnt := delay_40ns_Cnt+1;
					TFT_Init(BYTE_CLK,BITS_CLK);
				end if;    
			elsif(LCD_RES_f=False and main_f=True and Init_f=False) then  -------------Mains Start          
				if(delay_40ns_Cnt>=1) then  -------delay for 80ns (2*40ns)
					delay_40ns_Cnt := 0;
					Count_Data((128*160)+13,33,BYTE_CLK,BITS_CLK,Finish); --------Every 20*80ns => 1.6us
					if(Finish = True) then
							delay_40ns_Cnt := 0;
							LED_Buf <= '1';
							--main_f := False;
							color_Change := True; -------- Can Change color After display finish
					end if;
				else
					delay_40ns_Cnt := delay_40ns_Cnt + 1;
					Case main_Cnt is
							When 0 => FillRectangle(0,0,128,50,RED,BYTE_CLK,BITS_CLK);
							When 1 => FillRectangle(20,50,1,1,BLUE   ,BYTE_CLK,BITS_CLK);
							When 2 => FillRectangle(0,0,128,160,RED    ,BYTE_CLK,BITS_CLK);
							When 3 => FillRectangle(0,0,128,160,GREEN  ,BYTE_CLK,BITS_CLK);
							When 4 => FillRectangle(0,0,128,160,CYAN   ,BYTE_CLK,BITS_CLK);
							When 5 => FillRectangle(0,0,128,160,MAGENTA,BYTE_CLK,BITS_CLK);
							When 6 => FillRectangle(0,0,128,160,YELLOW ,BYTE_CLK,BITS_CLK);
							When 7 => FillRectangle(0,0,128,160,WHITE  ,BYTE_CLK,BITS_CLK);
							When others => FillRectangle(0,0,128,160,BLACK,BYTE_CLK,BITS_CLK);
					end Case;
				end if;
			end if;
				
			if(color_Change = True) then -------- Can change color
				if(delay_ms_Cnt>=25000000) then --------------------Every 1s(40ns*25000000) change the color 
					delay_ms_Cnt := 0;
					color_Change := False;
					if(main_Cnt>=8) then 
						main_Cnt := 0;
					else
						main_Cnt := main_Cnt+1;
					end if; 
				else
					delay_ms_Cnt := delay_ms_Cnt + 1;
				end if;
			end if;
		end if;
	end process;-------------------------------------------------------------------------------------End
    
    
     
	SCLK <= SCLK_Buf; 
	MOSI <= MOSI_Buf;
	CS   <= CS_Buf;
	DC   <= DC_Buf;
	RES  <= RES_Buf;
	LED  <= LED_Buf;

end inside;