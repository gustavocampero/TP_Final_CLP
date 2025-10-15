library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Declaracion de entidad

entity logic is
  generic (W: integer := 8);
  port (
	EN     : in  std_logic;
	OP	   : in  std_logic_vector(1 downto 0);
    A_i, B_i  : in  std_logic_vector(W-1 downto 0);
    RES_o   : out std_logic_vector(W-1 downto 0);
    C_o     : out std_logic;  	-- carry
    oF_o     : out std_logic   	-- overflow con signo
  );
end entity;

architecture logic_arq of logic is
	signal a_aux, b_aux : std_logic_vector(W-1 downto 0);
begin
	--  Si EN = 0 pone las entradas en 0 y no conmuta
	a_aux <= A_i when EN = '1' else (others => '0');
	b_aux <= B_i when EN = '1' else (others => '0');
	
	process(a_aux, b_aux, OP)
		variable y_v   : std_logic_vector(W-1 downto 0);
	begin
		y_v := (others => '0');
		
		case OP is
			when "00" => y_v := a_aux and b_aux;  -- AND
			when "01" => y_v := a_aux or  b_aux;  -- OR
			when "10" => y_v := a_aux xor b_aux;  -- XOR
			when "11" => y_v := not a_aux;      -- NOT (B ignorado)
			when others => null;
		end case;
		
		RES_o <= y_v;
		C_o   <= '0';
		oF_o  <= '0';
		
	end process;
end architecture;