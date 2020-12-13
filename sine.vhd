-- Make reference to libraries that are necessary for this file:
-- the first part is a symbolic name, the path is defined depending of the tools
-- the second part is a package name
-- the third part includes all functions from that package
-- Better for documentation would be to include only the functions that are necessary
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.modulator_pkg.all;
-- Entity defines the interface of a module
-- Generics are static, they are used at compile time
-- Ports are updated during operation and behave like signals on a schematic or
-- traces on a PCB
-- Entity is a primary design unit
entity sine is
generic(
depth_g : integer range 1 to 99 := 8; -- the number of samples in one period of the signal
width_g : integer range 1 to 99 := 12 -- the number of bits used to represent amplitude value
);
port(
clk_i : in std_logic; -- input clock signal
addr_i : in std_logic_vector(depth_g-1 downto 0); -- address value for the sine waveform ROM
data_o : out std_logic_vector(width_g-1 downto 0) -- current amplitude value of the sine signal
);
end entity;
-- Architecture is a secondary design unit and describes the functionality of the module
-- One entity can have multiple architectures for different families,
-- technologies or different levels of description
-- The name should represent the level of description like
-- structural, rtl, tb and maybe for which technology
architecture rtl of sine is
-- Between architecture and begin is declaration area for types, signals and constants
-- Everything declared here will be visible in the whole architecture
constant data_c : a1integer_t := init_sin_f(depth_g, width_g); -- returns sine amplitude value
signal addr_s : integer range 0 to 2 ** depth_g - 1 := 0; -- amplitude counter
signal data_s : std_logic_vector(width_g-1 downto 0) := (others=>'0'); -- sine signal
begin
-- Defines a sequential process
-- Fetches amplitude values and frequency -> generates sine
sine_p : process
begin
-- Replaces the sensitivity list
-- Suspends evaluation until an event occurs
-- In our case event we are waiting for is rising edge on the clk_i input port
wait until rising_edge(clk_i);
-- converts addr_i from std_logic_vector type to integer type
addr_s <= to_integer(unsigned(addr_i));
-- converts data_c from integer type to std_logic_vector type
data_s <= std_logic_vector(to_unsigned(data_c(addr_s), width_g)); -- fetch amplitude
end process;
data_o <= data_s;
end architecture;