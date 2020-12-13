-- Make reference to libraries that are necessary for this file:
-- the first part is a symbolic name, the path is defined depending of the tools
-- the second part is a package name
-- the third part includes all functions from that package
-- Better for documentation would be to include only the functions that are necessary
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- include user defined modulator_pkg package where are important related
-- declarations that serve a common purpose
library work;
use work.modulator_pkg.all;
-- Entity defines the interface of a module
-- Generics are static, they are used at compile time
-- Ports are updated during operation and behave like signals on a schematic or
-- traces on a PCB
-- Entity is a primary design unit
entity selector is
generic(
num_freqs_g : integer range 1 to 64 := 2; -- number of possible frequencies
width_g : integer range 1 to 64 := 1 -- the number of bits used to represent amplitude value
);
port(
-- input clock signal
clk_i : in std_logic;
-- different increments for different frequencies
-- inc_i port must be std_logic_vector type, because of the Vivado restrictions (IP Integrator and IP Packager)
inc_i : in std_logic_vector(num_freqs_g*width_g - 1 downto 0);
-- signal made for selecting frequency
sel_i : in std_logic_vector(0 downto 0);
-- output signal with appropriate increment value, depends on the sel_i state
inc_o : out std_logic_vector(width_g - 1 downto 0)
);
end entity;
-- Architecture is a secondary design unit and describes the functionality of the module
-- One entity can have multiple architectures for different families,
-- technologies or different levels of description
-- The name should represent the level of description like
-- structural, rtl, tb and maybe for which technology
architecture rtl of selector is
signal inc_s : std_logic_vector(inc_o'range) := (others => '0'); -- clock counter
begin
-- Defines a sequential process
-- Counts two different values depending on the sel_i
muxc_p : process
begin
-- Replaces the sensitivity list
-- Suspends evaluation until an event occurs
-- In our case event we are waiting for is rising edge on the clk_i input port
wait until rising_edge(clk_i);
if (unsigned(sel_i) < (inc_i'length)) then
inc_s <= inc_i((to_integer(unsigned(sel_i))+1)*width_g-1 downto to_integer(unsigned(sel_i))*width_g);
else
inc_s <= (others => '0');
end if;
end process;
inc_o <= inc_s;
end architecture;