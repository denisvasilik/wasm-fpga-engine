library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- local.get
--
-- Execution: https://www.w3.org/TR/wasm-core-1/#exec-local-get
-- Validation: https://www.w3.org/TR/wasm-core-1/#valid-local-get
--
entity InstructionLocalGet is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        ToWasmFpgaInstruction : in T_ToWasmFpgaInstruction;
        FromWasmFpgaInstruction : out T_FromWasmFpgaInstruction;
        FromWasmFpgaStack : in T_FromWasmFpgaStack;
        ToWasmFpgaStack : out T_ToWasmFpgaStack;
        FromWasmFpgaModuleRam : in T_FromWasmFpgaModuleRam;
        ToWasmFpgaModuleRam : buffer T_ToWasmFpgaModuleRam;
        FromWasmFpgaMemory : in T_FromWasmFpgaMemory;
        ToWasmFpgaMemory : out T_ToWasmFpgaMemory
    );
end;

architecture Behavioural of InstructionLocalGet is

    signal State : std_logic_vector(15 downto 0);
    signal GetLocalFromStackState : std_logic_vector(15 downto 0);
    signal ReadUnsignedLEB128State : std_logic_vector(15 downto 0);
    signal ReadFromModuleRamState : std_logic_vector(15 downto 0);
    signal DecodedValue : std_logic_vector(31 downto 0);
    signal CurrentByte : std_logic_vector(7 downto 0);

begin

    ToWasmFpgaMemory <= (
        Run => '0',
        Address => (others => '0'),
        WriteData => (others => '0'),
        WriteEnable => '0'
    );

    FromWasmFpgaInstruction <= (
        Address => (others => '0'),
        Trap => '0',
        Busy => '1'
    );

    process (Clk, nRst) is
    begin
        if (nRst = '0') then
          DecodedValue <= (others => '0');
          CurrentByte <= (others => '0');
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
          ToWasmFpgaModuleRam <= (
              Run => '0',
              Address => (others => '0')
          );
          ReadUnsignedLEB128State <= StateIdle;
          ReadFromModuleRamState <= StateIdle;
          GetLocalFromStackState <= StateIdle;
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                ToWasmFpgaInvocation.Busy <= '0';
                if (FromWasmFpgaInvocation.Run = '1') then
                    ToWasmFpgaInvocation.Busy <= '1';
                    ToWasmFpgaModuleRam.Address <= FromWasmFpgaInvocation.Address;
                    State <= State0;
                end if;
            elsif (State = State0) then
                -- Read local idx parameter from module RAM
                ReadUnsignedLEB128(ReadUnsignedLEB128State,
                                   ReadFromModuleRamState,
                                   DecodedValue,
                                   CurrentByte,
                                   FromWasmFpgaModuleRam,
                                   ToWasmFpgaModuleRam);
                if(ReadUnsignedLEB128State = StateEnd) then
                    ToWasmFpgaStack.LocalIndex <= DecodedValue;
                    State <= State1;
                end if;
            elsif (State = State1) then
                GetLocalFromStack(GetLocalFromStackState,
                                  ToWasmFpgaStack,
                                  FromWasmFpgaStack);
                if(GetLocalFromStackState = StateEnd) then
                    ToWasmFpgaInvocation.Address <= ToWasmFpgaModuleRam.Address;
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

end;