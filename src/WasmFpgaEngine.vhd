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

  signal Rst : std_logic;
  signal Run : std_logic;
  signal Busy : std_logic;

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
  signal ModuleRamBusy : std_logic;

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

  signal ModuleRamData : std_logic_vector(31 downto 0);

  signal Engine : T_WasmFpgaEngine;
  signal Stack : T_WasmFpgaStack;
  signal ModuleRam : T_WasmFpgaModuleRam;

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
      Engine.State <= (others => '0');
      Engine.ReturnState <= (others => '0');
      Engine.PushToStackState <= (others => '0');
      Engine.PopFromStackState <= (others => '0');
      Engine.ReadU32State <= (others => '0');
      Engine.ReadFromModuleRamState <= (others => '0');
      ModuleRam.Run <= '0';
      ModuleRam.CurrentByte <= (others => '0');
      ModuleRam.Data <= (others => '0');
      ModuleRam.Address <= (others => '0');
      ModuleRam.DecodedValue <= (others => '0');
      StoreRun <= '0';
      LocalDeclCount <= (others => '0');
      LocalDeclCountIteration <= (others => '0');
      ModuleInstanceUID <= (others => '0');
      SectionUID <= SECTION_UID_START;
      Idx <= (others => '0');
      StackValueType <= (others => '0');
      StackHighValue_Written <= (others => '0');
      StackLowValue_Written <= (others => '0');
      Stack.Run <= '0';
      Stack.Action <= '0';
      Stack.Busy <= '0';
      Engine.ReturnState <= (others => '0');
      Engine.State <= EngineStateIdle;
    elsif rising_edge(Clk) then
      Stack.Busy <= StackBusy;
      ModuleRam.Busy <= ModuleRamBusy;
      ModuleRam.Data <= ModuleRamData;
      --
      -- Idle
      --
      if (Engine.State = EngineStateIdle) then
          Busy <= '0';
          if (Run = '1') then
              Busy <= '1';
              Engine.State <= EngineStateStartFuncIdx0;
          end if;
      --
      -- Use ModuleInstanceUid = 0, SectionUid = 8 (Start) and Idx = 0 in order
      -- to retrieve the function Idx of the start function.
      --
      elsif(Engine.State = EngineStateStartFuncIdx0) then
        ModuleInstanceUID <= (others => '0');
        SectionUID <= SECTION_UID_START;
        Idx <= (others => '0');
        StoreRun <= '1';
        Engine.State <= EngineStateStartFuncIdx1;
      elsif(Engine.State = EngineStateStartFuncIdx1) then
        StoreRun <= '0';
        Engine.State <= EngineStateStartFuncIdx2;
      elsif(Engine.State = EngineStateStartFuncIdx2) then
        if(StoreBusy <= '0') then
            -- Start section size address
            ModuleRam.Address <= Address(23 downto 0);
            Engine.State <= EngineStateStartFuncIdx3;
        end if;
      elsif(Engine.State = EngineStateStartFuncIdx3) then
        -- Read section size
        ReadU32(Engine.State, EngineStateStartFuncIdx4, Engine, ModuleRam);
      elsif(Engine.State = EngineStateStartFuncIdx4) then
        -- Ignore section size
        -- Read start funx idx
        ReadU32(Engine.State, EngineStateStartFuncIdx5, Engine, ModuleRam);
      --
      -- Use ModuleInstanceUid = 0, SectionUid = 10 (Code) and function Idx of
      -- start function to get address of start function body.
      --
      elsif(Engine.State = EngineStateStartFuncIdx5) then
        ModuleInstanceUID <= (others => '0');
        SectionUID <= SECTION_UID_CODE;
        Idx <= ModuleRam.DecodedValue; -- Use start function idx
        StoreRun <= '1';
        Engine.State <= EngineStateStartFuncIdx6;
      elsif(Engine.State = EngineStateStartFuncIdx6) then
        StoreRun <= '0';
        Engine.State <= EngineStateStartFuncIdx7;
      elsif(Engine.State = EngineStateStartFuncIdx7) then
        if(StoreBusy <= '0') then
            -- Function address within code section
            ModuleRam.Address <= Address(23 downto 0);
            Engine.State <= EngineStateStartFuncIdx8;
        end if;
      elsif(Engine.State = EngineStateStartFuncIdx8) then
        ReadU32(Engine.State, EngineStateActivationFrame0, Engine, ModuleRam);
      --
      -- Create initial activation frame
      --
      elsif(Engine.State = EngineStateActivationFrame0) then
        -- Ignore function body size
        ReadU32(Engine.State, EngineStateActivationFrame1, Engine, ModuleRam);
      elsif(Engine.State = EngineStateActivationFrame1) then
        LocalDeclCount <= ModuleRam.DecodedValue;
        LocalDeclCountIteration <= (others => '0');
        Engine.State <= EngineStateActivationFrame2;
      elsif(Engine.State = EngineStateActivationFrame2) then
        if (LocalDeclCountIteration = unsigned(LocalDeclCount)) then
          Engine.State <= EngineStateActivationFrame3;
        else
          -- Reserve stack space for local variable
          --
          -- FIX ME: Where to get type information for local decl count?
          StackValueType <= WASMFPGASTACK_VAL_i32;
          StackHighValue_Written <= (others => '0');
          StackLowValue_Written <= (others => '0');
          LocalDeclCountIteration <= LocalDeclCountIteration + 1;
          PushToStack(Engine.State, EngineStateActivationFrame2, Engine, Stack);
        end if;
      elsif(Engine.State = EngineStateActivationFrame3) then
        -- Push ModuleInstanceUid
        StackValueType <= WASMFPGASTACK_VAL_Activation;
        StackHighValue_Written <= (others => '0');
        -- StackLowValue_Written <= ModuleInstanceUID;
        StackLowValue_Written <= (others => '0');
        PushToStack(Engine.State, EngineStateExec0, Engine, Stack);
      --
      -- Start executing code of start function.
      --
      elsif(Engine.State = EngineStateExec0) then
        ReadFromModuleRam(Engine.State, EngineStateDispatch0, Engine, ModuleRam);
      elsif(Engine.State = EngineStateDispatch0) then
        -- FIX ME: Assume valid instruction, for now.
        Engine.State <= ModuleRam.CurrentByte & x"00";
      --
      -- unreachable
      --
      elsif(Engine.State = EngineStateOpcodeUnreachable0) then
        Engine.State <= EngineStateTrap0;
      --
      -- nop
      --
      elsif(Engine.State = EngineStateOpcodeNop0) then
        Engine.State <= EngineStateExec0;
      --
      -- end
      --
      elsif(Engine.State = EngineStateOpcodeEnd0) then
        Engine.State <= EngineStateIdle;
      --
      -- drop
      --
      elsif(Engine.State = EngineStateDrop0) then
        PopFromStack(Engine.State, EngineStateExec0, Engine, Stack);
      --
      -- i32.const
      --
      elsif(Engine.State = EngineStateI32Const0) then
        ReadU32(Engine.State, EngineStateI32Const1, Engine, ModuleRam);
      elsif(Engine.State = EngineStateI32Const1) then
        StackLowValue_Written <= ModuleRam.DecodedValue;
        StackValueType <= WASMFPGASTACK_VAL_i32;
        Engine.State <= EngineStateI32Const2;
      elsif(Engine.State = EngineStateI32Const2) then
        PushToStack(Engine.State, EngineStateExec0, Engine, Stack);
      --
      -- i32.ctz
      --
      -- Return the count of trailing zero bits in i; all bits are considered
      -- trailing zeros if i is 0.
      --
      elsif(Engine.State = EngineStateI32Ctz0) then
        PopFromStack(Engine.State, EngineStateI32Ctz1, Engine, Stack);
      elsif(Engine.State = EngineStateI32Ctz1) then
        StackLowValue_Written <= ctz(StackLowValue_ToBeRead);
        Engine.State <= EngineStateI32Ctz2;
      elsif(Engine.State = EngineStateI32Ctz2) then
        PushToStack(Engine.State, EngineStateExec0, Engine, Stack);
      --
      -- i32.clz
      --
      -- Return the count of leading zero bits in i; all bits are considered
      -- leading zeros if i is 0.
      --
      elsif(Engine.State = EngineStateI32Clz0) then
        PopFromStack(Engine.State, EngineStateI32Clz1, Engine, Stack);
      elsif(Engine.State = EngineStateI32Clz1) then
        StackLowValue_Written <= clz(StackLowValue_ToBeRead);
        Engine.State <= EngineStateI32Clz2;
      elsif(Engine.State = EngineStateI32Clz2) then
        PushToStack(Engine.State, EngineStateExec0, Engine, Stack);
      --
      -- i32.popcnt
      --
      -- Return the count of non-zero bits in i.
      --
      elsif(Engine.State = EngineStateI32Popcnt0) then
        PopFromStack(Engine.State, EngineStateI32Popcnt1, Engine, Stack);
      elsif(Engine.State = EngineStateI32Popcnt1) then
        StackLowValue_Written <= popcnt(StackLowValue_ToBeRead);
        Engine.State <= EngineStateI32Popcnt2;
      elsif(Engine.State = EngineStateI32Popcnt2) then
        PushToStack(Engine.State, EngineStateExec0, Engine, Stack);
      --
      -- Read address from Store (ModuleInstanceUid, SectionUid, Idx) -> Address
      --

      --
      -- Unconditional trap
      --
      elsif (Engine.State = EngineStateTrap0) then
        Trap <= '1';
        Engine.State <= EngineStateTrap0;
      --
      -- Internal error
      --
      elsif (Engine.State = EngineStateError) then
        Engine.State <= EngineStateError;
      end if;
    end if;
  end process;

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
        Run => ModuleRam.Run,
        Busy => ModuleRamBusy,
        Address => ModuleRam.Address,
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

end;
