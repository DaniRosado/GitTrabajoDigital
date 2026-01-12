library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bloque2 is
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        
        NUM_JUGADORES : in  std_logic_vector (3 downto 0); -- "0010"(2), "0011"(3), "0100"(4)
        NUM_RONDA     : in  unsigned (7 downto 0); -- Ronda actual
        ALEATORIO_IN  : in  std_logic_vector (5 downto 0);
        SWITCHES      : in  std_logic_vector (3 downto 0);
        btn_confirm   : in  std_logic;
        btn_continuar : in  std_logic;

        freqdiv_end   : in  std_logic;                     -- Pulso de fin de 5s

        
        freqdiv_reset : out std_logic; 
        segments7     : out std_logic_vector (19 downto 0); -- 4 dígitos x 5 bits

        PIEDRAS_P1           : out std_logic_vector (1 downto 0);  -- Apuesta al registro J1
        PIEDRAS_P2           : out std_logic_vector (1 downto 0);  -- Apuesta al registro J2
        PIEDRAS_P3           : out std_logic_vector (1 downto 0);  -- Apuesta al registro J3
        PIEDRAS_P4           : out std_logic_vector (1 downto 0);  -- Apuesta al registro J4

        FIN_FASE : out std_logic                       -- Fin de fase
    );
end entity;

architecture Behavioral of Bloque2 is

    -- Estados de la FSM
    type state_type is (INICIO, ESPERA_INPUT, VALIDAR, PRINT_RESULTADO, ST_NEXT_PLAYER, FIN);
    signal state : state_type;

    -- Registro interno de apuestas para evitar duplicados 
    type stone_storage is array (0 to 3) of integer range 0 to 3;
    signal stones_introduced : stone_storage;
    
    signal current_player     : integer range 1 to 4;
    signal current_stone      : integer range 0 to 3;
    signal is_valid           : std_logic;


begin


    process(clk, reset)
    begin

        if clk'event and clk = '1' then

            if reset = '1' then
                state <= INICIO;
                FIN_FASE <= '0';

                segments7 <= (others => '1');   -- Todo apagado
            else
                case state is
                    -- Espera de activación
                    when INICIO =>
                        FIN_FASE <= '0';
                        current_player <= 1;
                        stones_introduced <= (others => 0);
                        state <= ESPERA_INPUT;
                        freqdiv_reset <= '1';

                    -- Muestra "chx" y espera entrada
                    when ESPERA_INPUT =>
                        -- segments7: [c][h][Jugador][ ]
                        segments7 <= "10100" & "10101" & std_logic_vector(to_unsigned(current_player, 5)) & "11111";
                        
                        if current_player = 1 then
                            current_stone <= to_integer(unsigned(ALEATORIO_IN)) mod 4 ;
                            if not (NUM_RONDA = "00000000" and current_stone = 0) then  -- Primera ronda
                                state <= VALIDAR;
                            end if;

                        elsif btn_confirm = '1' then
                            current_stone <= to_integer(unsigned(SWITCHES));
                            state <= VALIDAR;
                        end if;

                    -- Valida reglas del juego
                    when VALIDAR =>
                        is_valid <= '1';
                        -- Regla 1: Rango 0 a 3 Piedras      Regla 2: En ronda 0 no puede elegir 0 piedras
                        if (current_stone > 3) or (NUM_RONDA = "00000000" and current_stone = 0) then
                            is_valid <= '0';
                        end if;

                        state <= PRINT_RESULTADO;

                    -- Muestra chC (Correcto) o chE (Error) durante 5s
                    when PRINT_RESULTADO =>
                        freqdiv_reset <= '0'; -- Inicia conteo externo
                        if is_valid = '1' then
                            -- Display: [c][h][Jugador][C]
                            segments7 <= "10100" & "10101" & std_logic_vector(to_unsigned(current_player, 5)) & "01100";
                        else
                            -- Display: [c][h][Jugador][E]
                            segments7 <= "10100" & "10101" & std_logic_vector(to_unsigned(current_player, 5)) & "01110";
                        end if;

                        -- Espera fin de 5s o botón continuar
                        if freqdiv_end = '1' or (btn_continuar = '1' and is_valid = '1') then
                                freqdiv_reset <= '1';
                                if is_valid = '1' then
                                    -- Guardar en registro interno
                                    stones_introduced(current_player - 1) <= current_stone;
                                    state <= ST_NEXT_PLAYER;
                                else
                                    state <= ESPERA_INPUT; -- Reintentar si es error
                            end if;
                        end if;

                    -- Control de bucle de jugadores
                    when ST_NEXT_PLAYER =>
                        if current_player = to_integer(unsigned(NUM_JUGADORES)) then
                            state <= FIN;
                        else
                            current_player <= current_player + 1;
                            state <= ESPERA_INPUT;
                        end if;

                    when FIN =>
                        FIN_FASE <= '1'; 
                end case;
            end if;
        end if;
    end process;

    PIEDRAS_P1 <= std_logic_vector(to_unsigned(stones_introduced(0), 2));
    PIEDRAS_P2 <= std_logic_vector(to_unsigned(stones_introduced(1), 2));
    PIEDRAS_P3 <= std_logic_vector(to_unsigned(stones_introduced(2), 2));
    PIEDRAS_P4 <= std_logic_vector(to_unsigned(stones_introduced(3), 2));
end Behavioral;