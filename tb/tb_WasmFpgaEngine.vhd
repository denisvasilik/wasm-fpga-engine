library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

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

    signal WasmFpgaEngineDebug_FileIO : T_WasmFpgaEngineDebug_FileIO;
    signal FileIO_WasmFpgaEngineDebug : T_FileIO_WasmFpgaEngineDebug;

    signal ModuleMemory_FileIO : T_ModuleMemory_FileIO;
    signal FileIO_ModuleMemory : T_FileIO_ModuleMemory;

    signal StoreMemory_FileIO : T_StoreMemory_FileIO;
    signal FileIO_StoreMemory : T_FileIO_StoreMemory;

    signal StackMemory_FileIO : T_StackMemory_FileIO;
    signal FileIO_StackMemory : T_FileIO_StackMemory;

    signal Memory_FileIO : T_Memory_FileIO;
    signal FileIO_Memory : T_FileIO_Memory;

    signal WasmFpgaBus_WasmFpgaStore : T_WasmFpgaBus_WasmFpgaStore;
    signal WasmFpgaStore_WasmFpgaBus : T_WasmFpgaStore_WasmFpgaBus;

    signal WasmFpgaBus_WasmFpgaStack : T_WasmFpgaBus_WasmFpgaStack;
    signal WasmFpgaStack_WasmFpgaBus : T_WasmFpgaStack_WasmFpgaBus;

    signal WasmFpgaBus_WasmFpgaEngine : T_WasmFpgaBus_WasmFpgaEngine;
    signal WasmFpgaEngine_WasmFpgaBus : T_WasmFpgaEngine_WasmFpgaBus;

    signal WasmFpgaBus_WasmFpgaMemory : T_WasmFpgaBus_WasmFpgaMemory;
    signal WasmFpgaMemory_WasmFpgaBus : T_WasmFpgaMemory_WasmFpgaBus;

    signal WasmFpgaBus_FileIO : T_WasmFpgaBus_FileIO;
    signal FileIO_WasmFpgaBus : T_FileIO_WasmFpgaBus;

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

    signal Memory_Adr : std_logic_vector(23 downto 0);
    signal Memory_Sel : std_logic_vector(3 downto 0);
    signal Memory_We : std_logic;
    signal Memory_Stb : std_logic;
    signal Memory_DatOut : std_logic_vector(31 downto 0);
    signal Memory_DatIn: std_logic_vector(31 downto 0);
    signal Memory_Ack : std_logic;
    signal Memory_Cyc : std_logic_vector(0 downto 0);

    signal StoreMemory_Adr : std_logic_vector(23 downto 0);
    signal StoreMemory_Sel : std_logic_vector(3 downto 0);
    signal StoreMemory_We : std_logic;
    signal StoreMemory_Stb : std_logic;
    signal StoreMemory_DatOut : std_logic_vector(31 downto 0);
    signal StoreMemory_DatIn: std_logic_vector(31 downto 0);
    signal StoreMemory_Ack : std_logic;
    signal StoreMemory_Cyc : std_logic_vector(0 downto 0);

    signal StackMemory_Adr : std_logic_vector(23 downto 0);
    signal StackMemory_Sel : std_logic_vector(3 downto 0);
    signal StackMemory_We : std_logic;
    signal StackMemory_Stb : std_logic;
    signal StackMemory_DatOut : std_logic_vector(31 downto 0);
    signal StackMemory_DatIn: std_logic_vector(31 downto 0);
    signal StackMemory_Ack : std_logic;
    signal StackMemory_Cyc : std_logic_vector(0 downto 0);

    signal ModuleMemory_Adr : std_logic_vector(23 downto 0);
    signal ModuleMemory_Sel : std_logic_vector(3 downto 0);
    signal ModuleMemory_We : std_logic;
    signal ModuleMemory_Stb : std_logic;
    signal ModuleMemory_DatOut : std_logic_vector(31 downto 0);
    signal ModuleMemory_DatIn: std_logic_vector(31 downto 0);
    signal ModuleMemory_Ack : std_logic;
    signal ModuleMemory_Cyc : std_logic_vector(0 downto 0);

begin

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

    tb_FileIO_i : entity work.tb_FileIO
        generic map (
            stimulus_path => stimulus_path,
            stimulus_file => stimulus_file
        )
        port map (
            Clk => Clk100M,
            Rst => Rst,
            nRst => nRst,
            WasmFpgaEngine_FileIO => WasmFpgaEngine_FileIO,
            FileIO_WasmFpgaEngine => FileIO_WasmFpgaEngine,
            WasmFpgaEngineDebug_FileIO => WasmFpgaEngineDebug_FileIO,
            FileIO_WasmFpgaEngineDebug => FileIO_WasmFpgaEngineDebug,
            WasmFpgaBus_FileIO => WasmFpgaBus_FileIO,
            FileIO_WasmFpgaBus => FileIO_WasmFpgaBus,
            ModuleMemory_FileIO => ModuleMemory_FileIO,
            FileIO_ModuleMemory => FileIO_ModuleMemory,
            StoreMemory_FileIO => StoreMemory_FileIO,
            FileIO_StoreMemory => FileIO_StoreMemory,
            StackMemory_FileIO => StackMemory_FileIO,
            FileIO_StackMemory => FileIO_StackMemory,
            Memory_FileIO => Memory_FileIO,
            FileIO_Memory => FileIO_Memory
        );

    -- File IO and WebAssembly engine can write to store memory
    StackMemory_Adr <= FileIO_StackMemory.Adr when FileIO_StackMemory.Cyc = "1" else Stack_Adr;
    StackMemory_Sel <= FileIO_StackMemory.Sel when FileIO_StackMemory.Cyc = "1" else Stack_Sel;
    StackMemory_We <= FileIO_StackMemory.We when FileIO_StackMemory.Cyc = "1" else Stack_We;
    StackMemory_Stb <= FileIO_StackMemory.Stb when FileIO_StackMemory.Cyc = "1" else Stack_Stb;
    StackMemory_DatIn <= FileIO_StackMemory.DatIn when FileIO_StackMemory.Cyc = "1" else Stack_DatIn;
    StackMemory_Cyc <= FileIO_StackMemory.Cyc when FileIO_StackMemory.Cyc = "1" else Stack_Cyc;

    StackMemory_FileIO.Ack <= StackMemory_Ack;
    StackMemory_FileIO.DatOut <= StackMemory_DatOut;

    Stack_DatOut <= StackMemory_DatOut;
    Stack_Ack <= StackMemory_Ack;

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

    -- File IO and WebAssembly engine can write to the bus
    Bus_Adr <= FileIO_WasmFpgaBus.Adr when FileIO_WasmFpgaBus.Cyc = "1" else WasmFpgaEngine_WasmFpgaBus.Adr;
    Bus_Sel <= FileIO_WasmFpgaBus.Sel when FileIO_WasmFpgaBus.Cyc = "1" else WasmFpgaEngine_WasmFpgaBus.Sel;
    Bus_We <= FileIO_WasmFpgaBus.We when FileIO_WasmFpgaBus.Cyc = "1" else WasmFpgaEngine_WasmFpgaBus.We;
    Bus_Stb <= FileIO_WasmFpgaBus.Stb when FileIO_WasmFpgaBus.Cyc = "1" else WasmFpgaEngine_WasmFpgaBus.Stb;
    Bus_DatIn <= FileIO_WasmFpgaBus.DatIn when FileIO_WasmFpgaBus.Cyc = "1" else WasmFpgaEngine_WasmFpgaBus.DatIn;
    Bus_Cyc <= FileIO_WasmFpgaBus.Cyc when FileIO_WasmFpgaBus.Cyc = "1" else WasmFpgaEngine_WasmFpgaBus.Cyc;

    WasmFpgaBus_FileIO.Ack <= Bus_Ack;
    WasmFpgaBus_FileIO.DatOut <= Bus_DatOut;

    WasmFpgaBus_WasmFpgaEngine.DatOut <= Bus_DatOut;
    WasmFpgaBus_WasmFpgaEngine.Ack <= Bus_Ack;

    -- File IO and WebAssembly engine can write to memory
    Memory_Adr <= FileIO_Memory.Adr when FileIO_Memory.Cyc = "1" else WasmFpgaBus_WasmFpgaMemory.Adr;
    Memory_Sel <= FileIO_Memory.Sel when FileIO_Memory.Cyc = "1" else WasmFpgaBus_WasmFpgaMemory.Sel;
    Memory_We <= FileIO_Memory.We when FileIO_Memory.Cyc = "1" else WasmFpgaBus_WasmFpgaMemory.We;
    Memory_Stb <= FileIO_Memory.Stb when FileIO_Memory.Cyc = "1" else WasmFpgaBus_WasmFpgaMemory.Stb;
    Memory_DatIn <= FileIO_Memory.DatIn when FileIO_Memory.Cyc = "1" else WasmFpgaBus_WasmFpgaMemory.DatIn;
    Memory_Cyc <= FileIO_Memory.Cyc when FileIO_Memory.Cyc = "1" else WasmFpgaBus_WasmFpgaMemory.Cyc;

    Memory_FileIO.Ack <= Memory_Ack;
    Memory_FileIO.DatOut <= Memory_DatOut;

    WasmFpgaMemory_WasmFpgaBus.DatOut <= Memory_DatOut;
    WasmFpgaMemory_WasmFpgaBus.Ack <= Memory_Ack;

    WasmFpgaEngine_i : entity work.WasmFpgaEngine
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
            Debug_Adr => FileIO_WasmFpgaEngineDebug.Adr,
            Debug_Sel => FileIO_WasmFpgaEngineDebug.Sel,
            Debug_DatIn => FileIO_WasmFpgaEngineDebug.DatIn,
            Debug_We => FileIO_WasmFpgaEngineDebug.We,
            Debug_Stb => FileIO_WasmFpgaEngineDebug.Stb,
            Debug_Cyc => FileIO_WasmFpgaEngineDebug.Cyc,
            Debug_DatOut => WasmFpgaEngineDebug_FileIO.DatOut,
            Debug_Ack => WasmFpgaEngineDebug_FileIO.Ack,
            Bus_Adr => WasmFpgaEngine_WasmFpgaBus.Adr,
            Bus_Sel => WasmFpgaEngine_WasmFpgaBus.Sel,
            Bus_We => WasmFpgaEngine_WasmFpgaBus.We,
            Bus_Stb => WasmFpgaEngine_WasmFpgaBus.Stb,
            Bus_DatOut => WasmFpgaEngine_WasmFpgaBus.DatIn,
            Bus_DatIn => WasmFpgaBus_WasmFpgaEngine.DatOut,
            Bus_Ack => WasmFpgaBus_WasmFpgaEngine.Ack,
            Bus_Cyc => WasmFpgaEngine_WasmFpgaBus.Cyc,
            Trap => open
       );

    WasmFpgaBus_i : entity work.WasmFpgaBus
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
            StackArea_Adr => WasmFpgaBus_WasmFpgaStack.Adr,
            StackArea_Sel => WasmFpgaBus_WasmFpgaStack.Sel,
            StackArea_We => WasmFpgaBus_WasmFpgaStack.We,
            StackArea_Stb => WasmFpgaBus_WasmFpgaStack.Stb,
            StackArea_DatOut => WasmFpgaBus_WasmFpgaStack.DatIn,
            StackArea_DatIn => WasmFpgaStack_WasmFpgaBus.DatOut,
            StackArea_Ack => WasmFpgaStack_WasmFpgaBus.Ack,
            StackArea_Cyc => WasmFpgaBus_WasmFpgaStack.Cyc(0),
            StoreArea_Adr => WasmFpgaBus_WasmFpgaStore.Adr,
            StoreArea_Sel => WasmFpgaBus_WasmFpgaStore.Sel,
            StoreArea_We => WasmFpgaBus_WasmFpgaStore.We,
            StoreArea_Stb => WasmFpgaBus_WasmFpgaStore.Stb,
            StoreArea_DatOut => WasmFpgaBus_WasmFpgaStore.DatIn,
            StoreArea_DatIn => WasmFpgaStore_WasmFpgaBus.DatOut,
            StoreArea_Ack => WasmFpgaStore_WasmFpgaBus.Ack,
            StoreArea_Cyc => WasmFpgaBus_WasmFpgaStore.Cyc(0),
            MemoryArea_Adr => WasmFpgaBus_WasmFpgaMemory.Adr,
            MemoryArea_Sel => WasmFpgaBus_WasmFpgaMemory.Sel,
            MemoryArea_We => WasmFpgaBus_WasmFpgaMemory.We,
            MemoryArea_Stb => WasmFpgaBus_WasmFpgaMemory.Stb,
            MemoryArea_DatOut => WasmFpgaBus_WasmFpgaMemory.DatIn,
            MemoryArea_DatIn => WasmFpgaMemory_WasmFpgaBus.DatOut,
            MemoryArea_Ack => WasmFpgaMemory_WasmFpgaBus.Ack,
            MemoryArea_Cyc => WasmFpgaBus_WasmFpgaMemory.Cyc(0)
       );

    WasmFpgaStack_i : entity work.WasmFpgaStack
        port map (
            Clk => Clk100M,
            nRst => nRst,
            Adr => WasmFpgaBus_WasmFpgaStack.Adr,
            Sel => WasmFpgaBus_WasmFpgaStack.Sel,
            DatIn => WasmFpgaBus_WasmFpgaStack.DatIn,
            We => WasmFpgaBus_WasmFpgaStack.We,
            Stb => WasmFpgaBus_WasmFpgaStack.Stb,
            Cyc => WasmFpgaBus_WasmFpgaStack.Cyc,
            DatOut => WasmFpgaStack_WasmFpgaBus.DatOut,
            Ack => WasmFpgaStack_WasmFpgaBus.Ack,
            Stack_Adr => Stack_Adr,
            Stack_Sel => Stack_Sel,
            Stack_We => Stack_We,
            Stack_Stb => Stack_Stb,
            Stack_DatOut => Stack_DatIn,
            Stack_DatIn => Stack_DatOut,
            Stack_Ack => Stack_Ack,
            Stack_Cyc => Stack_Cyc,
            Trap => open
       );

    WasmFpgaStore_i : entity work.WasmFpgaStore
      generic map (
          PinMaxAddress => true,
          MaxAddress => x"00000100"
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

    ModuleMemory_i : entity work.WbRam
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

    StoreMemory_i : entity work.WbRam
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

    StackMemory_i : entity work.WbRam
        port map (
            Clk => Clk100M,
            nRst => nRst,
            Adr => StackMemory_Adr,
            Sel => StackMemory_Sel,
            DatIn => StackMemory_DatIn,
            We => StackMemory_We,
            Stb => StackMemory_Stb,
            Cyc => StackMemory_Cyc,
            DatOut => StackMemory_DatOut,
            Ack => StackMemory_Ack
        );

    Memory_i : entity work.WbRam
        port map (
            Clk => Clk100M,
            nRst => nRst,
            Adr => Memory_Adr,
            Sel => Memory_Sel,
            DatIn => Memory_DatIn,
            We => Memory_We,
            Stb => Memory_Stb,
            Cyc => Memory_Cyc,
            DatOut => Memory_DatOut,
            Ack => Memory_Ack
        );

end;
