Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity quartime is 
    port(
        switch: in std_logic;
        led: out std_logic
    );
end entity quartime;


architecture rtl of quartime is
begin
    led <= switch;
end architecture rtl;
