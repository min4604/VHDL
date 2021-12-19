library verilog;
use verilog.vl_types.all;
entity and_not_or is
    port(
        A               : in     vl_logic;
        B               : in     vl_logic;
        C               : in     vl_logic;
        D               : out    vl_logic;
        E               : out    vl_logic
    );
end and_not_or;
