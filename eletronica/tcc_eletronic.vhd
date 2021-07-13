library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tcc_eletronica is
	port(
		A : IN std_logic_vector(12 downto 0);
		IO : INOUT std_logic_vector(7 downto 0);
		nCE : IN std_logic := '1';
		nWE : IN std_logic := '1';
		nOE : IN std_logic := '1'
	);
end tcc_eletronica;

-- ESTADOS: IDLE (CE = 0)
--				WRITE (CE = 1, WE = 1)
--				OUTPUT (CE = 1, OE = 1)
-- IDLE -> WRITE
-- IDLE -> OUTPUT
-- WRITE -> IDLE
-- WRITE -> OUTPUT
-- OUTPUT -> IDLE
-- OUTPUT -> WRITE

architecture eeprom of tcc_eletronica is
	type ESTADO is (PARADO,LE,ESCREVE);
	type BANCO is ARRAY (8191 downto 0) of std_logic_vector(7 downto 0);
	signal estado_atual: ESTADO;
	signal estado_proximo: ESTADO;
	signal s_a: std_logic_vector(12 downto 0);
	signal s_io: std_logic_vector(7 downto 0);


begin

--	portas : tcc_eletronica
--		port map(
--		A => s_a,
--		IO => s_io
--	);
	
PROX_ESTADO: process(nCE,nWE,nOE)

begin
	case estado_atual is
		when PARADO =>
			if nCE = '0' then
				if nWE = '0' then
					estado_proximo <= ESCREVE;
				elsif nOE = '0' then
					estado_proximo <= LE;
				end if;
			else
				estado_proximo <= PARADO;
			end if;
		when LE =>
			if nCE = '0' then
				if nWE = '0' then
					estado_proximo <= ESCREVE;
				elsif nOE = '0' then
					estado_proximo <= LE;
				end if;
			else
				estado_proximo <= PARADO;
			end if;
		when ESCREVE =>
			if nCE = '0' then
				if nWE = '0' then
					estado_proximo <= ESCREVE;
				elsif nOE = '0' then
					estado_proximo <= LE;
				end if;
			else
				estado_proximo <= PARADO;
			end if;
	end case;
end process;

executa_estado: process(estado_proximo)
	variable endereco: NATURAL RANGE 0 TO 8191;
--	variable endereco: std_logic_vector(12 downto 0);
	variable valor: std_logic_vector(7 downto 0);
	variable banco_memoria: BANCO;
begin
	case estado_proximo is
		when PARADO =>
			null;
		when LE =>
			endereco := to_integer(unsigned(s_a));
			valor := banco_memoria(endereco);
			s_io <= valor;
		when ESCREVE =>
			endereco := to_integer(unsigned(s_a));
			valor := s_io;
			banco_memoria(endereco) := valor;
	end case;
	estado_atual <= estado_proximo;
end process;

end eeprom;
