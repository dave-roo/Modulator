library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Entity defines the interface of a module
-- Generics are static, they are used at compile time
-- Ports are updated during operation and behave like signals on a schematic or
-- traces on a PCB
-- Entity is a primary design unit
entity counter is
generic(
bits_g : integer range 1 to 99 := 1; -- the number of samples in one period of the signal
count_max_g : integer -- threshold value for counter
);
port(
clk_i : in std_logic; -- input clock signal
inc_i : in std_logic_vector(bits_g - 1 downto 0); -- counter increment value
count_o : out std_logic_vector(bits_g - 1 downto 0) -- current counter value
);
end entity;
architecture rtl of counter is
-- Between architecture and begin is declaration area for types, signals and constants
-- Everything declared here will be visible in the whole architecture
signal count_s : unsigned (count_o'range) := (others => '0');
begin
-- Defines a sequential process
-- This will be universal (generic) counter
counter_p: process
begin
-- Replaces the sensitivity list
-- Suspends evaluation until an event occurs
-- In our case event we are waiting for is rising edge on the clk_i input port
wait until rising_edge(clk_i);
-- to_unsigned function converts from integer type to unsigned integer type
if (count_s = to_unsigned(count_max_g, count_s'length)) then
count_s <= (others => '0'); -- counter reset
else
count_s <= count_s + unsigned(inc_i); -- counting
end if;
end process;
count_o <= std_logic_vector(count_s);
end architecture;