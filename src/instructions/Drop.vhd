library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- i32.ctz
--
-- Return the count of trailing zero bits in i; all bits are considered
-- trailing zeros if i is 0.
--
entity InstructionDrop is
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

architecture InstructionDropArchitecture of InstructionDrop is

    signal Rst : std_logic;
    signal State : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);

begin

    Rst <= not nRst;

    ToWasmFpgaMemory.Run <= '0';
    ToWasmFpgaMemory.Address <= (others => '0');
    ToWasmFpgaMemory.WriteData <= (others => '0');
    ToWasmFpgaMemory.WriteEnable <= '0';

    process (Clk, Rst) is
    begin
        if (Rst = '1') then
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
          ToWasmFpgaModuleRam.Run <= '0';
          ToWasmFpgaModuleRam.Address <= (others => '0');
          ToWasmFpgaInvocation.Address <= (others => '0');
          ToWasmFpgaInvocation.Trap <= '0';
          ToWasmFpgaInvocation.Busy <= '1';
          PopFromStackState <= (others => '0');
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
                PopFromStack(PopFromStackState,
                             ToWasmFpgaStack,
                             FromWasmFpgaStack);
                if(PopFromStackState = StateEnd) then
                    State <= State1;
                end if;
            elsif (State = State1) then
                ToWasmFpgaInvocation.Address <= ToWasmFpgaModuleRam.Address;
                State <= StateIdle;
            end if;
        end if;
    end process;

end;