-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pongZybo2017spring is
  Port ( 
    Clock : in STD_LOGIC;
    Reset : in STD_LOGIC;
    rota : in STD_LOGIC;
    rotb : in STD_LOGIC;
    red : out STD_LOGIC_VECTOR ( 4 downto 0 );
    green : out STD_LOGIC_VECTOR ( 5 downto 0 );
    blue : out STD_LOGIC_VECTOR ( 4 downto 0 );
    hsync : out STD_LOGIC;
    vsync : out STD_LOGIC
  );

end pongZybo2017spring;

architecture stub of pongZybo2017spring is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
begin
end;
