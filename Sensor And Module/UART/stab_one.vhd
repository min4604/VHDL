--P8-18 ex
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--******************************
entity stab_one is
	port(
		 CLKin,rest,Plus_in:in  std_logic;
		 Plus_out:out  std_logic
		
           );
end stab_one;
--*******************************
architecture A1 of stab_one is
signal tem:std_logic_vector(3 downto 0);
signal num_tem:std_logic_vector(3 downto 0):="1001";
signal ftem:std_logic_vector(12 downto 0);
begin 
process(CLKin,rest,Plus_in)
begin
  if(rest='0')then 
    ftem<="0000000000000";
    tem<="0000";
    
  elsif(CLKin'event and CLKin='0' )then
     if Plus_in='1' then  
       if  (tem>=num_tem)then
         tem<="1110";
        
       else       
         tem<=tem+1;
       end if;
      else
         tem<="0000"; 
     end if;  
  end if;
case tem is
  when "0000"=>
         ftem<="0000000000000";--0
  when "0001"=>
         ftem<="0000000000001";--1
  when "0010"=>
         ftem<="0000000000010";--2
  when "0011"=>
         ftem<="0000000000100";--3
  when "0100"=>
         ftem<="0000000001000";--4
  when "0101"=>
         ftem<="0000000010000";--5
  when "0110"=>
         ftem<="0000000100000";--6
  when "0111"=>
         ftem<="0000001000000";--7       
  when "1000"=>
         ftem<="0000010000000";--8
  when "1001"=>
         ftem<="0000100000000";--9
  when "1010"=>
         ftem<="0001000000000";--10
  when "1011"=>
         ftem<="0010000000000";--11
  when "1100"=>
         ftem<="0100000000000";--12
  when "1101"=>
         ftem<="1000000000000";--13
  when others=>
         ftem<="0000000000000";--14,15
  end case;
  --f<=ftem;
  
end process ;
Plus_out<=ftem(0)or ftem(1) or ftem(2)or ftem(3) or ftem(4)or 
          ftem(5) or ftem(6)or ftem(7) or ftem(8)or ftem(9)or
          ftem(10)or ftem(11) or ftem(12);
end A1;



