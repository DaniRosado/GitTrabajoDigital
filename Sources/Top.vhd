library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.estados_pkg.all;

entity Top is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC; -- de la FPGA

           leds_4 : out STD_LOGIC_VECTOR (3 downto 0); --Placa rosa
           leds_8 : out STD_LOGIC_VECTOR (7 downto 0); --Placa negra

           botones  : in STD_LOGIC_VECTOR (3 downto 0);
           selector : out STD_LOGIC_VECTOR (3 downto 0);
           segments : out STD_LOGIC_VECTOR (6 downto 0);

           switches : in STD_LOGIC_VECTOR (3 downto 0)           
           );
end Top;

-- Distribución de botones:
-- boton 0: CONFIRMACIÓN
-- boton 1: REINICIO
-- boton 2: CONTINUAR

architecture Behavioral of Top is

    --||ANTIREBOTES||--
    component Antirrebotes is
    Port (  clk      : in  std_logic;
            reset    : in  std_logic;
        
            boton    : in  std_logic;
            filtrado : out std_logic
            );
    end component;
    -- señales internas para los botones filtrados (outputs)
    signal botonesf : STD_LOGIC_VECTOR (3 downto 0);


    --||FREQDIV||--
    component Freqdiv is
    Port (clk    :  in  std_logic;

          estado_in :  in  estados;

          reset1  :  in  std_logic;
          reset2  :  in  std_logic;
          reset3  :  in  std_logic;
          reset4  :  in  std_logic;
          reset5  :  in  std_logic;
          
          fdiv_out :  out std_logic);
    end component;

    -- señales internas del freqdiv
    signal fdiv_reset1_int, fdiv_reset2_int, fdiv_reset3_int, fdiv_reset4_int, fdiv_reset5_int, fdiv_out_int : std_logic; 

    --||RNG||--
    component RNG_Generator is
    Port ( clk     : in  STD_LOGIC;
           reset   : in  STD_LOGIC; --Reset de la placa

           rng_out : out STD_LOGIC_VECTOR (5 downto 0));
    end component;
    -- señales internas del RNG
    signal rng_out_int : STD_LOGIC_VECTOR (5 downto 0);

    --||DECODER CONTROLER||--
    component DecoderControler is
    port(clk    :   in  std_logic;
         reset  :   in  std_logic;

         estado_in  :   in  estados;

         long_mensaje1_in  : in  std_logic_vector(19 downto 0);
         long_mensaje2_in  : in  std_logic_vector(19 downto 0);
         long_mensaje3_in  : in  std_logic_vector(19 downto 0);
         long_mensaje4_in  : in  std_logic_vector(19 downto 0);
         long_mensaje5_in  : in  std_logic_vector(19 downto 0); 

         segments : out std_logic_vector( 6 downto 0);      -- Salida para el display de 7 segmentos
         selector : out std_logic_vector( 3 downto 0)       -- Selector para saber que 7s se va a actualizar
         );
    end component;
    -- señales internas del decodercontroler
    signal long_mensaje1_in_int : std_logic_vector(19 downto 0);
    signal long_mensaje2_in_int : std_logic_vector(19 downto 0);
    signal long_mensaje3_in_int : std_logic_vector(19 downto 0);
    signal long_mensaje4_in_int : std_logic_vector(19 downto 0);
    signal long_mensaje5_in_int : std_logic_vector(19 downto 0);

    --||FMS||--
    component fms is
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
    end component;
    -- señales internas del fms
    signal estado_fms : estados;
    signal fin_B1_int, fin_B2_int, fin_B3_int, fin_B4_int, fin_B5_int : STD_LOGIC;
    signal reset_B1_int, reset_B2_int, reset_B3_int, reset_B4_int, reset_B5_int : STD_LOGIC;


    --||REGISTRO||--
    component Registro is
    Port (clk : in STD_LOGIC;
          reset : in STD_LOGIC;

          estado_in : in estados;

          num_jug_in : in std_logic_vector (3 downto 0);
          num_jug_out : out std_logic_vector (3 downto 0);

          num_round_in  : in  std_logic;
          num_round_out : out unsigned(7 downto 0);

          NumPiedras1_in : in std_logic_vector (1 downto 0);
          NumPiedras2_in : in std_logic_vector (1 downto 0);
          NumPiedras3_in : in std_logic_vector (1 downto 0);
          NumPiedras4_in : in std_logic_vector (1 downto 0);

          NumPiedras1_out : out std_logic_vector (1 downto 0);
          NumPiedras2_out : out std_logic_vector (1 downto 0);
          NumPiedras3_out : out std_logic_vector (1 downto 0);
          NumPiedras4_out : out std_logic_vector (1 downto 0);

          Apuesta1_in : in std_logic_vector (3 downto 0);
          Apuesta2_in : in std_logic_vector (3 downto 0);
          Apuesta3_in : in std_logic_vector (3 downto 0);
          Apuesta4_in : in std_logic_vector (3 downto 0);

          Apuesta1_out : out std_logic_vector (3 downto 0);
          Apuesta2_out : out std_logic_vector (3 downto 0);
          Apuesta3_out : out std_logic_vector (3 downto 0);
          Apuesta4_out : out std_logic_vector (3 downto 0);

          Puntos1_in : in std_logic;
          Puntos2_in : in std_logic;
          Puntos3_in : in std_logic;
          Puntos4_in : in std_logic;

          Puntos1_out : out std_logic_vector (1 downto 0);
          Puntos2_out : out std_logic_vector (1 downto 0);
          Puntos3_out : out std_logic_vector (1 downto 0);
          Puntos4_out : out std_logic_vector (1 downto 0)
    );
    end component;
    -- señales internas del registro
    signal num_jug_in_int, num_jug_out_int : std_logic_vector (3 downto 0);
    signal num_round_in_int : std_logic;
    signal num_round_out_int : unsigned (7 downto 0);
    signal NumPiedras1_in_int, NumPiedras2_in_int, NumPiedras3_in_int, NumPiedras4_in_int : std_logic_vector (1 downto 0);
    signal NumPiedras1_out_int, NumPiedras2_out_int, NumPiedras3_out_int, NumPiedras4_out_int : std_logic_vector (1 downto 0);
    signal Apuesta1_in_int, Apuesta2_in_int, Apuesta3_in_int, Apuesta4_in_int : std_logic_vector (3 downto 0);
    signal Apuesta1_out_int, Apuesta2_out_int, Apuesta3_out_int, Apuesta4_out_int : std_logic_vector (3 downto 0);
    signal Puntos1_in_int, Puntos2_in_int, Puntos3_in_int, Puntos4_in_int : std_logic;
    signal Puntos1_out_int, Puntos2_out_int, Puntos3_out_int, Puntos4_out_int : std_logic_vector (1 downto 0);
    
    --||BLOQUES PRINCIPALES||-- 
    component Bloque1 is
    port(
        clk            : in  std_logic;
        reset          : in  std_logic;  -- 1 = apagado (estado inicial), 0 = funcionando

        btn_confirm    : in  std_logic;  -- boton CONFIRMACION (elige nº jugadores)
        btn_continue   : in  std_logic;  -- boton CONTINUAR (salta los 5s)

        switches    : in  std_logic_vector(3 downto 0);
        fdiv_fin    : in  std_logic;
        fdiv_reset  : out std_logic;  -- Va al reset del FreqDiv: 1=reset(parado), 0=contando
        fin_fase       : out std_logic;
        seven_segments : out std_logic_vector(19 downto 0);
        num_jug        : out std_logic_vector(3 downto 0)
    );
    end component;

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
        leds        : out std_logic_vector (11 downto 0);  -- Barra de LEDs

        R_Apuesta1  : out std_logic_vector (3 downto 0);  -- Apuesta al registro J1
        R_Apuesta2  : out std_logic_vector (3 downto 0);  -- Apuesta al registro J2
        R_Apuesta3  : out std_logic_vector (3 downto 0);  -- Apuesta al registro J3
        R_Apuesta4  : out std_logic_vector (3 downto 0);  -- Apuesta al registro J4

        fin_fase : out std_logic                       -- Fin de fase
    );
    end component;

    signal leds_int : STD_LOGIC_VECTOR (11 downto 0);

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

            W_Puntos1 : out std_logic;
            W_Puntos2 : out std_logic;
            W_Puntos3 : out std_logic;
            W_Puntos4 : out std_logic;

            R_Puntos1: in std_logic_vector (1 downto 0);
            R_Puntos2 : in std_logic_vector (1 downto 0);
            R_Puntos3 : in std_logic_vector (1 downto 0);
            R_Puntos4 : in std_logic_vector (1 downto 0);

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

            fin_fase     : out std_logic;

            segments7   : out std_logic_vector(19 downto 0) -- display
        );
    end component;

    signal Megareset : std_logic;
begin
    Megareset <= reset or botonesf(1); -- reset de la placa o boton de reinicio
    -- instanciamos todos los componentes que se van a usar
    -- instanciación de los antirrebotes para los botones
    antirrebotes_B1 : Antirrebotes
    Port map (clk => clk,
              reset => Megareset,
              boton => botones(0),
              filtrado => botonesf(0)
            );
    antirrebotes_B2 : Antirrebotes
    Port map (clk => clk,
              reset => Megareset,
              boton => botones(1),
              filtrado => botonesf(1)
            );
    antirrebotes_B3 : Antirrebotes
    Port map (clk => clk,
              reset => Megareset,
              boton => botones(2),
              filtrado => botonesf(2)
            );
    antirrebotes_B4 : Antirrebotes
    Port map (clk => clk,
              reset => Megareset,
              boton => botones(3),
              filtrado => botonesf(3)
            );
    --- instanciación del freqdiv
    freqdiv_inst : Freqdiv
    Port map (clk => clk,
              estado_in => estado_fms,
              reset1 => fdiv_reset1_int,
              reset2 => fdiv_reset2_int,
              reset3 => fdiv_reset3_int,
              reset4 => fdiv_reset4_int,
              reset5 => fdiv_reset5_int,
              fdiv_out => fdiv_out_int
             );
    -- instanciación del RNG
    rng_inst : RNG_Generator
    Port map ( clk => clk,
               reset => Megareset,
               rng_out => rng_out_int
             );
    -- instanciación del decodercontroler
    decodercontroler_inst : DecoderControler
    port map( clk => clk,
              reset => Megareset,
              estado_in => estado_fms,
              long_mensaje1_in => long_mensaje1_in_int,
              long_mensaje2_in => long_mensaje2_in_int,
              long_mensaje3_in => long_mensaje3_in_int,
              long_mensaje4_in => long_mensaje4_in_int,
              long_mensaje5_in => long_mensaje5_in_int,
              segments => segments,
              selector => selector
            );
    -- instanciación del FMS
    fms_inst : fms
    Port map ( clk => clk,
               reset => Megareset, -- aquí seguramente tengamos que meter el boton1
               estado_out => estado_fms,
               sum_round => num_round_in_int,
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
    -- instanciamos el registro
    registro_inst : Registro
    port map( clk => clk,
              reset => Megareset,
              estado_in => estado_fms,
              num_jug_in => num_jug_in_int,
              num_jug_out => num_jug_out_int,
              num_round_in => num_round_in_int,
              num_round_out => num_round_out_int,
              NumPiedras1_in => NumPiedras1_in_int,
              NumPiedras2_in => NumPiedras2_in_int,
              NumPiedras3_in => NumPiedras3_in_int,
              NumPiedras4_in => NumPiedras4_in_int,
              NumPiedras1_out => NumPiedras1_out_int,
              NumPiedras2_out => NumPiedras2_out_int,
              NumPiedras3_out => NumPiedras3_out_int,
              NumPiedras4_out => NumPiedras4_out_int,
              Apuesta1_in => Apuesta1_in_int,
              Apuesta2_in => Apuesta2_in_int,
              Apuesta3_in => Apuesta3_in_int,
              Apuesta4_in => Apuesta4_in_int,
              Apuesta1_out => Apuesta1_out_int,
              Apuesta2_out => Apuesta2_out_int,
              Apuesta3_out => Apuesta3_out_int,
              Apuesta4_out => Apuesta4_out_int,
              Puntos1_in => Puntos1_in_int,
              Puntos2_in => Puntos2_in_int,
              Puntos3_in => Puntos3_in_int,
              Puntos4_in => Puntos4_in_int,
              Puntos1_out => Puntos1_out_int,
              Puntos2_out => Puntos2_out_int,
              Puntos3_out => Puntos3_out_int,
              Puntos4_out => Puntos4_out_int
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
              fdiv_reset => fdiv_reset1_int,
              fin_fase => fin_B1_int,
              seven_segments => long_mensaje1_in_int,
              num_jug => num_jug_in_int
    );
    -- instanciación del bloque 2
    bloque2_inst : Bloque2
    port map( clk => clk,
              reset => reset_B2_int,
              num_jug => num_jug_out_int,
              num_ronda => num_round_out_int,
              rng_in => rng_out_int,
              switches => switches,
              btn_continue => botonesf(2),
              btn_confirm => botonesf(0),
              fdiv_fin => fdiv_out_int,
              fdiv_reset => fdiv_reset2_int,
              segments7 => long_mensaje2_in_int,
              R_NumPiedras1 => NumPiedras1_in_int,
              R_NumPiedras2 => NumPiedras2_in_int,
              R_NumPiedras3 => NumPiedras3_in_int,
              R_NumPiedras4 => NumPiedras4_in_int,
              fin_fase => fin_B2_int
    );
    -- instanciación del bloque 3
    bloque3_inst : Bloque3
    port map( clk => clk,
              reset => reset_B3_int,
              num_jug => num_jug_out_int,
              num_ronda => num_round_out_int,
              rng_in => rng_out_int,
              switches => switches,
              btn_continue => botonesf(2),
              btn_confirm => botonesf(0),
              fdiv_fin => fdiv_out_int,
              fdiv_reset => fdiv_reset3_int,
              segments7 => long_mensaje3_in_int,
              leds => leds_int,
              R_Apuesta1 => Apuesta1_in_int,
              R_Apuesta2 => Apuesta2_in_int,
              R_Apuesta3 => Apuesta3_in_int,
              R_Apuesta4 => Apuesta4_in_int,
              fin_fase => fin_B3_int
    );

    leds_4 <= leds_int(11 downto 8);
    leds_8 <= leds_int(7 downto 0);
    -- instanciación del bloque 4
    bloque4_inst : Bloque4
    Port map ( clk => clk,
               reset => reset_B4_int,
               fdiv_reset => fdiv_reset4_int,
               fdiv_fin => fdiv_out_int,
               R_NumPiedras1 => NumPiedras1_out_int,
               R_NumPiedras2 => NumPiedras2_out_int,
               R_NumPiedras3 => NumPiedras3_out_int,
               R_NumPiedras4 => NumPiedras4_out_int,
               R_Apuesta1 => Apuesta1_out_int,
               R_Apuesta2 => Apuesta2_out_int,
               R_Apuesta3 => Apuesta3_out_int,
               R_Apuesta4 => Apuesta4_out_int,
               W_Puntos1 => Puntos1_in_int,
               W_Puntos2 => Puntos2_in_int,
               W_Puntos3 => Puntos3_in_int,
               W_Puntos4 => Puntos4_in_int,
               R_puntos1 => Puntos1_out_int,
               R_puntos2 => Puntos2_out_int,
               R_puntos3 => Puntos3_out_int,
               R_puntos4 => Puntos4_out_int,
               segments7 => long_mensaje4_in_int,
               fin_fase => fin_B4_int
             );
    -- instanciación del bloque 5
    bloque5_inst : Bloque5
    Port map ( clk => clk,
               reset => reset_B5_int,
               num_jug => num_jug_out_int,
               R_Puntos1 => Puntos1_out_int,
               R_Puntos2 => Puntos2_out_int,
               R_Puntos3 => Puntos3_out_int,
               R_Puntos4 => Puntos4_out_int,
               fin_fase => fin_B5_int,
               segments7 => long_mensaje5_in_int
             );
    -- hacemos la conexiones correspondientes
    
end Behavioral;
