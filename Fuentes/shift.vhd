library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Declaracion de entidad

entity shifter is
  generic (W: integer := 8);
  port (
	EN     : in  std_logic;
	OP	   : in  std_logic_vector(2 downto 0);
    A_i, B_i  : in  std_logic_vector(W-1 downto 0);
    RES_o   : out std_logic_vector(W-1 downto 0);
    C_o     : out std_logic;  	-- carry
    oF_o     : out std_logic   	-- overflow con signo
  );
end entity;

architecture shifter_arq of shifter is
	signal a_aux, b_aux : std_logic_vector(W-1 downto 0);
begin
	--  Si EN = 0 pone las entradas en 0 y no conmuta
	a_aux <= A_i when EN = '1' else (others => '0');
	b_aux <= B_i when EN = '1' else (others => '0');
	
	process(a_aux, b_aux, OP)
		variable y_v   : std_logic_vector(W-1 downto 0);
		variable shamt : integer;
	begin
		y_v := (others => '0');
		if W = 0 then
			shamt := 0;
		else
			shamt := to_integer(unsigned(b_aux)) mod W;
		end if;
		
		case OP is
			when "000" => y_v := std_logic_vector( shift_left(unsigned(a_aux), shamt) ); -- SLL
			when "001" => y_v := std_logic_vector( shift_right(unsigned(a_aux), shamt) );  -- SRL
			when "010" => y_v := std_logic_vector( shift_right(signed(a_aux), shamt) ); -- SRA
			when "011" =>  -- ROL
				y_v := std_logic_vector(
					(unsigned(a_aux) sll (shamt mod W)) or
					(unsigned(a_aux) srl ((W - (shamt mod W)) mod W))
               );
			when "100" =>  -- ROR
				y_v := std_logic_vector(
					(unsigned(a_aux) srl (shamt mod W)) or
					(unsigned(a_aux) sll ((W - (shamt mod W)) mod W))
				);
			when others => null;
		end case;
		
		RES_o <= y_v;
		C_o   <= '0';
		oF_o  <= '0';
		
	end process;
end architecture;