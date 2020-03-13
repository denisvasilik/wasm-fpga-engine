library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.tb_types.all;

entity tb_WasmFpgaEngine is
    generic (
        stimulus_path : string := "../../../../../simstm/";
        stimulus_file : string := "WasmFpgaEngine.stm"
    );
end;

architecture behavioural of tb_WasmFpgaEngine is

    constant CLK100M_PERIOD : time := 10 ns;

    signal Clk100M : std_logic := '0';
    signal Rst : std_logic := '1';
    signal nRst : std_logic := '0';

    signal WasmFpgaEngine_FileIO : T_WasmFpgaEngine_FileIO;
    signal FileIO_WasmFpgaEngine : T_FileIO_WasmFpgaEngine;

    signal WbRam_FileIO : T_WbRam_FileIO;
    signal FileIO_WbRam : T_FileIO_WbRam;

    signal ModuleArea_Adr : std_logic_vector(23 downto 0);
    signal ModuleArea_Sel : std_logic_vector(3 downto 0);
    signal ModuleArea_We : std_logic;
    signal ModuleArea_Stb : std_logic;
    signal ModuleArea_DatOut : std_logic_vector(31 downto 0);
    signal ModuleArea_DatIn: std_logic_vector(31 downto 0);
    signal ModuleArea_Ack : std_logic;
    signal ModuleArea_Cyc : std_logic_vector(0 downto 0);

    signal WbRam_Adr : std_logic_vector(23 downto 0);
    signal WbRam_Sel : std_logic_vector(3 downto 0);
    signal WbRam_We : std_logic;
    signal WbRam_Stb : std_logic;
    signal WbRam_DatOut : std_logic_vector(31 downto 0);
    signal WbRam_DatIn: std_logic_vector(31 downto 0);
    signal WbRam_Ack : std_logic;
    signal WbRam_Cyc : std_logic_vector(0 downto 0);

    component WbRam is
        port ( 
            Clk : in std_logic;
            nRst : in std_logic;
            Adr : in std_logic_vector(23 downto 0);
            Sel : in std_logic_vector(3 downto 0);
            DatIn : in std_logic_vector(31 downto 0); 
            We : in std_logic;
            Stb : in std_logic; 
            Cyc : in std_logic_vector(0 downto 0);
            DatOut : out std_logic_vector(31 downto 0);
            Ack : out std_logic
        );
    end component;

    component tb_FileIO is
        generic (
            stimulus_path: in string;
            stimulus_file: in string
        );
        port (
            Clk : in std_logic;
            Rst : in std_logic;
            WasmFpgaEngine_FileIO : in T_WasmFpgaEngine_FileIO;
            FileIO_WasmFpgaEngine : out T_FileIO_WasmFpgaEngine;
            WbRam_FileIO : in T_WbRam_FileIO;
            FileIO_WbRam : out T_FileIO_WbRam
        );
    end component;

    component WasmFpgaEngine
        port (
            Clk : in std_logic;
            nRst : in std_logic;
            Adr : in std_logic_vector(23 downto 0);
            Sel : in std_logic_vector(3 downto 0);
            DatIn : in std_logic_vector(31 downto 0); 
            We : in std_logic;
            Stb : in std_logic; 
            Cyc : in std_logic_vector(0 downto 0);
            DatOut : out std_logic_vector(31 downto 0);
            Ack : out std_logic;
            Module_Adr : out std_logic_vector(23 downto 0);
            Module_Sel : out std_logic_vector(3 downto 0);
            Module_We : out std_logic;
            Module_Stb : out std_logic;
            Module_DatOut : out std_logic_vector(31 downto 0);
            Module_DatIn: in std_logic_vector(31 downto 0);
            Module_Ack : in std_logic;
            Module_Cyc : out std_logic_vector(0 downto 0)
		);
    end component;

begin

	nRst <= not Rst;

    Clk100MGen : process is
    begin
        Clk100M <= not Clk100M;
        wait for CLK100M_PERIOD / 2;
    end process;

    RstGen : process is
    begin
        Rst <= '1';
        wait for 100ns;
        Rst <= '0';
        wait;
    end process;

    tb_FileIO_i : tb_FileIO
        generic map (
            stimulus_path => stimulus_path,
            stimulus_file => stimulus_file
        )
        port map (
            Clk => Clk100M,
            Rst => Rst,
            WasmFpgaEngine_FileIO => WasmFpgaEngine_FileIO,
            FileIO_WasmFpgaEngine => FileIO_WasmFpgaEngine,
            WbRam_FileIO => WbRam_FileIO,
            FileIO_WbRam => FileIO_WbRam
        );

    WbRam_Adr <= FileIO_WbRam.Adr when FileIO_WbRam.Cyc = "1" else ModuleArea_Adr;
    WbRam_Sel <= FileIO_WbRam.Sel when FileIO_WbRam.Cyc = "1" else ModuleArea_Sel;
    WbRam_We <= FileIO_WbRam.We when FileIO_WbRam.Cyc = "1" else '0';
    WbRam_Stb <= FileIO_WbRam.Stb when FileIO_WbRam.Cyc = "1" else ModuleArea_Stb;
    WbRam_DatIn <= FileIO_WbRam.DatIn when FileIO_WbRam.Cyc = "1" else ModuleArea_DatIn;
    WbRam_Cyc <= FileIO_WbRam.Cyc when FileIO_WbRam.Cyc = "1" else ModuleArea_Cyc;

    WbRam_FileIO.Ack <= WbRam_Ack;
    WbRam_FileIO.DatOut <= WbRam_DatOut;

    ModuleArea_DatOut <= WbRam_DatOut;
    ModuleArea_Ack <= WbRam_Ack;

    WbRam_i : WbRam
        port map ( 
            Clk => Clk100M,
            nRst => nRst,
            Adr => WbRam_Adr,
            Sel => WbRam_Sel,
            DatIn => WbRam_DatIn,
            We => WbRam_We,
            Stb => WbRam_Stb,
            Cyc => WbRam_Cyc,
            DatOut => WbRam_DatOut,
            Ack => WbRam_Ack
        );

    WasmFpgaEngine_i : WasmFpgaEngine
        port map (
            Clk => Clk100M,
            nRst => nRst,
            Adr => FileIO_WasmFpgaEngine.Adr,
            Sel => FileIO_WasmFpgaEngine.Sel,
            DatIn => FileIO_WasmFpgaEngine.DatIn,
            We => FileIO_WasmFpgaEngine.We,
            Stb => FileIO_WasmFpgaEngine.Stb,
            Cyc => FileIO_WasmFpgaEngine.Cyc,
            DatOut => WasmFpgaEngine_FileIO.DatOut,
            Ack => WasmFpgaEngine_FileIO.Ack,
            Module_Adr => ModuleArea_Adr,
            Module_Sel => ModuleArea_Sel,
            Module_We => ModuleArea_We,
            Module_Stb => ModuleArea_Stb,
            Module_DatOut => ModuleArea_DatIn,
            Module_DatIn => ModuleArea_DatOut,
            Module_Ack => ModuleArea_Ack,
            Module_Cyc => ModuleArea_Cyc
       );

end;
