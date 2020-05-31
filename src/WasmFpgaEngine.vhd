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
      WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction;
      WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack
    );
  end component;

  component InstructionI32Const is
      port (
          Clk : in std_logic;
          nRst : in std_logic;
          Run : in std_logic;
          Busy : out std_logic;
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

  signal EngineBlk_Ack : std_logic;
  signal EngineBlk_DatOut : std_logic_vector(31 downto 0);
  signal EngineBlk_Unoccupied_Ack : std_logic;

  signal LocalDeclCount : std_logic_vector(31 downto 0);
  signal LocalDeclCountIteration : unsigned(31 downto 0);

  signal ModuleInstanceUID : std_logic_vector(31 downto 0);
  signal SectionUID : std_logic_vector(31 downto 0);
  signal Idx : std_logic_vector(31 downto 0);
  signal Address : std_logic_vector(31 downto 0);

  signal StoreRun : std_logic;
  signal StoreBusy : std_logic;

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

  signal Stack : T_WasmFpgaStack;

  signal EngineState : std_logic_vector(15 downto 0);

  signal CurrentInstruction : integer range 0 to 256;

  signal ModuleRamRun : std_logic;
  signal ModuleRamBusy : std_logic;
  signal ModuleRamAddress : std_logic_vector(23 downto 0);
  signal ModuleRamData : std_logic_vector(31 downto 0);

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

  EngineProcess : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      Trap <= '1';
      Busy <= '1';
      StoreRun <= '0';
      LocalDeclCount <= (others => '0');
      LocalDeclCountIteration <= (others => '0');
      ModuleInstanceUID <= (others => '0');
      SectionUID <= SECTION_UID_START;
      Idx <= (others => '0');
      InstructionRun <= (others => '0');
      CurrentInstruction <= 0;
      EngineState <= EngineStateIdle;
    elsif rising_edge(Clk) then
      if (EngineState = EngineStateIdle) then
          Busy <= '0';
          if (Run = '1') then
              Busy <= '1';
              EngineState <= EngineStateExec0;
          end if;
      --
      -- Start executing code of start function.
      --
      elsif(EngineState = EngineStateExec0) then
        -- FIX ME: Assume valid instruction, for now.
        -- CurrentInstruction <= to_integer(WasmFpgaInstruction_WasmFpgaModuleRam.CurrentByte);
        EngineState <= EngineStateExec1;
      elsif(EngineState = EngineStateExec1) then
        InstructionRun(CurrentInstruction) <= '1';
        EngineState <= EngineStateExec2;
      elsif(EngineState = EngineStateExec2) then
        InstructionRun(CurrentInstruction) <= '0';
        EngineState <= EngineStateExec3;
      elsif(EngineState = EngineStateExec3) then
        if (InstructionBusy(CurrentInstruction) = '0') then
            EngineState <= EngineStateExec0;
        end if;
      --
      -- Unconditional trap
      --
      elsif (EngineState = EngineStateTrap0) then
        Trap <= '1';
        EngineState <= EngineStateTrap0;
      --
      -- Internal error
      --
      elsif (EngineState = EngineStateError) then
        EngineState <= EngineStateError;
      end if;
    end if;
  end process;

  Arbiter : process (Clk, Rst) is
  begin
    if (Rst = '1') then
        Stack.Run <= '0';
        Stack.Action <= '0';
        Stack.Busy <= '0';
        StackValueType <= (others => '0');
        StackHighValue_Written <= (others => '0');
        StackLowValue_Written <= (others => '0');
        for i in WasmFpgaStack_WasmFpgaInstruction'RANGE loop
            WasmFpgaStack_WasmFpgaInstruction(i).Busy <= '1';
            WasmFpgaStack_WasmFpgaInstruction(i).HighValue <= (others => '0');
            WasmFpgaStack_WasmFpgaInstruction(i).LowValue <= (others => '0');
        end loop;
    elsif rising_edge(Clk) then
        for i in WasmFpgaStack_WasmFpgaInstruction'RANGE loop
            WasmFpgaStack_WasmFpgaInstruction(i).Busy <= Stack.Busy;
        end loop;
        WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).HighValue <= StackHighValue_ToBeRead;
        WasmFpgaStack_WasmFpgaInstruction(CurrentInstruction).LowValue <= StackLowValue_ToBeRead;
        Stack.Run <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).Run;
        Stack.Action <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).Action;
        StackValueType <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).ValueType;
        StackLowValue_Written <= WasmFpgaInstruction_WasmFpgaStack(CurrentInstruction).LowValue;

        WasmFpgaModuleRam_WasmFpgaInstruction(CurrentInstruction).Busy <= ModuleRamBusy;
        WasmFpgaModuleRam_WasmFpgaInstruction(CurrentInstruction).Data <= ModuleRamData;

        ModuleRamRun <= WasmFpgaInstruction_WasmFpgaModuleRam(CurrentInstruction).Run;
        ModuleRamAddress <= WasmFpgaInstruction_WasmFpgaModuleRam(CurrentInstruction).Address;
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
      Run =>  Stack.Run,
      Busy => StackBusy,
      Action => Stack.Action,
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
      Address_ToBeRead => Address,
      Address_Written => (others => '0')
    );

  InstructionI32Ctz_i : InstructionI32Ctz
    port map (
      Clk => Clk,
      nRst => nRst,
      Run => InstructionRun(0),
      Busy => InstructionBusy(0),
      WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(0),
      WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(0)
    );

  InstructionI32Const_i : InstructionI32Const
    port map (
      Clk => Clk,
      nRst => nRst,
      Run => InstructionRun(1),
      Busy => InstructionBusy(1),
      WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(1),
      WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(1),
      WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(1),
      WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(1)
    );

end;
