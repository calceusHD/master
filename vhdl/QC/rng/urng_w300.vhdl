LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity urng_w300 is
  generic(
    W:integer:=234
  );
  port(
    clk:in std_logic;
    ce : in std_logic;
    load_en : in std_logic;
    load_data : in std_logic;
    rng:out std_logic_vector(W-1 downto 0)
  );
end urng_w300;

architecture RTL of urng_w300 is
begin
  assert W=300 report "This RNG only does W=300" severity failure;

  the : entity work.rng_n300_r300_t5_k0_s778
    port map(clk=>clk,ce=>ce,mode=>load_en,s_in=>load_data,rng=>rng);
end RTL;
