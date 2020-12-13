library ieee;
use ieee.std_logic_1164.all;
library work;
use work.modulator_pkg.all;
entity counter_tb is
-- Use lower values for generics to speed up simulation time
generic(
bits_g : integer range 1 to 99 := 4; -- the number of samples in one period of the signal
count_max_g : integer := 12 -- threshold value for counter
);
end entity;
architecture tb of counter_tb is
signal clk_s : std_logic := '1'; -- input clock signal
signal inc_s : std_logic_vector(bits_g - 1 downto 0) := X"3"; -- counter increment value
signal count_s : std_logic_vector(bits_g - 1 downto 0) := (others => '0'); -- current counter value
begin
-- Instantiation of device under test (DUT)
-- No component definition is necessary
-- Use keyword entity, work is the library
counter_i : entity work.counter(rtl)
generic map(
bits_g => bits_g,
count_max_g => count_max_g
)
port map (
clk_i => clk_s,
inc_i => inc_s,
count_o => count_s
);
clk_s <= not (clk_s) after 5 ns; -- generates input clock signal
end architecture;