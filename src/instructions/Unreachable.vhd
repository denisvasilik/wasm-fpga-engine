library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;
  use work.WasmFpgaStackWshBn_Package.all;

--
-- unreachable
--
entity InstructionUnreachable is
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

architecture Behavioural of InstructionUnreachable is

    signal State : std_logic_vector(15 downto 0);

begin

    ToWasmFpgaMemory <= (
        Run => '0',
        Address => (others => '0'),
        WriteData => (others => '0'),
        WriteEnable => '0'
    );

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

    process (Clk, nRst) is
    begin
        if (nRst = '0') then
          FromWasmFpgaInstruction <= (
              Address => (others => '0'),
              Trap => '0',
              Busy => '1'
          );
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                FromWasmFpgaInstruction.Busy <= '0';
                if (ToWasmFpgaInstruction.Run = '1') then
                    FromWasmFpgaInstruction.Busy <= '1';
                    FromWasmFpgaInstruction.Trap <= '1';
                    FromWasmFpgaInstruction.Address <= FromWasmFpgaModuleRam.Address;
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

end;