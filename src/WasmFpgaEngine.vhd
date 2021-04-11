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
end entity;

architecture WasmFpgaEngineArchitecture of WasmFpgaEngine is

  type T_WasmFpgaStack_WasmFpgaInstruction_Array is array (127 downto 0) of T_WasmFpgaStack_WasmFpgaInstruction;
  type T_WasmFpgaInstruction_WasmFpgaStack_Array is array (127 downto 0) of T_WasmFpgaInstruction_WasmFpgaStack;

  type T_WasmFpgaModuleRam_WasmFpgaInstruction_Array is array (127 downto 0) of T_WasmFpgaModuleRam_WasmFpgaInstruction;
  type T_WasmFpgaInstruction_WasmFpgaModuleRam_Array is array (127 downto 0) of T_WasmFpgaInstruction_WasmFpgaModuleRam;

  type T_WasmFpgaMemory_WasmFpgaInstruction_Array is array (127 downto 0) of T_WasmFpgaMemory_WasmFpgaInstruction;
  type T_WasmFpgaInstruction_WasmFpgaMemory_Array is array (127 downto 0) of T_WasmFpgaInstruction_WasmFpgaMemory;

  type T_WasmFpgaInvocation_WasmFpgaInstruction_Array is array (127 downto 0) of T_WasmFpgaInvocation_WasmFpgaInstruction;
  type T_WasmFpgaInstruction_WasmFpgaInvocation_Array is array (127 downto 0) of T_WasmFpgaInstruction_WasmFpgaInvocation;

  type T_WasmFpgaStore_WasmFpgaInstruction_Array is array (127 downto 0) of T_FromWasmFpgaStore;
  type T_WasmFpgaInstruction_WasmFpgaStore_Array is array (127 downto 0) of T_ToWasmFpgaStore;

  signal Rst : std_logic;
  signal Run : std_logic;
  signal Busy : std_logic;
  signal InvocationTrap : std_logic;
  signal InstantiationTrap : std_logic;

  signal WasmFpgaStack_WasmFpgaInstruction : T_WasmFpgaStack_WasmFpgaInstruction_Array;
  signal WasmFpgaInstruction_WasmFpgaStack : T_WasmFpgaInstruction_WasmFpgaStack_Array;

  signal WasmFpgaMemory_WasmFpgaInstruction : T_WasmFpgaMemory_WasmFpgaInstruction_Array;
  signal WasmFpgaInstruction_WasmFpgaMemory : T_WasmFpgaInstruction_WasmFpgaMemory_Array;

  signal WasmFpgaModuleRam_WasmFpgaInstruction : T_WasmFpgaModuleRam_WasmFpgaInstruction_Array;
  signal WasmFpgaInstruction_WasmFpgaModuleRam : T_WasmFpgaInstruction_WasmFpgaModuleRam_Array;

  signal WasmFpgaInvocation_WasmFpgaInstruction : T_WasmFpgaInvocation_WasmFpgaInstruction_Array;
  signal WasmFpgaInstruction_WasmFpgaInvocation : T_WasmFpgaInstruction_WasmFpgaInvocation_Array;

  signal WasmFpgaStore_WasmFpgaInstruction : T_WasmFpgaStore_WasmFpgaInstruction_Array;
  signal WasmFpgaInstruction_WasmFpgaStore : T_WasmFpgaInstruction_WasmFpgaStore_Array;

  signal WasmFpgaModuleRam_WasmFpgaInstantiation : T_WasmFpgaModuleRam_WasmFpgaInstruction;
  signal WasmFpgaInstantiation_WasmFpgaModuleRam : T_WasmFpgaInstruction_WasmFpgaModuleRam;

  signal WasmFpgaModuleRam_WasmFpgaInvocation : T_WasmFpgaModuleRam_WasmFpgaInstruction;
  signal WasmFpgaInvocation_WasmFpgaModuleRam : T_WasmFpgaInstruction_WasmFpgaModuleRam;

  signal WasmFpgaInstantiation_WasmFpgaStack : T_WasmFpgaInstruction_WasmFpgaStack;
  signal WasmFpgaStack_WasmFpgaInstantiation : T_WasmFpgaStack_WasmFpgaInstruction;

  signal WasmFpgaInstantiation_WasmFpgaStore : T_ToWasmFpgaStore;
  signal WasmFpgaStore_WasmFpgaInstantiation : T_FromWasmFpgaStore;

  signal EngineBlk_Ack : std_logic;
  signal EngineBlk_DatOut : std_logic_vector(31 downto 0);
  signal EngineBlk_Unoccupied_Ack : std_logic;

  signal LocalDeclCount : std_logic_vector(31 downto 0);
  signal ModuleInstanceUid : std_logic_vector(31 downto 0);

  signal StoreModuleInstanceUid : std_logic_vector(31 downto 0);
  signal StoreSectionUID : std_logic_vector(31 downto 0);
  signal StoreIdx : std_logic_vector(31 downto 0);

  signal StoreAddress : std_logic_vector(31 downto 0);
  signal StoreRun : std_logic;
  signal StoreBusy : std_logic;

  signal StackRun : std_logic;
  signal StackAction : std_logic_vector(2 downto 0);
  signal StackBusy : std_logic;
  signal StackSizeValue : std_logic_vector(31 downto 0);
  signal StackHighValue_ToBeRead : std_logic_vector(31 downto 0);
  signal StackHighValue_Written : std_logic_vector(31 downto 0);
  signal StackLowValue_ToBeRead : std_logic_vector(31 downto 0);
  signal StackLowValue_Written : std_logic_vector(31 downto 0);
  signal StackType_ToBeRead : std_logic_vector(2 downto 0);
  signal StackType_Written : std_logic_vector(2 downto 0);
  signal StackMaxLocals : std_logic_vector(31 downto 0);
  signal StackMaxResults : std_logic_vector(31 downto 0);
  signal StackReturnAddress : std_logic_vector(31 downto 0);
  signal StackModuleInstanceUid : std_logic_vector(31 downto 0);

  signal Bus_ModuleBlk : T_WshBnUp;
  signal ModuleBlk_Bus : T_WshBnDown;

  signal Bus_StoreBlk : T_WshBnUp;
  signal StoreBlk_Bus : T_WshBnDown;

  signal Bus_StackBlk : T_WshBnUp;
  signal StackBlk_Bus : T_WshBnDown;

  signal Bus_MemoryBlk : T_WshBnUp;
  signal MemoryBlk_Bus : T_WshBnDown;

  signal InvocationState : std_logic_vector(15 downto 0);

  signal CurrentInstruction : integer range 0 to 256;

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

  signal CurrentByte : std_logic_vector(7 downto 0);
  signal DecodedValue : std_logic_vector(31 downto 0);
  signal SignBits : std_logic_vector(31 downto 0);

  signal InstantiationState : std_logic_vector(15 downto 0);
  signal PushToStackState : std_logic_vector(15 downto 0);
  signal Read32UState : std_logic_vector(15 downto 0);
  signal ReadFromModuleRamState : std_logic_vector(15 downto 0);
  signal StoreState : std_logic_vector(15 downto 0);

  signal InstantiationBusy : std_logic;

  signal WRegPulse_ControlReg : std_logic;

  signal InvocationRun : std_logic;
  signal InvocationBusy : std_logic;

  signal InvocationReadFromModuleRamState : std_logic_vector(15 downto 0);
  signal InvocationCurrentByte : std_logic_vector(7 downto 0);

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

  Instantiation : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      InstantiationTrap <= '0';
      LocalDeclCount <= (others => '0');
      DecodedValue <= (others => '0');
      SignBits <= (others => '0');
      CurrentByte <= (others => '0');
      InvocationRun <= '0';
      -- Module
      WasmFpgaInstantiation_WasmFpgaModuleRam.Run <= '0';
      WasmFpgaInstantiation_WasmFpgaModuleRam.Address <= (others => '0');
      -- Stack
      WasmFpgaInstantiation_WasmFpgaStack.TypeValue <= (others => '0');
      WasmFpgaInstantiation_WasmFpgaStack.HighValue <= (others => '0');
      WasmFpgaInstantiation_WasmFpgaStack.LowValue <= (others => '0');
      -- Store
      WasmFpgaInstantiation_WasmFpgaStore.ModuleInstanceUid <= (others => '0');
      WasmFpgaInstantiation_WasmFpgaStore.SectionUID <= (others => '0');
      WasmFpgaInstantiation_WasmFpgaStore.Idx <= (others => '0');
      WasmFpgaInstantiation_WasmFpgaStore.Run <= '0';
      -- States
      StoreState <= StateIdle;
      ReadFromModuleRamState <= StateIdle;
      Read32UState <= StateIdle;
      PushToStackState <= StateIdle;
      InstantiationState <= StateIdle;
    elsif rising_edge(Clk) then
        if (InstantiationState = StateIdle) then
            InstantiationBusy <= '0';
            InvocationRun <= '0';
            if (WRegPulse_ControlReg = '1' and Run = '1') then
                InstantiationBusy <= '1';
                InstantiationState <= State0;
            end if;
        --
        -- RetrieveStartFunctionIdx
        --
        -- Use ModuleInstanceUid = 0, SectionUid = 8 (Start) and Idx = 0 in order
        -- to retrieve the function Idx of the start function.
        --
        elsif(InstantiationState = State0) then
            WasmFpgaInstantiation_WasmFpgaStore.ModuleInstanceUid <= ModuleInstanceUid;
            WasmFpgaInstantiation_WasmFpgaStore.SectionUID <= SECTION_UID_START;
            WasmFpgaInstantiation_WasmFpgaStore.Idx <= (others => '0');
            InstantiationState <= State1;
        elsif(InstantiationState = State1) then
            ReadModuleAddressFromStore(StoreState,
                WasmFpgaInstantiation_WasmFpgaStore,
                WasmFpgaStore_WasmFpgaInstantiation);
            if (StoreState = StateEnd) then
                -- Start section size address
                WasmFpgaInstantiation_WasmFpgaModuleRam.Address <= WasmFpgaStore_WasmFpgaInstantiation.Address(23 downto 0);
                InstantiationState <= State2;
            end if;
        elsif(InstantiationState = State2) then
            -- Read section size
            ReadUnsignedLEB128(Read32UState,
                    ReadFromModuleRamState,
                    DecodedValue,
                    CurrentByte,
                    WasmFpgaModuleRam_WasmFpgaInstantiation,
                    WasmFpgaInstantiation_WasmFpgaModuleRam);
            if (Read32UState = StateEnd) then
                InstantiationState <= State4;
            end if;
        elsif(InstantiationState = State4) then
            -- Read start funx idx
            ReadUnsignedLEB128(Read32UState,
                    ReadFromModuleRamState,
                    DecodedValue,
                    CurrentByte,
                    WasmFpgaModuleRam_WasmFpgaInstantiation,
                    WasmFpgaInstantiation_WasmFpgaModuleRam);
            if (Read32UState = StateEnd) then
                InstantiationState <= State5;
            end if;
        --
        -- RetrieveStartFunctionAddress
        --
        -- Use ModuleInstanceUid = 0, SectionUid = 10 (Code) and function Idx of
        -- start function to get address of start function body.
        --
        elsif(InstantiationState = State5) then
            WasmFpgaInstantiation_WasmFpgaStore.ModuleInstanceUid <= ModuleInstanceUid;
            WasmFpgaInstantiation_WasmFpgaStore.SectionUID <= SECTION_UID_CODE;
            WasmFpgaInstantiation_WasmFpgaStore.Idx <= DecodedValue; -- Use start function idx
            InstantiationState <= State6;
        elsif(InstantiationState = State6) then
            ReadModuleAddressFromStore(StoreState,
                WasmFpgaInstantiation_WasmFpgaStore,
                WasmFpgaStore_WasmFpgaInstantiation);
            if (StoreState = StateEnd) then
                -- Start section size address
                WasmFpgaInstantiation_WasmFpgaModuleRam.Address <= WasmFpgaStore_WasmFpgaInstantiation.Address(23 downto 0);
                InstantiationState <= State8;
            end if;
        elsif(InstantiationState = State8) then
            -- Read function body size
            ReadUnsignedLEB128(Read32UState,
                    ReadFromModuleRamState,
                    DecodedValue,
                    CurrentByte,
                    WasmFpgaModuleRam_WasmFpgaInstantiation,
                    WasmFpgaInstantiation_WasmFpgaModuleRam);
            if (Read32UState = StateEnd) then
                InstantiationState <= State9;
            end if;
        --
        -- CreateInitialActivationFrame
        --
        elsif(InstantiationState = State9) then
            -- Ignore function body size
            -- Read local decl count
            ReadUnsignedLEB128(Read32UState,
                    ReadFromModuleRamState,
                    DecodedValue,
                    CurrentByte,
                    WasmFpgaModuleRam_WasmFpgaInstantiation,
                    WasmFpgaInstantiation_WasmFpgaModuleRam);
            if (Read32UState = StateEnd) then
                InstantiationState <= State10;
            end if;
        elsif(InstantiationState = State10) then
            if (DecodedValue = x"00000000") then
                WasmFpgaInstantiation_WasmFpgaStack.TypeValue <= WASMFPGASTACK_VAL_Activation;
                WasmFpgaInstantiation_WasmFpgaStack.HighValue <= (others => '0');
                WasmFpgaInstantiation_WasmFpgaStack.LowValue <= ModuleInstanceUid;
                InstantiationState <= State11;
            else
                -- The start function type must be [] -> []
                InstantiationTrap <= '1';
            end if;
        elsif (InstantiationState = State11) then
            -- Push ModuleInstanceUid
            PushToStack(PushToStackState,
                        WasmFpgaInstantiation_WasmFpgaStack,
                        WasmFpgaStack_WasmFpgaInstantiation);
            if (PushToStackState = StateEnd) then
               InstantiationState <= State12;
            end if;
        elsif (InstantiationState = State12) then
            InvocationRun <= '1';
            InstantiationState <= State13;
        elsif (InstantiationState = State13) then
            InvocationRun <= '0';
            InstantiationState <= State14;
        elsif (InstantiationState = State14) then
            if (InvocationBusy = '0') then
                InstantiationState <= StateIdle;
            end if;
        end if;
    end if;
  end process;


  Invocation : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      InvocationTrap <= '0';
      InvocationBusy <= '1';
      CurrentInstruction <= 0;
      InvocationCurrentByte <= (others => '0');
      WasmFpgaInvocation_WasmFpgaModuleRam.Run <= '0';
      WasmFpgaInvocation_WasmFpgaModuleRam.Address <= (others => '0');
      for i in WasmFpgaInvocation_WasmFpgaInstruction'RANGE loop
            WasmFpgaInvocation_WasmFpgaInstruction(i) <= (
                Run => '0',
                Address => (others => '0'),
                ModuleInstanceUid => (others => '0')
            );
      end loop;
      InvocationReadFromModuleRamState <= StateIdle;
      InvocationState <= StateIdle;
    elsif rising_edge(Clk) then
      if (InvocationState = StateIdle) then
          InvocationBusy <= '0';
          if (InvocationRun = '1') then
              InvocationBusy <= '1';
              WasmFpgaInvocation_WasmFpgaModuleRam.Address <=
                                WasmFpgaInstantiation_WasmFpgaModuleRam.Address;
              InvocationState <= State0;
          end if;
      elsif(InvocationState = State0) then
        ReadFromModuleRam(InvocationReadFromModuleRamState,
                          InvocationCurrentByte,
                          WasmFpgaModuleRam_WasmFpgaInvocation,
                          WasmFpgaInvocation_WasmFpgaModuleRam);
        if (InvocationReadFromModuleRamState = StateEnd) then
            InvocationState <= State1;
        end if;
      elsif(InvocationState = State1) then
        -- FIX ME: Assume valid instruction, for now.
        CurrentInstruction <= to_integer(unsigned(InvocationCurrentByte));
        InvocationState <= State2;
      elsif(InvocationState = State2) then
        WasmFpgaInvocation_WasmFpgaInstruction(CurrentInstruction).Address <=
                                    WasmFpgaInvocation_WasmFpgaModuleRam.Address;
        WasmFpgaInvocation_WasmFpgaInstruction(CurrentInstruction).Run <= '1';
        InvocationState <= State3;
      elsif(InvocationState = State3) then
        WasmFpgaInvocation_WasmFpgaInstruction(CurrentInstruction).Run <= '0';
        InvocationState <= State4;
      elsif(InvocationState = State4) then
        if (WasmFpgaInstruction_WasmFpgaInvocation(CurrentInstruction).Busy = '0') then
            WasmFpgaInvocation_WasmFpgaModuleRam.Address <=
                WasmFpgaInstruction_WasmFpgaInvocation(CurrentInstruction).Address;
            if (WasmFpgaInstruction_WasmFpgaInvocation(CurrentInstruction).Trap = '1') then
                InvocationState <= StateTrapped;
            elsif (InvocationCurrentByte = WASM_OPCODE_END) then
                InvocationState <= StateIdle;
            else
                InvocationState <= State0;
            end if;
        end if;
      --
      -- Unconditional trap
      --
      elsif (InvocationState = StateTrapped) then
        InvocationBusy <= '0';
        InvocationTrap <= '1';
      --
      -- Internal error
      --
      elsif (InvocationState = StateError) then
        InvocationState <= StateError;
      end if;
    end if;
  end process;

  Arbiter : process (Clk, Rst) is
  begin
    if (Rst = '1') then
        -- Stack
        StackRun <= '0';
        StackAction <= (others => '0');
        StackHighValue_Written <= (others => '0');
        StackLowValue_Written <= (others => '0');
        StackType_Written <= (others => '0');
        StackMaxLocals <= (others => '0');
        StackMaxResults <= (others => '0');
        StackReturnAddress <= (others => '0');
        StackModuleInstanceUid <= (others => '0');
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
        WasmFpgaModuleRam_WasmFpgaInstantiation.Busy <= '0';
        WasmFpgaModuleRam_WasmFpgaInstantiation.ReadData <= (others => '0');
        for i in WasmFpgaModuleRam_WasmFpgaInstruction'RANGE loop
            WasmFpgaModuleRam_WasmFpgaInstruction(i).Busy <= '1';
            WasmFpgaModuleRam_WasmFpgaInstruction(i).ReadData <= (others => '0');
        end loop;
        WasmFpgaStack_WasmFpgaInstantiation.Busy <= '0';
        WasmFpgaStack_WasmFpgaInstantiation.HighValue <= (others => '0');
        WasmFpgaStack_WasmFpgaInstantiation.LowValue <= (others => '0');
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
            StackRun <= WasmFpgaInstantiation_WasmFpgaStack.Run;
            StackAction <= WasmFpgaInstantiation_WasmFpgaStack.Action;
            StackLowValue_Written <= WasmFpgaInstantiation_WasmFpgaStack.LowValue;
            StackType_Written <= WasmFpgaInstantiation_WasmFpgaStack.TypeValue;
            StackMaxLocals <= WasmFpgaInstantiation_WasmFpgaStack.MaxLocals;
            StackMaxResults <= WasmFpgaInstantiation_WasmFpgaStack.MaxResults;
            StackReturnAddress <= WasmFpgaInstantiation_WasmFpgaStack.ReturnAddress;
            StackModuleInstanceUid <= WasmFpgaInstantiation_WasmFpgaStack.ModuleInstanceUid;

            -- Module
            WasmFpgaModuleRam_WasmFpgaInstantiation.Busy <= ModuleRamBusy;
            WasmFpgaModuleRam_WasmFpgaInstantiation.ReadData <= ModuleRamData;
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
            -- Stack
            WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).Busy <= StackBusy;
            WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).HighValue <= StackHighValue_ToBeRead;
            WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).LowValue <= StackLowValue_ToBeRead;
            WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).TypeValue <= StackType_ToBeRead;
            StackRun <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).Run;
            StackAction <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).Action;
            StackLowValue_Written <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).LowValue;
            StackType_Written <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).TypeValue;
            StackMaxLocals <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).MaxLocals;
            StackMaxResults <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).MaxResults;
            StackReturnAddress <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).ReturnAddress;
            StackModuleInstanceUid <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).ModuleInstanceUid;

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
                ModuleRamRun <= WasmFpgaInstruction_WasmFpgaModuleRam(CurrentInstruction).Run;
                ModuleRamAddress <= WasmFpgaInstruction_WasmFpgaModuleRam(CurrentInstruction).Address;
            else
                -- Invocation process accesses Module RAM for next instruction
                WasmFpgaModuleRam_WasmFpgaInvocation.Busy <= ModuleRamBusy;
                WasmFpgaModuleRam_WasmFpgaInvocation.ReadData <= ModuleRamData;
                ModuleRamRun <= WasmFpgaInvocation_WasmFpgaModuleRam.Run;
                ModuleRamAddress <= WasmFpgaInvocation_WasmFpgaModuleRam.Address;
            end if;
        end if;
    end if;
  end process;

  WasmFpgaEngine_StackBlk_i : entity work.WasmFpgaEngine_StackBlk
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
      SizeValue => StackSizeValue,
      HighValue_ToBeRead => StackHighValue_ToBeRead,
      HighValue_Written => StackHighValue_Written,
      LowValue_ToBeRead => StackLowValue_ToBeRead,
      LowValue_Written => StackLowValue_Written,
      Type_ToBeRead => StackType_ToBeRead,
      Type_Written => StackType_Written,
      MaxLocals => StackMaxLocals,
      MaxResults => StackMaxResults,
      ReturnAddress => StackReturnAddress,
      ModuleInstanceUid => StackModuleInstanceUid
    );

  EngineBlk_WasmFpgaEngine_i : entity work.EngineBlk_WasmFpgaEngine
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

    EngineBlk_WasmFpgaEngineDebug_i : entity work.EngineBlk_WasmFpgaEngineDebug
      port map (
        Clk => Clk,
        Rst => Rst,
        Adr => Debug_Adr,
        Sel => Debug_Sel,
        DatIn => Debug_DatIn,
        We => Debug_We,
        Stb => Debug_Stb,
        Cyc => Debug_Cyc,
        EngineBlk_DatOut => Debug_DatOut,
        EngineBlk_Ack => Debug_Ack,
        EngineBlk_Unoccupied_Ack => open,
        InvocationTrap => InvocationTrap,
        InstantiationTrap => InstantiationTrap,
        InstantiationRunning => InstantiationBusy,
        InvocationRunning => InvocationBusy,
        Address => WasmFpgaInvocation_WasmFpgaModuleRam.Address,
        Instruction => InvocationCurrentByte,
        Error => (others => '0')
      );

    WasmFpgaEngine_ModuleBlk_i : entity work.WasmFpgaEngine_ModuleBlk
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

    WasmFpgaEngine_MemoryBlk_i : entity work.WasmFpgaEngine_MemoryBlk
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

  WasmFpgaEngine_StoreBlk_i : entity work.WasmFpgaEngine_StoreBlk
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

    InstructionI32Ctz_i : entity work.InstructionI32Ctz
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_CTZ)))
        );

    InstructionI32Const_i : entity work.InstructionI32Const
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_CONST)))
        );

    InstructionEnd_i : entity work.InstructionEnd
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_END)))
        );

    InstructionNop_i : entity work.InstructionNop
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_NOP)))
        );

    InstructionI32And_i : entity work.InstructionI32And
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_AND)))
        );

    InstructionI32Popcnt_i : entity work.InstructionI32Popcnt
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_POPCNT)))
        );

    InstructionI32Or_i : entity work.InstructionI32Or
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_OR)))
        );

    InstructionDrop_i : entity work.InstructionDrop
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_DROP)))
        );

    InstructionI32Clz_i : entity work.InstructionI32Clz
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_CLZ)))
        );

    InstructionI32Xor_i : entity work.InstructionI32Xor
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_XOR)))
        );

    InstructionI32Rotl_i : entity work.InstructionI32Rotl
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_ROTL)))
        );

    InstructionI32Rotr_i : entity work.InstructionI32Rotr
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_ROTR)))
        );

    InstructionI32Shl_i : entity work.InstructionI32Shl
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SHL)))
        );

    InstructionI32Shrs_i : entity work.InstructionI32Shrs
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SHR_S)))
        );

    InstructionI32Shru_i : entity work.InstructionI32Shru
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SHR_U)))
        );

    InstructionUnreachable_i : entity work.InstructionUnreachable
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_UNREACHABLE)))
        );

    InstructionI32Eqz_i : entity work.InstructionI32Eqz
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_EQZ)))
        );

    InstructionI32Eq_i : entity work.InstructionI32Eq
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_EQ)))
        );

    InstructionI32Ne_i : entity work.InstructionI32Ne
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_NE)))
        );

    InstructionI32Lts_i : entity work.InstructionI32Lts
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LT_S)))
        );

    InstructionI32Ltu_i : entity work.InstructionI32Ltu
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LT_U)))
        );

    InstructionI32Ges_i : entity work.InstructionI32Ges
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GE_S)))
        );

    InstructionI32Geu_i : entity work.InstructionI32Geu
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GE_U)))
        );

    InstructionI32Gts_i : entity work.InstructionI32Gts
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GT_S)))
        );

    InstructionI32Gtu_i : entity work.InstructionI32Gtu
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GT_U)))
        );

    InstructionI32Les_i : entity work.InstructionI32Les
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LE_S)))
        );

    InstructionI32Leu_i : entity work.InstructionI32Leu
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LE_U)))
        );

    InstructionSelect_i : entity work.InstructionSelect
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_SELECT)))
        );

    InstructionI32Add_i : entity work.InstructionI32Add
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_ADD)))
        );

    InstructionI32Sub_i : entity work.InstructionI32Sub
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SUB)))
        );

    InstructionI32Mul_i : entity work.InstructionI32Mul
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_MUL)))
        );

    InstructionI32Divs_i : entity work.InstructionI32Divs
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_DIV_S)))
        );

    InstructionI32Divu_i : entity work.InstructionI32Divu
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_DIV_U)))
        );

    InstructionI32Rems_i : entity work.InstructionI32Rems
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_REM_S)))
        );

    InstructionI32Remu_i : entity work.InstructionI32Remu
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_REM_U)))
        );

    InstructionI32Store_i : entity work.InstructionI32Store
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_STORE)))
        );

    InstructionI32Load_i : entity work.InstructionI32Load
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LOAD)))
        );

    InstructionLocalGet_i : entity work.InstructionLocalGet
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_LOCAL_GET)))
        );

    InstructionLocalSet_i : entity work.InstructionLocalSet
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_LOCAL_SET)))
        );

    InstructionCall_i : entity work.InstructionCall
        port map (
            Clk => Clk,
            nRst => nRst,
            FromWasmFpgaInvocation => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaStack => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaModuleRam => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaMemory => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaStore => WasmFpgaStore_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaStore => WasmFpgaInstruction_WasmFpgaStore(to_integer(unsigned(WASM_OPCODE_CALL)))
        );

end;