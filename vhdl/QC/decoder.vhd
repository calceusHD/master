library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity decoder is
	port (
		clk : in std_logic;
		res : in std_logic;
		llr_in : in llr_column_t;
		wr_in : in std_logic;
		end_in : in std_logic;
		res_out : out min_signs_t;
		res_rd : out std_logic;
		res_end : out std_logic

	);
end entity;

architecture base of decoder is
    signal offset : min_id_t;
	signal roll : roll_t;
	signal row_end, col_end, no_error : std_logic;
	signal llr_mem_rd, result_wr, store_cn_wr, load_cn_rd, store_vn_wr, load_vn_rd, store_signs_wr, load_signs_rd : std_logic;
	signal load_min, load_min2, store_min, store_min2 : min_array_t;
	signal load_min_id, store_min_id : min_id_array_t;
	signal load_sign, store_sign : min_signs_t;
	signal load_signs, store_signs : signs_t;
	signal cn_local_roll, roll_vn, vn_local_roll, roll_cn_global, vn_local_cn_global : llr_array_t;
	signal load_col_sum, store_col_sum, current_llr_in : column_sum_array_t;
	signal llr_mem_addr, result_addr, store_vn_addr, load_vn_addr : row_addr_t;
	signal store_cn_addr, load_cn_addr : col_addr_t;
	signal store_result : min_signs_t;
	signal store_signs_addr, load_signs_addr : signs_addr_t;
begin
	fsm_inst : entity work.fsm
	port map (
		clk => clk,
		res => res,
		start => end_in,
		no_error => no_error,
		row_end => row_end,
		col_end => col_end,
		llr_mem_rd => llr_mem_rd,
		llr_mem_addr => llr_mem_addr,
		result_addr => result_addr,
		result_wr => result_wr,
		store_cn_wr => store_cn_wr,
		store_cn_addr => store_cn_addr,
		load_cn_rd => load_cn_rd,
		load_cn_addr => load_cn_addr,
		store_vn_wr => store_vn_wr,
		store_vn_addr => store_vn_addr,
		load_vn_rd => load_vn_rd,
		load_vn_addr => load_vn_addr,
		min_offset => offset,
		roll => roll
	);


--so as I do 2 distinct step but they have some functions in common so I get a big mess. As I want to save hardware I have to combine it into 1 file. 
    --the two different paths are cn_local -> roll -> vn_local -> roll -> cn_global
    --and cn_local -> roll -> vn_global
--so after the first roll the data is pushed to different targets, but I can just leave both connected so no problem. Only two seperate datapaths.

	cn_local_inst : entity work.cn_local
	port map (
		min_in => load_min,
		min2_in => load_min2,
		min_id_in => load_min_id,
		sign_in => load_sign,
		signs => load_signs,
		data_out => cn_local_roll,
		offset => offset
	);

	roll_1 : entity work.dynamic_roll
	generic map (
		DIRECTION => false
	)
	port map (
		roll_count => roll,
		data_in => cn_local_roll,
		data_out => roll_vn
	);

	--starting the second chain. I'll continue later with the first one.

	vn_global_inst : entity work.vn_global_accu
	port map (
		clk => clk,
		data_in => vn_local_cn_global,
		col_end => col_end,
		preload_in => current_llr_in,
		sum_out => store_col_sum
	);
	--and continuing with the first

	vn_local_inst : entity work.vn_local
	port map (
		col_sum => load_col_sum,
		data_in => roll_vn,
		data_out => vn_local_roll
	);
	
	roll_2 : entity work.dynamic_roll
	generic map (
		DIRECTION => true
	)
	port map (
		roll_count => roll,
		data_in => vn_local_roll,
		data_out => roll_cn_global
	);

	cn_global_inst : entity work.cn_global_accu
	port map (
		clk => clk,
		data_in => roll_cn_global,
		row_end => row_end,
		offset => offset,
		min_out => store_min, 
		min2_out => store_min2,
		min_id_out => store_min_id,
		sign_out => store_sign,
		signs_out => store_signs
	);

	--now follows the memory
	
	--oh no not the memory
    
	llr_mem_inst : entity work.llr_in_memory
	port map (
		clk => clk,
		res => res,
		llr_in => llr_in,
		wr_in => wr_in,
		end_in => end_in,
		llr_out => current_llr_in,
		rd_in => llr_mem_rd,
		rd_addr => llr_mem_addr
	);

	result_memory_inst : entity work.result_memory
	port map (
		clk => clk,
		res => res,
		res_in => store_result,
		addr_in => result_addr,
		wr_in => result_wr,
		res_out => res_out,
		res_rd => res_rd,
		res_end => res_end
	);

	cn_memory_inst : entity work.cn_memory
	port map (
		clk => clk,
		min_in => store_min,
		min2_in => store_min2,
		min_id_in => store_min_id,
		sign_in => store_sign,
		wr_in => store_cn_wr,
		wr_addr => store_cn_addr,
		min_out => load_min,
		min2_out => load_min2,
		min_id_out => load_min_id,
		sign_out => load_sign,
		rd_in => load_cn_rd,
		rd_addr => load_cn_addr
	);

	vn_memory_inst : entity work.vn_memory
	port map (
		clk => clk,
		sum_in => store_col_sum,
		wr_in => store_vn_wr,
		wr_addr => store_vn_addr,
		sum_out => load_col_sum,
		rd_in => load_vn_rd,
		rd_addr => load_vn_addr
	);

	signs_memory_inst : entity work.signs_memory
	port map (
		clk => clk,
		signs_in => store_signs,
		wr_in => store_signs_wr,
		wr_addr => store_signs_addr,
		signs_out => load_signs,
		rd_in => load_signs_rd,
		rd_addr => load_signs_addr
	);
end architecture;
