library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;
  use work.WasmFpgaStackWshBn_Package.all;


entity WasmFpgaEngineInvocation is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        Run : in std_logic;
        Busy : out std_logic;
        Trap : out std_logic;
        EntryPointAddress : in std_logic_vector(23 downto 0);
        StackAddress : in std_logic_vector(31 downto 0);
        Instruction : out std_logic_vector(7 downto 0);
        -- Debug Interface
        Debug : in std_logic;
        WRegPulse_DebugControlReg : in std_logic;
        Breakpoint0 : in std_logic_vector(31 downto 0);
        StopInMain : in std_logic;
        StepOver : in std_logic;
        StepInto : in std_logic;
        StepOut : in std_logic;
        Continue : in std_logic;
        StopDebugging : in std_logic;
        --
        FromWasmFpgaModuleRam : in T_FromWasmFpgaModuleRam;
        ToWasmFpgaModuleRam : out T_ToWasmFpgaModuleRam;
        FromWasmFpgaInstruction : in T_FromWasmFpgaInstruction_Array;
        ToWasmFpgaInstruction : out T_ToWasmFpgaInstruction_Array
    );
end;

architecture Behavioural of WasmFpgaEngineInvocation is

  signal State : std_logic_vector(15 downto 0);
  signal ReadFromModuleRamState : std_logic_vector(15 downto 0);
  signal IsInMain : std_logic;
  signal CurrentByte : std_logic_vector(7 downto 0);
  signal CurrentInstruction : integer range 0 to 256;
  signal InstructionAddress : std_logic_vector(23 downto 0);

    signal ToWasmFpgaModuleRamBuf : T_ToWasmFpgaModuleRam;

begin

  ToWasmFpgaModuleRam <= ToWasmFpgaModuleRamBuf;

  Instruction <= CurrentByte;

  Invocation : process (Clk, nRst) is
  begin
    if (nRst = '0') then
      Trap <= '0';
      Busy <= '1';
      IsInMain <= '1';
      CurrentInstruction <= 0;
      InstructionAddress <= (others => '0');
      CurrentByte <= (others => '0');
      ToWasmFpgaModuleRamBuf.Run <= '0';
      ToWasmFpgaModuleRamBuf.Address <= (others => '0');
      for i in ToWasmFpgaInstruction'RANGE loop
            ToWasmFpgaInstruction(i) <= (
                Run => '0',
                Address => (others => '0'),
                ModuleInstanceUid => (others => '0')
            );
      end loop;
      ReadFromModuleRamState <= StateIdle;
      State <= StateIdle;
    elsif rising_edge(Clk) then
      if (State = StateIdle) then
          Busy <= '0';
          if (Run = '1') then
            Busy <= '1';
            ToWasmFpgaModuleRamBuf.Address <= EntryPointAddress;
            InstructionAddress <= EntryPointAddress;
            State <= State0;
          end if;
      elsif(State = State0) then
        if (Debug = '1') then
            if (StopInMain = '1' and IsInMain = '1') then
                IsInMain <= '0';
                if (WRegPulse_DebugControlReg = '1' and
                    (StepOver = '1' or StepInto = '1' or StepOut = '1' or Continue = '1'))
                then
                    State <= State1;
                end if;
            elsif (StepOver = '1' and Continue = '0') then
                if (WRegPulse_DebugControlReg = '1' and
                    (StepOver = '1' or StepInto = '1' or StepOut = '1' or Continue = '1'))
                then
                    State <= State1;
                end if;
            elsif (InstructionAddress = Breakpoint0(23 downto 0)) then
                if (StopDebugging = '1') then
                   State <= StateIdle;
                elsif (WRegPulse_DebugControlReg = '1') then
                    if (StepOver = '1' or StepInto = '1' or StepOut = '1' or Continue = '1') then
                        State <= State1;
                    end if;
                end if;
            else
                State <= State1;
            end if;
        else
            State <= State1;
        end if;
      elsif(State = State1) then
        ReadFromModuleRam(ReadFromModuleRamState,
                          CurrentByte,
                          FromWasmFpgaModuleRam,
                          ToWasmFpgaModuleRamBuf);
        if (ReadFromModuleRamState = StateEnd) then
            State <= State2;
        end if;
      elsif(State = State2) then
        -- FIX ME: Assume valid instruction, for now.
        CurrentInstruction <= to_integer(unsigned(CurrentByte));
        State <= State3;
      elsif(State = State3) then
        ToWasmFpgaInstruction(CurrentInstruction).Address <= FromWasmFpgaModuleRam.Address;
        ToWasmFpgaInstruction(CurrentInstruction).Run <= '1';
        State <= State4;
      elsif(State = State4) then
        ToWasmFpgaInstruction(CurrentInstruction).Run <= '0';
        State <= State5;
      elsif(State = State5) then
        if (FromWasmFpgaInstruction(CurrentInstruction).Busy = '0') then
            ToWasmFpgaModuleRamBuf.Address <= FromWasmFpgaInstruction(CurrentInstruction).Address;
            InstructionAddress <= FromWasmFpgaInstruction(CurrentInstruction).Address;
            if (FromWasmFpgaInstruction(CurrentInstruction).Trap = '1') then
                State <= StateTrapped;
            elsif (CurrentByte = WASM_OPCODE_END and StackAddress = x"00000000") then
                State <= StateIdle;
            else
                State <= State0;
            end if;
        end if;
      --
      -- Unconditional trap
      --
      elsif (State = StateTrapped) then
        Busy <= '0';
        Trap <= '1';
      --
      -- Internal error
      --
      elsif (State = StateError) then
        State <= StateError;
      end if;
    end if;
  end process;

end;