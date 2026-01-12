----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.12.2025 12:40:46
-- Design Name: 
-- Module Name: Top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           leds_4 : out STD_LOGIC_VECTOR (3 downto 0);
           botones : in STD_LOGIC_VECTOR (3 downto 0);
           selector : out STD_LOGIC_VECTOR (3 downto 0);
           segments : out STD_LOGIC_VECTOR (6 downto 0);
           leds_8 : out STD_LOGIC_VECTOR (7 downto 0);
           switches : in STD_LOGIC_VECTOR (3 downto 0)           
           );
end Top;

architecture Behavioral of Top is
    component Antirrebotes is
    Port (  clk      : in  std_logic;
            reset    : in  std_logic;
            boton    : in  std_logic;
            filtrado : out std_logic);
    end component;

    signal botones_filtrado : std_logic_vector(2 downto 0);

    component DecoderLeds is
    port(Input :   in  std_logic_vector(3 downto 0);
         Leds  :   out std_logic_vector(11 downto 0));
    end component;

    signal leds_controler : std_logic_vector(3 downto 0);
    signal leds_output : std_logic_vector(11 downto 0);
    
    component DecoderControler is
    port(clk    :   in  std_logic;
         reset  :   in  std_logic;
         Input  :   in  std_logic_vector(19 downto 0); 
         Output :   out std_logic_vector( 6 downto 0);
         Selector :   out  std_logic_vector( 3 downto 0)
         );
    end component;

    signal DisplayIN : std_logic_vector(19 downto 0);

    component Freqdiv is
    Port (clk    :  in  std_logic;
          reset  :  in  std_logic;
          Output :  out std_logic);
    end component;
    -- señales de Freqdiv
    signal fdiv_reset, fdiv_fin : std_logic;

    component RNG is
    Port ( clk     : in  STD_LOGIC;
           reset   : in  STD_LOGIC; --Reset de la placa
           random_number : out STD_LOGIC_VECTOR (5 downto 0));
    end component;
    
    signal rng_out : std_logic_vector(5 downto 0);

    component SeleccionJugadores is
    port(
        clk            : in  std_logic;
        reset          : in  std_logic;
        continue       : in  std_logic; -- boton
        switches       : in  std_logic_vector(3 downto 0); -- interruptores
        freq_div_fin   : in  std_logic;
        freq_div_start : out std_logic;
        Fin            : out std_logic;
        seven_segments : out std_logic_vector(19 downto 0);
        Num            : out std_logic_vector(3 downto 0)
    );
    end component;
    --señales de las entradas de SeleccionJugadores
    signal reset_SJ, continue_SJ, fdiv_fin_SJ, fdiv_start_SJ, fin_SJ : std_logic;
    signal display_SJ : std_logic_vector(19 downto 0);
    signal switches_SJ, Num_Jug_SJ : std_logic_vector(3 downto 0);

    -- bloque extracción de piedras

    component Bloque2 is
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        
        NUM_JUGADORES : in  std_logic_vector (3 downto 0); -- "0010"(2), "0011"(3), "0100"(4)
        NUM_RONDA     : in  unsigned (7 downto 0);
        ALEATORIO_IN  : in  std_logic_vector (5 downto 0);
        SWITCHES      : in  std_logic_vector (3 downto 0);
        BTN_CONFIRM   : in std_logic;
        BTN_CONTINUAR : in  std_logic;

        freqdiv_end   : in  std_logic;                     -- Pulso de fin de 5s

        
        freqdiv_reset : out std_logic; 
        segments7     : out std_logic_vector (19 downto 0); -- 4 dígitos x 5 bits

        PIEDRAS_P1           : out std_logic_vector (1 downto 0);  -- Apuesta al registro J1
        PIEDRAS_P2           : out std_logic_vector (1 downto 0);  -- Apuesta al registro J2
        PIEDRAS_P3           : out std_logic_vector (1 downto 0);  -- Apuesta al registro J3
        PIEDRAS_P4           : out std_logic_vector (1 downto 0);  -- Apuesta al registro J4

        FIN_FASE : out std_logic                       -- Fin de fase
    );
    end component;

    signal reset_B2, btn_confirm_B2, btn_continuar_B2, freqdiv_end_B2, freqdiv_reset_B2, fin_fase_B2 : std_logic;
    signal segments7_B2 : std_logic_vector(19 downto 0);
    signal num_jugadores_B2, switches_B2 : std_logic_vector(3 downto 0);
    signal piedras_p1_B2, piedras_p2_B2, piedras_p3_B2, piedras_p4_B2 : std_logic_vector(1 downto 0);
    signal num_ronda_B2 : unsigned(7 downto 0);
    signal aleatorio_in_B2 : std_logic_vector(5 downto 0);

    component Bloque3 is
        port (
            clk           : in  std_logic;
            reset         : in  std_logic;
            continue      : in  std_logic; -- boton
            confirm       : in  std_logic; -- otro boton
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
    end component;
    -- señales Bloque3
    signal reset_B3, continue_B3, confirm_B3, freqdiv_end_B3, freqdiv_reset_B3, end_inserting_B3 : std_logic;
    signal segments7_B3 : std_logic_vector(19 downto 0);
    signal leds_B3, player_number_B3 : std_logic_vector(3 downto 0);
    signal ap1_B3, ap2_B3, ap3_B3, ap4_B3 : std_logic_vector(3 downto 0);
    signal round_B3 : unsigned(7 downto 0);
    signal rng_B3 : std_logic_vector(5 downto 0); 

    component ResolRonda is
    Port (  clk             : in STD_LOGIC;
            reset           : in STD_LOGIC;
            fdiv_reset      : out STD_LOGIC;
            fdiv_fin        : in STD_LOGIC;
            R_NumPiedras1   : in std_logic_vector (1 downto 0);
            R_NumPiedras2   : in std_logic_vector (1 downto 0);
            R_NumPiedras3   : in std_logic_vector (1 downto 0);
            R_NumPiedras4   : in std_logic_vector (1 downto 0);
            R_Apuesta1      : in std_logic_vector (3 downto 0);
            R_Apuesta2      : in std_logic_vector (3 downto 0);
            R_Apuesta3      : in std_logic_vector (3 downto 0);
            R_Apuesta4      : in std_logic_vector (3 downto 0);
            W_Puntos1       : out std_logic;
            W_Puntos2       : out std_logic;
            W_Puntos3       : out std_logic;
            W_Puntos4       : out std_logic;
            W_Display       : out std_logic_vector(19 downto 0);
            fin             : out std_logic
           );
    end component;
    --señales de las entradas de ResolRonda
    signal fdiv_reset_RR, fdiv_fin_RR, W_Puntos1_RR, W_Puntos2_RR, W_Puntos3_RR, W_Puntos4_RR : std_logic;
    signal W_Puntos1_RR_ant, W_Puntos2_RR_ant, W_Puntos3_RR_ant, W_Puntos4_RR_ant : std_logic;
    signal R_NumPiedras1_RR, R_NumPiedras2_RR, R_NumPiedras3_RR, R_NumPiedras4_RR : std_logic_vector(1 downto 0);
    signal R_Apuesta1_RR, R_Apuesta2_RR, R_Apuesta3_RR, R_Apuesta4_RR : std_logic_vector(3 downto 0);
    signal W_Display_RR : std_logic_vector(19 downto 0);
    signal reset_RR, fin_RR : std_logic;

    component FinJuego is
    port(
        clk           : in  std_logic;
        reset         : in  std_logic;
        Num_jugadores : in  std_logic_vector(3 downto 0);
        p1            : in  std_logic_vector(1 downto 0);
        p2            : in  std_logic_vector(1 downto 0);
        p3            : in  std_logic_vector(1 downto 0);
        p4            : in  std_logic_vector(1 downto 0);
        repetir       : out std_logic;
        ganador       : out std_logic_vector(19 downto 0)
    );
    end component;
    --señales FinJuego
    signal repetir_FJ : std_logic;
    signal display_FJ : std_logic_vector(19 downto 0);
    signal reset_FJ : std_logic;
    signal p1_FJ, p2_FJ, p3_FJ, p4_FJ : std_logic_vector(1 downto 0);
    signal Num_jugadores_FJ : std_logic_vector(3 downto 0);
    
    -- máquina de estados principal
    type estados is (SJug, ExtPied, IntrApuesta, ResRonda, FinJug);
    signal estado : estados;

    -- registro
    signal Num_Jugadores : std_logic_vector(3 downto 0);
    signal NumPiedras1, NumPiedras2, NumPiedras3, NumPiedras4 : std_logic_vector(1 downto 0);
    signal Apuesta1, Apuesta2, Apuesta3, Apuesta4 : std_logic_vector(3 downto 0);
    signal Puntos1, Puntos2, Puntos3, Puntos4 : std_logic_vector(1 downto 0);
    signal ronda : unsigned(7 downto 0);

begin
    AR_bot1 : Antirrebotes
    port map (
        clk => clk,
        reset => reset,
        boton => botones(0),
        filtrado => botones_filtrado(0)
    );

    AR_bot2 : Antirrebotes
    port map (
        clk => clk,
        reset => reset,
        boton => botones(1),
        filtrado => botones_filtrado(1)
    );

    AR_bot3 : Antirrebotes
    port map (
        clk => clk,
        reset => reset,
        boton => botones(2),
        filtrado => botones_filtrado(2)
    );

    Decod_contrl : DecoderControler
    port map(
        clk => clk,
        reset => reset,
        Input => DisplayIN,
        Output => segments,
        Selector => selector
    );

    Decod_leds : DecoderLeds
    port map(
        Input => leds_controler,
        Leds => leds_output
    );

    fdiv : Freqdiv
    port map (
        clk => clk,
        reset => fdiv_reset,
        Output => fdiv_fin
    );

    rng_comp : RNG
    port map (
        clk => clk,
        reset => reset,
        random_number => rng_out
    );

    SJug_comp : SeleccionJugadores
    port map (
        clk => clk,
        reset => reset_SJ,
        continue => continue_SJ,
        switches => switches_SJ,
        freq_div_fin => fdiv_fin_SJ,
        freq_div_start => fdiv_start_SJ,
        Fin => fin_SJ,
        seven_segments => display_SJ,
        Num => Num_Jug_SJ
    );
    
    extraccion_piedras : Bloque2
    port map (
        clk => clk,
        reset => reset_B2,
        NUM_JUGADORES => num_jugadores_B2,
        NUM_RONDA => num_ronda_B2,
        ALEATORIO_IN => aleatorio_in_B2,
        SWITCHES => switches_B2,
        BTN_CONFIRM => btn_confirm_B2,
        BTN_CONTINUAR => btn_continuar_B2,
        freqdiv_end => freqdiv_end_B2,
        freqdiv_reset => freqdiv_reset_B2,
        segments7 => segments7_B2,
        PIEDRAS_P1 => piedras_p1_B2,
        PIEDRAS_P2 => piedras_p2_B2,
        PIEDRAS_P3 => piedras_p3_B2,
        PIEDRAS_P4 => piedras_p4_B2,
        FIN_FASE => fin_fase_B2
    );

    Bloque3_inst : Bloque3
    port map (
        clk => clk,
        reset => reset_B3,
        continue => continue_B3,
        confirm => confirm_B3,
        switches => switches,
        player_number => player_number_B3,
        freqdiv_end => freqdiv_end_B3,
        round => round_B3,
        rng => rng_out,

        freqdiv_reset => freqdiv_reset_B3,
        segments7 => segments7_B3,
        leds => leds_controler,
        ap1 => ap1_B3,
        ap2 => ap2_B3,
        ap3 => ap3_B3,
        ap4 => ap4_B3,

        end_inserting => end_inserting_B3
    );

    RRonda : ResolRonda
        port map (
            clk => clk,
            reset => reset_RR,
            fdiv_reset => fdiv_reset_RR,
            fdiv_fin => fdiv_fin_RR,
            R_NumPiedras1 => R_NumPiedras1_RR,
            R_NumPiedras2 => R_NumPiedras2_RR,
            R_NumPiedras3 => R_NumPiedras3_RR,
            R_NumPiedras4 => R_NumPiedras4_RR,
            R_Apuesta1 => R_Apuesta1_RR,
            R_Apuesta2 => R_Apuesta2_RR,
            R_Apuesta3 => R_Apuesta3_RR,
            R_Apuesta4 => R_Apuesta4_RR,
            W_Puntos1 => W_Puntos1_RR,
            W_Puntos2 => W_Puntos2_RR,
            W_Puntos3 => W_Puntos3_RR,
            W_Puntos4 => W_Puntos4_RR,
            W_Display => W_Display_RR,
            fin => fin_RR
        );

    FinJuego_inst : FinJuego
        port map (
            clk => clk,
            reset => reset_FJ,
            Num_jugadores => Num_jugadores_FJ,
            p1 => p1_FJ,
            p2 => p2_FJ,
            p3 => p3_FJ,
            p4 => p4_FJ,
            repetir => repetir_FJ,
            ganador => display_FJ
        );
    
    process(clk, reset)
    begin
    if reset = '1' then
        estado <= SJug;
        reset_SJ <= '1';
        reset_B2 <= '1';
        reset_B3 <= '1';
        reset_RR <= '1';
        reset_FJ <= '1';
        -- valores iniciales de las variables del registro
        Puntos1 <= (others => '0');
        Puntos2 <= (others => '0');
        Puntos3 <= (others => '0');
        Puntos4 <= (others => '0');
        Num_Jugadores <= (others => '-');
        NumPiedras1 <= (others => '-');
        NumPiedras2 <= (others => '-');
        NumPiedras3 <= (others => '-');
        NumPiedras4 <= (others => '-');
        Apuesta1 <= (others => '-');
        Apuesta2 <= (others => '-');
        Apuesta3 <= (others => '-');
        Apuesta4 <= (others => '-');
        ronda <= (others => '0');

    elsif clk'event and clk = '1' then
        case estado is
            when SJug => -- solo se ejecuta una vez al inicio de la partida
                if fin_SJ = '0' then
                    reset_SJ <= '0';
                else
                    estado <= ExtPied;
                    reset_SJ <= '1';
                end if;
                fdiv_reset <= fdiv_start_SJ;
                fdiv_fin_SJ <= fdiv_fin;
                Num_Jugadores <= Num_Jug_SJ;
                continue_SJ <= botones_filtrado(0);
                switches_SJ <= switches;
                DisplayIN <= display_SJ;
            when ExtPied =>
                if fin_fase_B2 = '0' then
                    reset_B2 <= '0';
                else
                    estado <= IntrApuesta;
                    reset_B2 <= '1';
                end if;
                fdiv_reset <= freqdiv_reset_B2;
                freqdiv_end_B2 <= fdiv_fin;
                num_jugadores_B2 <= Num_Jugadores;
                num_ronda_B2 <= ronda;
                aleatorio_in_B2 <= rng_out;
                switches_B2 <= switches;
                btn_confirm_B2 <= botones_filtrado(0);
                btn_continuar_B2 <= botones_filtrado(1);
                NumPiedras1 <= piedras_p1_B2;
                NumPiedras2 <= piedras_p2_B2;
                NumPiedras3 <= piedras_p3_B2;
                NumPiedras4 <= piedras_p4_B2;
                DisplayIN <= segments7_B2;
            when IntrApuesta =>
                if end_inserting_B3 = '0' then
                    reset_B3 <= '0';
                else
                    estado <= ResRonda;
                    reset_B3 <= '1';
                end if;
                fdiv_reset <= freqdiv_reset_B3;
                freqdiv_end_B3 <= fdiv_fin;
                player_number_B3 <= Num_Jugadores;
                round_B3 <= ronda;
                rng_B3 <= rng_out;
                continue_B3 <= botones_filtrado(2);
                confirm_B3 <= botones_filtrado(0);
                Apuesta1 <= ap1_B3;
                Apuesta2 <= ap2_B3;
                Apuesta3 <= ap3_B3;
                Apuesta4 <= ap4_B3;
                DisplayIN <= segments7_B3;
            when ResRonda =>
                -- lógica de transición de rondas
                if fin_RR = '0' then
                    reset_RR <= '0';
                else
                    estado <= FinJug;
                    reset_RR <= '1';
                end if;
                -- señales de entrada de ResolRonda
                fdiv_reset <= fdiv_reset_RR;
                fdiv_fin_RR <= fdiv_fin;
                R_NumPiedras1_RR <= NumPiedras1;
                R_NumPiedras2_RR <= NumPiedras2;
                R_NumPiedras3_RR <= NumPiedras3;
                R_NumPiedras4_RR <= NumPiedras4;
                R_Apuesta1_RR <= Apuesta1;
                R_Apuesta2_RR <= Apuesta2;
                R_Apuesta3_RR <= Apuesta3;
                R_Apuesta4_RR <= Apuesta4;
                DisplayIN <= W_Display_RR;
            when FinJug =>
                Num_jugadores_FJ <= Num_Jugadores;
                p1_FJ <= Puntos1;
                p2_FJ <= Puntos2;
                p3_FJ <= Puntos3;
                p4_FJ <= Puntos4;
                DisplayIN <= display_FJ;
                if repetir_FJ = '1' then
                    estado <= ExtPied;
                    reset_FJ <= '1';
                    ronda <= ronda + 1;
                else
                    reset_FJ <= '0';
                end if;
        end case;

        -- lógica de actualización de puntos
        if W_Puntos1_RR = '1' then
                if W_Puntos1_RR_ant = '0' then
                    Puntos1 <= std_logic_vector(unsigned(Puntos1) + 1);
                end if;
                W_Puntos1_RR_ant <= '1';
            else
                W_Puntos1_RR_ant <= '0';
            end if;
            if W_Puntos2_RR = '1' then
                if W_Puntos2_RR_ant = '0' then
                    Puntos2 <= std_logic_vector(unsigned(Puntos2) + 1);
                end if;
                W_Puntos2_RR_ant <= '1';
            else
                W_Puntos2_RR_ant <= '0';
            end if;
            if W_Puntos3_RR = '1' then
                if W_Puntos3_RR_ant = '0' then
                    Puntos3 <= std_logic_vector(unsigned(Puntos3) + 1);
                end if;
                W_Puntos3_RR_ant <= '1';
            else
                W_Puntos3_RR_ant <= '0';
            end if;
            if W_Puntos4_RR = '1' then
                if W_Puntos4_RR_ant = '0' then
                    Puntos4 <= std_logic_vector(unsigned(Puntos4) + 1);
                end if;
                W_Puntos4_RR_ant <= '1';
            else
                W_Puntos4_RR_ant <= '0';
            end if;
    end if;
    end process;

    -- Split the 12-bit output into leds_8 and leds_4
    leds_8 <= leds_output(11 downto 4);
    leds_4 <= leds_output(3 downto 0);
end Behavioral;
