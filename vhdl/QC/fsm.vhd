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
		store_signs_wr : out std_logic;
		store_signs_addr : out signs_addr_t;
		load_signs_rd : out std_logic;
		load_signs_addr : out signs_addr_t;
		min_offset : out min_id_t;
		roll : out roll_t
	);
end entity;

architecture base of fsm is
	signal inst_read_addr : unsigned(32 downto 0);
	signal current_inst : inst_t;
	type states_t is (FSM_IDLE, FSM_WORK);
	signal state : states_t := FSM_IDLE;
    signal done_int : std_logic;
begin

    row_end <= current_inst.row_end;
    col_end <= current_inst.col_end;
    llr_mem_rd <= current_inst.llr_mem_rd;
    llr_mem_addr <= current_inst.llr_mem_addr;
    result_wr <= current_inst.result_wr;
    result_addr <= current_inst.result_addr;
    store_cn_wr <= current_inst.store_cn_wr;
    store_cn_addr <= current_inst.store_cn_addr;
    load_cn_rd <= current_inst.load_cn_rd;
    load_cn_addr <= current_inst.load_cn_addr;
    store_vn_wr <= current_inst.store_vn_wr;
    store_vn_addr <= current_inst.store_vn_addr;
    load_vn_rd <= current_inst.load_vn_rd;
    load_vn_addr <= current_inst.load_vn_addr;
    store_signs_wr <= current_inst.store_signs_wr;
    store_signs_addr <= current_inst.store_signs_addr;
    load_signs_rd <= current_inst.load_signs_rd;
    load_signs_addr <= current_inst.load_signs_addr;
    min_offset <= current_inst.min_offset;
    roll <= current_inst.roll;

	process (clk)
	begin
		if rising_edge(clk) then
			if res = '1' then
				state <= FSM_IDLE;
			else
				if start = '1' then
					state <= FSM_WORK;
				end if;
                if done_int = '1' then
                    state <= FSM_IDLE;
                end if;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			if state = FSM_WORK then
				current_inst <= INSTRUCTIONS(to_integer(inst_read_addr));
                if inst_read_addr = INSTRUCTIONS'high then
					if no_error = '1' then
                    	done_int <= '1';
					else
						inst_read_addr <= (others => '0');
					end if;
                else
                    inst_read_addr <= inst_read_addr + 1;
                end if;
            else
                done_int <= '0';
                inst_read_addr <= (others => '0');
            end if;
        end if;
    end process;

end architecture;
