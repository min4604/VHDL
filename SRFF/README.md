# SR_aoolication.vhd Function:
– I/O Functions:
- PushButton2 (S) is to turn on the motor (i.e., LED0: Q).
- PushButton1 (R) is to turn off motor (i.e., LED0: Q).
- PushButton0 is to reset the 2-digit BCD (or decimal) counter to 00.
- Hex1 and Hex0 shows the value of the 2-digit BCD counter.
- SW0 is to enable/disable the pushbuttons.
· When SW0 is Logic-High, enable the pushbuttons. Otherwise, the pushbuttons are disabled.
– The 2-digit BCD counter is advanced by one whenever the motor is turned ON
from OFF (rising-edge trigger).