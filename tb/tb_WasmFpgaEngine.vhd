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

    signal ModuleMemory_FileIO : T_ModuleMemory_FileIO;
    signal FileIO_ModuleMemory : T_FileIO_ModuleMemory;

    signal StoreMemory_FileIO : T_StoreMemory_FileIO;
    signal FileIO_StoreMemory : T_FileIO_StoreMemory;

    signal WasmFpgaBus_WasmFpgaStore : T_WasmFpgaBus_WasmFpgaStore;
    signal WasmFpgaStore_WasmFpgaBus : T_WasmFpgaStore_WasmFpgaBus;

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

    signal ModuleMemory_Adr : std_logic_vector(23 downto 0);
    signal ModuleMemory_Sel : std_logic_vector(3 downto 0);
    signal ModuleMemory_We : std_logic;
    signal ModuleMemory_Stb : std_logic;
    signal ModuleMemory_DatOut : std_logic_vector(31 downto 0);
    signal ModuleMemory_DatIn: std_logic_vector(31 downto 0);
    signal ModuleMemory_Ack : std_logic;
    signal ModuleMemory_Cyc : std_logic_vector(0 downto 0);

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
            ModuleMemory_FileIO : in T_ModuleMemory_FileIO;
            FileIO_ModuleMemory : out T_FileIO_ModuleMemory;
            StoreMemory_FileIO : in T_StoreMemory_FileIO;
            FileIO_StoreMemory : out T_FileIO_StoreMemory
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
      generic (
        PinMaxAddress : boolean := false;
        MaxAddress : std_logic_vector(31 downto 0) := x"00000000"
      );
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
            ModuleMemory_FileIO => ModuleMemory_FileIO,
            FileIO_ModuleMemory => FileIO_ModuleMemory,
            StoreMemory_FileIO => StoreMemory_FileIO,
            FileIO_StoreMemory => FileIO_StoreMemory
        );

    -- File IO and WebAssembly engine can write to module memory
    ModuleMemory_Adr <= FileIO_ModuleMemory.Adr when FileIO_ModuleMemory.Cyc = "1" else Module_Adr;
    ModuleMemory_Sel <= FileIO_ModuleMemory.Sel when FileIO_ModuleMemory.Cyc = "1" else Module_Sel;
    ModuleMemory_We <= FileIO_ModuleMemory.We when FileIO_ModuleMemory.Cyc = "1" else '0';
    ModuleMemory_Stb <= FileIO_ModuleMemory.Stb when FileIO_ModuleMemory.Cyc = "1" else Module_Stb;
    ModuleMemory_DatIn <= FileIO_ModuleMemory.DatIn when FileIO_ModuleMemory.Cyc = "1" else Module_DatIn;
    ModuleMemory_Cyc <= FileIO_ModuleMemory.Cyc when FileIO_ModuleMemory.Cyc = "1" else Module_Cyc;

    ModuleMemory_FileIO.Ack <= ModuleMemory_Ack;
    ModuleMemory_FileIO.DatOut <= ModuleMemory_DatOut;

    Module_DatOut <= ModuleMemory_DatOut;
    Module_Ack <= ModuleMemory_Ack;

    -- File IO and WebAssembly engine can write to store memory
    StoreMemory_Adr <= FileIO_StoreMemory.Adr when FileIO_StoreMemory.Cyc = "1" else Store_Adr;
    StoreMemory_Sel <= FileIO_StoreMemory.Sel when FileIO_StoreMemory.Cyc = "1" else Store_Sel;
    StoreMemory_We <= FileIO_StoreMemory.We when FileIO_StoreMemory.Cyc = "1" else '0';
    StoreMemory_Stb <= FileIO_StoreMemory.Stb when FileIO_StoreMemory.Cyc = "1" else Store_Stb;
    StoreMemory_DatIn <= FileIO_StoreMemory.DatIn when FileIO_StoreMemory.Cyc = "1" else Store_DatIn;
    StoreMemory_Cyc <= FileIO_StoreMemory.Cyc when FileIO_StoreMemory.Cyc = "1" else Store_Cyc;

    StoreMemory_FileIO.Ack <= StoreMemory_Ack;
    StoreMemory_FileIO.DatOut <= StoreMemory_DatOut;

    Store_DatOut <= StoreMemory_DatOut;
    Store_Ack <= StoreMemory_Ack;

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
            StoreArea_Adr => WasmFpgaBus_WasmFpgaStore.Adr,
            StoreArea_Sel => WasmFpgaBus_WasmFpgaStore.Sel,
            StoreArea_We => WasmFpgaBus_WasmFpgaStore.We,
            StoreArea_Stb => WasmFpgaBus_WasmFpgaStore.Stb,
            StoreArea_DatOut => WasmFpgaBus_WasmFpgaStore.DatIn,
            StoreArea_DatIn => WasmFpgaStore_WasmFpgaBus.DatOut,
            StoreArea_Ack => WasmFpgaStore_WasmFpgaBus.Ack,
            StoreArea_Cyc => WasmFpgaBus_WasmFpgaStore.Cyc(0)
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
      generic map (
          PinMaxAddress => true,
          MaxAddress => x"00000020"
      )
      port map (
        Clk => Clk100M,
        nRst => nRst,
        Adr => WasmFpgaBus_WasmFpgaStore.Adr,
        Sel => WasmFpgaBus_WasmFpgaStore.Sel,
        DatIn => WasmFpgaBus_WasmFpgaStore.DatIn,
        We => WasmFpgaBus_WasmFpgaStore.We,
        Stb => WasmFpgaBus_WasmFpgaStore.Stb,
        Cyc => WasmFpgaBus_WasmFpgaStore.Cyc,
        DatOut => WasmFpgaStore_WasmFpgaBus.DatOut,
        Ack => WasmFpgaStore_WasmFpgaBus.Ack,
        Memory_Adr => Store_Adr,
        Memory_Sel => Store_Sel,
        Memory_We => Store_We,
        Memory_Stb => Store_Stb,
        Memory_DatOut => Store_DatIn,
        Memory_DatIn => Store_DatOut,
        Memory_Ack => Store_Ack,
        Memory_Cyc => Store_Cyc
      );

    ModuleMemory_i : WbRam
        port map ( 
            Clk => Clk100M,
            nRst => nRst,
            Adr => ModuleMemory_Adr,
            Sel => ModuleMemory_Sel,
            DatIn => ModuleMemory_DatIn,
            We => ModuleMemory_We,
            Stb => ModuleMemory_Stb,
            Cyc => ModuleMemory_Cyc,
            DatOut => ModuleMemory_DatOut,
            Ack => ModuleMemory_Ack
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
