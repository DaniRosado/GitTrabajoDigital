library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bloque3 is
    Port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        
        num_jug     : in  std_logic_vector (3 downto 0); -- "0010"(2), "0011"(3), "0100"(4)
        num_ronda   : in  unsigned (7 downto 0); -- Ronda actual
        rng_in      : in  std_logic_vector (5 downto 0);
        
        switches    : in  std_logic_vector (3 downto 0);
        btn_continue    : in  std_logic;
        btn_confirm     : in  std_logic;

        fdiv_fin    : in  std_logic;                     -- Pulso de fin de 5s
        fdiv_reset  : out std_logic;

        segments7   : out std_logic_vector (19 downto 0); -- 4 dígitos x 5 bits
        leds        : out std_logic_vector (11 downto 0);  -- Barra de LEDs

        R_Apuesta1  : out std_logic_vector (3 downto 0);  -- Apuesta al registro J1
        R_Apuesta2  : out std_logic_vector (3 downto 0);  -- Apuesta al registro J2
        R_Apuesta3  : out std_logic_vector (3 downto 0);  -- Apuesta al registro J3
        R_Apuesta4  : out std_logic_vector (3 downto 0);  -- Apuesta al registro J4

        fin_fase : out std_logic                       -- Fin de fase

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
    signal leds_int           : std_logic_vector(3 downto 0);

    component DecoderLeds is
        port(Input  :   in  std_logic_vector(3 downto 0);
             Leds   :   out std_logic_vector(11 downto 0));
    end component;

begin

    DecoderLeds_inst : DecoderLeds
        port map(
            Input => leds_int,
            Leds  => leds
        );


    process(clk, reset)
    begin

        if clk'event and clk = '1' then

            if reset = '1' then
                
                fdiv_reset <= '1';
                segments7 <= (others => '1'); -- Apagar display
                leds_int <= (others => '0');
                R_Apuesta1  <= (others => '1');
                R_Apuesta2  <=(others => '1');  
                R_Apuesta3 <= (others => '1');
                R_Apuesta4 <= (others => '1');
                fin_fase <= '0';

                state <= INICIO;

            else
                case state is

                    -- Espera de activación
                    when INICIO =>

                        players_processed <= 0;
                        bets_made <= (others => 15);

                        state <= CALCULAR_TURNO;

                    -- Determina el orden circular
                    when CALCULAR_TURNO =>
                    -- Definimos una variable temporal para la suma
                    -- Asumiendo que has declarado 'v_suma' como variable integer en el proceso
                    -- O simplemente calculándolo directamente en el case:

                    case num_jug is
                        when "0010" => -- 2 Jugadores (Divide por 2, muy fácil para la FPGA)
                            current_player <= ((to_integer(num_ronda) + players_processed) mod 2) + 1;
                            
                        when "0011" => -- 3 Jugadores (Vivado ya sabe dividir por la constante 3)
                            current_player <= ((to_integer(num_ronda) + players_processed) mod 3) + 1;
                            
                        when "0100" => -- 4 Jugadores (Divide por 4, muy fácil)
                            current_player <= ((to_integer(num_ronda) + players_processed) mod 4) + 1;
                            
                        when others => -- Caso por defecto (seguridad)
                            current_player <= 1;
                    end case;

                    state <= ESPERA_INPUT;
                    -- Muestra "APx" y espera entrada
                    when ESPERA_INPUT =>
                        -- segments7: [A][P][Jugador][ ]
                        segments7 <= "01010" & "10110" & std_logic_vector(to_unsigned(current_player, 5)) & "11111";
                        
                        if current_player = 1 then
                            current_bet <= to_integer(unsigned(rng_in)) mod 13;

                            if not (bets_made(1) = current_bet or bets_made(2) = current_bet or bets_made(3) = current_bet or current_bet > to_integer(unsigned(num_jug)) * 3) then
                                state <= PRINT_RESULTADO;
                                is_valid <= '1';
                            end if;

                        elsif btn_confirm = '1' then
                            current_bet <= to_integer(unsigned(switches));
                            state <= VALIDAR;
                        end if;

                    -- Valida reglas del juego
                    when VALIDAR =>
                        -- Regla 1: Rango 0 a 3*Jugadores
                        if current_bet > to_integer(unsigned(num_jug)) * 3 or bets_made(0) = current_bet or bets_made(1) = current_bet or bets_made(2) = current_bet or bets_made(3) = current_bet then
                            is_valid <= '0';
                        else 
                            is_valid <= '1';
                        end if;
                        state <= PRINT_RESULTADO;
                    -- Muestra APC (Correcto) o APE (Error) durante 5s
                    when PRINT_RESULTADO =>
                        fdiv_reset <= '0'; -- Inicia conteo externo
                        if is_valid = '1' then
                            -- Display: [A][P][ID][C]
                            segments7 <= "01010" & "10110" & std_logic_vector(to_unsigned(current_player, 5)) & "01100";
                            -- Decodificación de barra de LEDs (apuesta)                                                                                                --!!!!!!!!
                            leds_int <= std_logic_vector(to_unsigned(current_bet, 4));
                        else
                            -- Display: [A][P][ID][E]
                            segments7 <= "01010" & "10110" & std_logic_vector(to_unsigned(current_player, 5)) & "01110";
                        end if;

                        -- Espera fin de 5s o botón continuar
                        if fdiv_fin = '1' or btn_continue = '1' then
                            fdiv_reset <= '1';
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
                        if players_processed + 1 = to_integer(unsigned(num_jug)) then
                            state <= FIN;
                        else
                            players_processed <= players_processed + 1;
                            state <= CALCULAR_TURNO;
                        end if;

                    when FIN =>
                        R_Apuesta1 <= std_logic_vector(to_unsigned(bets_made(0), 4));
                        R_Apuesta2 <= std_logic_vector(to_unsigned(bets_made(1), 4));
                        R_Apuesta3 <= std_logic_vector(to_unsigned(bets_made(2), 4));
                        R_Apuesta4 <= std_logic_vector(to_unsigned(bets_made(3), 4));
                        fin_fase <= '1'; 

                end case;
            end if;
        end if;
    end process;

end Behavioral;