-- Make reference to libraries that are necessary for this file:
-- the first part is a symbolic name, the path is defined depending of the tools
-- the second part is a package name
-- the third part includes all functions from that package
-- Better for documentation would be to include only the functions that are necessary
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Entity defines the interface of a module
-- Generics are static, they are used at compile time
-- Ports are updated during operation and behave like signals on a schematic or
-- traces on a PCB
-- Entity is a primary design unit
entity pwm is
generic(
width_g : integer range 1 to 99 := 12 -- the number of bits used to represent amplitude value
);
port(
clk_i : in std_logic; -- input clock signal
value_i : in std_logic_vector(width_g-1 downto 0); -- current amplitude value of the sine signal
pwm_o : out std_logic -- pulse width modulated signal
);
end entity;
-- Architecture is a secondary design unit and describes the functionality of the module
-- One entity can have multiple architectures for different families,
-- technologies or different levels of description
-- The name should represent the level of description like
-- structural, rtl, tb and maybe for which technology
architecture rtl of pwm is
-- Between architecture and begin is declaration area for types, signals and constants
-- Everything declared here will be visible in the whole architecture
signal duration_s : std_logic_vector(width_g -1 downto 0) := (others => '0');
signal count_s : unsigned(width_g - 1 downto 0) := (others => '0');
type state_t is (load_st, pwm_high_st, pwm_low_st); -- states for finite state machine
signal state : state_t;
begin
-- fsm_state_p models state register and next-state logic
fsm_state_p : process
begin
wait until rising_edge(clk_i);
count_s <= count_s + 1;
pwm_o <= '0';
case state is
when load_st =>
if (unsigned(value_i) = 0) then
state <= pwm_low_st;
else
state <= pwm_high_st;
end if;
duration_s <= value_i;
count_s <= (others => '0');
when pwm_high_st =>
if (count_s = unsigned(duration_s)) then
state <= pwm_low_st;
elsif (count_s = 2 ** width_g - 1) then
state <= load_st;
end if;
pwm_o <= '1';
when pwm_low_st =>
-- if count_s is equal to maximum, we go to load_st state
if (count_s = 2 ** width_g - 1) then
state <= load_st;
end if;
end case;
end process;
end architecture;