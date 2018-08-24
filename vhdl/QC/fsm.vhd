library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

-- we need some sigals...  LUL some, more like a metric ton
/*
	so the task for this fsm is to wait until a complete set of data is received and the start the decoding process
	the decoding process has no additional dependencies except the signal that tells us if the errors are corrected and we shall stop. Otherwise the complete set of signal for each step of the decoding process will be read from memory
	vn_mem address read / write seperate?
	vn_mem read / write enable
	vn_global step reset
	
	vn_sum write address
	vn_sum read / write enable
	
	global check node / global variable node connection control
*/


entity fsm is
	port (
		clk : in std_logic;
		res : in std_logic;
		start : in std_logic;
		no_error : in std_logic;

		row_end : out std_logic;
		col_end : out std_logic;
		llr_mem_rd : out std_logic;
		llr_mem_addr : out row_addr_t;
		result_addr : out row_addr_t;
		result_wr : out std_logic;
		store_cn_wr : out std_logic;
		store_cn_addr : out col_addr_t;
		load_cn_rd : out std_logic;
		load_cn_addr : out col_addr_t;
		store_vn_wr : out std_logic;
		store_vn_addr : out row_addr_t;
		load_vn_rd : out std_logic;
		load_vn_addr : out row_addr_t;
		min_offset : out min_id_t;
		roll : out roll_t
	);
end entity;

architecture base of fsm is
	signal inst_read_addr : unsigned;
	signal current_inst : inst_t;
	type states_t is (FSM_IDLE, FSM_WORK);
	signal state : states_t := FSM_IDLE;
begin
	process (clk)
	begin
		if rising_edge(clk) then
			if res = '1' then
				state <= FSM_IDLE;
			else
				if start = '1' then
					state <= FSM_WORK;
				end if;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			if state = FSM_WORK then
				current_inst <= 

end architecture;
