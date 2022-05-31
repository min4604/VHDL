# only have code this is a databass

# integer and std_logic_vector convert
if you need use this you need use ieee.std_logic_arith.all

A:intger
B:std_logic_vector
A<=conv_integer(B);

B<=conv_std_logic_vector(A,std_logic_vector range);