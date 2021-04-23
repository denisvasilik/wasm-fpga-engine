library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;
  use work.WasmFpgaStackWshBn_Package.all;

--
-- i32.ctz
--
-- Return the count of trailing zero bits in i; all bits are considered
-- trailing zeros if i is 0.
--
entity InstructionI32Const is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        ToWasmFpgaInstruction : in T_ToWasmFpgaInstruction;
        FromWasmFpgaInstruction : out T_FromWasmFpgaInstruction;
        FromWasmFpgaStack : in T_FromWasmFpgaStack;
        ToWasmFpgaStack : out T_ToWasmFpgaStack;
        FromWasmFpgaModuleRam : in T_FromWasmFpgaModuleRam;
        ToWasmFpgaModuleRam : out T_ToWasmFpgaModuleRam;
        FromWasmFpgaMemory : in T_FromWasmFpgaMemory;
        ToWasmFpgaMemory : out T_ToWasmFpgaMemory
    );
end;

architecture Behavioural of InstructionI32Const is

    signal State : std_logic_vector(15 downto 0);
    signal ReadSignedLEB128State : std_logic_vector(15 downto 0);
    signal ReadFromModuleRamState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);

    signal CurrentByte : std_logic_vector(7 downto 0);
    signal DecodedValue : std_logic_vector(31 downto 0);
    signal SignBits : std_logic_vector(31 downto 0);

    signal ToWasmFpgaModuleRamBuffered : T_ToWasmFpgaModuleRam;

begin

    ToWasmFpgaMemory <= (
        Run => '0',
        Address => (others => '0'),
        WriteData => (others => '0'),
        WriteEnable => '0'
    );

    ToWasmFpgaModuleRam <= ToWasmFpgaModuleRamBuffered;

    process (Clk, nRst) is
    begin
        if (nRst = '0') then
          CurrentByte <= (others => '0');
          DecodedValue <= (others => '0');
          SignBits <= (others => '0');
          ToWasmFpgaStack <= (
              Run => '0',
              Action => (others => '0'),
              TypeValue => (others => '0'),
              HighValue => (others => '0'),
              LowValue => (others => '0'),
              MaxResults => (others => '0'),
              MaxLocals => (others => '0'),
              ReturnAddress => (others => '0'),
              ModuleInstanceUid => (others => '0'),
              LocalIndex => (others => '0')
          );
          ToWasmFpgaModuleRamBuffered <= (
              Run => '0',
              Address => (others => '0')
          );
          FromWasmFpgaInstruction <= (
              Address => (others => '0'),
              Trap => '0',
              Busy => '1'
          );
          ReadSignedLEB128State <= StateIdle;
          ReadFromModuleRamState <= StateIdle;
          PushToStackState <= StateIdle;
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                FromWasmFpgaInstruction.Busy <= '0';
                if (ToWasmFpgaInstruction.Run = '1') then
                    FromWasmFpgaInstruction.Busy <= '1';
                    ToWasmFpgaModuleRamBuffered.Address <= ToWasmFpgaInstruction.Address;
                    State <= State0;
                end if;
            elsif (State = State0) then
                ReadSignedLEB128(ReadSignedLEB128State,
                                 ReadFromModuleRamState,
                                 DecodedValue,
                                 CurrentByte,
                                 SignBits,
                                 FromWasmFpgaModuleRam,
                                 ToWasmFpgaModuleRamBuffered);
                if(ReadSignedLEB128State = StateEnd) then
                    State <= State1;
                    ToWasmFpgaStack.LowValue <= DecodedValue;
                end if;
            elsif (State = State1) then
                PushToStack(PushToStackState,
                            FromWasmFpgaStack,
                            ToWasmFpgaStack);
                if(PushToStackState = StateEnd) then
                    FromWasmFpgaInstruction.Address <= FromWasmFpgaModuleRam.Address;
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

end;