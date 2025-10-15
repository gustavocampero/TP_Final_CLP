library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addsub_tb is
end entity;

architecture addsub_tb_arq of addsub_tb is
  constant W_tb : integer := 8;

  -- DUT component
  component addsub is
    generic ( W : integer := 8 );
    port (
		EN  : in  std_logic;
		OP	: in std_logic;
		A_i : in  std_logic_vector(W-1 downto 0);
		B_i : in  std_logic_vector(W-1 downto 0);
		RES_o : out std_logic_vector(W-1 downto 0);
		C_o : out std_logic;  -- carry out
		oF_o : out std_logic   -- overflow con signo
    );
  end component;

  -- Señales TB
  signal EN_tb   : std_logic := '0';
  signal OP_tb   : std_logic := '0';
  signal A_tb, B_tb : std_logic_vector(W_tb-1 downto 0);
  signal Y_tb       : std_logic_vector(W_tb-1 downto 0);
  signal C_tb, oF_tb : std_logic;
begin
  -- Instancia del DUT
  DUT: addsub
    generic map ( W => W_tb )
    port map (
		EN    => EN_tb,
		OP    => OP_tb,
		A_i => A_tb,
		B_i => B_tb,
		RES_o => Y_tb,
		C_o => C_tb,
		oF_o => oF_tb
    );

  process
  begin
    -- 1) EN=0, SUB aislado: 0-0 -> RES=00, C=1, OF=0
    EN_tb <= '0'; OP_tb <= '1'; A_tb <= x"05"; B_tb <= x"03"; wait for 10 ns;

    -- 2) ADD simple: 05+03=08, C=0, OF=0
    EN_tb <= '1'; OP_tb <= '0'; A_tb <= x"05"; B_tb <= x"03"; wait for 10 ns;

    -- 3) ADD con carry sin OF: FF+01=00, C=1, OF=0
    EN_tb <= '1'; OP_tb <= '0'; A_tb <= x"FF"; B_tb <= x"01"; wait for 10 ns;
	
	-- 4) ADD con overflow: 7F+01=80, C=0, OF=1
    EN_tb <= '1'; OP_tb <= '0'; A_tb <= x"7F"; B_tb <= x"01"; wait for 10 ns;

    -- 5) SUB sin borrow: 05-03=02, C=1, OF=0
    EN_tb <= '1'; OP_tb <= '1'; A_tb <= x"05"; B_tb <= x"03"; wait for 10 ns;

    -- 6) SUB con overflow: 80-01=7F, C=1, OF=1
    EN_tb <= '1'; OP_tb <= '1'; A_tb <= x"80"; B_tb <= x"01"; wait for 10 ns;

    -- 7) SUB con borrow: 02-03=FF, C=0, OF=0
    EN_tb <= '1'; OP_tb <= '1'; A_tb <= x"02"; B_tb <= x"03"; wait for 10 ns;

    report "addsub_tb: TODOS LOS TESTS OK" severity note;
    wait;
  end process;
end architecture;