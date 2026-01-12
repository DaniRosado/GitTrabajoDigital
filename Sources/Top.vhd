library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
use work.estados_pkg.all;

entity Top is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC; -- de la FPGA
           leds_4 : out STD_LOGIC_VECTOR (3 downto 0);
           botones : in STD_LOGIC_VECTOR (3 downto 0);
           selector : out STD_LOGIC_VECTOR (3 downto 0);
           segments : out STD_LOGIC_VECTOR (6 downto 0);
           leds_8 : out STD_LOGIC_VECTOR (7 downto 0);
           switches : in STD_LOGIC_VECTOR (3 downto 0)           
           );
end Top;

-- comentario de los botones
-- boton 0: CONFIRMACIÓN
-- boton 1: REINICIO
-- boton 2: CONTINUAR

architecture Behavioral of Top is
    -- componentes de filtrado y auxiliares
    component Antirrebotes is
    Port (  clk      : in  std_logic;
            reset    : in  std_logic;
        
            boton    : in  std_logic;
            filtrado : out std_logic
            );
    end component;
    -- señales internas de los antirrebotes
    signal botonesf : STD_LOGIC_VECTOR (3 downto 0);
    -- Freqdiv
    component Freqdiv is
    Port (  clk    :  in  std_logic;
            reset  :  in  std_logic;

            fdiv_out :  out std_logic);
    end component;
    -- señales internas del freqdiv
    signal fdiv_reset_int, fdiv_out_int : std_logic;
    -- Controlador de los leds
    component DecoderControler is
    port(   clk    :   in  std_logic;
            reset  :   in  std_logic;

            long_mensaje_in  : in  std_logic_vector(19 downto 0); 

            segments : out std_logic_vector( 6 downto 0);      -- Salida para el display de 7 segmentos
            selector : out std_logic_vector( 3 downto 0)       -- Selector para saber que 7s se va a actualizar
         );
    end component;
    -- señales internas del decodercontroler
    signal long_mensaje_in_int : std_logic_vector(19 downto 0);

    -- FMS
    component fms is
    Port (  clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            
            signal estado : estados;
            signal fin_B1 : in STD_LOGIC;
            signal fin_B2 : in STD_LOGIC;
            signal fin_B3 : in STD_LOGIC;
            signal fin_B4 : in STD_LOGIC;
            signal fin_B5 : in STD_LOGIC;

            signal reset_B1 : out STD_LOGIC;
            signal reset_B2 : out STD_LOGIC;
            signal reset_B3 : out STD_LOGIC;
            signal reset_B4 : out STD_LOGIC;
            signal reset_B5 : out STD_LOGIC
           );
    end component;
    -- señales internas del fms
    signal estado_fms : estados;
    signal fin_B1_int, fin_B2_int, fin_B3_int, fin_B4_int, fin_B5_int : STD_LOGIC;
    signal reset_B1_int, reset_B2_int, reset_B3_int, reset_B4_int, reset_B5_int : STD_LOGIC;

    -- instanciamos los distintos bloques 
    component Bloque1 is
    port(
        clk            : in  std_logic;
        reset          : in  std_logic;  -- 1 = apagado (estado inicial), 0 = funcionando

        btn_confirm        : in  std_logic;  -- boton CONFIRMACION (elige nº jugadores)
        btn_continue       : in  std_logic;  -- boton CONTINUAR (salta los 5s)

        switches       : in  std_logic_vector(3 downto 0);
        fdiv_fin   : in  std_logic;
        fdiv_reset : out std_logic;  -- Va al reset del FreqDiv: 1=reset(parado), 0=contando
        Fin            : out std_logic;
        seven_segments : out std_logic_vector(19 downto 0);
        num_jug            : out std_logic_vector(3 downto 0)
    );
    end component;
    -- definimos las señales internas del bloque 1
    
    component Bloque2 is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        
        num_jug     : in  std_logic_vector (3 downto 0);    -- "0010"(2), "0011"(3), "0100"(4)
        num_ronda   : in  unsigned (7 downto 0);            -- Ronda actual
        rng_in      : in  std_logic_vector (5 downto 0);

        switches      : in  std_logic_vector (3 downto 0);
        btn_continue : in  std_logic;
        btn_confirm   : in  std_logic;

        fdiv_fin   : in  std_logic;                         -- Pulso de fin de 5s
        fdiv_reset : out std_logic;

        segments7     : out std_logic_vector (19 downto 0); -- 4 dígitos x 5 bits

        R_NumPiedras1   : out std_logic_vector (1 downto 0);  -- Apuesta al registro J1
        R_NumPiedras2   : out std_logic_vector (1 downto 0);  -- Apuesta al registro J2
        R_NumPiedras3   : out std_logic_vector (1 downto 0);  -- Apuesta al registro J3
        R_NumPiedras4   : out std_logic_vector (1 downto 0);  -- Apuesta al registro J4

        fin_fase : out std_logic
    );
    end component;
    component Bloque3 is
    Port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        
        num_jug     : in  std_logic_vector (3 downto 0); -- "0010"(2), "0011"(3), "0100"(4)
        num_ronda       : in  unsigned (7 downto 0); -- Ronda actual
        rng_in         : in  std_logic_vector (5 downto 0);
        
        switches    : in  std_logic_vector (3 downto 0);
        btn_continue    : in  std_logic;
        btn_confirm     : in  std_logic;

        fdiv_fin    : in  std_logic;                     -- Pulso de fin de 5s
        fdiv_reset  : out std_logic;

        segments7   : out std_logic_vector (19 downto 0); -- 4 dígitos x 5 bits
        leds        : out std_logic_vector (3 downto 0);  -- Barra de LEDs

        R_Apuesta1  : out std_logic_vector (3 downto 0);  -- Apuesta al registro J1
        R_Apuesta2  : out std_logic_vector (3 downto 0);  -- Apuesta al registro J2
        R_Apuesta3  : out std_logic_vector (3 downto 0);  -- Apuesta al registro J3
        R_Apuesta4  : out std_logic_vector (3 downto 0);  -- Apuesta al registro J4

        fin_fase : out std_logic                       -- Fin de fase
    );
    end component;
    component Bloque4 is
    Port (  clk : in STD_LOGIC;
            reset : in STD_LOGIC;

            fdiv_reset : out STD_LOGIC;
            fdiv_fin : in STD_LOGIC;
            
            R_NumPiedras1 : in std_logic_vector (1 downto 0);
            R_NumPiedras2 : in std_logic_vector (1 downto 0);
            R_NumPiedras3 : in std_logic_vector (1 downto 0);
            R_NumPiedras4 : in std_logic_vector (1 downto 0);

            R_Apuesta1 : in std_logic_vector (3 downto 0);
            R_Apuesta2 : in std_logic_vector (3 downto 0);
            R_Apuesta3 : in std_logic_vector (3 downto 0);
            R_Apuesta4 : in std_logic_vector (3 downto 0);

            R_Puntos1 : out std_logic;
            R_Puntos2 : out std_logic;
            R_Puntos3 : out std_logic;
            R_Puntos4 : out std_logic;

            segments7 : out std_logic_vector(19 downto 0);
            
            fin_fase : out std_logic
           );
    end component;
    component Bloque5 is
    Port(
            clk           : in  std_logic;
            reset         : in  std_logic;
            
            num_jug     : in  std_logic_vector(3 downto 0);
            R_Puntos1   : in  std_logic_vector(1 downto 0);
            R_Puntos2   : in  std_logic_vector(1 downto 0);
            R_Puntos3   : in  std_logic_vector(1 downto 0);
            R_Puntos4   : in  std_logic_vector(1 downto 0);

            repetir     : out std_logic;

            segments7   : out std_logic_vector(19 downto 0) -- display
        );
    end component;

begin
    -- instanciamos todos los componentes que se van a usar
    -- instanciación de los antirrebotes para los botones
    antirrebotes_B1 : Antirrebotes
    Port map ( clk => clk,
               reset => reset,
               boton => botones(0),
               filtrado => botonesf(0)
            );
    antirrebotes_B2 : Antirrebotes
    Port map ( clk => clk,
               reset => reset,
               boton => botones(1),
               filtrado => botonesf(1)
            );
    antirrebotes_B3 : Antirrebotes
    Port map ( clk => clk,
               reset => reset,
               boton => botones(2),
               filtrado => botonesf(2)
            );
    antirrebotes_B4 : Antirrebotes
    Port map ( clk => clk,
               reset => reset,
               boton => botones(3),
               filtrado => botonesf(3)
            );
    --- instanciación del freqdiv
    freqdiv_inst : Freqdiv
    Port map ( clk => clk,
               reset => fdiv_reset_int,
               fdiv_out => fdiv_out_int
             );
    -- instanciación del decodercontroler
    decodercontroler_inst : DecoderControler
    port map( clk => clk,
              reset => reset,
              long_mensaje_in => long_mensaje_in_int,
              segments => segments,
              selector => selector
            );
    -- instanciación del FMS
    fms_inst : fms
    Port map ( clk => clk,
               reset => reset, -- aquí seguramente tengamos que meter el boton1
               estado => estado_fms,
               fin_B1 => fin_B1_int,
               fin_B2 => fin_B2_int,
               fin_B3 => fin_B3_int,
               fin_B4 => fin_B4_int,
               fin_B5 => fin_B5_int,
               reset_B1 => reset_B1_int,
               reset_B2 => reset_B2_int,
               reset_B3 => reset_B3_int,
               reset_B4 => reset_B4_int,
               reset_B5 => reset_B5_int
             );
    -- instanciamos los bloques principales
    -- instanciación del bloque 1
    bloque1_inst : Bloque1
    port map( clk => clk,
              reset => reset_B1_int,
              btn_confirm => botonesf(0),
              btn_continue => botonesf(2),
              switches => switches,
              fdiv_fin => fdiv_out_int,
              fdiv_reset => fdiv_reset_int,
              Fin => fin_B1_int,
              seven_segments => long_mensaje_in_int,
              num_jug => leds_4
    );
    -- instanciación del bloque 2
    bloque2_inst : Bloque2
    port map( clk => clk,
              reset => reset_B2_int,
              num_jug => leds_4,
              num_ronda => "00000001", -- pendiente de conectar
              rng_in => "000000", -- pendiente de conectar
              switches => switches,
              btn_continue => botonesf(2),
              btn_confirm => botonesf(0),
              fdiv_fin => fdiv_out_int,
              fdiv_reset => fdiv_reset_int,
              segments7 => long_mensaje_in_int,
              R_NumPiedras1 => open,
              R_NumPiedras2 => open,
              R_NumPiedras3 => open,
              R_NumPiedras4 => open,
              fin_fase => fin_B2_int
    );
    
end Behavioral;
