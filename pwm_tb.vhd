library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

use work.modulator_pkg.all;
entity pwm_tb is
generic(
-- defines board specific settings
board_setting_g : board_setting_t := sozius_c;
-- defines simulation specific settings
design_setting_g : design_setting_t := sim_setting_c
);
end entity;
architecture tb of pwm_tb is
-- period of input clock signal
constant clock_period_c : time := 1000000000.0 / board_setting_g.fclk * 1 ns;
-- max number of samples in one period of the sine signal
constant counter_max_c : unsigned(design_setting_g.lut_width - 1 downto 0) := (others => '1');
signal clk_s : std_logic := '0'; -- input clock signal
signal count_s : unsigned(design_setting_g.lut_width - 1 downto 0) := (others => '0');
-- counts samples in one period of the sine signal
signal data_s : unsigned(design_setting_g.lut_width - 1 downto 0) := (others => '0');
-- current amplitude value of the sine signal
signal pwm_s : std_logic := '0'; -- pwm signal
signal sim_end_s : boolean := false; -- end of simulation process
begin
ramp_p : process
begin
wait until rising_edge(clk_s);
if (count_s = 2 ** design_setting_g.lut_width - 1) then
count_s <= (others => '0');
if (data_s = counter_max_c) then
wait for 20 us;
data_s <= (others => '0') ;
sim_end_s <= true;
else
data_s <= data_s + 1;
end if;
else
count_s <= count_s + 1;
end if;
end process;
pwm_i : entity work.pwm(rtl) -- pwm module instance
generic map (
width_g => design_setting_g.lut_width
)
port map (
clk_i => clk_s,
value_i => std_logic_vector(data_s),
pwm_o => pwm_s
);
clk_p : process -- generates input clock signal
begin
while not (sim_end_s) loop
clk_s <= not (clk_s);
wait for clock_period_c/2;
end loop;
wait;
end process;
end architecture;