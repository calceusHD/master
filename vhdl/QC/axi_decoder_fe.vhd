library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity axi_decoder is
    port (
        clk : in std_logic;
        res_e : in std_logic;
        s_tvalid : in std_logic;
        s_tlast : in std_logic;
        s_tdata : in std_logic_vector(31 downto 0);
        s_tready : out std_logic;
        m_tvalid : out std_logic;
        m_tlast : out std_logic;
        m_tdata : out std_logic_vector(31 downto 0);
        m_tready : in std_logic;
        
        max_iter, param_1, param_2 : in std_logic_vector(31 downto 0)
    );
end entity;

architecture base of axi_decoder is
    signal s_wr, s_tready_int, res : std_logic;
    signal llr_wr : std_logic;
    signal llr_rep : llr_column_t;
    signal llr_vec : std_logic_vector(llr_rep'length * llr_rep(0)'length -1 downto 0);
    signal result : min_signs_t;
    signal res_rd, res_end, res_done, res_rdy, rd_mem : std_logic;
	signal end_in, in_wr, in_last, in_valid, res_end_reg : std_logic;
	signal readout : std_logic := '0';
	signal decoder_ready : std_logic := '1';
	signal has_reg : std_logic := '0';
begin
    --s_tready <= '1';
    res <= res_e;
    
    
	process (clk)
	begin
		if rising_edge(clk) then
            if res = '1' then
                readout <= '0';
			elsif res_done = '1' then
				readout <= '1';
			elsif res_end = '1' then
				readout <= '0';
			end if;
            
		res_end_reg <= res_end;
		end if;
	end process;
	res_rd <= readout and res_rdy;
	process (clk)
	begin
        if rising_edge(clk) then
            if res = '1' then
                decoder_ready <= '1';
            elsif in_last = '1' then
                decoder_ready <= '0';
            elsif res_end_reg = '1' then
                decoder_ready <= '1';
            end if;
        end if;
    end process;
    in_wr <= decoder_ready and in_valid;

	rd_mem <= readout and res_rdy;

    remap_gen : for i in llr_rep'range generate
        constant start : natural := (i+1) * llr_rep(0)'length - 1;
        constant stop : natural := i * llr_rep(0)'length;
    begin
        llr_rep(llr_rep'length - i - 1) <= 
                     signed(llr_vec(start downto stop));
    end generate;

    decoder_inst : entity work.decoder
    port map (
        clk => clk,
        res => res,
        llr_in => llr_rep,
        wr_in => in_wr,
        end_in => in_last,
        res_out => result,
        res_rd => rd_mem,
        res_end => res_end,
		res_done => res_done,
		max_iter => max_iter,
		param_1 => param_1,
		param_2 => param_2
    );

    slave_repack : entity work.axi_repack
	generic map (
		LAST_WORD_PADDING => 8
	)
    port map (
        clk => clk,
        res => res,
        in_bits => s_tdata,
        out_bits => llr_vec,
        in_ready => s_tready,
		in_valid => s_tvalid,
		in_last => s_tlast,
		out_ready => decoder_ready,
		out_valid => in_valid,
		out_last => in_last	
	);

    master_repack : entity work.axi_repack
	generic map (
		LAST_WORD_PADDING => 8
	)
    port map (
        clk => clk,
        res => res,
        in_bits => result,
        out_bits => m_tdata,
        in_ready => res_rdy,
		in_valid => res_rd,
		in_last => res_end,
		out_ready => m_tready,
		out_valid => m_tvalid,
		out_last => m_tlast
	);


end architecture;
