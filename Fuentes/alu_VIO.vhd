library IEEE;
use IEEE.std_logic_1164.all;
-- use ieee.numeric_std.all;

-- Declaracion de entidad

entity ALU_VIO is
	generic ( W : integer := 8 );
	port(
		clk_i: in std_logic
	);
end entity;

architecture ALU_VIO_arq of ALU_VIO is
-- Parte declarativa

	signal probe_A : std_logic_vector(W-1 downto 0);
	signal probe_B : std_logic_vector(W-1 downto 0);
	signal probe_OP : std_logic_vector(3 downto 0);
	signal probe_Y : std_logic_vector(W-1 downto 0);
	signal probe_flags : std_logic_vector(3 downto 0);
	signal probe_Z, probe_N, probe_C, probe_oF  : std_logic;
	
	COMPONENT vio
      PORT (
        clk : IN STD_LOGIC;
        probe_in0 : IN STD_LOGIC_VECTOR(W-1 DOWNTO 0);
        probe_in1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        probe_out0 : OUT STD_LOGIC_VECTOR(W-1 DOWNTO 0);
        probe_out1 : OUT STD_LOGIC_VECTOR(W-1 DOWNTO 0);
        probe_out2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
      );
    END COMPONENT;

begin
-- Parte descriptiva
	probe_flags <= probe_Z & probe_N & probe_C & probe_oF;
	
	ALU_inst: entity work.ALU
		port map(
			A_i => probe_A,
			B_i => probe_B,
			OP_i => probe_OP,
		
			Y_o => probe_Y,
			zero_o => probe_Z,
			neg_o => probe_N,
			carry_o => probe_C,
			oflow_o => probe_oF
		);
		
    vio_inst : vio
      PORT MAP (
        clk => clk_i,
        probe_in0 => probe_Y,
        probe_in1 => probe_flags,
        probe_out0 => probe_A,
        probe_out1 => probe_B,
        probe_out2 => probe_OP
      );
end;