library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package tb_Types is

    type T_WasmFpgaEngine_FileIO is
    record
        DatOut : std_logic_vector(31 downto 0);
        Ack : std_logic;
    end record;

    type T_FileIO_WasmFpgaEngine is
    record
        Adr : std_logic_vector(23 downto 0);
        Sel : std_logic_vector(3 downto 0);
        DatIn : std_logic_vector(31 downto 0);
        We : std_logic;
        Stb : std_logic;
        Cyc : std_logic_vector(0 downto 0);
    end record;

    type T_WbRam_FileIO is
    record
        DatOut : std_logic_vector(31 downto 0);
        Ack : std_logic;
    end record;

    type T_FileIO_WbRam is
    record
        Adr : std_logic_vector(23 downto 0);
        Sel : std_logic_vector(3 downto 0);
        DatIn : std_logic_vector(31 downto 0);
        We : std_logic;
        Stb : std_logic;
        Cyc : std_logic_vector(0 downto 0);
    end record;

end package;

package body tb_Types is

end package body;
