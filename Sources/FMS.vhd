-- FMS.vhd: Máquina de estados finita para el control de las fases del juego

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.estados_pkg.all;

entity fms is
    Port (clk : in STD_LOGIC;
          reset : in STD_LOGIC;
          estado_out : out estados;
          sum_round : out std_logic;
          fin_B1 : in STD_LOGIC;
          fin_B2 : in STD_LOGIC;
          fin_B3 : in STD_LOGIC;
          fin_B4 : in STD_LOGIC;
          fin_B5 : in STD_LOGIC;
          reset_B1 : out STD_LOGIC;
          reset_B2 : out STD_LOGIC;
          reset_B3 : out STD_LOGIC;
          reset_B4 : out STD_LOGIC;
          reset_B5 : out STD_LOGIC
           );
end fms;

architecture Behavioral of fms is
    signal estado : estados;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            estado <= SJug; -- estado inicial
            -- inicializamos todos los componentes reseteados
            reset_B1 <= '1';
            reset_B2 <= '1';
            reset_B3 <= '1';
            reset_B4 <= '1';
            reset_B5 <= '1';
            sum_round <= '0';
        elsif clk'event and clk = '1' then
            case estado is
                when SJug =>
                    -- añadimos la lógica de transición
                    if fin_B1 = '1' then
                        -- cuando hagamos la transición, ponemos el bloque actual en reset
                        reset_B1 <= '1';
                        -- pasamos al siguiente estado
                        estado <= ExtPied;
                    else
                        -- quitamos el reset para que funione con normalidad
                        reset_B1 <= '0';
                    end if;
                when ExtPied =>
                    sum_round <= '0';
                    if fin_B2 = '1' then
                        reset_B2 <= '1';
                        estado <= IntrApuesta;
                    else
                        reset_B2 <= '0';
                    end if;
                when IntrApuesta =>
                    if fin_B3 = '1' then
                        reset_B3 <= '1';
                        estado <= ResRonda;
                    else
                        reset_B3 <= '0';
                    end if;
                when ResRonda =>
                    if fin_B4 = '1' then
                        reset_B4 <= '1';
                        estado <= FinJug;
                    else
                        reset_B4 <= '0';
                    end if;
                when FinJug =>
                    if fin_B5 = '1' then
                        sum_round <= '1';
                        reset_B5 <= '1';
                        estado <= ExtPied;
                    else
                        reset_B5 <= '0';
                    end if;
            end case;
        end if;
    end process;
    estado_out <= estado;
end Behavioral;