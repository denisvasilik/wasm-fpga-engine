library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- local.set
--
-- Execution: https://www.w3.org/TR/wasm-core-1/#exec-local-tee
-- Validation: https://www.w3.org/TR/wasm-core-1/#valid-local-tee
--
entity InstructionLocalTee is
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

architecture Behavioural of InstructionLocalTee is

    signal State : std_logic_vector(15 downto 0);
    signal SetLocalFromStackState : std_logic_vector(15 downto 0);
    signal ReadUnsignedLEB128State : std_logic_vector(15 downto 0);
    signal ReadFromModuleRamState : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);
    signal DecodedValue : std_logic_vector(31 downto 0);
    signal CurrentByte : std_logic_vector(7 downto 0);
    
    signal ToWasmFpgaStackBuf : T_ToWasmFpgaStack;
    signal ToWasmFpgaModuleRamBuf : T_ToWasmFpgaModuleRam;

begin

    ToWasmFpgaStack <= ToWasmFpgaStackBuf;
    ToWasmFpgaModuleRam <= ToWasmFpgaModuleRamBuf;

    ToWasmFpgaMemory <= (
        Run => '0',
        Address => (others => '0'),
        WriteData => (others => '0'),
        WriteEnable => '0'
    );

    process (Clk, nRst) is
    begin
        if (nRst = '0') then
          DecodedValue <= (others => '0');
          CurrentByte <= (others => '0');
          ToWasmFpgaStackBuf <= (
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
          FromWasmFpgaInstruction <= (
              Address => (others => '0'),
              Trap => '0',
              Busy => '1'
          );
          ToWasmFpgaModuleRamBuf <= (
              Run => '0',
              Address => (others => '0')
          );
          ReadUnsignedLEB128State <= StateIdle;
          ReadFromModuleRamState <= StateIdle;
          SetLocalFromStackState <= StateIdle;
          PopFromStackState <= StateIdle;
          PushToStackState <= StateIdle;
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                FromWasmFpgaInstruction.Busy <= '0';
                if (ToWasmFpgaInstruction.Run = '1') then
                    FromWasmFpgaInstruction.Busy <= '1';
                    ToWasmFpgaModuleRamBuf.Address <= ToWasmFpgaInstruction.Address;
                    State <= State0;
                end if;
            elsif (State = State0) then
                PopFromStack(PopFromStackState,
                             FromWasmFpgaStack,
                             ToWasmFpgaStackBuf);
                if(PopFromStackState = StateEnd) then
                    ToWasmFpgaStackBuf.LowValue <= FromWasmFpgaStack.LowValue;
                    ToWasmFpgaStackBuf.HighValue <= FromWasmFpgaStack.HighValue;
                    ToWasmFpgaStackBuf.TypeValue <= FromWasmFpgaStack.TypeValue;
                    State <= State1;
                end if;
            elsif (State = State1) then
                PushToStack(PushToStackState,
                            FromWasmFpgaStack,
                            ToWasmFpgaStackBuf);
                if(PushToStackState = StateEnd) then
                    State <= State2;
                end if;
            elsif (State = State2) then
                PushToStack(PushToStackState,
                            FromWasmFpgaStack,
                            ToWasmFpgaStackBuf);
                if(PushToStackState = StateEnd) then
                    State <= State3;
                end if;
            elsif (State = State3) then
                -- Read local idx parameter from module RAM
                ReadUnsignedLEB128(ReadUnsignedLEB128State,
                                   ReadFromModuleRamState,
                                   DecodedValue,
                                   CurrentByte,
                                   FromWasmFpgaModuleRam,
                                   ToWasmFpgaModuleRamBuf);
                if(ReadUnsignedLEB128State = StateEnd) then
                    ToWasmFpgaStackBuf.LocalIndex <= DecodedValue;
                    State <= State4;
                end if;
            elsif (State = State4) then
                SetLocalFromStack(SetLocalFromStackState,
                                  FromWasmFpgaStack,
                                  ToWasmFpgaStackBuf);
                if(SetLocalFromStackState = StateEnd) then
                    FromWasmFpgaInstruction.Address <= FromWasmFpgaModuleRam.Address;
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

end;
