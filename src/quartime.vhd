------------------------ SECOND COUNTER ---------------------------------------
Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity second_counter is
    port (
        input: in std_logic;
        reset: in std_logic;
        stop: in std_logic;
        output: out unsigned(16 downto 0)
    );
end second_counter;

architecture rtl of second_counter is
    constant counter_limit: unsigned(25 downto 0) := to_unsigned(50000000, 26);
begin
    process(input, reset, stop) is
        variable counter: unsigned(25 downto 0) := to_unsigned(0, 26);
        variable seconds: unsigned(16 downto 0) := to_unsigned(0, 17);
        variable stopped: boolean;
    begin

        if rising_edge(input) and not stopped then
           counter := counter + 1;

            if counter = counter_limit then
                counter := to_unsigned(0, 26);
                seconds := seconds + 1;

                if seconds = to_unsigned(60 * 60 * 24, 17) then
                    seconds := to_unsigned(0, 17);
                end if;
            end if;

        end if;

        if reset = '0' then
            counter := to_unsigned(0, 26);
            seconds := to_unsigned(0, 17);
        end if;

        if falling_edge(stop) then
            stopped := not stopped;
        end if;

        output <= seconds;
    end process;
end architecture rtl;

------------------------ GET REMAINDER ----------------------------------------
Library ieee;
use ieee.numeric_std.all;

entity get_remainder is
    generic (
        divisor: integer := 60
    );

    port (
        dividend: in unsigned(16 downto 0);
        quotient: in unsigned(11 downto 0);
        output: out unsigned(6 downto 0)
    );
end get_remainder;

architecture rtl of get_remainder is
    signal internal_divisor: unsigned(5 downto 0) := to_unsigned(divisor, 6);
    signal internal_result: unsigned(17 downto 0);
begin
    internal_result <= dividend - quotient * internal_divisor;
    output <= internal_result(6 downto 0);
end rtl;

------------------------ DIVIDER ----------------------------------------------
Library ieee;
use ieee.numeric_std.all;

entity divider is
    generic (
        scaled_divisor: integer := 139811;
        scaling_shift: integer := 23
    );

    port (
        input: in unsigned(16 downto 0);
        output: out unsigned(11 downto 0)
    );
end divider;

architecture rtl of divider is
    signal mul_input: unsigned(17 downto 0) := to_unsigned(scaled_divisor, 18);
    -- Internal signal to store the result of the multiplication
    signal mul_res: unsigned(34 downto 0);
begin
    mul_res <= shift_right(input * mul_input, scaling_shift);
    output <= mul_res(11 downto 0);
end rtl;

------------------------ TIME DECODER -----------------------------------------
Library ieee;
use ieee.numeric_std.all;

entity time_decoder is
    port (
        input: in unsigned(16 downto 0);
        seconds: out unsigned(6 downto 0);
        minutes: out unsigned(6 downto 0);
        hours: out unsigned(6 downto 0)
    );
end time_decoder;

architecture rtl of time_decoder is
    signal minutes_divider_out: unsigned(11 downto 0);
    signal minutes_divider_out_rsize: unsigned(16 downto 0);
    signal hours_divider_out: unsigned(11 downto 0);
begin
    minutes_divider: entity WORK.divider(rtl)
    port map (
        input => input,
        output => minutes_divider_out
    );

    minutes_divider_out_rsize <= resize(
        minutes_divider_out,
        minutes_divider_out_rsize'length
    );

    hours_divider: entity WORK.divider(rtl)
    port map (
        input => minutes_divider_out_rsize,
        output => hours_divider_out
    );

    seconds_remainder: entity WORK.get_remainder(rtl)
    port map (
        dividend => input,
        quotient => minutes_divider_out,
        output => seconds
    );

    minutes_remainder: entity WORK.get_remainder(rtl)
    port map (
        dividend => minutes_divider_out_rsize,
        quotient => hours_divider_out,
        output => minutes
    );

    hours <= hours_divider_out(6 downto 0);
end rtl;

------------------------ TENS SPLITTER ----------------------------------------
Library ieee;
use ieee.numeric_std.all;

entity tens_splitter is
    port (
        input: in unsigned(6 downto 0);
        ones: out unsigned(3 downto 0);
        tens: out unsigned(3 downto 0)
    );
end tens_splitter;

architecture rtl of tens_splitter is
    signal divider_in: unsigned(16 downto 0);
    signal divider_out: unsigned(11 downto 0);
    signal remainder_out: unsigned(6 downto 0);
begin
    divider_instance: entity WORK.divider(rtl)
    generic map (
        scaled_divisor => 103,
        scaling_shift => 10
    )
    port map (
        input => divider_in,
        output => divider_out
    );

    remainder_instance: entity WORK.get_remainder(rtl)
    generic map (
        divisor => 10
    )
    port map (
        dividend => divider_in,
        quotient => divider_out,
        output => remainder_out
    );

    divider_in <= resize(input, divider_in'length);
    tens <= divider_out(3 downto 0);
    ones <= remainder_out(3 downto 0);
end rtl;

------------------------ SEGMENT DISPLAY DECODER-------------------------------
Library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity seven_seg_decoder is
    port (
        input: in unsigned(3 downto 0);
        output: out std_logic_vector(6 downto 0)
    );
end seven_seg_decoder;

architecture rtl of seven_seg_decoder is
begin
    with input select
        output <=
            "0000001" when "0000",
            "1001111" when "0001",
            "0010010" when "0010",
            "0000110" when "0011",
            "1001100" when "0100",
            "0100100" when "0101",
            "0100000" when "0110",
            "0001111" when "0111",
            "0000000" when "1000",
            "0000100" when "1001",
            "0001000" when "1010",
            "1100000" when "1011",
            "0110001" when "1100",
            "1000010" when "1101",
            "0110000" when "1110",
            "0111000" when "1111",
            "1111111" when others;
end rtl;

------------------------ MAIN PROGRAM -----------------------------------------
Library ieee;
use ieee.std_logic_1164.all;

package pkg is
    type t_display_outputs is array (0 to 5) of STD_LOGIC_VECTOR(0 to 6);
end package pkg;

Library ieee;
use WORK.pkg.t_display_outputs;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity quartime is
    port(
        dot_a: out std_logic := '0';
        dot_b: out std_logic := '0';
        clock: in std_logic;
        reset: in std_logic;
        stop: in std_logic;
        display_outputs: out t_display_outputs
    );
end entity quartime;

architecture rtl of quartime is
    type t_tens_splitter_inputs is array (0 to 2) of unsigned(6 downto 0);
    type t_seven_seg_inputs is array (0 to 5) of unsigned(3 downto 0);

    signal tens_splitter_inputs: t_tens_splitter_inputs;
    signal seven_seg_inputs: t_seven_seg_inputs;
    signal second_counter_out: unsigned(16 downto 0);
begin

    second_counter: entity WORK.second_counter(rtl)
    port map (
        input => clock,
        reset => reset,
        stop => stop,
        output => second_counter_out
    );

    time_decoder: entity WORK.time_decoder(rtl)
    port map (
        input => second_counter_out,
        seconds => tens_splitter_inputs(0),
        minutes => tens_splitter_inputs(1),
        hours => tens_splitter_inputs(2)
    );

    gen_tens_splitters: for i in 0 to 2 generate
        decoder: entity WORK.tens_splitter(rtl)
        port map (
            input => tens_splitter_inputs(i),
            ones => seven_seg_inputs(i * 2),
            tens => seven_seg_inputs(i * 2 + 1)
        );
    end generate gen_tens_splitters;

    gen_seven_seg_decoders: for i in 0 to 5 generate
        seven_seg_decoder: entity WORK.seven_seg_decoder(rtl)
        port map (
            input => seven_seg_inputs(i),
            output => display_outputs(i)
        );
    end generate gen_seven_seg_decoders;

end architecture rtl;

