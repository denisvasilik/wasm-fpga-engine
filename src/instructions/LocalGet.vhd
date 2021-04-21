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
        FromWasmFpgaInvocation : in T_WasmFpgaInvocation_WasmFpgaInstruction;
        ToWasmFpgaInvocation : out T_WasmFpgaInstruction_WasmFpgaInvocation;
        FromWasmFpgaStack : in T_WasmFpgaStack_WasmFpgaInstruction;
        ToWasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
        FromWasmFpgaModuleRam : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
        ToWasmFpgaModuleRam : buffer T_WasmFpgaInstruction_WasmFpgaModuleRam;
        FromWasmFpgaMemory : in T_WasmFpgaMemory_WasmFpgaInstruction;
        ToWasmFpgaMemory : out T_WasmFpgaInstruction_WasmFpgaMemory
    );
end;

architecture InstructionLocalGetArchitecture of InstructionLocalGet is

    signal Rst : std_logic;
    signal State : std_logic_vector(15 downto 0);
    signal GetLocalFromStackState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);
    signal ReadUnsignedLEB128State : std_logic_vector(15 downto 0);
    signal ReadFromModuleRamState : std_logic_vector(15 downto 0);
    signal DecodedValue : std_logic_vector(31 downto 0);
    signal CurrentByte : std_logic_vector(7 downto 0);

begin

    Rst <= not nRst;

    -- Memory
    ToWasmFpgaMemory.Run <= '0';
    ToWasmFpgaMemory.Address <= (others => '0');
    ToWasmFpgaMemory.WriteData <= (others => '0');
    ToWasmFpgaMemory.WriteEnable <= '0';

    process (Clk, Rst) is
    begin
        if (Rst = '1') then
          DecodedValue <= (others => '0');
          CurrentByte <= (others => '0');
          -- Invocation
          ToWasmFpgaInvocation <= (
              Address => (others => '0'),
              Trap => '0',
              Busy => '1'
          );
          -- Stack
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
          -- Module
          ToWasmFpgaModuleRam <= (
              Run => '0',
              Address => (others => '0')
          );
          -- FSM States
          ReadUnsignedLEB128State <= (others => '0');
          ReadFromModuleRamState <= (others => '0');
          GetLocalFromStackState <= (others => '0');
          PushToStackState <= (others => '0');
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

end architecture;