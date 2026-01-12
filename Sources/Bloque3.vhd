library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bloque3 is
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        
        btn_continue      : in  std_logic;
        btn_confirm       : in  std_logic;
        switches      : in  std_logic_vector (3 downto 0);
        player_number : in  std_logic_vector (3 downto 0); -- "0010"(2), "0011"(3), "0100"(4)
        freqdiv_end   : in  std_logic;                     -- Pulso de fin de 5s
        round         : in  unsigned (7 downto 0); -- Ronda actual
        rng           : in  std_logic_vector (5 downto 0);
        
        freqdiv_reset : out std_logic;
        segments7     : out std_logic_vector (19 downto 0); -- 4 dígitos x 5 bits
        leds          : out std_logic_vector (3 downto 0);  -- Barra de LEDs
        ap1           : out std_logic_vector (3 downto 0);  -- Apuesta al registro J1
        ap2           : out std_logic_vector (3 downto 0);  -- Apuesta al registro J2
        ap3           : out std_logic_vector (3 downto 0);  -- Apuesta al registro J3
        ap4           : out std_logic_vector (3 downto 0);  -- Apuesta al registro J4

        end_inserting : out std_logic                       -- Fin de fase
    );
end entity;

architecture Behavioral of Bloque3 is

    -- Estados de la FSM
    type state_type is (INICIO, CALCULAR_TURNO, ESPERA_INPUT, VALIDAR, PRINT_RESULTADO, ST_NEXT_PLAYER, FIN);
    signal state : state_type;

    -- Registro interno de apuestas para evitar duplicados 
    type bet_storage is array (0 to 3) of integer range 0 to 15;
    signal bets_made : bet_storage;
    
    signal current_player     : integer range 1 to 4  := 1;
    signal current_bet        : integer range 0 to 15 := 0;
    signal players_processed  : integer range 0 to 4  := 0;
    signal is_valid           : std_logic;
    signal rng_valid          : std_logic;


begin


    process(clk, reset)
    begin

        if clk'event and clk = '1' then

            if reset = '1' then
                
                freqdiv_reset <= '1';
                segments7 <= (others => '1'); -- Apagar display
                leds <= (others => '0');
                ap1  <= (others => '1');
                ap2  <=(others => '1');  
                ap3 <= (others => '1');
                ap4 <= (others => '1');
                end_inserting <= '0';

                state <= INICIO;

            else
                case state is

                    -- Espera de activación
                    when INICIO =>

                        players_processed <= 0;
                        bets_made <= (others => 15);
                        rng_valid <= '0';

                        state <= CALCULAR_TURNO;

                    -- Determina el orden circular
                    when CALCULAR_TURNO =>
                        -- El primer jugador de la ronda es: (round MOD player_number) + 1
                        -- Luego sumamos los ya procesados con desplazamiento circular
                        current_player <= ((to_integer(round) + players_processed) rem to_integer(unsigned(player_number))) + 1;              --!!!!!!!!!!
                        state <= ESPERA_INPUT;

                    -- Muestra "APx" y espera entrada
                    when ESPERA_INPUT =>
                        -- segments7: [A][P][Jugador][ ]
                        segments7 <= "01010" & "10110" & std_logic_vector(to_unsigned(current_player, 5)) & "11111";
                        
                        if current_player = 1 then
                            if rng_valid = '0' then 
                                current_bet <= to_integer(unsigned(rng)) mod 13;
                            end if;
                            rng_valid <= '1';
                            for i in 0 to 3 loop
                                if bets_made(i) = current_bet then
                                    rng_valid <= '0';
                                end if;
                            end loop;

                            if current_bet > to_integer(unsigned(player_number)) * 3 then
                                rng_valid <= '0';
                            end if;
                            
                            if rng_valid = '1' then
                                is_valid <= '1';
                                state <= PRINT_RESULTADO;
                            end if;
                        elsif btn_confirm = '1' then
                            current_bet <= to_integer(unsigned(switches));
                            state <= VALIDAR;
                        end if;

                    -- Valida reglas del juego
                    when VALIDAR =>
                        is_valid <= '1';
                        -- Regla 1: Rango 0 a 3*Jugadores
                        if current_bet > to_integer(unsigned(player_number)) * 3 then
                            is_valid <= '0';
                        end if;
                        -- Regla 2: No repetida en la ronda
                        for i in 0 to 3 loop                                                                                            --!!!!!!!!!!
                            if bets_made(i) = current_bet then
                                is_valid <= '0';
                            end if;
                        end loop;
                        state <= PRINT_RESULTADO;

                    -- Muestra APC (Correcto) o APE (Error) durante 5s
                    when PRINT_RESULTADO =>
                        freqdiv_reset <= '0'; -- Inicia conteo externo
                        if is_valid = '1' then
                            -- Display: [A][P][ID][C]
                            segments7 <= "01010" & "10110" & std_logic_vector(to_unsigned(current_player, 5)) & "01100";
                            -- Decodificación de barra de LEDs (apuesta)                                                                                                --!!!!!!!!
                            leds <= std_logic_vector(to_unsigned(current_bet, 4));
                        else
                            -- Display: [A][P][ID][E]
                            segments7 <= "01010" & "10110" & std_logic_vector(to_unsigned(current_player, 5)) & "01110";
                        end if;

                        -- Espera fin de 5s o botón continuar
                        if freqdiv_end = '1' or btn_continue = '1' then
                            freqdiv_reset <= '1';
                            if is_valid = '1' then
                                -- Guardar en registro externo
                                bets_made(current_player - 1) <= current_bet;
                                state <= ST_NEXT_PLAYER;
                            else
                                state <= ESPERA_INPUT; -- Reintentar si es error
                            end if;
                        end if;

                    -- Control de bucle de jugadores
                    when ST_NEXT_PLAYER =>
                        if players_processed + 1 = to_integer(unsigned(player_number)) then
                            state <= FIN;
                        else
                            players_processed <= players_processed + 1;
                            state <= CALCULAR_TURNO;
                        end if;

                    when FIN =>
                        ap1 <= std_logic_vector(to_unsigned(bets_made(0), 4));
                        ap2 <= std_logic_vector(to_unsigned(bets_made(1), 4));
                        ap3 <= std_logic_vector(to_unsigned(bets_made(2), 4));
                        ap4 <= std_logic_vector(to_unsigned(bets_made(3), 4));
                        end_inserting <= '1'; 

                end case;
            end if;
        end if;
    end process;

end Behavioral;