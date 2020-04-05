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

    signal Module_Adr : std_logic_vector(23 downto 0);
    signal Module_Sel : std_logic_vector(3 downto 0);
    signal Module_We : std_logic;
    signal Module_Stb : std_logic;
    signal Module_DatOut : std_logic_vector(31 downto 0);
    signal Module_DatIn: std_logic_vector(31 downto 0);
    signal Module_Ack : std_logic;
    signal Module_Cyc : std_logic_vector(0 downto 0);

    signal Bus_Adr : std_logic_vector(23 downto 0);
    signal Bus_Sel : std_logic_vector(3 downto 0);
    signal Bus_We : std_logic;
    signal Bus_Stb : std_logic;
    signal Bus_DatOut : std_logic_vector(31 downto 0);
    signal Bus_DatIn: std_logic_vector(31 downto 0);
    signal Bus_Ack : std_logic;
    signal Bus_Cyc : std_logic_vector(0 downto 0);

    signal Stack_Adr : std_logic_vector(23 downto 0);
    signal Stack_Sel : std_logic_vector(3 downto 0);
    signal Stack_We : std_logic;
    signal Stack_Stb : std_logic;
    signal Stack_DatOut : std_logic_vector(31 downto 0);
    signal Stack_DatIn: std_logic_vector(31 downto 0);
    signal Stack_Ack : std_logic;
    signal Stack_Cyc : std_logic_vector(0 downto 0);

    signal Store_Adr : std_logic_vector(23 downto 0);
    signal Store_Sel : std_logic_vector(3 downto 0);
    signal Store_We : std_logic;
    signal Store_Stb : std_logic;
    signal Store_DatOut : std_logic_vector(31 downto 0);
    signal Store_DatIn: std_logic_vector(31 downto 0);
    signal Store_Ack : std_logic;
    signal Store_Cyc : std_logic_vector(0 downto 0);

    signal StoreMemory_Adr : std_logic_vector(23 downto 0);
    signal StoreMemory_Sel : std_logic_vector(3 downto 0);
    signal StoreMemory_We : std_logic;
    signal StoreMemory_Stb : std_logic;
    signal StoreMemory_DatOut : std_logic_vector(31 downto 0);
    signal StoreMemory_DatIn: std_logic_vector(31 downto 0);
    signal StoreMemory_Ack : std_logic;
    signal StoreMemory_Cyc : std_logic_vector(0 downto 0);

    signal WbRam_Adr : std_logic_vector(23 downto 0);
    signal WbRam_Sel : std_logic_vector(3 downto 0);
    signal WbRam_We : std_logic;
    signal WbRam_Stb : std_logic;
    signal WbRam_DatOut : std_logic_vector(31 downto 0);
    signal WbRam_DatIn: std_logic_vector(31 downto 0);
    signal WbRam_Ack : std_logic;
    signal WbRam_Cyc : std_logic_vector(0 downto 0);

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
            Bus_Adr : out std_logic_vector(23 downto 0);
            Bus_Sel : out std_logic_vector(3 downto 0);
            Bus_We : out std_logic;
            Bus_Stb : out std_logic;
            Bus_DatOut : out std_logic_vector(31 downto 0);
            Bus_DatIn: in std_logic_vector(31 downto 0);
            Bus_Ack : in std_logic;
            Bus_Cyc : out std_logic_vector(0 downto 0);
            Trap : out std_logic
        );
    end component;

    component WasmFpgaBus
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
        ModuleArea_Adr : out std_logic_vector(23 downto 0);
        ModuleArea_Sel : out std_logic_vector(3 downto 0);
        ModuleArea_We : out std_logic;
        ModuleArea_Stb : out std_logic;
        ModuleArea_DatOut : out std_logic_vector(31 downto 0);
        ModuleArea_DatIn: in std_logic_vector(31 downto 0);
        ModuleArea_Ack : in std_logic;
        ModuleArea_Cyc : out std_logic;
        StackArea_Adr : out std_logic_vector(23 downto 0);
        StackArea_Sel : out std_logic_vector(3 downto 0);
        StackArea_We : out std_logic;
        StackArea_Stb : out std_logic;
        StackArea_DatOut : out std_logic_vector(31 downto 0);
        StackArea_DatIn: in std_logic_vector(31 downto 0);
        StackArea_Ack : in std_logic;
        StackArea_Cyc : out std_logic;
        StoreArea_Adr : out std_logic_vector(23 downto 0);
        StoreArea_Sel : out std_logic_vector(3 downto 0);
        StoreArea_We : out std_logic;
        StoreArea_Stb : out std_logic;
        StoreArea_DatOut : out std_logic_vector(31 downto 0);
        StoreArea_DatIn: in std_logic_vector(31 downto 0);
        StoreArea_Ack : in std_logic;
        StoreArea_Cyc : out std_logic
      );
    end component;

    component WasmFpgaStack
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

    component WasmFpgaStore
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
        Memory_Adr : out std_logic_vector(23 downto 0);
        Memory_Sel : out std_logic_vector(3 downto 0);
        Memory_We : out std_logic;
        Memory_Stb : out std_logic;
        Memory_DatOut : out std_logic_vector(31 downto 0);
        Memory_DatIn: in std_logic_vector(31 downto 0);
        Memory_Ack : in std_logic;
        Memory_Cyc : out std_logic_vector(0 downto 0)
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

    WbRam_Adr <= FileIO_WbRam.Adr when FileIO_WbRam.Cyc = "1" else Module_Adr;
    WbRam_Sel <= FileIO_WbRam.Sel when FileIO_WbRam.Cyc = "1" else Module_Sel;
    WbRam_We <= FileIO_WbRam.We when FileIO_WbRam.Cyc = "1" else '0';
    WbRam_Stb <= FileIO_WbRam.Stb when FileIO_WbRam.Cyc = "1" else Module_Stb;
    WbRam_DatIn <= FileIO_WbRam.DatIn when FileIO_WbRam.Cyc = "1" else Module_DatIn;
    WbRam_Cyc <= FileIO_WbRam.Cyc when FileIO_WbRam.Cyc = "1" else Module_Cyc;

    WbRam_FileIO.Ack <= WbRam_Ack;
    WbRam_FileIO.DatOut <= WbRam_DatOut;

    Module_DatOut <= WbRam_DatOut;
    Module_Ack <= WbRam_Ack;

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
            Bus_Adr => Bus_Adr,
            Bus_Sel => Bus_Sel,
            Bus_We => Bus_We,
            Bus_Stb => Bus_Stb,
            Bus_DatOut => Bus_DatIn,
            Bus_DatIn => Bus_DatOut,
            Bus_Ack => Bus_Ack,
            Bus_Cyc => Bus_Cyc,
            Trap => open
       );

    WasmFpgaBus_i : WasmFpgaBus
        port map (
            Clk => Clk100M,
            nRst => nRst,
            Adr => Bus_Adr,
            Sel => Bus_Sel,
            DatIn => Bus_DatIn,
            We => Bus_We,
            Stb => Bus_Stb,
            Cyc => Bus_Cyc,
            DatOut => Bus_DatOut,
            Ack => Bus_Ack,
            ModuleArea_Adr => Module_Adr,
            ModuleArea_Sel => Module_Sel,
            ModuleArea_We => Module_We,
            ModuleArea_Stb => Module_Stb,
            ModuleArea_DatOut => Module_DatIn,
            ModuleArea_DatIn => Module_DatOut,
            ModuleArea_Ack => Module_Ack,
            ModuleArea_Cyc => Module_Cyc(0),
            StackArea_Adr => Stack_Adr,
            StackArea_Sel => Stack_Sel,
            StackArea_We => Stack_We,
            StackArea_Stb => Stack_Stb,
            StackArea_DatOut => Stack_DatIn,
            StackArea_DatIn => Stack_DatOut,
            StackArea_Ack => Stack_Ack,
            StackArea_Cyc => Stack_Cyc(0),
            StoreArea_Adr => Store_Adr,
            StoreArea_Sel => Store_Sel,
            StoreArea_We => Store_We,
            StoreArea_Stb => Store_Stb,
            StoreArea_DatOut => Store_DatIn,
            StoreArea_DatIn => Store_DatOut,
            StoreArea_Ack => Store_Ack,
            StoreArea_Cyc => Store_Cyc(0)
       );

    WasmFpgaStack_i : WasmFpgaStack
        port map (
            Clk => Clk100M,
            nRst => nRst,
            Adr => Stack_Adr,
            Sel => Stack_Sel,
            DatIn => Stack_DatIn,
            We => Stack_We,
            Stb => Stack_Stb,
            Cyc => Stack_Cyc,
            DatOut => Stack_DatOut,
            Ack => Stack_Ack
       );

    WasmFpgaStore_i : WasmFpgaStore
      port map (
        Clk => Clk100M,
        nRst => nRst,
        Adr => Store_Adr,
        Sel => Store_Sel,
        DatIn => Store_DatIn,
        We => Store_We,
        Stb => Store_Stb,
        Cyc => Store_Cyc,
        DatOut => Store_DatOut,
        Ack => Store_Ack,
        Memory_Adr => StoreMemory_Adr,
        Memory_Sel => StoreMemory_Sel,
        Memory_We => StoreMemory_We,
        Memory_Stb => StoreMemory_Stb,
        Memory_DatOut => StoreMemory_DatIn,
        Memory_DatIn => StoreMemory_DatOut,
        Memory_Ack => StoreMemory_Ack,
        Memory_Cyc => StoreMemory_Cyc
      );

    ModuleMemory_i : WbRam
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

    StoreMemory_i : WbRam
        port map ( 
            Clk => Clk100M,
            nRst => nRst,
            Adr => StoreMemory_Adr,
            Sel => StoreMemory_Sel,
            DatIn => StoreMemory_DatIn,
            We => StoreMemory_We,
            Stb => StoreMemory_Stb,
            Cyc => StoreMemory_Cyc,
            DatOut => StoreMemory_DatOut,
            Ack => StoreMemory_Ack
        );

end;
