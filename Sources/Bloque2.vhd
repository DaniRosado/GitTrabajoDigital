library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bloque2 is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        
        num_jug     : in  std_logic_vector (3 downto 0);    -- "0010"(2), "0011"(3), "0100"(4)
        num_ronda   : in  unsigned (7 downto 0);            -- Ronda actual
        rng_in      : in  std_logic_vector (5 downto 0);

        switches        : in  std_logic_vector (3 downto 0);
        btn_continue    : in  std_logic;
        btn_confirm     : in  std_logic;

        fdiv_fin    : in  std_logic;                         -- Pulso de fin de 5s
        fdiv_reset  : out std_logic;

        segments7   : out std_logic_vector (19 downto 0); -- 4 dígitos x 5 bits

        R_NumPiedras1   : out std_logic_vector (1 downto 0);  -- Apuesta al registro J1
        R_NumPiedras2   : out std_logic_vector (1 downto 0);  -- Apuesta al registro J2
        R_NumPiedras3   : out std_logic_vector (1 downto 0);  -- Apuesta al registro J3
        R_NumPiedras4   : out std_logic_vector (1 downto 0);  -- Apuesta al registro J4

        fin_fase : out std_logic
    );
end entity;

architecture Behavioral of Bloque2 is

    -- Estados de la FSM
    type state_type is (INICIO, ESPERA_INPUT, VALIDAR, PRINT_RESULTADO, ST_NEXT_PLAYER, FIN);
    signal state : state_type;

    -- Registro interno de apuestas para evitar duplicados 
    type stone_storage is array (0 to 3) of integer range 0 to 3;
    signal stones_introduced : stone_storage;
    
    signal current_player   : integer range 1 to 4;
    signal current_stone    : integer range 0 to 3;
    signal is_valid         : std_logic;


begin


    process(clk, reset)
    begin

        if clk'event and clk = '1' then

            if reset = '1' then
                state <= INICIO;
                fin_fase <= '0';

                segments7 <= (others => '1');   -- Todo apagado
            else
                case state is
                    -- Espera de activación
                    when INICIO =>
                        fin_fase <= '0';
                        current_player <= 1;
                        stones_introduced <= (others => 0);
                        state <= ESPERA_INPUT;
                        fdiv_reset <= '1';

                    -- Muestra "chx" y espera entrada
                    when ESPERA_INPUT =>
                        -- segments7: [c][h][Jugador][ ]
                        segments7 <= "10100" & "10101" & std_logic_vector(to_unsigned(current_player, 5)) & "11111";
                        
                        if current_player = 1 then
                            current_stone <= to_integer(unsigned(rng_in)) mod 4 ;
                            if not (num_ronda = "00000000" and current_stone = 0) then  -- Primera ronda
                                state <= VALIDAR;
                            end if;

                        elsif btn_confirm = '1' then
                            current_stone <= to_integer(unsigned(switches));
                            state <= VALIDAR;
                        end if;

                    -- Valida reglas del juego
                    when VALIDAR =>
                        is_valid <= '1';
                        -- Regla 1: Rango 0 a 3 Piedras      Regla 2: En ronda 0 no puede elegir 0 piedras
                        if (current_stone > 3) or (num_ronda = "00000000" and current_stone = 0) then
                            is_valid <= '0';
                        end if;

                        state <= PRINT_RESULTADO;

                    -- Muestra chC (Correcto) o chE (Error) durante 5s
                    when PRINT_RESULTADO =>
                        fdiv_reset <= '0'; -- Inicia conteo externo
                        if is_valid = '1' then
                            -- Display: [c][h][Jugador][C]
                            segments7 <= "10100" & "10101" & std_logic_vector(to_unsigned(current_player, 5)) & "01100";
                        else
                            -- Display: [c][h][Jugador][E]
                            segments7 <= "10100" & "10101" & std_logic_vector(to_unsigned(current_player, 5)) & "01110";
                        end if;

                        -- Espera fin de 5s o botón continuar
                        if fdiv_fin = '1' or (btn_continue = '1' and is_valid = '1') then
                                fdiv_reset <= '1';
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
                        if current_player = to_integer(unsigned(num_jug)) then
                            state <= FIN;
                        else
                            current_player <= current_player + 1;
                            state <= ESPERA_INPUT;
                        end if;

                    when FIN =>
                        fin_fase <= '1'; 
                end case;
            end if;
        end if;
    end process;

    R_NumPiedras1 <= std_logic_vector(to_unsigned(stones_introduced(0), 2));
    R_NumPiedras2 <= std_logic_vector(to_unsigned(stones_introduced(1), 2));
    R_NumPiedras3 <= std_logic_vector(to_unsigned(stones_introduced(2), 2));
    R_NumPiedras4 <= std_logic_vector(to_unsigned(stones_introduced(3), 2));
end Behavioral;