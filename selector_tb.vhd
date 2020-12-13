library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.modulator_pkg.all;
entity selector_tb is
generic(
board_setting_g : board_setting_t := sozius_c; -- defines board specific settings
design_setting_g : design_setting_t := sim_setting_c -- defines design specific settings
);
end entity;
architecture tb of selector_tb is
-- calculates from the design setting the actual used configuration
constant inc_c : a1integer_t := calc_inc_f(board_setting_g, design_setting_g);
signal inc_i_s : std_logic_vector(design_setting_g.freq_hz'length*design_setting_g.nco_width - 1 downto 0)
:= (others => '0');
-- input clock signal
signal clk_s : std_logic := '0';
-- signal used to select output signal increment value
signal sel_s : std_logic_vector(0 downto 0) := (others => '0');
-- signal whose increment value depends on the sel_s state
signal inc_s : std_logic_vector(design_setting_g.nco_width - 1 downto 0) := (others => '0');
begin
-- converts from array of ints to std_logic_vector
inc_i_s <= conv_int_array_to_slv_f(inc_c, design_setting_g.nco_width);
-- Instantiation of device under test (DUT)
-- No component definition is necessary
-- Use keyword entity, work is the library
selector_i : entity work.selector(rtl) -- selector module instance
generic map(
width_g => design_setting_g.nco_width
)
port map(
clk_i => clk_s,
inc_i => inc_i_s,
sel_i => sel_s,
inc_o => inc_s
);
clk_s <= not (clk_s) after 10 ns;
sel_s(0) <= '1' after 200 ns;
end architecture;