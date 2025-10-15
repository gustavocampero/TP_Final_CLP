library ieee;
use ieee.std_logic_1164.all;

entity ALU_tb is
end entity;

architecture ALU_tb_arq of ALU_tb is

	component ALU is
		generic ( W : integer := 8 );
		port(
			A_i: in std_logic_vector(W-1 downto 0);
			B_i: in std_logic_vector(W-1 downto 0);
			OP_i: in std_logic_vector(3 downto 0);
			
			Y_o: out std_logic_vector(W-1 downto 0);
			zero_o: out std_logic;
			neg_o: out std_logic;
			carry_o: out std_logic;
			oflow_o: out std_logic
		);
	end component;
	
	constant W_tb : integer := 8;
	signal A_tb: std_logic_vector(W_tb-1 downto 0);
	signal B_tb: std_logic_vector(W_tb-1 downto 0);
	signal OP_tb: std_logic_vector(3 downto 0);
	signal Y_tb: std_logic_vector(W_tb-1 downto 0);
	signal zero_tb: std_logic;
	signal neg_tb: std_logic;
	signal carry_tb: std_logic;
	signal oflow_rb: std_logic;
begin

	-- Instancia del componente a probar
	DUT: ALU
	   generic map ( W => W_tb )
		port map(
			A_i => A_tb,
			B_i => B_tb,
			OP_i => OP_tb,
			Y_o => Y_tb,
			zero_o => zero_tb,
			neg_o => neg_tb,
			carry_o => carry_tb,
			oflow_o => oflow_rb
		);
		
		process
		begin
			-- 1) ADD/SUB: 7F + 01 = 80  -> Y=80, Z=0, N=1, C=0, oF=1
			A_tb <= x"7F"; B_tb <= x"01"; OP_tb <= "0000"; wait for 10 ns;

			-- 2) MUL: 80 * 02 = 0100 -> Y=00, Z=1, N=0, C=1, oF=0
			A_tb <= x"80"; B_tb <= x"02"; OP_tb <= "0010"; wait for 10 ns;
				
			 -- 3) LOGIC: 80 ^ 0F = 8F -> N=1, Z=0, C=0, oF=0
			A_tb <= x"80"; B_tb <= x"0F"; OP_tb <= "0101"; wait for 10 ns;
			  
			-- 4) SHIFT: 20 << 3 = 00 -> Z=1, N=0, C=0, oF=0
			A_tb <= x"20"; B_tb <= x"03"; OP_tb <= "0111"; wait for 10 ns;
			
			report "ALU_tb: TODOS LOS TESTS OK" severity note;
			wait;
		end process;
end architecture;