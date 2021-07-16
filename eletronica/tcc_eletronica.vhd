library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tcc_eletronica is
	port(
		A : IN std_logic_vector(12 downto 0) :=  "ZZZZZZZZZZZZZ";
		IO : INOUT std_logic_vector(7 downto 0) := "ZZZZZZZZ";
		nCE : IN std_logic := '1';
		nWE : IN std_logic := '1';
		nOE : IN std_logic := '1'
	);
end tcc_eletronica;

-- ESTADOS:
--		IDLE		(CE = 0)
--		WRITE		(CE = 1, WE = 1)
--		OUTPUT	(CE = 1, OE = 1)


architecture eeprom of tcc_eletronica is
		type ESTADO is (PARADO,LE,ESCREVE);
		type BANCO is ARRAY (8191 downto 0) of std_logic_vector(7 downto 0);

	begin
		
	ALTERA_ESTADO: process(nCE,nWE,nOE)
		variable endereco: NATURAL RANGE 0 TO 8191;
		variable valor: std_logic_vector(7 downto 0);
		variable banco_memoria: BANCO;
		variable estado_atual: ESTADO := PARADO;
		variable estado_proximo: ESTADO := PARADO;
		
		begin
			case estado_atual is
				when PARADO =>
					if nCE = '0' then
						if nWE = '0' then
							estado_proximo := ESCREVE;
						elsif nOE = '0' then
							estado_proximo := LE;
						end if;
					else
						estado_proximo := PARADO;
					end if;
				when LE =>
					if nCE = '0' then
						if nWE = '0' then
							estado_proximo := ESCREVE;
						elsif nOE = '0' then
							estado_proximo := LE;
						end if;
					else
						estado_proximo := PARADO;
					end if;
				when ESCREVE =>
					if nCE = '0' then
						if nWE = '0' then
							estado_proximo := ESCREVE;
						elsif nOE = '0' then
							estado_proximo := LE;
						end if;
					else
					-- Se o estado atual é ESCREVE e nCE subiu,
					-- então lemos o valor em IO e salvamos na
					-- EEPROM.
						endereco := to_integer(unsigned(A));
						valor := IO;
						banco_memoria(endereco) := valor;
						estado_proximo := PARADO;
					end if;
			end case;

			case estado_proximo is
				when PARADO =>
					null;
				when LE =>
				-- O livro não descreve nenhum intervalo para a
				-- leitura.
					endereco := to_integer(unsigned(A));
					valor := banco_memoria(endereco);
					IO <= valor;
				when ESCREVE =>
				-- A operação de escrita só ocorre quando nCE sobe.
					null;
			end case;
			estado_atual := estado_proximo;
		end process;

end eeprom;