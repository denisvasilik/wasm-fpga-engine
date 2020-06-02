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
end entity WasmFpgaEngine;

architecture WasmFpgaEngineArchitecture of WasmFpgaEngine is

  component EngineBlk_WasmFpgaEngine is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        Adr : in std_logic_vector(23 downto 0);
        Sel : in std_logic_vector(3 downto 0);
        DatIn : in std_logic_vector(31 downto 0);
        We : in std_logic;
        Stb : in std_logic;
        Cyc : in  std_logic_vector(0 downto 0);
        EngineBlk_DatOut : out std_logic_vector(31 downto 0);
        EngineBlk_Ack : out std_logic;
        EngineBlk_Unoccupied_Ack : out std_logic;
        Run : out std_logic;
        Busy : in std_logic
     );
  end component EngineBlk_WasmFpgaEngine;

  component WasmFpgaEngine_ModuleBlk is
    port (
      Clk : in std_logic;
      Rst : in std_logic;
      Adr : out std_logic_vector(23 downto 0);
      Sel : out std_logic_vector(3 downto 0);
      DatIn : out std_logic_vector(31 downto 0);
      We : out std_logic;
      Stb : out std_logic;
      Cyc : out  std_logic_vector(0 downto 0);
      ModuleBlk_DatOut : in std_logic_vector(31 downto 0);
      ModuleBlk_Ack : in std_logic;
      Run : in std_logic;
      Busy : out std_logic;
      Address : in std_logic_vector(23 downto 0);
      Data : out std_logic_vector(31 downto 0)
    );
  end component;

  component WasmFpgaEngine_StoreBlk is
    port (
      Clk : in std_logic;
      Rst : in std_logic;
      Adr : out std_logic_vector(23 downto 0);
      Sel : out std_logic_vector(3 downto 0);
      DatIn : out std_logic_vector(31 downto 0);
      We : out std_logic;
      Stb : out std_logic;
      Cyc : out  std_logic_vector(0 downto 0);
      StoreBlk_DatOut : in std_logic_vector(31 downto 0);
      StoreBlk_Ack : in std_logic;
      Operation : in std_logic;
      Run : in std_logic;
      Busy : out std_logic;
      ModuleInstanceUID : in std_logic_vector(31 downto 0);
      SectionUID : in std_logic_vector(31 downto 0);
      Idx : in std_logic_vector(31 downto 0);
      Address_ToBeRead : out std_logic_vector(31 downto 0);
      Address_Written : in std_logic_vector(31 downto 0)
    );
  end component;

  component WasmFpgaEngine_StackBlk is
    port (
      Clk : in std_logic;
      Rst : in std_logic;
      Adr : out std_logic_vector(23 downto 0);
      Sel : out std_logic_vector(3 downto 0);
      DatIn : out std_logic_vector(31 downto 0);
      We : out std_logic;
      Stb : out std_logic;
      Cyc : out  std_logic_vector(0 downto 0);
      StackBlk_DatOut : in std_logic_vector(31 downto 0);
      StackBlk_Ack : in std_logic;
      Run : in std_logic;
      Busy : out std_logic;
      Action : in std_logic;
      ValueType : in std_logic_vector(2 downto 0);
      SizeValue : out std_logic_vector(31 downto 0);
      HighValue_ToBeRead : out std_logic_vector(31 downto 0);
      HighValue_Written : in std_logic_vector(31 downto 0);
      LowValue_ToBeRead : out std_logic_vector(31 downto 0);
      LowValue_Written : in std_logic_vector(31 downto 0)
    );
  end component;

  component InstructionI32Ctz is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        Run : in std_logic;
        Busy : out std_logic;
        WasmFpgaInvocation_WasmFpgaInstruction : in T_WasmFpgaInvocation_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaInvocation : out T_WasmFpgaInstruction_WasmFpgaInvocation;
        WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
        WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaModuleRam : out T_WasmFpgaInstruction_WasmFpgaModuleRam
    );
  end component;

  component InstructionI32Const is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        Run : in std_logic;
        Busy : out std_logic;
        WasmFpgaInvocation_WasmFpgaInstruction : in T_WasmFpgaInvocation_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaInvocation : out T_WasmFpgaInstruction_WasmFpgaInvocation;
        WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
        WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaModuleRam : out T_WasmFpgaInstruction_WasmFpgaModuleRam
    );
  end component;

  component InstructionEnd is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        Run : in std_logic;
        Busy : out std_logic;
        WasmFpgaInvocation_WasmFpgaInstruction : in T_WasmFpgaInvocation_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaInvocation : out T_WasmFpgaInstruction_WasmFpgaInvocation;
        WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
        WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaModuleRam : out T_WasmFpgaInstruction_WasmFpgaModuleRam
    );
  end component;

  component InstructionNop is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        Run : in std_logic;
        Busy : out std_logic;
        WasmFpgaInvocation_WasmFpgaInstruction : in T_WasmFpgaInvocation_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaInvocation : out T_WasmFpgaInstruction_WasmFpgaInvocation;
        WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
        WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaModuleRam : out T_WasmFpgaInstruction_WasmFpgaModuleRam
    );
  end component;

  signal Rst : std_logic;
  signal Run : std_logic;
  signal Busy : std_logic;

  signal InstructionRun : std_logic_vector(127 downto 0);
  signal InstructionBusy : std_logic_vector(127 downto 0);

  type T_WasmFpgaStack_WasmFpgaInstruction_Array is array (127 downto 0) of T_WasmFpgaStack_WasmFpgaInstruction;
  type T_WasmFpgaInstruction_WasmFpgaStack_Array is array (127 downto 0) of T_WasmFpgaInstruction_WasmFpgaStack;

  type T_WasmFpgaModuleRam_WasmFpgaInstruction_Array is array (127 downto 0) of T_WasmFpgaModuleRam_WasmFpgaInstruction;
  type T_WasmFpgaInstruction_WasmFpgaModuleRam_Array is array (127 downto 0) of T_WasmFpgaInstruction_WasmFpgaModuleRam;

  signal WasmFpgaStack_WasmFpgaInstruction : T_WasmFpgaStack_WasmFpgaInstruction_Array;
  signal WasmFpgaInstruction_WasmFpgaStack : T_WasmFpgaInstruction_WasmFpgaStack_Array;

  signal WasmFpgaModuleRam_WasmFpgaInstruction : T_WasmFpgaModuleRam_WasmFpgaInstruction_Array;
  signal WasmFpgaInstruction_WasmFpgaModuleRam : T_WasmFpgaInstruction_WasmFpgaModuleRam_Array;

  signal WasmFpgaModuleRam_WasmFpgaInstantiation : T_WasmFpgaModuleRam_WasmFpgaInstruction;
  signal WasmFpgaInstantiation_WasmFpgaModuleRam : T_WasmFpgaInstruction_WasmFpgaModuleRam;

  signal WasmFpgaModuleRam_WasmFpgaInvocation : T_WasmFpgaModuleRam_WasmFpgaInstruction;
  signal WasmFpgaInvocation_WasmFpgaModuleRam : T_WasmFpgaInstruction_WasmFpgaModuleRam;

  signal WasmFpgaInstantiation_WasmFpgaStack : T_WasmFpgaInstruction_WasmFpgaStack;
  signal WasmFpgaStack_WasmFpgaInstantiation : T_WasmFpgaStack_WasmFpgaInstruction;

  type T_WasmFpgaInstruction_WasmFpgaInvocation_Array is array (127 downto 0) of T_WasmFpgaInstruction_WasmFpgaInvocation;

  signal WasmFpgaInvocation_WasmFpgaInstruction : T_WasmFpgaInvocation_WasmFpgaInstruction;
  signal WasmFpgaInstruction_WasmFpgaInvocation : T_WasmFpgaInstruction_WasmFpgaInvocation_Array;

  signal EngineBlk_Ack : std_logic;
  signal EngineBlk_DatOut : std_logic_vector(31 downto 0);
  signal EngineBlk_Unoccupied_Ack : std_logic;

  signal LocalDeclCount : std_logic_vector(31 downto 0);
  signal LocalDeclCountIteration : unsigned(31 downto 0);

  signal ModuleInstanceUID : std_logic_vector(31 downto 0);
  signal SectionUID : std_logic_vector(31 downto 0);
  signal Idx : std_logic_vector(31 downto 0);

  signal StoreAddress : std_logic_vector(31 downto 0);
  signal StoreRun : std_logic;
  signal StoreBusy : std_logic;

  signal StackRun : std_logic;
  signal StackAction : std_logic;
  signal StackBusy : std_logic;
  signal StackSizeValue : std_logic_vector(31 downto 0);
  signal StackValueType : std_logic_vector(2 downto 0);
  signal StackHighValue_ToBeRead : std_logic_vector(31 downto 0);
  signal StackHighValue_Written : std_logic_vector(31 downto 0);
  signal StackLowValue_ToBeRead : std_logic_vector(31 downto 0);
  signal StackLowValue_Written : std_logic_vector(31 downto 0);

  signal Bus_ModuleBlk : T_WshBnUp;
  signal ModuleBlk_Bus : T_WshBnDown;

  signal Bus_StoreBlk : T_WshBnUp;
  signal StoreBlk_Bus : T_WshBnDown;

  signal Bus_StackBlk : T_WshBnUp;
  signal StackBlk_Bus : T_WshBnDown;

  signal InvocationState : std_logic_vector(15 downto 0);

  signal CurrentInstruction : integer range 0 to 256;

  signal ModuleRamRun : std_logic;
  signal ModuleRamBusy : std_logic;
  signal ModuleRamAddress : std_logic_vector(23 downto 0);
  signal ModuleRamData : std_logic_vector(31 downto 0);

  signal CurrentByte : std_logic_vector(7 downto 0);
  signal DecodedValue : std_logic_vector(31 downto 0);

  signal InstantiationState : std_logic_vector(15 downto 0);
  signal PushToStackState : std_logic_vector(15 downto 0);
  signal Read32UState : std_logic_vector(15 downto 0);
  signal ReadFromModuleRamState : std_logic_vector(15 downto 0);

  signal InstantiationRun : std_logic;
  signal InstantiationBusy : std_logic;

  signal InvocationRun : std_logic;
  signal InvocationBusy : std_logic;

  signal InvocationReadFromModuleRamState : std_logic_vector(15 downto 0);
  signal InvocationCurrentByte : std_logic_vector(7 downto 0);

begin

  Rst <= not nRst;

  Ack <= EngineBlk_Ack;
  DatOut <= EngineBlk_DatOut;

  Bus_Adr <= ModuleBlk_Bus.Adr when ModuleBlk_Bus.Cyc = "1" else
             StackBlk_Bus.Adr when StackBlk_Bus.Cyc = "1" else
             StoreBlk_Bus.Adr when StoreBlk_Bus.Cyc = "1" else
             (others => '0');

  Bus_Sel <= ModuleBlk_Bus.Sel when ModuleBlk_Bus.Cyc = "1" else
             StackBlk_Bus.Sel when StackBlk_Bus.Cyc = "1" else
             StoreBlk_Bus.Sel when StoreBlk_Bus.Cyc = "1" else
             (others => '0');

  Bus_DatOut <= ModuleBlk_Bus.DatIn when ModuleBlk_Bus.Cyc = "1" else
                StackBlk_Bus.DatIn when StackBlk_Bus.Cyc = "1" else
                StoreBlk_Bus.DatIn when StoreBlk_Bus.Cyc = "1" else
                (others => '0');

  Bus_We <= ModuleBlk_Bus.We when ModuleBlk_Bus.Cyc = "1" else
            StackBlk_Bus.We when StackBlk_Bus.Cyc = "1" else
            StoreBlk_Bus.We when StoreBlk_Bus.Cyc = "1" else
            '0';

  Bus_Stb <= ModuleBlk_Bus.Stb when ModuleBlk_Bus.Cyc = "1" else
             StackBlk_Bus.Stb when StackBlk_Bus.Cyc = "1" else
             StoreBlk_Bus.Stb when StoreBlk_Bus.Cyc = "1" else
             '0';

  Bus_Cyc <= ModuleBlk_Bus.Cyc when ModuleBlk_Bus.Cyc = "1" else
             StackBlk_Bus.Cyc when StackBlk_Bus.Cyc = "1" else
             StoreBlk_Bus.Cyc when StoreBlk_Bus.Cyc = "1" else
             "0";

  Bus_ModuleBlk.DatOut <= Bus_DatIn;
  Bus_ModuleBlk.Ack <= Bus_Ack;

  Bus_StackBlk.DatOut <= Bus_DatIn;
  Bus_StackBlk.Ack <= Bus_Ack;

  Bus_StoreBlk.DatOut <= Bus_DatIn;
  Bus_StoreBlk.Ack <= Bus_Ack;

  InstantiationRun <= Run;

  Instantiation : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      LocalDeclCount <= (others => '0');
      LocalDeclCountIteration <= (others => '0');
      ModuleInstanceUID <= (others => '0');
      SectionUID <= SECTION_UID_START;
      Idx <= (others => '0');
      DecodedValue <= (others => '0');
      CurrentByte <= (others => '0');
      InvocationRun <= '0';
      WasmFpgaInstantiation_WasmFpgaModuleRam.Run <= '0';
      WasmFpgaInstantiation_WasmFpgaModuleRam.Address <= (others => '0');
      ReadFromModuleRamState <= StateIdle;
      Read32UState <= StateIdle;
      PushToStackState <= StateIdle;
      InstantiationState <= StateIdle;
    elsif rising_edge(Clk) then
        if (InstantiationState = StateIdle) then
            InstantiationBusy <= '0';
            InvocationRun <= '0';
            if (InstantiationRun = '1') then
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
            ModuleInstanceUID <= (others => '0');
            SectionUID <= SECTION_UID_START;
            Idx <= (others => '0');
            StoreRun <= '1';
            InstantiationState <= State1;
        elsif(InstantiationState = State1) then
            StoreRun <= '0';
            InstantiationState <= State2;
        elsif(InstantiationState = State2) then
            if(StoreBusy <= '0') then
                -- Start section size address
                WasmFpgaInstantiation_WasmFpgaModuleRam.Address <= StoreAddress(23 downto 0);
                InstantiationState <= State3;
            end if;
        elsif(InstantiationState = State3) then
            -- Read section size
            ReadU32(Read32UState,
                    ReadFromModuleRamState,
                    DecodedValue,
                    CurrentByte,
                    WasmFpgaModuleRam_WasmFpgaInstantiation,
                    WasmFpgaInstantiation_WasmFpgaModuleRam);
            if (Read32UState = StateEnd) then
                InstantiationState <= State4;
            end if;
        elsif(InstantiationState = State4) then
            -- Ignore section size
            -- Read start funx idx
            ReadU32(Read32UState,
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
            ModuleInstanceUID <= (others => '0');
            SectionUID <= SECTION_UID_CODE;
            Idx <= DecodedValue; -- Use start function idx
            StoreRun <= '1';
            InstantiationState <= State6;
        elsif(InstantiationState = State6) then
            StoreRun <= '0';
            InstantiationState <= State7;
        elsif(InstantiationState = State7) then
            if(StoreBusy <= '0') then
                -- Function address within code section
                WasmFpgaInstantiation_WasmFpgaModuleRam.Address <= StoreAddress(23 downto 0);
                InstantiationState <= State8;
            end if;
        elsif(InstantiationState = State8) then
            -- Read function body size
            ReadU32(Read32UState,
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
            ReadU32(Read32UState,
                    ReadFromModuleRamState,
                    DecodedValue,
                    CurrentByte,
                    WasmFpgaModuleRam_WasmFpgaInstantiation,
                    WasmFpgaInstantiation_WasmFpgaModuleRam);
            if (Read32UState = StateEnd) then
                InstantiationState <= State10;
            end if;
        elsif(InstantiationState = State10) then
            LocalDeclCount <= DecodedValue;
            LocalDeclCountIteration <= (others => '0');
            InstantiationState <= State11;
        elsif(InstantiationState = State11) then
            if (LocalDeclCountIteration = unsigned(LocalDeclCount)) then
                WasmFpgaInstantiation_WasmFpgaStack.ValueType <= WASMFPGASTACK_VAL_Activation;
                WasmFpgaInstantiation_WasmFpgaStack.HighValue <= (others => '0');
                WasmFpgaInstantiation_WasmFpgaStack.LowValue <= ModuleInstanceUID;
                InstantiationState <= State12;
            else
                -- Reserve stack space for local variable
                --
                -- FIX ME: Where to get type information for local decl count?
                WasmFpgaInstantiation_WasmFpgaStack.ValueType <= WASMFPGASTACK_VAL_i32;
                WasmFpgaInstantiation_WasmFpgaStack.HighValue <= (others => '0');
                WasmFpgaInstantiation_WasmFpgaStack.LowValue <= (others => '0');
                LocalDeclCountIteration <= LocalDeclCountIteration + 1;
                InstantiationState <= State13;
            end if;
        elsif (InstantiationState = State13) then
            PushToStack(PushToStackState,
                        WasmFpgaInstantiation_WasmFpgaStack,
                        WasmFpgaStack_WasmFpgaInstantiation);
            if (PushToStackState = StateEnd) then
               InstantiationState <= State11;
            end if;
        elsif (InstantiationState = State12) then
            -- Push ModuleInstanceUid
            PushToStack(PushToStackState,
                        WasmFpgaInstantiation_WasmFpgaStack,
                        WasmFpgaStack_WasmFpgaInstantiation);
            if (PushToStackState = StateEnd) then
               InstantiationState <= State14;
            end if;
        elsif (InstantiationState = State14) then
            InvocationRun <= '1';
            InstantiationState <= StateIdle;
        end if;
    end if;
  end process;

  Busy <= InvocationBusy or InstantiationBusy;

  Invocation : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      Trap <= '1';
      InstructionRun <= (others => '0');
      CurrentInstruction <= 0;
      WasmFpgaInvocation_WasmFpgaModuleRam.Run <= '0';
      WasmFpgaInvocation_WasmFpgaModuleRam.Address <= (others => '0');
      WasmFpgaInvocation_WasmFpgaInstruction.Address <= (others => '0');
      InvocationReadFromModuleRamState <= StateIdle;
      InvocationCurrentByte <= (others => '0');
      InvocationBusy <= '1';
      InvocationState <= StateIdle;
    elsif rising_edge(Clk) then
      if (InvocationState = StateIdle) then
          InvocationBusy <= '0';
          if (InvocationRun = '1') then
              InvocationBusy <= '1';
              WasmFpgaInvocation_WasmFpgaModuleRam.Address <= std_logic_vector(unsigned(WasmFpgaInstantiation_WasmFpgaModuleRam.Address));
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
        WasmFpgaInvocation_WasmFpgaInstruction.Address <= std_logic_vector(unsigned(WasmFpgaInvocation_WasmFpgaModuleRam.Address));
        InvocationState <= State2;
      elsif(InvocationState = State2) then
        InstructionRun(CurrentInstruction) <= '1';
        InvocationState <= State3;
      elsif(InvocationState = State3) then
        InstructionRun(CurrentInstruction) <= '0';
        InvocationState <= State4;
      elsif(InvocationState = State4) then
        if (InstructionBusy(CurrentInstruction) = '0') then
            WasmFpgaInvocation_WasmFpgaModuleRam.Address <= WasmFpgaInstruction_WasmFpgaInvocation(CurrentInstruction).Address;
            if (InvocationCurrentByte = x"0B") then
                InvocationState <= StateIdle;
            else
                InvocationState <= State0;
            end if;
        end if;
      --
      -- Unconditional trap
      --
      elsif (InvocationState = StateTrapped) then
        Trap <= '1';
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
        StackRun <= '0';
        StackAction <= '0';
        StackBusy <= '0';
        StackValueType <= (others => '0');
        StackHighValue_Written <= (others => '0');
        StackLowValue_Written <= (others => '0');
        for i in WasmFpgaStack_WasmFpgaInstruction'RANGE loop
            WasmFpgaStack_WasmFpgaInstruction(i).Busy <= '1';
            WasmFpgaStack_WasmFpgaInstruction(i).HighValue <= (others => '0');
            WasmFpgaStack_WasmFpgaInstruction(i).LowValue <= (others => '0');
        end loop;
        WasmFpgaModuleRam_WasmFpgaInstantiation.Busy <= '0';
        WasmFpgaModuleRam_WasmFpgaInstantiation.Data <= (others => '0');
    elsif rising_edge(Clk) then
        if (InstantiationBusy = '1') then
            -- Stack
            WasmFpgaStack_WasmFpgaInstantiation.Busy <= StackBusy;
            WasmFpgaStack_WasmFpgaInstantiation.HighValue <= StackHighValue_ToBeRead;
            WasmFpgaStack_WasmFpgaInstantiation.LowValue <= StackLowValue_ToBeRead;
            StackRun <= WasmFpgaInstantiation_WasmFpgaStack.Run;
            StackAction <= WasmFpgaInstantiation_WasmFpgaStack.Action;
            StackValueType <= WasmFpgaInstantiation_WasmFpgaStack.ValueType;
            StackLowValue_Written <= WasmFpgaInstantiation_WasmFpgaStack.LowValue;

            -- Module RAM
            WasmFpgaModuleRam_WasmFpgaInstantiation.Busy <= ModuleRamBusy;
            WasmFpgaModuleRam_WasmFpgaInstantiation.Data <= ModuleRamData;
            ModuleRamRun <= WasmFpgaInstantiation_WasmFpgaModuleRam.Run;
            ModuleRamAddress <= WasmFpgaInstantiation_WasmFpgaModuleRam.Address;
        end if;

        if (InvocationBusy = '1') then
            -- Stack
            for i in WasmFpgaStack_WasmFpgaInstruction'RANGE loop
                WasmFpgaStack_WasmFpgaInstruction(i).Busy <= StackBusy;
            end loop;
            WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).HighValue <= StackHighValue_ToBeRead;
            WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).LowValue <= StackLowValue_ToBeRead;
            StackRun <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).Run;
            StackAction <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).Action;
            StackValueType <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).ValueType;
            StackLowValue_Written <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).LowValue;

            if (InstructionBusy(CurrentInstruction) = '1') then
                -- Module RAM
                WasmFpgaModuleRam_WasmFpgaInstruction(CurrentInstruction).Busy <= ModuleRamBusy;
                WasmFpgaModuleRam_WasmFpgaInstruction(CurrentInstruction).Data <= ModuleRamData;
                ModuleRamRun <= WasmFpgaInstruction_WasmFpgaModuleRam(CurrentInstruction).Run;
                ModuleRamAddress <= WasmFpgaInstruction_WasmFpgaModuleRam(CurrentInstruction).Address;
            else
                -- Module RAM
                WasmFpgaModuleRam_WasmFpgaInvocation.Busy <= ModuleRamBusy;
                WasmFpgaModuleRam_WasmFpgaInvocation.Data <= ModuleRamData;
                ModuleRamRun <= WasmFpgaInvocation_WasmFpgaModuleRam.Run;
                ModuleRamAddress <= WasmFpgaInvocation_WasmFpgaModuleRam.Address;
            end if;
        end if;
    end if;
  end process;

  WasmFpgaEngine_StackBlk_i : WasmFpgaEngine_StackBlk
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
      ValueType => StackValueType,
      SizeValue => StackSizeValue,
      HighValue_ToBeRead => StackHighValue_ToBeRead,
      HighValue_Written => StackHighValue_Written,
      LowValue_ToBeRead => StackLowValue_ToBeRead,
      LowValue_Written => StackLowValue_Written
    );

  EngineBlk_WasmFpgaEngine_i : EngineBlk_WasmFpgaEngine
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
      Busy => Busy
    );

    WasmFpgaEngine_ModuleBlk_i : WasmFpgaEngine_ModuleBlk
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

  WasmFpgaEngine_StoreBlk_i : WasmFpgaEngine_StoreBlk
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
      ModuleInstanceUID => ModuleInstanceUID,
      SectionUID => SectionUID,
      Idx => Idx,
      Address_ToBeRead => StoreAddress,
      Address_Written => (others => '0')
    );

  InstructionI32Ctz_i : InstructionI32Ctz
    port map (
      Clk => Clk,
      nRst => nRst,
      Run => InstructionRun(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
      Busy => InstructionBusy(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
      WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction,
      WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
      WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
      WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
      WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
      WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CTZ)))
    );

  InstructionI32Const_i : InstructionI32Const
    port map (
      Clk => Clk,
      nRst => nRst,
      Run => InstructionRun(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
      Busy => InstructionBusy(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
      WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction,
      WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
      WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
      WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
      WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
      WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CONST)))
    );

    InstructionEnd_i : InstructionEnd
        port map (
            Clk => Clk,
            nRst => nRst,
            Run => InstructionRun(to_integer(unsigned(WASM_OPCODE_END))),
            Busy => InstructionBusy(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction,
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_END)))
        );

    InstructionNop_i : InstructionNop
        port map (
            Clk => Clk,
            nRst => nRst,
            Run => InstructionRun(to_integer(unsigned(WASM_OPCODE_NOP))),
            Busy => InstructionBusy(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction,
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_NOP)))
        );

end;
