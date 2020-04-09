library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

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

  signal Rst : std_logic;
  signal Run : std_logic;
  signal Busy : std_logic;

  signal EngineBlk_Ack : std_logic;
  signal EngineBlk_DatOut : std_logic_vector(31 downto 0);
  signal EngineBlk_Unoccupied_Ack : std_logic;

  signal ArbiterState : std_logic_vector(3 downto 0);
  signal ArbiterRun : std_logic;
  signal ArbiterBusy : std_logic;
  signal ArbiterData : std_logic_vector(31 downto 0);
  signal ArbiterAddress : std_logic_vector(23 downto 0);
  signal ReadData : std_logic_vector(7 downto 0);

  signal DecodedValue : std_logic_vector(31 downto 0);
  signal LocalDeclCount : std_logic_vector(31 downto 0);

  signal ModuleInstanceUID : std_logic_vector(31 downto 0);
  signal SectionUID : std_logic_vector(31 downto 0);
  signal Idx : std_logic_vector(31 downto 0);
  signal Address : std_logic_vector(31 downto 0);

  signal EngineState : std_logic_vector(15 downto 0);
  signal EngineStateReturnU32 : std_logic_vector(15 downto 0);
  signal EngineStateReturn : std_logic_vector(15 downto 0);

  constant EngineStateOpcodeUnreachable0 : std_logic_vector(15 downto 0) := WASM_OPCODE_UNREACHABLE & x"00";
  constant EngineStateOpcodeNop0 : std_logic_vector(15 downto 0) := WASM_OPCODE_NOP & x"00";
  constant EngineStateOpcodeEnd0 : std_logic_vector(15 downto 0) := WASM_OPCODE_END & x"00";
  constant EngineStateI32Const0 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_CONST & x"00";

  signal StoreRun : std_logic;
  signal StoreBusy : std_logic;

  signal Bus_ModuleBlk : T_WshBnUp;
  signal ModuleBlk_Bus : T_WshBnDown;

  signal Bus_StoreBlk : T_WshBnUp;
  signal StoreBlk_Bus : T_WshBnDown;

  signal Bus_StackBlk : T_WshBnUp;
  signal StackBlk_Bus : T_WshBnDown;

  constant SECTION_UID_TYPE : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"01";
  constant SECTION_UID_IMPORT : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"02";
  constant SECTION_UID_FUNCTION : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"03";
  constant SECTION_UID_TABLE : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"04";
  constant SECTION_UID_MEMORY : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"05";
  constant SECTION_UID_GLOBAL : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"06";
  constant SECTION_UID_EXPORT : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"07";
  constant SECTION_UID_START : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"08";
  constant SECTION_UID_ELEMENT : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"09";
  constant SECTION_UID_CODE : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"0A";
  constant SECTION_UID_DATA : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"0B";

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

  StackBlk_Bus.Adr <= (others => '0');
  StackBlk_Bus.DatIn <= (others => '0');
  StackBlk_Bus.Sel <= (others => '0');
  StackBlk_Bus.We <= '0';
  StackBlk_Bus.Stb <= '0';
  StackBlk_Bus.Cyc <= (others => '0');

  Bus_ModuleBlk.DatOut <= Bus_DatIn;
  Bus_ModuleBlk.Ack <= Bus_Ack;

  Bus_StackBlk.DatOut <= Bus_DatIn;
  Bus_StackBlk.Ack <= Bus_Ack;

  Bus_StoreBlk.DatOut <= Bus_DatIn;
  Bus_StoreBlk.Ack <= Bus_Ack;

  Engine : process (Clk, Rst) is
    constant EngineStateIdle : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"00";
    constant EngineStateExec0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"01";
    constant EngineStateDispatch0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"02";
    constant EngineStateReadRam0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"03";
    constant EngineStateReadRam1 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"04";
    constant EngineStateReadRam2 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"05";
    constant EngineStateStartFuncIdx0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"06";
    constant EngineStateStartFuncIdx1 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"07";
    constant EngineStateStartFuncIdx2 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"08";
    constant EngineStateStartFuncIdx3 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"09";
    constant EngineStateStartFuncIdx4 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"0A";
    constant EngineStateStartFuncIdx5 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"0B";
    constant EngineStateStartFuncIdx6 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"0C";
    constant EngineStateActivationFrame0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"10";
    constant EngineStateActivationFrame1 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"11";
    constant EngineStateActivationFrame2 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"12";
    constant EngineStateReadU32_0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"A0";
    constant EngineStateReadU32_1 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"A1";
    constant EngineStateReadU32_2 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"A2";
    constant EngineStateReadU32_3 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"A3";
    constant EngineStateReadU32_4 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"A4";
    constant EngineStateReadU32_5 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"A5";
    constant EngineStateTrap0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"FE";
    constant EngineStateError : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"FF";
  begin
    if (Rst = '1') then
      Trap <= '1';
      Busy <= '1';
      ArbiterRun <= '0';
      StoreRun <= '0';
      DecodedValue <= (others => '0');
      ReadData <= (others => '0');
      ArbiterAddress <= (others => '0');
      ModuleInstanceUID <= (others => '0');
      SectionUID <= SECTION_UID_START;
      Idx <= (others => '0');
      EngineStateReturn <= (others => '0');
      EngineState <= EngineStateIdle;
    elsif rising_edge(Clk) then
      --
      -- Idle
      --
      if (EngineState = EngineStateIdle) then
          Busy <= '0';
          if (Run = '1') then
              Busy <= '1';
              EngineState <= EngineStateStartFuncIdx0;
          else
              EngineState <= EngineStateIdle;
          end if;
      --
      -- Use ModuleInstanceUid = 0, SectionUid = 8 (Start) and Idx = 0 in order 
      -- to retrieve the function Idx of the start function.
      --
      elsif(EngineState = EngineStateStartFuncIdx0) then
        ModuleInstanceUID <= (others => '0');
        SectionUID <= SECTION_UID_START;
        Idx <= (others => '0');
        StoreRun <= '1';
        EngineState <= EngineStateStartFuncIdx1;
      elsif(EngineState = EngineStateStartFuncIdx1) then
        StoreRun <= '0';
        EngineState <= EngineStateStartFuncIdx2;
      elsif(EngineState = EngineStateStartFuncIdx2) then
        if(StoreBusy <= '0') then
            -- Start section size address
            ArbiterAddress <= Address(23 downto 0);
            EngineStateReturnU32 <= EngineStateStartFuncIdx3;
            EngineState <= EngineStateReadU32_0;
        end if;
      elsif(EngineState = EngineStateStartFuncIdx3) then
        -- Ignore section size
        EngineStateReturnU32 <= EngineStateStartFuncIdx4;
        EngineState <= EngineStateReadU32_0;
      --
      -- Use ModuleInstanceUid = 0, SectionUid = 10 (Code) and function Idx of
      -- start function to get address of start function body.
      --
      elsif(EngineState = EngineStateStartFuncIdx4) then
        ModuleInstanceUID <= (others => '0');
        SectionUID <= SECTION_UID_CODE;
        Idx <= DecodedValue; -- Use start function idx
        StoreRun <= '1';
        EngineState <= EngineStateStartFuncIdx5;
      elsif(EngineState = EngineStateStartFuncIdx5) then
        StoreRun <= '0';
        EngineState <= EngineStateStartFuncIdx6;
      elsif(EngineState = EngineStateStartFuncIdx6) then
        if(StoreBusy <= '0') then
            -- Function address within code section
            ArbiterAddress <= Address(23 downto 0);
            EngineStateReturnU32 <= EngineStateActivationFrame0;
            EngineState <= EngineStateReadU32_0;
        end if;
      --
      -- Use body declaration count of start function to establish the first 
      -- stack frame. 
      --
      -- () -> (local 0, ModuleInstanceUid)
      --
      elsif(EngineState = EngineStateActivationFrame0) then
        -- Ignore function body size
        EngineStateReturnU32 <= EngineStateActivationFrame1;
        EngineState <= EngineStateReadU32_0;
      elsif(EngineState = EngineStateActivationFrame1) then
        LocalDeclCount <= DecodedValue;
        EngineState <= EngineStateActivationFrame2;
      elsif(EngineState = EngineStateActivationFrame2) then
        EngineState <= EngineStateExec0;
      --
      -- Start executing code of start function.
      --
      elsif(EngineState = EngineStateExec0) then
        EngineStateReturn <= EngineStateDispatch0;
        EngineState <= EngineStateReadRam0;
      elsif(EngineState = EngineStateDispatch0) then
        -- FIX ME: Assume valid instruction, for now.
        EngineState <= ReadData & x"00";
      --
      -- UNREACHABLE
      --
      elsif(EngineState = EngineStateOpcodeUnreachable0) then
        EngineState <= EngineStateTrap0;
      --
      -- NOP
      --
      elsif(EngineState = EngineStateOpcodeNop0) then
        EngineState <= EngineStateExec0;
      --
      -- END
      --
      elsif(EngineState = EngineStateOpcodeEnd0) then
        EngineState <= EngineStateIdle;
      --
      -- i32.const
      --
      elsif(EngineState = EngineStateI32Const0) then
        -- TODO: Push value onto stack
        EngineState <= EngineStateIdle;
      --
      -- Read from RAM
      --
      elsif (EngineState = EngineStateReadRam0) then
        ArbiterRun <= '1';
        EngineState <= EngineStateReadRam1;
      elsif (EngineState = EngineStateReadRam1) then
        EngineState <= EngineStateReadRam2;
      elsif (EngineState = EngineStateReadRam2) then
        ArbiterRun <= '0';
        if(ArbiterBusy = '0') then
            if ArbiterAddress(1 downto 0) = "00" then
                ReadData <= ArbiterData(7 downto 0);
            elsif ArbiterAddress(1 downto 0) = "01" then
                ReadData <= ArbiterData(15 downto 8);
            elsif ArbiterAddress(1 downto 0) = "10" then
                ReadData <= ArbiterData(23 downto 16);
            else 
                ReadData <= ArbiterData(31 downto 24);
            end if;
            ArbiterAddress <= std_logic_vector(unsigned(ArbiterAddress) + 1);
            EngineState <= EngineStateReturn;
        end if;
      --
      -- Push value onto stack
      --

      --
      -- Pop value from stack
      --

      --
      -- Read address from store (ModuleInstanceUid, SectionUid, Idx) -> Address
      --

      --
      -- Read u32 (LEB128 encoded)
      --
      elsif (EngineState = EngineStateReadU32_0) then
        DecodedValue <= (others => '0');
        EngineStateReturn <= EngineStateReadU32_1;
        EngineState <= EngineStateReadRam0;
      elsif (EngineState = EngineStateReadU32_1) then
        if ((ReadData and x"80") = x"00") then
          -- 1 byte
          DecodedValue(6 downto 0) <= ReadData(6 downto 0);
          EngineState <= EngineStateReturnU32;
        else 
          EngineStateReturn <= EngineStateReadU32_2;
          EngineState <= EngineStateReadRam0;
        end if;
      elsif (EngineState = EngineStateReadU32_3) then
        if ((ReadData and x"80") = x"00") then
          -- 2 byte
          DecodedValue(13 downto 7) <= ReadData(6 downto 0);
          EngineState <= EngineStateReturnU32;
        else
          EngineStateReturn <= EngineStateReadU32_4;
          EngineState <= EngineStateReadRam0;
        end if;
      elsif (EngineState = EngineStateReadU32_4) then
        if ((ReadData and x"80") = x"00") then
          -- 3 byte
          DecodedValue(20 downto 14) <= ReadData(6 downto 0);
          EngineState <= EngineStateReturnU32;
        else
          EngineStateReturn <= EngineStateReadU32_5;
          EngineState <= EngineStateReadRam0;
        end if;
      elsif (EngineState = EngineStateReadU32_5) then
        if ((ReadData and x"80") = x"00") then
          -- 4 byte
          DecodedValue(27 downto 21) <= ReadData(6 downto 0);
          EngineState <= EngineStateReturnU32;
        else
          -- > u32 not supported
          EngineState <= EngineStateError;
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

  Stack : process (Clk, Rst) is
  begin
    if (Rst = '1') then

    elsif rising_edge(Clk) then
      -- Push value onto stack
      -- Pop value from stack

    end if;
  end process;

  ModuleBlk_Bus.DatIn <= (others => '0');
  ModuleBlk_Bus.We <= '0';

  Arbiter : process (Clk, Rst) is
    constant ArbiterStateIdle0 : std_logic_vector(3 downto 0) := x"0";
    constant ArbiterStateRead0 : std_logic_vector(3 downto 0) := x"1";
    constant ArbiterStateRead1 : std_logic_vector(3 downto 0) := x"2";
  begin
    if (Rst = '1') then
      ModuleBlk_Bus.Cyc <= (others => '0');
      ModuleBlk_Bus.Stb <= '0';
      ModuleBlk_Bus.Adr <= (others => '0');
      ModuleBlk_Bus.Sel <= (others => '0');
      ArbiterBusy <= '0';
      ArbiterData <= (others => '0');
      ArbiterState <= (others => '0');
    elsif rising_edge(Clk) then
      if( ArbiterState = ArbiterStateIdle0 ) then
        ArbiterBusy <= '0';
        ModuleBlk_Bus.Cyc <= (others => '0');
        ModuleBlk_Bus.Stb <= '0';
        ModuleBlk_Bus.Adr <= (others => '0');
        ModuleBlk_Bus.Sel <= (others => '0');
        if(ArbiterRun = '1') then
          ModuleBlk_Bus.Cyc <= "1";
          ModuleBlk_Bus.Stb <= '1';
          ModuleBlk_Bus.Adr <= "00" & ArbiterAddress(23 downto 2);
          ModuleBlk_Bus.Sel <= (others => '1');
          ArbiterBusy <= '1';
          ArbiterState <= ArbiterStateRead0;
        end if;
      elsif( ArbiterState = ArbiterStateRead0 ) then
        if ( Bus_ModuleBlk.Ack = '1' ) then
          ArbiterData <= Bus_DatIn;
          ArbiterState <= ArbiterStateRead1;
        end if;
      elsif( ArbiterState = ArbiterStateRead1 ) then
        ModuleBlk_Bus.Cyc <= (others => '0');
        ModuleBlk_Bus.Stb <= '0';
        ArbiterBusy <= '0';
        ArbiterState <= ArbiterStateIdle0;
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

end;
