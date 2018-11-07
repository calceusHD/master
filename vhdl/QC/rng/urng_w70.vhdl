LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity urng_w70 is
  generic(
    W:integer:=70
  );
  port(
    clk:in std_logic;
    ce : in std_logic;
    load_en : in std_logic;
    load_data : in std_logic;
    rng:out std_logic_vector(W-1 downto 0)
  );
end urng_w70;

architecture RTL of urng_w70 is
begin
  assert W=70 report "This RNG only does W=70" severity failure;

  the : entity work.rng_n70_r70_t4_k1_s4b8
    port map(clk=>clk,ce=>ce,mode=>load_en,s_in=>load_data,rng=>rng);
end RTL;
