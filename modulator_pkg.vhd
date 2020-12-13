-- Make reference to libraries that are necessary for this file:
-- the first part is a symbolic name, the path is defined depending of the tools
-- the second part is a package name
-- the third part includes all functions from that package
-- Better for documentation would be to include only the functions that are necessary
library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- VHDL package is a way of grouping related declarations that serve a common purpose
-- Each VHDL package contains package declaration and package body
-- Package declaration:
package modulator_pkg is
-- type declarations
type a1integer_t is array (natural range <>) of integer;
type module_is_top_t is (yes, no); -- only the top module can instantiate a diff clk buffer
type board_type_t is (lx9, zedboard, ml605, kc705, microzed, sozius, undefined); -- enumeration type
type has_diff_clk_t is (yes, no); -- enumeration type for differential clock buffer use
type a1real_t is array (natural range <>) of real;
-- defines board specific settings
type board_setting_t is record
board_name : board_type_t; -- specifies the name of the board that we are using
fclk : real; -- specifies the reference clock frequency that is presented of the board (in Hz)
has_diff_clk : has_diff_clk_t; -- specifies if board has differential clock or not
end record;
-- place the information about the new boards here, assignment by position
constant lx9_c : board_setting_t := (lx9, 100000000.0, no); -- Spartan-6
constant zedboard_c : board_setting_t := (zedboard, 100000000.0, no); -- Zynq-7000
constant ml605_c : board_setting_t := (ml605, 200000000.0, yes); -- Virtex-6
constant kc705_c : board_setting_t := (kc705, 200000000.0, yes); -- Kintex-7
constant microzed_c : board_setting_t := (microzed, 33333333.3, no); -- MicroZed
constant sozius_c : board_setting_t := (sozius, 50000000.0, no); -- Sozius
constant undefined_c : board_setting_t := (undefined, 50000000.0, no); -- not defined
-- defines design specific settings
type design_setting_t is record
freq_hz : a1real_t(0 to 1); -- frequencies for the PWM signal, specified in Hz
lut_depth : integer range 0 to 31; -- the number of samples in one period of the signal
lut_width : integer range 0 to 63; -- the number of bits used to represent amplitude value
nco_width : integer range 0 to 63; -- number of bits used for numerically controlled oscillator
end record;
-- defines audio specific settings
constant audio_setting_c : design_setting_t :=
(
freq_hz => (880.0, 440.0),
lut_depth => 12,
lut_width => 8,
nco_width => 24
);

-- defines led specific settings
constant led_setting_c : design_setting_t :=
(
freq_hz => (1.0, 3.5),
lut_depth => 12,
lut_width => 16,
nco_width => 31
);
-- defines simulation specific settings
constant sim_setting_c : design_setting_t :=
(
freq_hz => (1000.0, 10000.0),
lut_depth => 12,
lut_width => 8,
nco_width => 24
);
-- defines simulation specific settings
constant sim_setting1_c : design_setting_t :=
(
freq_hz => (1000.0, 10000.0),
lut_depth => 12,
lut_width => 16,
nco_width => 31
);
-- calculates from the design setting the actual used configuration
function calc_inc_f
(
constant board_c : board_setting_t;
constant design_c : design_setting_t
)
return a1integer_t;
-- init_sin_f function declaration
function init_sin_f
(
constant depth_c : in integer; -- is the number of samples in one period of the signal (2^8=256)
constant width_c : in integer -- is the number of bits used to represent amplitude value (2^12=4096)
)
return a1integer_t;
-- converts from array of ints to std_logic_vector
function conv_int_array_to_slv_f
(
constant int_array_i : a1integer_t;
constant width_c : integer
)
return std_logic_vector;
end package;
-- in the package body will be description of the function defined before
package body modulator_pkg is
-- calculates from the design setting the actual used configuration
function calc_inc_f
(
constant board_c : board_setting_t;
constant design_c : design_setting_t
)
return a1integer_t is
variable inc_v : a1integer_t(design_c.freq_hz'range);
begin
for i in design_c.freq_hz'range loop
inc_v(i) := integer(round(real(2 ** design_c.nco_width) * design_c.freq_hz(i) / board_c.fclk));
end loop;
return inc_v;
end function;
-- init_sin_f function definition
function init_sin_f
(
constant depth_c : in integer;
constant width_c : in integer
)
return a1integer_t is
variable init_arr_v : a1integer_t(0 to (2 ** depth_c - 1));
begin
for i in 0 to ((2 ** depth_c)- 1) loop -- calculates amplitude values
-- sin (2*pi*i / N) * (2width_c-1 - 1) + 2width_c-1 - 1, N = 2depth_c
init_arr_v(i):=integer(round(sin((math_2_pi / real(2 ** depth_c)) * real(i)) *

(real(2 ** (width_c - 1)) - 1.0))) + integer(2 ** (width_c - 1) - 1);
end loop;
return init_arr_v;
end function;
-- converts from array of ints to std_logic_vector
function conv_int_array_to_slv_f
(
constant int_array_i : a1integer_t;
constant width_c : integer
)
return std_logic_vector is
variable out_slv_v : std_logic_vector(int_array_i'length*width_c-1 downto 0) := (others => '0');
begin
for i in int_array_i'range loop
out_slv_v((i+1)*width_c-1 downto i*width_c) := std_logic_vector(to_unsigned(int_array_i(i), width_c));
end loop;
return out_slv_v;
end function;
end package body;