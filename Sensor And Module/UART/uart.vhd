-------------------------------------------------------
--龅率選擇腳
--	(Sel[2..0])		龅率(bclk)
--		000			  38400
--		001			  19200
--		010			  9600
--		011			  4800
--		100			  2400
--		101			  1200
--		110			  600
--		111			  300
--
--	sysclk_11_059M 	輸入之頻率為 11.059MHz
--	rst_L			低態重置
--	txd_start_H		一脈波(負緣觸發)傳送一筆資料
--	txd_down_H		資料傳送完成產生一脈波
--	rxd_ready_H		接收資料產生一脈波

-------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



entity uart is
port(	sysclk_11_059M	: in	std_logic;
		rst_L			: in	std_logic;
		txd_start_H		: in	std_logic;
		txd_data_BUS	: in	std_logic_vector(7 downto 0);
		rxd				: in 	std_logic;
		rxd_ready_H		: out	std_logic;
		rxd_data_BUS	: out	std_logic_vector(7 downto 0);
		txd_down_H		: out	std_logic;
		txd 			: out	std_logic

	);
end uart;

architecture uarts of uart is


signal sel :std_logic_vector(2 downto 0):="010"; --選擇鮑率


component divden
generic(N:integer);--除N倍頻率 
port(
		Pinclk,rst:in  std_logic;
		clkout    :out  std_logic
    );
end component;


component br_gen
generic(divisor: integer := 3); --if sysclk=1.8432M then divisor=3
port(
		sysclk:in std_logic;                    --system clock
		sel   :in std_logic_vector(2 downto 0); --baud rate select
		bclkx8:buffer std_logic;                --baud rate X 8
		bclk  :out std_logic                    --baud rate
    );
end component;


component stab_one
port(
		CLKin,rest,Plus_in:in  std_logic;
		Plus_out:out  std_logic
    );
end component;


component uart_receiver
port(
		sysclk    :in  std_logic;         --system clock
		rst_n     :in  std_logic;         --system rest
		bclkx8    :in  std_logic;         --detection baud rate
		rxd       :in  std_logic;         --rx of uart  
		rxd_readyH:out std_logic;         --rxd_readyH; rising edge
		RDR       :out std_logic_vector(7 downto 0)--receive data 1
    );
end component;


component uart_transmitter
port(
		sysclk     : in std_logic;  --system clock
		rst_n      : in std_logic;  --system reset; 
		bclk       : in std_logic;  --baud rate clock
		txd_startH : in std_logic;  --rxd start; active high
		DBUS       : in std_logic_vector(7 downto 0);--Data Bus
		txd_doneH  : out std_logic; --transmmit finished
		txd        : out std_logic  --txd
      );
end component;


signal clk_1_8432M 		:std_logic;
signal bclk				:std_logic;
signal bclkx8			:std_logic;
signal txd_start_plus 	:std_logic;
begin
	
	divden_6 	: divden
	generic	map(n=>6) --除6倍頻率
	port	map(sysclk_11_059M,rst_L,clk_1_8432M);
	
	
	br_gen_3 	: br_gen
	generic	map(divisor=>3)
	port	map(clk_1_8432M,sel,bclkx8,bclk);
	
	txd_en_stab	: stab_one
	port	map(bclk,rst_L,txd_start_H,txd_start_plus);
	
	
	rxd_A		: uart_receiver
	port	map(clk_1_8432M,rst_L,bclkx8,rxd,rxd_ready_H,rxd_data_BUS);
	
	
	txd_A		: uart_transmitter
	port	map(clk_1_8432M,rst_L,bclk,txd_start_plus,txd_data_BUS,txd_down_H,txd);

end uarts;


