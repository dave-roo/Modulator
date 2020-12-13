-- Make reference to libraries that are necessary for this file:
-- the first part is a symbolic name, the path is defined depending of the tools
-- the second part is a package name
-- the third part includes all functions from that package
-- Better for documentation would be to include only the functions that are necessary
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
library work;
use work.modulator_pkg.all;
-- Entity defines the interface of a module
-- Generics are static, they are used at compile time
-- Ports are updated during operation and behave like signals on a schematic or
-- traces on a PCB
-- Entity is a primary design unit
entity modulator is
generic(
-- defines board specific settings
board_setting_g : board_setting_t := sozius_c;
-- defines simulation specific settings
design_setting_g : design_setting_t := sim_setting_c
);
port(
-- input clock signal
clk_i : in std_logic;
-- different increments for different frequencies
inc_i : in std_logic_vector(design_setting_g.freq_hz'length*design_setting_g.nco_width - 1 downto 0);
-- signal made for selecting frequency
sel_i : in std_logic_vector(0 downto 0);
-- pulse width modulated signal
pwm_o : out std_logic
);
end entity;
-- Architecture is a secondary design unit and describes the functionality of the module
-- One entity can have multiple architectures for different families,
-- technologies or different levels of description
-- The name should represent the level of description like
-- structural, rtl, tb and maybe for which technology
architecture rtl of modulator is
-- Between architecture and begin is declaration area for types, signals and constants
-- Everything declared here will be visible in the whole architecture
constant counter_max_c : std_logic_vector(design_setting_g.nco_width - 1 downto 0) := (others => '1');
signal addr_s : std_logic_vector(design_setting_g.nco_width - 1 downto 0) := (others => '0');
signal inc_s : std_logic_vector(design_setting_g.nco_width - 1 downto 0) := (others => '0');
signal data_s : std_logic_vector(design_setting_g.lut_width - 1 downto 0) := (others => '0');
begin
selector_i : entity work.selector(rtl) -- selector module instance
generic map(
width_g => design_setting_g.nco_width
)
port map(
clk_i => clk_i,
inc_i => inc_i,
inc_o => inc_s,
sel_i => sel_i
);
counter_i : entity work.counter(rtl) -- counter module instance
generic map(
bits_g => design_setting_g.nco_width,
count_max_g => to_integer(unsigned(counter_max_c))
)
port map (
clk_i => clk_i,
inc_i => inc_s,
count_o => addr_s
);
waveform_i : entity work.sine(rtl) -- digital sine module instance
generic map(
depth_g => design_setting_g.lut_depth,
width_g => design_setting_g.lut_width
)
port map(
addr_i => addr_s(design_setting_g.nco_width - 1 downto design_setting_g.nco_width - design_setting_g.lut_depth),
clk_i => clk_i,
data_o => data_s
);
pwm_i : entity work.pwm(rtl) -- pwm module instance
generic map (
width_g => design_setting_g.lut_width
)
port map (
clk_i => clk_i,
value_i => data_s,
pwm_o => pwm_o
);
end architecture;