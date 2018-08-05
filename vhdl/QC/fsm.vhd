library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

-- we need some sigals...
/*
	vn_mem address read / write seperate?
	vn_mem read / write enable
	vn_global step reset
	
	vn_sum write address
	vn_sum read / write enable
	
	global check node / global variable node connection control
*/


entity fsm is
	port (
		clk : std_logic;
		res : std_logic;
		
	);
end entity;

architecture base of fsm is
	
begin

