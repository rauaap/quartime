LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY quartime_vhd_tst IS
END quartime_vhd_tst;

ARCHITECTURE quartime_arch OF quartime_vhd_tst IS
    signal seven_seg_input: std_logic_vector(0 to 3);
    signal seven_seg_output: std_logic_vector(0 to 6);

    signal divider_input: unsigned(16 downto 0);
    signal divider_output: unsigned(11 downto 0);

    signal get_remainder_dividend: unsigned(16 downto 0);
    signal get_remainder_quotient: unsigned(11 downto 0);
    signal get_remainder_output: unsigned(6 downto 0);

    signal tens_splitter_input: unsigned(6 downto 0);
    signal tens_splitter_ones: unsigned(3 downto 0);
    signal tens_splitter_tens: unsigned(3 downto 0);

    signal time_decoder_input: unsigned(16 downto 0);
    signal time_decoder_seconds: unsigned(6 downto 0);
    signal time_decoder_minutes: unsigned(6 downto 0);
    signal time_decoder_hours: unsigned(6 downto 0);

    BEGIN
        seven_seg_decoder: entity WORK.seven_seg_decoder(rtl)
        port map (
            input => seven_seg_input,
            output => seven_seg_output
        );

        divider: entity WORK.divider(rtl)
        port map (
            input => divider_input,
            output => divider_output
        );

        get_remainder: entity WORK.get_remainder(rtl)
        port map (
            dividend => get_remainder_dividend,
            quotient => get_remainder_quotient,
            output => get_remainder_output
        );

        tens_splitter: entity WORK.tens_splitter(rtl)
        port map (
            input => tens_splitter_input,
            ones => tens_splitter_ones,
            tens => tens_splitter_tens
        );

        time_decoder: entity WORK.time_decoder(rtl)
        port map (
            input => time_decoder_input,
            seconds => time_decoder_seconds,
            minutes => time_decoder_minutes,
            hours => time_decoder_hours
        );

    init : PROCESS
    -- variable declarations
    BEGIN
    WAIT;
    END PROCESS init;

    always : PROCESS
    BEGIN
        for n in 0 to 24 loop
            time_decoder_input <= to_unsigned(n * 60 * 60, 17);
            wait for 5 ns;
        end loop;
--        get_remainder_dividend <= to_unsigned(1000, 17);
--        get_remainder_quotient <= to_unsigned(16, 12);
--        tens_splitter_input <= to_unsigned(67, 7);
--
--        for n in 0 to 9 loop
--            seven_seg_input <= std_logic_vector(to_unsigned(n, 4));
--            wait for 5 ns;
--        end loop;
--
--        for x in 1 to 1440 loop
--            divider_input <= to_unsigned(x * 60, 17);
--            wait for 5 ns;
--        end loop;
    WAIT;
    END PROCESS always;
END quartime_arch;
