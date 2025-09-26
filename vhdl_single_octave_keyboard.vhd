-- Western Carolina University
-- EE221 - Logic Design Systems I - Fall 2024
-- Jake Elmore
-- Single Octave Keyboard 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity octave1 is
    port (
        switch   : in std_logic_vector(7 downto 0);  			-- 8 slide switches
        clk      : in std_logic;                    			-- 50 MHz clock input
        resetn   : in std_logic;                    			-- Active-low reset
        buzzer   : out std_logic;                   			-- Piezo buzzer output
        seg7_0   : out std_logic_vector(6 downto 0); 			-- Left-most 7-segment (note character)
        seg7_1   : out std_logic_vector(6 downto 0); 			-- Second 7-segment (hundreds place)
        seg7_2   : out std_logic_vector(6 downto 0); 			-- Third 7-segment (tens place)
        seg7_3   : out std_logic_vector(6 downto 0)  			-- Fourth 7-segment (ones place)
    );
end octave1;

architecture behavioral of octave1 is

    signal q        : integer range 0 to 7 := 0;         	-- Priority encoder output (0-7 based on switches)
    signal freq     : std_logic_vector(23 downto 0);    		-- Frequency divider value for buzzer
    signal cnt      : std_logic_vector(23 downto 0);    		-- Clock counter for toggling buzzer
    signal pulse    : std_logic;                        		-- Toggle signal for buzzer sound
    signal freq_disp: std_logic_vector(11 downto 0);    		-- Frequency in display format (12 bits)
    signal hundreds, tens, ones : integer range 0 to 9; 		-- Individual digits of the frequency
    signal all_off  : std_logic;                        		-- Flag indicating if all switches are off

    -- Note Character Mapping for the left-most 7-segment display
    type char_map is array(0 to 7) of std_logic_vector(6 downto 0);
    constant char_values: char_map := (
        0 => "0001000", -- A
        1 => "0000011", -- B
        2 => "1000110", -- C
        3 => "0100001", -- D
        4 => "0000110", -- E
        5 => "0001110", -- F
        6 => "0010000", -- G
        7 => "0001000"  -- A'
    );

    -- Digit Mapping for numeric 7-segment displays
    type digit_map is array(0 to 9) of std_logic_vector(6 downto 0);
    constant digit_values: digit_map := (
        0 => "1000000", -- 0
        1 => "1111001", -- 1
        2 => "0100100", -- 2
        3 => "0110000", -- 3
        4 => "0011001", -- 4
        5 => "0010010", -- 5
        6 => "0000010", -- 6
        7 => "1111000", -- 7
        8 => "0000000", -- 8
        9 => "0010000"  -- 9
    );

begin

    -- Determine if all switches are off
    all_off <= '1' when unsigned(switch) = 0 else '0';

    -- Priority encoder: Select the highest-priority switch
    priority_encoder: process(switch)
    begin
        if switch(7) = '1' then
            q <= 7; -- Highest priority
        elsif switch(6) = '1' then
            q <= 6;
        elsif switch(5) = '1' then
            q <= 5;
        elsif switch(4) = '1' then
            q <= 4;
        elsif switch(3) = '1' then
            q <= 3;
        elsif switch(2) = '1' then
            q <= 2;
        elsif switch(1) = '1' then
            q <= 1;
        else
            q <= 0; 
        end if;
    end process;

    -- Frequency encoder: Map selected note (q) to frequency and display value
    frequency_encoder: process(q, all_off)
    begin
        if all_off = '1' then
            freq <= (others => '0'); 		-- No frequency when switches are off
            freq_disp <= (others => '0'); -- No display
        else
            case q is
                when 0 => freq <= x"01BBE4"; freq_disp <= "000110111000"; -- 440 Hz (A)
                when 1 => freq <= x"018B5F"; freq_disp <= "000111101110"; -- 494 Hz (B)
                when 2 => freq <= x"016069"; freq_disp <= "001000101010"; -- 554 Hz (C)
                when 3 => freq <= x"014C5E"; freq_disp <= "001001001011"; -- 587 Hz (D)
                when 4 => freq <= x"012845"; freq_disp <= "001010010011"; -- 659 Hz (E)
                when 5 => freq <= x"0107F0"; freq_disp <= "001011100011"; -- 739 Hz (F)
                when 6 => freq <= x"00EB52"; freq_disp <= "001100111110"; -- 830 Hz (G)
                when 7 => freq <= x"00DDF2"; freq_disp <= "001101110000"; -- 880 Hz (A')
                when others => freq <= (others => '0'); freq_disp <= (others => '0'); -- Default case
            end case;
        end if;
    end process;

    -- Clock divider: Generate a toggling pulse at the selected frequency
    clock_divider: process(clk, resetn)
    begin
        if resetn = '0' then
            cnt <= (others => '0'); 		-- Reset counter
            pulse <= '0'; 						-- Reset pulse
        elsif rising_edge(clk) then
            if all_off = '1' then
                pulse <= '0'; 				-- Stop buzzer if all switches are off
            elsif cnt = freq then
                cnt <= (others => '0');	-- Reset counter when frequency is reached
                pulse <= not pulse; 		-- Toggle buzzer pulse
            else
                cnt <= cnt + 1; 				-- Increment counter
            end if;
        end if;
    end process;

    -- Extract digits for frequency display
    digit_extraction: process(freq_disp)
        variable freq_value: integer;
    begin
        freq_value := to_integer(unsigned(freq_disp)); 	-- Convert frequency to integer
        hundreds <= freq_value / 100;                 	-- Extract hundreds digit
        tens     <= (freq_value / 10) mod 10;         	-- Extract tens digit
        ones     <= freq_value mod 10;                	-- Extract ones digit
    end process;

    -- Assign 7-segment display outputs
    seg7_0 <= char_values(q) when all_off = '0' else "1111111"; 			-- Show note or blank
    seg7_1 <= digit_values(hundreds) when all_off = '0' else "1111111"; -- Show hundreds or blank
    seg7_2 <= digit_values(tens) when all_off = '0' else "1111111"; 		-- Show tens or blank
    seg7_3 <= digit_values(ones) when all_off = '0' else "1111111"; 		-- Show ones or blank

    -- Drive buzzer with toggled pulse
    buzzer <= pulse;

end behavioral;
