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

  signal Rst : std_logic;
  signal Run : std_logic;
  signal Busy : std_logic;

  signal EngineBlk_Ack : std_logic;
  signal EngineBlk_DatOut : std_logic_vector(31 downto 0);
  signal EngineBlk_Unoccupied_Ack : std_logic;

  signal ReadBusState : unsigned(7 downto 0);
  signal ReadBusRun : std_logic;
  signal ReadBusBusy : std_logic;
  signal ReadBusData : std_logic_vector(31 downto 0);
  signal InstructionAddress : std_logic_vector(23 downto 0);
  signal Instruction : std_logic_vector(7 downto 0);

  constant ReadBusStateIdle0 : natural := 0;
  constant ReadBusStateReadCyc0 : natural := 1;
  constant ReadBusStateReadAck0 : natural := 2;

  signal EngineState : std_logic_vector(15 downto 0);
  signal EngineStateReturn : std_logic_vector(15 downto 0);

  constant EngineStateIdle0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"00";
  constant EngineStateExec0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"01";
  constant EngineStateDispatch0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"02";
  constant EngineStateReadRam0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"03";
  constant EngineStateReadRam1 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"04";
  constant EngineStateReadRam2 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"05";
  constant EngineStateTrap0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"06";
  constant EngineStateError0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"06";

  constant EngineStateOpcodeUnreachable0 : std_logic_vector(15 downto 0) := WASM_OPCODE_UNREACHABLE & x"00";
  constant EngineStateOpcodeNop0 : std_logic_vector(15 downto 0) := WASM_OPCODE_NOP & x"00";
  constant EngineStateI32Const0 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_CONST & x"00";

 begin

  Rst <= not nRst;

  Ack <= EngineBlk_Ack;
  DatOut <= EngineBlk_DatOut;

  Bus_We <= '0';
  Bus_DatOut <= (others => '0');

  Engine : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      Trap <= '1';
      Busy <= '1';
      ReadBusRun <= '0';
      Instruction <= (others => '0');
      InstructionAddress <= (others => '0');
      EngineStateReturn <= (others => '0');
      EngineState <= EngineStateIdle0;
    elsif rising_edge(Clk) then
      --
      -- Idle
      --
      if (EngineState = EngineStateIdle0) then
          Busy <= '0';
          if (Run = '1') then
              Busy <= '1';
              EngineState <= EngineStateExec0;
          else
              EngineState <= EngineStateIdle0;
          end if;
      --
      -- Execute
      --
      elsif(EngineState = EngineStateExec0) then
        EngineStateReturn <= EngineStateDispatch0;
        EngineState <= EngineStateReadRam0;
      elsif(EngineState = EngineStateDispatch0) then
        -- Ensure validity of instructions
        if (Instruction(15 downto 8) = x"FF") then
          EngineState <= EngineStateError0;
        else
          EngineState <= Instruction & x"00";
        end if;
      --
      -- UNREACHABLE
      --
      elsif(EngineState = EngineStateOpcodeUnreachable0) then
        EngineState <= EngineStateTrap0;
      --
      -- NOP
      --
      elsif(EngineState = EngineStateOpcodeNop0) then
        EngineState <= EngineStateIdle0;
      --
      -- i32.const
      --
      elsif(EngineState = EngineStateI32Const0) then
        -- TODO: Push value onto stack
        EngineState <= EngineStateIdle0;
      --
      -- Read from RAM
      --
      elsif (EngineState = EngineStateReadRam0) then
        ReadBusRun <= '1';
        EngineState <= EngineStateReadRam1;
      elsif (EngineState = EngineStateReadRam1) then
        EngineState <= EngineStateReadRam2;
      elsif (EngineState = EngineStateReadRam2) then
        ReadBusRun <= '0';
        if(ReadBusBusy = '0') then
            if InstructionAddress(1 downto 0) = "00" then
                Instruction <= ReadBusData(7 downto 0);
            elsif InstructionAddress(1 downto 0) = "01" then
                Instruction <= ReadBusData(15 downto 8);
            elsif InstructionAddress(1 downto 0) = "10" then
                Instruction <= ReadBusData(23 downto 16);
            else 
                Instruction <= ReadBusData(31 downto 24);
            end if;
            InstructionAddress <= std_logic_vector(unsigned(InstructionAddress) + 1);
            EngineState <= EngineStateReturn;
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
      elsif (EngineState = EngineStateError0) then
        EngineState <= EngineStateError0;
      end if;
    end if;
  end process;

  Store : process (Clk, Rst) is
  begin
    if (Rst = '1') then

    elsif rising_edge(Clk) then
      -- Push value onto stack
      -- Pop value from stack

    end if;
  end process;

  Bus_i : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      ReadBusBusy <= '0';
      ReadBusData <= (others => '0');
      Bus_Cyc <= (others => '0');
      Bus_Stb <= '0';
      Bus_Adr <= (others => '0');
      Bus_Sel <= (others => '0');
      ReadBusState <= (others => '0');
    elsif rising_edge(Clk) then
      if( ReadBusState = ReadBusStateIdle0 ) then
        ReadBusBusy <= '0';
        Bus_Cyc <= (others => '0');
        Bus_Stb <= '0';
        Bus_Adr <= (others => '0');
        Bus_Sel <= (others => '0');
        if( ReadBusRun = '1' ) then
          ReadBusBusy <= '1';
          Bus_Cyc <= "1";
          Bus_Stb <= '1';
          Bus_Adr <= "00" & InstructionAddress(23 downto 2);
          Bus_Sel <= (others => '1');
          ReadBusState <= to_unsigned(ReadBusStateReadCyc0, ReadBusState'LENGTH);
        end if;
      elsif( ReadBusState = ReadBusStateReadCyc0 ) then
        if ( Bus_Ack = '1' ) then
          ReadBusData <= Bus_DatIn;
          ReadBusState <= to_unsigned(ReadBusStateReadAck0, ReadBusState'LENGTH);
        end if;
      elsif( ReadBusState = ReadBusStateReadAck0 ) then
        Bus_Cyc <= (others => '0');
        Bus_Stb <= '0';
        ReadBusBusy <= '0';
        ReadBusState <= to_unsigned(ReadBusStateIdle0, ReadBusState'LENGTH);
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

end;
