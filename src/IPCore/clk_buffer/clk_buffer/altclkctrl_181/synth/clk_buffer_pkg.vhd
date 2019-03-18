library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package clk_buffer_pkg is
	component clk_buffer_altclkctrl_181_4ev4gqi is
		port (
			inclk  : in  std_logic := 'X'; -- inclk
			outclk : out std_logic         -- outclk
		);
	end component clk_buffer_altclkctrl_181_4ev4gqi;

end clk_buffer_pkg;
