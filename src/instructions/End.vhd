library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;
  use work.WasmFpgaStackWshBn_Package.all;

--
-- end
--
-- A pseudo-instruction that terminates a block.
--
entity InstructionEnd is
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

architecture Behavioural of InstructionEnd is

    signal State : std_logic_vector(15 downto 0);
    signal ActivationFrameStackState : std_logic_vector(15 downto 0);

    signal ToWasmFpgaStackBuf : T_ToWasmFpgaStack;

begin

    ToWasmFpgaStack <= ToWasmFpgaStackBuf;

    ToWasmFpgaMemory <= (
        Run => '0',
        Address => (others => '0'),
        WriteData => (others => '0'),
        WriteEnable => '0'
    );

    ToWasmFpgaModuleRam <= (
        Run => '0',
        Address => (others => '0')
    );

    process (Clk, nRst) is
    begin
        if (nRst = '0') then
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
          ActivationFrameStackState <= StateIdle;
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                FromWasmFpgaInstruction.Busy <= '0';
                if (ToWasmFpgaInstruction.Run = '1') then
                    FromWasmFpgaInstruction.Busy <= '1';
                    FromWasmFpgaInstruction.Address <= ToWasmFpgaInstruction.Address;
                    State <= State0;
                end if;
            elsif(State = State0) then
                RemoveActivationFrame(ActivationFrameStackState,
                                      FromWasmFpgaStack,
                                      ToWasmFpgaStackBuf);
                if(ActivationFrameStackState = StateEnd) then
                    FromWasmFpgaInstruction.Address <= FromWasmFpgaStack.ReturnAddress(23 downto 0);
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

end;