library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
use work.estados_pkg.all;

entity fms is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
                     
           );
end fms;

architecture Behavioral of fms is