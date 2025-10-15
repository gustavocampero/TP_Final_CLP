library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity logic_tb is
end entity;

architecture logic_tb_arq of logic_tb is
  constant W_tb : integer := 8;

  -- DUT component
  component logic is
    generic ( W : integer := 8 );
    port (
		EN  : in  std_logic;
		OP    : in  std_logic_vector(1 downto 0);
		A_i : in  std_logic_vector(W-1 downto 0);
		B_i : in  std_logic_vector(W-1 downto 0);
		RES_o : out std_logic_vector(W-1 downto 0);
		C_o : out std_logic;  -- carry out
		oF_o : out std_logic
    );
  end component;

  -- Señales TB
  signal EN_tb   : std_logic := '0';
  signal OP_tb   : std_logic_vector(1 downto 0) := "00";
  signal A_tb, B_tb : std_logic_vector(W_tb-1 downto 0);
  signal Y_tb       : std_logic_vector(W_tb-1 downto 0);
  signal C_tb, oF_tb : std_logic;
begin
  -- Instancia del DUT
  DUT: logic
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
    -- 1) EN=0: entradas forzadas a 0 -> AND(0,0)=00
    EN_tb <= '0'; OP_tb <= "00"; A_tb <= x"AA"; B_tb <= x"55"; wait for 10 ns;
    
    -- 2) AND: F0 & AA = A0
    EN_tb <= '1'; OP_tb <= "00"; A_tb <= x"F0"; B_tb <= x"AA"; wait for 10 ns;

    -- 3) AND: AA & 55 = 00
    EN_tb <= '1'; OP_tb <= "00"; A_tb <= x"AA"; B_tb <= x"55"; wait for 10 ns;

    -- 4) OR: AA | 55 = FF
    EN_tb <= '1'; OP_tb <= "01"; A_tb <= x"AA"; B_tb <= x"55"; wait for 10 ns;

    -- 5) XOR: AA ^ 0F = A5
    EN_tb <= '1'; OP_tb <= "10"; A_tb <= x"AA"; B_tb <= x"0F"; wait for 10 ns;

    -- 6) NOT: ~A, con B ignorado -> ~0F = F0
    EN_tb <= '1'; OP_tb <= "11"; A_tb <= x"0F"; B_tb <= x"00"; wait for 10 ns;

    report "logic_tb: TODOS LOS TESTS OK" severity note;
    wait;
  end process;
end architecture;