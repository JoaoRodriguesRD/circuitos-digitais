LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

Entity Microprocessador is 
	port(
	CLK, RESET : IN STD_LOGIC;
	ENTRADA			: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	SEL_ESCRITA		: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	SEL_A_OU_B		: IN STD_LOGIC;
	SEL_MUX_ALU     : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	RECEBE_ENTRADA  : IN STD_LOGIC; -- aceita novas entradas nos registradores
	CARRY_SAIDA_DO_MICRO : OUT STD_LOGIC;
	SAIDA : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	);
end Microprocessador;



Architecture meu_Microprocessador of Microprocessador is
	TYPE BancoRegistradores is array(0 to 7) of STD_LOGIC; --0 a 3 para o A e 4 a 7 para o B
	SIGNAL REGISTRADORES: BancoRegistradores;
	SIGNAL SAIDA_ESCRITA, SAIDA_ALU : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL RECEBEU_ENTRADA_A_OU_B : STD_LOGIC;
	SIGNAL A, B : STD_LOGIC_VECTOR(3 DOWNTO 0); --Alterei para 4 bits
	
	-- Sinais para soma
	SIGNAL carry :STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL carry_In, carry_Out : STD_LOGIC;	
	SIGNAL SOMA : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	-- Sinal do ou 
	SIGNAL OU : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	-- Sinal do E 
	SIGNAL E : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	-- Sinal do NAO 
	SIGNAL NAO : STD_LOGIC_VECTOR(3 DOWNTO 0);
begin

SAIDA(0) <= SAIDA_ALU(0); 
SAIDA(1) <= SAIDA_ALU(1);
SAIDA(2) <= SAIDA_ALU(2);
SAIDA(3) <= SAIDA_ALU(3);
SAIDA_ESCRITA(3 DOWNTO 0) <= ENTRADA;


carry(0)<= carry_In;
carry(4 DOWNTO 1) <= (A AND B) OR (A AND carry(3 DOWNTO 0)) OR (B AND carry(3 DOWNTO 0));
SOMA <= A XOR B XOR carry(3 DOWNTO 0);
carry_Out <= carry(4);
	
CARRY_SAIDA_DO_MICRO <= carry_Out;

OU(3 DOWNTO 0) <= A OR B;

E(3 DOWNTO 0) <= A AND B;

--Escolha da Funcao 
WITH SEL_MUX_ALU SELECT
	SAIDA_ALU(3 DOWNTO 0) <= SOMA WHEN "00",
	OU WHEN "01",
	E  WHEN "10",
    NAO WHEN "11";

-- 1 para A e 0 para B (nos registradores para A ou B)
IF (SEL_A_OU_B = '1') THEN
	RECEBEU_ENTRADA_A_OU_B = '1';
	A(0) <= REGISTRADORES(0);
	A(1) <= REGISTRADORES(1);
	A(2) <= REGISTRADORES(2);
	A(3) <= REGISTRADORES(3);
		ELSE
		RECEBEU_ENTRADA_A_OU_B = '0';
		B(0) <= REGISTRADORES(4);
		B(1) <= REGISTRADORES(5);
		B(2) <= REGISTRADORES(6);
		B(3) <= REGISTRADORES(7);
END IF;

		  
PROCESS (CLK, RESET, RECEBE_ENTRADA)
	BEGIN
		IF RESET = '1' THEN
			REGISTRADORES(0) <= '0';
			REGISTRADORES(1) <= '0';
			REGISTRADORES(2) <= '0';
			REGISTRADORES(3) <= '0';
			REGISTRADORES(4) <= '0';
			REGISTRADORES(5) <= '0';
			REGISTRADORES(6) <= '0';
			REGISTRADORES(7) <= '0';
			
			
			ELSIF ((CLK'event AND CLK = '1') AND (RECEBE_ENTRADA = '1')) THEN
					--1 para A e 0 para B 
					IF (RECEBEU_ENTRADA_A_OU_B = '1') THEN
						REGISTRADORES(3 DOWNTO 0) <= SAIDA_ESCRITA;
					    ELSE
						REGISTRADORES(7 DOWNTO 4) <= SAIDA_ESCRITA;
					
					ELSE
					     	REGISTRADORES(0) <= REGISTRADORES(0);
							REGISTRADORES(1) <= REGISTRADORES(1);
							REGISTRADORES(2) <= REGISTRADORES(2);
							REGISTRADORES(3) <= REGISTRADORES(3);
							REGISTRADORES(4) <= REGISTRADORES(4);
							REGISTRADORES(5) <= REGISTRADORES(5);
							REGISTRADORES(6) <= REGISTRADORES(6);
							REGISTRADORES(7) <= REGISTRADORES(7);
		END IF;
	END PROCESS;		  
	
END meu_Microprocessador;