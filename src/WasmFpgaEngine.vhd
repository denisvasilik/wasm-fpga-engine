library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;
  use work.WasmFpgaStackWshBn_Package.all;

entity WasmFpgaEngine is
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
        Debug_Adr : in std_logic_vector(23 downto 0);
        Debug_Sel : in std_logic_vector(3 downto 0);
        Debug_DatIn : in std_logic_vector(31 downto 0);
        Debug_We : in std_logic;
        Debug_Stb : in std_logic;
        Debug_Cyc : in std_logic_vector(0 downto 0);
        Debug_DatOut : out std_logic_vector(31 downto 0);
        Debug_Ack : out std_logic;
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
end;

architecture Behavioural of WasmFpgaEngine is

  signal Rst : std_logic;
  signal Run : std_logic;
  signal Debug : std_logic;
  signal Busy : std_logic;
  signal InvocationTrap : std_logic;
  signal InstantiationTrap : std_logic;


  signal Bus_ModuleBlk : T_WshBnUp;
  signal ModuleBlk_Bus : T_WshBnDown;

  signal Bus_StoreBlk : T_WshBnUp;
  signal StoreBlk_Bus : T_WshBnDown;

  signal Bus_StackBlk : T_WshBnUp;
  signal StackBlk_Bus : T_WshBnDown;

  signal Bus_MemoryBlk : T_WshBnUp;
  signal MemoryBlk_Bus : T_WshBnDown;


  signal WasmFpgaInstruction_WasmFpgaInvocation : T_FromWasmFpgaInstruction_Array;
  signal WasmFpgaInvocation_WasmFpgaInstruction : T_ToWasmFpgaInstruction_Array;

  signal WasmFpgaStack_WasmFpgaInstruction : T_FromWasmFpgaStack_Array;
  signal WasmFpgaInstruction_WasmFpgaStack : T_ToWasmFpgaStack_Array;

  signal WasmFpgaMemory_WasmFpgaInstruction : T_FromWasmFpgaMemory_Array;
  signal WasmFpgaInstruction_WasmFpgaMemory : T_ToWasmFpgaMemory_Array;

  signal WasmFpgaModuleRam_WasmFpgaInstruction : T_FromWasmFpgaModuleRam_Array;
  signal WasmFpgaInstruction_WasmFpgaModuleRam : T_ToWasmFpgaModuleRam_Array;

  signal WasmFpgaStore_WasmFpgaInstruction : T_FromWasmFpgaStore_Array;
  signal WasmFpgaInstruction_WasmFpgaStore : T_ToWasmFpgaStore_Array;


  signal WasmFpgaModuleRam_WasmFpgaInstantiation : T_FromWasmFpgaModuleRam;
  signal WasmFpgaInstantiation_WasmFpgaModuleRam : T_ToWasmFpgaModuleRam;

  signal WasmFpgaModuleRam_WasmFpgaInvocation : T_FromWasmFpgaModuleRam;
  signal WasmFpgaInvocation_WasmFpgaModuleRam : T_ToWasmFpgaModuleRam;

  signal WasmFpgaInstantiation_WasmFpgaStack : T_ToWasmFpgaStack;
  signal WasmFpgaStack_WasmFpgaInstantiation : T_FromWasmFpgaStack;

  signal WasmFpgaInstantiation_WasmFpgaStore : T_ToWasmFpgaStore;
  signal WasmFpgaStore_WasmFpgaInstantiation : T_FromWasmFpgaStore;


  signal EngineBlk_Ack : std_logic;
  signal EngineBlk_DatOut : std_logic_vector(31 downto 0);
  signal EngineBlk_Unoccupied_Ack : std_logic;

  signal ModuleInstanceUid : std_logic_vector(31 downto 0);

  signal StoreModuleInstanceUid : std_logic_vector(31 downto 0);
  signal StoreSectionUID : std_logic_vector(31 downto 0);
  signal StoreIdx : std_logic_vector(31 downto 0);

  signal StoreAddress : std_logic_vector(31 downto 0);
  signal StoreRun : std_logic;
  signal StoreBusy : std_logic;

  signal StackRun : std_logic;
  signal StackAction : std_logic_vector(2 downto 0);
  signal StackAddress : std_logic_vector(31 downto 0);
  signal StackBusy : std_logic;
  signal StackHighValue_ToBeRead : std_logic_vector(31 downto 0);
  signal StackHighValue_Written : std_logic_vector(31 downto 0);
  signal StackLowValue_ToBeRead : std_logic_vector(31 downto 0);
  signal StackLowValue_Written : std_logic_vector(31 downto 0);
  signal StackType_ToBeRead : std_logic_vector(2 downto 0);
  signal StackType_Written : std_logic_vector(2 downto 0);
  signal StackMaxLocals : std_logic_vector(31 downto 0);
  signal StackMaxResults : std_logic_vector(31 downto 0);
  signal StackReturnAddress_Written : std_logic_vector(31 downto 0);
  signal StackReturnAddress_ToBeRead : std_logic_vector(31 downto 0);
  signal StackModuleInstanceUid : std_logic_vector(31 downto 0);
  signal StackLocalIndex : std_logic_vector(31 downto 0);

  signal ModuleRamRun : std_logic;
  signal ModuleRamBusy : std_logic;
  signal ModuleRamAddress : std_logic_vector(23 downto 0);
  signal ModuleRamData : std_logic_vector(31 downto 0);

  signal MemoryRun : std_logic;
  signal MemoryBusy : std_logic;
  signal MemoryAddress : std_logic_vector(23 downto 0);
  signal MemoryReadData : std_logic_vector(31 downto 0);
  signal MemoryWriteData : std_logic_vector(31 downto 0);
  signal MemoryWriteEnable : std_logic;

  signal InstantiationRun : std_logic;
  signal InstantiationBusy : std_logic;

  signal WRegPulse_ControlReg : std_logic;
  signal WRegPulse_DebugControlReg : std_logic;

  signal InvocationRun : std_logic;
  signal InvocationBusy : std_logic;

  signal Breakpoint0 : std_logic_vector(31 downto 0);
  signal StopInMain : std_logic;
  signal StepOver : std_logic;
  signal StepInto : std_logic;
  signal StepOut : std_logic;
  signal Continue : std_logic;
  signal StopDebugging : std_logic;

  signal Instruction : std_logic_vector(7 downto 0);

  signal State : std_logic_vector(15 downto 0);

  signal EntryPointAddress : std_logic_vector(23 downto 0);

begin

  Rst <= not nRst;
  Busy <= InvocationBusy or InstantiationBusy;
  Trap <= InvocationTrap or InstantiationTrap;

  Ack <= EngineBlk_Ack;
  DatOut <= EngineBlk_DatOut;

  Bus_Adr <= ModuleBlk_Bus.Adr when ModuleBlk_Bus.Cyc = "1" else
             StackBlk_Bus.Adr when StackBlk_Bus.Cyc = "1" else
             StoreBlk_Bus.Adr when StoreBlk_Bus.Cyc = "1" else
             MemoryBlk_Bus.Adr when MemoryBlk_Bus.Cyc = "1" else
             (others => '0');

  Bus_Sel <= ModuleBlk_Bus.Sel when ModuleBlk_Bus.Cyc = "1" else
             StackBlk_Bus.Sel when StackBlk_Bus.Cyc = "1" else
             StoreBlk_Bus.Sel when StoreBlk_Bus.Cyc = "1" else
             MemoryBlk_Bus.Sel when MemoryBlk_Bus.Cyc = "1" else
             (others => '0');

  Bus_DatOut <= ModuleBlk_Bus.DatIn when ModuleBlk_Bus.Cyc = "1" else
                StackBlk_Bus.DatIn when StackBlk_Bus.Cyc = "1" else
                StoreBlk_Bus.DatIn when StoreBlk_Bus.Cyc = "1" else
                MemoryBlk_Bus.DatIn when MemoryBlk_Bus.Cyc = "1" else
                (others => '0');

  Bus_We <= ModuleBlk_Bus.We when ModuleBlk_Bus.Cyc = "1" else
            StackBlk_Bus.We when StackBlk_Bus.Cyc = "1" else
            StoreBlk_Bus.We when StoreBlk_Bus.Cyc = "1" else
            MemoryBlk_Bus.We when MemoryBlk_Bus.Cyc = "1" else
            '0';

  Bus_Stb <= ModuleBlk_Bus.Stb when ModuleBlk_Bus.Cyc = "1" else
             StackBlk_Bus.Stb when StackBlk_Bus.Cyc = "1" else
             StoreBlk_Bus.Stb when StoreBlk_Bus.Cyc = "1" else
             MemoryBlk_Bus.Stb when MemoryBlk_Bus.Cyc = "1" else
             '0';

  Bus_Cyc <= ModuleBlk_Bus.Cyc when ModuleBlk_Bus.Cyc = "1" else
             StackBlk_Bus.Cyc when StackBlk_Bus.Cyc = "1" else
             StoreBlk_Bus.Cyc when StoreBlk_Bus.Cyc = "1" else
             MemoryBlk_Bus.Cyc when MemoryBlk_Bus.Cyc = "1" else
             "0";

  Bus_MemoryBlk.DatOut <= Bus_DatIn;
  Bus_MemoryBlk.Ack <= Bus_Ack;

  Bus_ModuleBlk.DatOut <= Bus_DatIn;
  Bus_ModuleBlk.Ack <= Bus_Ack;

  Bus_StackBlk.DatOut <= Bus_DatIn;
  Bus_StackBlk.Ack <= Bus_Ack;

  Bus_StoreBlk.DatOut <= Bus_DatIn;
  Bus_StoreBlk.Ack <= Bus_Ack;

  Engine : process(Clk, nRst) is
  begin
    if (nRst = '0') then
        State <= StateIdle;
    elsif rising_edge(Clk) then
        if (State = StateIdle) then
            if ((WRegPulse_ControlReg = '1' and Run = '1') or
                (WRegPulse_DebugControlReg = '1' and Debug = '1')) then
                State <= State0;
            end if;
        elsif (State = State0) then
            InstantiationRun <= '1';
            State <= State1;
        elsif (State = State1) then
            InstantiationRun <= '0';
            State <= State2;
        elsif (State = State2) then
            if (InstantiationBusy = '0') then
                State <= State3;
            end if;
        elsif (State = State3) then
            InvocationRun <= '1';
            State <= State4;
        elsif (State = State4) then
            InvocationRun <= '0';
            State <= State5;
        elsif (State = State5) then
            if (InvocationBusy = '0') then
                State <= StateIdle;
            end if;
        end if;
    end if;
  end process;

  Arbiter : process (Clk, nRst) is
    variable CurrentInstruction : integer range 0 to 256;
  begin
    if (nRst = '0') then
        CurrentInstruction := 0;
        -- Stack
        StackRun <= '0';
        StackAction <= (others => '0');
        StackHighValue_Written <= (others => '0');
        StackLowValue_Written <= (others => '0');
        StackType_Written <= (others => '0');
        StackMaxLocals <= (others => '0');
        StackMaxResults <= (others => '0');
        StackReturnAddress_Written <= (others => '0');
        StackModuleInstanceUid <= (others => '0');
        StackLocalIndex <= (others => '0');
        for i in WasmFpgaStack_WasmFpgaInstruction'RANGE loop
            WasmFpgaStack_WasmFpgaInstruction(i).Busy <= '1';
            WasmFpgaStack_WasmFpgaInstruction(i).HighValue <= (others => '0');
            WasmFpgaStack_WasmFpgaInstruction(i).LowValue <= (others => '0');
            WasmFpgaStack_WasmFpgaInstruction(i).TypeValue <= (others => '0');
        end loop;
        -- Memory
        MemoryRun <= '0';
        MemoryAddress <= (others => '0');
        MemoryWriteEnable <= '0';
        MemoryWriteData <= (others => '0');
        for i in WasmFpgaMemory_WasmFpgaInstruction'RANGE loop
            WasmFpgaMemory_WasmFpgaInstruction(i).Busy <= '1';
            WasmFpgaMemory_WasmFpgaInstruction(i).ReadData <= (others => '0');
        end loop;
        -- Module
        ModuleRamRun <= '0';
        ModuleRamAddress <= (others => '0');
        WasmFpgaModuleRam_WasmFpgaInstantiation <= (
            ReadData => (others => '0'),
            Busy => '0',
            Address => (others => '0')
        );
        for i in WasmFpgaModuleRam_WasmFpgaInstruction'RANGE loop
            WasmFpgaModuleRam_WasmFpgaInstruction(i).Busy <= '1';
            WasmFpgaModuleRam_WasmFpgaInstruction(i).ReadData <= (others => '0');
            WasmFpgaModuleRam_WasmFpgaInstruction(i).Address <= (others => '0');
        end loop;
        WasmFpgaStack_WasmFpgaInstantiation.Busy <= '0';
        WasmFpgaStack_WasmFpgaInstantiation.HighValue <= (others => '0');
        WasmFpgaStack_WasmFpgaInstantiation.LowValue <= (others => '0');
        WasmFpgaStack_WasmFpgaInstantiation.TypeValue <= (others => '0');
        WasmFpgaStack_WasmFpgaInstantiation.ReturnAddress <= (others => '0');
        WasmFpgaModuleRam_WasmFpgaInvocation <= (
            ReadData => (others => '0'),
            Busy => '0',
            Address => (others => '0')
        );
        -- Store
        StoreModuleInstanceUid <= (others => '0');
        StoreSectionUID <= (others => '0');
        StoreIdx <= (others => '0');
        StoreRun <= '0';
    elsif rising_edge(Clk) then
        if (InstantiationBusy = '1') then
            -- Stack
            WasmFpgaStack_WasmFpgaInstantiation.Busy <= StackBusy;
            WasmFpgaStack_WasmFpgaInstantiation.HighValue <= StackHighValue_ToBeRead;
            WasmFpgaStack_WasmFpgaInstantiation.LowValue <= StackLowValue_ToBeRead;
            WasmFpgaStack_WasmFpgaInstantiation.TypeValue <= StackType_ToBeRead;
            WasmFpgaStack_WasmFpgaInstantiation.ReturnAddress <= StackReturnAddress_ToBeRead;
            StackRun <= WasmFpgaInstantiation_WasmFpgaStack.Run;
            StackAction <= WasmFpgaInstantiation_WasmFpgaStack.Action;
            StackLowValue_Written <= WasmFpgaInstantiation_WasmFpgaStack.LowValue;
            StackType_Written <= WasmFpgaInstantiation_WasmFpgaStack.TypeValue;
            StackMaxLocals <= WasmFpgaInstantiation_WasmFpgaStack.MaxLocals;
            StackMaxResults <= WasmFpgaInstantiation_WasmFpgaStack.MaxResults;
            StackReturnAddress_Written <= WasmFpgaInstantiation_WasmFpgaStack.ReturnAddress;
            StackModuleInstanceUid <= WasmFpgaInstantiation_WasmFpgaStack.ModuleInstanceUid;
            StackLocalIndex <= WasmFpgaInstantiation_WasmFpgaStack.LocalIndex;

            -- Module
            WasmFpgaModuleRam_WasmFpgaInstantiation.Busy <= ModuleRamBusy;
            WasmFpgaModuleRam_WasmFpgaInstantiation.ReadData <= ModuleRamData;
            WasmFpgaModuleRam_WasmFpgaInstantiation.Address <= ModuleRamAddress;
            ModuleRamRun <= WasmFpgaInstantiation_WasmFpgaModuleRam.Run;
            ModuleRamAddress <= WasmFpgaInstantiation_WasmFpgaModuleRam.Address;

            -- Store
            WasmFpgaStore_WasmFpgaInstantiation.Busy <= StoreBusy;
            WasmFpgaStore_WasmFpgaInstantiation.Address <= StoreAddress(23 downto 0);
            StoreModuleInstanceUid <= WasmFpgaInstantiation_WasmFpgaStore.ModuleInstanceUid;
            StoreSectionUID <= WasmFpgaInstantiation_WasmFpgaStore.SectionUID;
            StoreIdx <= WasmFpgaInstantiation_WasmFpgaStore.Idx;
            StoreRun <= WasmFpgaInstantiation_WasmFpgaStore.Run;
        end if;

        if (InvocationBusy = '1') then
            CurrentInstruction := to_integer(unsigned(Instruction));
            -- Stack
            WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).Busy <= StackBusy;
            WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).HighValue <= StackHighValue_ToBeRead;
            WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).LowValue <= StackLowValue_ToBeRead;
            WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).TypeValue <= StackType_ToBeRead;
            WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).ReturnAddress <= StackReturnAddress_ToBeRead;
            StackRun <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).Run;
            StackAction <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).Action;
            StackLowValue_Written <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).LowValue;
            StackType_Written <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).TypeValue;
            StackMaxLocals <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).MaxLocals;
            StackMaxResults <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).MaxResults;
            StackReturnAddress_Written <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).ReturnAddress;
            StackModuleInstanceUid <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).ModuleInstanceUid;
            StackLocalIndex <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).LocalIndex;
            -- Memory
            WasmFpgaMemory_WasmFpgaInstruction(CurrentInstruction).Busy <= MemoryBusy;
            WasmFpgaMemory_WasmFpgaInstruction(CurrentInstruction).ReadData <= MemoryReadData;
            MemoryRun <= WasmFpgaInstruction_WasmFpgaMemory(CurrentInstruction).Run;
            MemoryAddress <= WasmFpgaInstruction_WasmFpgaMemory(CurrentInstruction).Address;
            MemoryWriteEnable <= WasmFpgaInstruction_WasmFpgaMemory(CurrentInstruction).WriteEnable;
            MemoryWriteData <= WasmFpgaInstruction_WasmFpgaMemory(CurrentInstruction).WriteData;

            -- Store
            WasmFpgaStore_WasmFpgaInstruction(CurrentInstruction).Busy <= StoreBusy;
            WasmFpgaStore_WasmFpgaInstruction(CurrentInstruction).Address <= StoreAddress(23 downto 0);
            StoreModuleInstanceUid <= WasmFpgaInstruction_WasmFpgaStore(CurrentInstruction).ModuleInstanceUid;
            StoreSectionUID <= WasmFpgaInstruction_WasmFpgaStore(CurrentInstruction).SectionUID;
            StoreIdx <= WasmFpgaInstruction_WasmFpgaStore(CurrentInstruction).Idx;
            StoreRun <= WasmFpgaInstruction_WasmFpgaStore(CurrentInstruction).Run;

            -- Module
            if (WasmFpgaInstruction_WasmFpgaInvocation(CurrentInstruction).Busy = '1') then
                -- Instruction uses access to Module RAM
                WasmFpgaModuleRam_WasmFpgaInstruction(CurrentInstruction).Busy <= ModuleRamBusy;
                WasmFpgaModuleRam_WasmFpgaInstruction(CurrentInstruction).ReadData <= ModuleRamData;
                WasmFpgaModuleRam_WasmFpgaInstruction(CurrentInstruction).Address <= ModuleRamAddress;
                ModuleRamRun <= WasmFpgaInstruction_WasmFpgaModuleRam(CurrentInstruction).Run;
                ModuleRamAddress <= WasmFpgaInstruction_WasmFpgaModuleRam(CurrentInstruction).Address;
            else
                -- Invocation process accesses Module RAM for next instruction
                WasmFpgaModuleRam_WasmFpgaInvocation.Busy <= ModuleRamBusy;
                WasmFpgaModuleRam_WasmFpgaInvocation.ReadData <= ModuleRamData;
                WasmFpgaModuleRam_WasmFpgaInvocation.Address <= ModuleRamAddress;
                ModuleRamRun <= WasmFpgaInvocation_WasmFpgaModuleRam.Run;
                ModuleRamAddress <= WasmFpgaInvocation_WasmFpgaModuleRam.Address;
            end if;
        end if;
    end if;
  end process;

    Instantiation : entity work.WasmFpgaEngineInstantiation
        port map (
            Clk => Clk,
            nRst => nRst,
            Run => InstantiationRun,
            Busy => InstantiationBusy,
            ModuleInstanceUid => ModuleInstanceUid,
            EntryPointAddress => EntryPointAddress,
            Trap => InstantiationTrap,
            FromWasmFpgaModuleRam => WasmFpgaModuleRam_WasmFpgaInstantiation,
            ToWasmFpgaModuleRam => WasmFpgaInstantiation_WasmFpgaModuleRam,
            FromWasmFpgaStore => WasmFpgaStore_WasmFpgaInstantiation,
            ToWasmFpgaStore => WasmFpgaInstantiation_WasmFpgaStore,
            FromWasmFpgaStack => WasmFpgaStack_WasmFpgaInstantiation,
            ToWasmFpgaStack => WasmFpgaInstantiation_WasmFpgaStack
        );

    Invocation : entity work.WasmFpgaEngineInvocation
        port map (
            Clk => Clk,
            nRst => nRst,
            Run => InvocationRun,
            Busy => InvocationBusy,
            Debug => Debug,
            WRegPulse_DebugControlReg => WRegPulse_DebugControlReg,
            Breakpoint0 => Breakpoint0,
            StopInMain => StopInMain,
            StepOver => StepOver,
            StepInto => StepInto,
            StepOut => StepOut,
            Continue => Continue,
            StopDebugging => StopDebugging,
            EntryPointAddress => EntryPointAddress,
            StackAddress => StackAddress,
            Instruction => Instruction,
            Trap => InvocationTrap,
            FromWasmFpgaModuleRam => WasmFpgaModuleRam_WasmFpgaInvocation,
            ToWasmFpgaModuleRam => WasmFpgaInvocation_WasmFpgaModuleRam,
            FromWasmFpgaInstruction => WasmFpgaInstruction_WasmFpgaInvocation,
            ToWasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction
        );

    EngineInterface : entity work.EngineBlk_WasmFpgaEngine
      port map (
        Clk => Clk,
        Rst => Rst,
        Adr => Adr,
        Sel => Sel,
        DatIn => DatIn,
        We => We,
        Stb => Stb,
        Cyc => Cyc,
        EngineBlk_DatOut => EngineBlk_DatOut,
        EngineBlk_Ack => EngineBlk_Ack,
        EngineBlk_Unoccupied_Ack => EngineBlk_Unoccupied_Ack,
        Run => Run,
        WRegPulse_ControlReg => WRegPulse_ControlReg,
        Trap => InvocationTrap,
        Busy => Busy,
        ModuleInstanceUid => ModuleInstanceUid
      );

    DebugInterface : entity work.EngineDebugBlk_WasmFpgaEngineDebug
      port map (
        Clk => Clk,
        Rst => Rst,
        Adr => Debug_Adr,
        Sel => Debug_Sel,
        DatIn => Debug_DatIn,
        We => Debug_We,
        Stb => Debug_Stb,
        Cyc => Debug_Cyc,
        EngineDebugBlk_DatOut => Debug_DatOut,
        EngineDebugBlk_Ack => Debug_Ack,
        EngineDebugBlk_Unoccupied_Ack => open,
        StopDebugging => StopDebugging,
        Reset => open,
        StepOver => StepOver,
        StepInto => StepInto,
        StepOut => StepOut,
        Continue => Continue,
        StopInMain => StopInMain,
        Debug => Debug,
        WRegPulse_ControlReg => WRegPulse_DebugControlReg,
        InvocationTrap => InvocationTrap,
        InstantiationTrap => InstantiationTrap,
        InstantiationRunning => InstantiationBusy,
        InvocationRunning => InvocationBusy,
        InstructionAddress => WasmFpgaInvocation_WasmFpgaModuleRam.Address,
        Instruction => Instruction,
        Error => (others => '0'),
        Breakpoint0 => Breakpoint0,
        StackAddress => StackAddress
      );

    Module : entity work.WasmFpgaModuleProxy
      port map (
        Clk => Clk,
        Rst => Rst,
        Adr => ModuleBlk_Bus.Adr,
        Sel => ModuleBlk_Bus.Sel,
        DatIn => ModuleBlk_Bus.DatIn,
        We => ModuleBlk_Bus.We,
        Stb => ModuleBlk_Bus.Stb,
        Cyc => ModuleBlk_Bus.Cyc,
        ModuleBlk_DatOut => Bus_ModuleBlk.DatOut,
        ModuleBlk_Ack => Bus_ModuleBlk.Ack,
        Run => ModuleRamRun,
        Busy => ModuleRamBusy,
        Address => ModuleRamAddress,
        Data => ModuleRamData
      );

    Memory : entity work.WasmFpgaMemoryProxy
      port map (
        Clk => Clk,
        Rst => Rst,
        Adr => MemoryBlk_Bus.Adr,
        Sel => MemoryBlk_Bus.Sel,
        DatIn => MemoryBlk_Bus.DatIn,
        We => MemoryBlk_Bus.We,
        Stb => MemoryBlk_Bus.Stb,
        Cyc => MemoryBlk_Bus.Cyc,
        MemoryBlk_DatOut => Bus_MemoryBlk.DatOut,
        MemoryBlk_Ack => Bus_MemoryBlk.Ack,
        Run => MemoryRun,
        WriteEnable => MemoryWriteEnable,
        Busy => MemoryBusy,
        Address => MemoryAddress,
        ReadData => MemoryReadData,
        WriteData => MemoryWriteData
      );

    Stack : entity work.WasmFpgaStackProxy
      port map (
        Clk => Clk,
        Rst => Rst,
        Adr => StackBlk_Bus.Adr,
        Sel => StackBlk_Bus.Sel,
        DatIn => StackBlk_Bus.DatIn,
        We => StackBlk_Bus.We,
        Stb => StackBlk_Bus.Stb,
        Cyc => StackBlk_Bus.Cyc,
        StackBlk_DatOut => Bus_StackBlk.DatOut,
        StackBlk_Ack => Bus_StackBlk.Ack,
        Run =>  StackRun,
        Busy => StackBusy,
        Action => StackAction,
        SizeValue => open,
        StackAddress => StackAddress,
        HighValue_ToBeRead => StackHighValue_ToBeRead,
        HighValue_Written => StackHighValue_Written,
        LowValue_ToBeRead => StackLowValue_ToBeRead,
        LowValue_Written => StackLowValue_Written,
        Type_ToBeRead => StackType_ToBeRead,
        Type_Written => StackType_Written,
        MaxLocals => StackMaxLocals,
        MaxResults => StackMaxResults,
        ReturnAddress_Written => StackReturnAddress_Written,
        ReturnAddress_ToBeRead => StackReturnAddress_ToBeRead,
        ModuleInstanceUid => StackModuleInstanceUid,
        LocalIndex => StackLocalIndex
      );

    Store : entity work.WasmFpgaStoreProxy
      port map (
        Clk => Clk,
        Rst => Rst,
        Adr => StoreBlk_Bus.Adr,
        Sel => StoreBlk_Bus.Sel,
        DatIn => StoreBlk_Bus.DatIn,
        We => StoreBlk_Bus.We,
        Stb => StoreBlk_Bus.Stb,
        Cyc => StoreBlk_Bus.Cyc,
        StoreBlk_DatOut => Bus_StoreBlk.DatOut,
        StoreBlk_Ack => Bus_StoreBlk.Ack,
        Operation => '0',
        Run => StoreRun,
        Busy => StoreBusy,
        ModuleInstanceUid => StoreModuleInstanceUid,
        SectionUID => StoreSectionUID,
        Idx => StoreIdx,
        Address_ToBeRead => StoreAddress,
        Address_Written => (others => '0')
      );

    Instructions : entity work.WasmFpgaEngineInstructions
      port map (
        Clk => Clk,
        nRst => nRst,
        ToWasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction,
        FromWasmFpgaInstruction => WasmFpgaInstruction_WasmFpgaInvocation,
        FromWasmFpgaStack => WasmFpgaStack_WasmFpgaInstruction,
        ToWasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack,
        FromWasmFpgaModuleRam => WasmFpgaModuleRam_WasmFpgaInstruction,
        ToWasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam,
        FromWasmFpgaMemory => WasmFpgaMemory_WasmFpgaInstruction,
        ToWasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory,
        FromWasmFpgaStore => WasmFpgaStore_WasmFpgaInstruction,
        ToWasmFpgaStore => WasmFpgaInstruction_WasmFpgaStore
      );

end;
