library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

use work.modulator_pkg.all;
entity modulator_tb is
generic(
-- defines board specific settings
board_setting_g : board_setting_t := sozius_c;
-- defines simulation specific settings
design_setting_g : design_setting_t := sim_setting_c;
-- defines duration of the simulation process
sim_end_g : time := 10 ms
);
end entity;
architecture tb of modulator_tb is
-- period of input clock signal
constant clock_period_c : time := 1000000000.0 / board_setting_g.fclk * 1 ns;
constant inc_c : a1integer_t := calc_inc_f(board_setting_g, design_setting_g);
signal inc_s : std_logic_vector(design_setting_g.freq_hz'length*design_setting_g.nco_width - 1 downto 0) := (others => '0');
signal clk_s : std_logic := '1'; -- input clock signal
signal sel_s : std_logic_vector(0 downto 0); -- signal made for selecting frequency
signal pwm_s : std_logic := '0'; -- pulse width modulated signal
begin
-- converts from array of ints to std_logic_vector
inc_s <= conv_int_array_to_slv_f(inc_c, design_setting_g.nco_width);
modulator_i : entity work.modulator -- modulator module instance
generic map(
design_setting_g => design_setting_g,
board_setting_g => board_setting_g
)
port map(
clk_i => clk_s,
inc_i => inc_s,
sel_i => sel_s,
pwm_o => pwm_s
);
clk_p: process -- generates input clock signal
begin
while (now < sim_end_g) loop
clk_s <= not (clk_s);
wait for clock_period_c/2;
end loop;
wait;
end process;
sel_s(0) <= '0', '1' after sim_end_g * 3 / 4;
end architecture;