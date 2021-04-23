library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- i32.rem_s
--
-- Operation: https://www.w3.org/TR/wasm-core-1/#op-irem-u
-- Execution: https://www.w3.org/TR/wasm-core-1/#exec-binop
-- Validation: https://www.w3.org/TR/wasm-core-1/#valid-binop
--
entity InstructionI32Rems is
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

architecture Behavioural of InstructionI32Rems is

    component WasmFpgaDivider32BitSigned is
      port (
        aclk : in std_logic;
        s_axis_divisor_tvalid : in std_logic;
        s_axis_divisor_tready : out std_logic;
        s_axis_divisor_tdata : in std_logic_vector ( 31 downto 0 );
        s_axis_dividend_tvalid : in std_logic;
        s_axis_dividend_tready : out std_logic;
        s_axis_dividend_tdata : in std_logic_vector ( 31 downto 0 );
        m_axis_dout_tvalid : out std_logic;
        m_axis_dout_tdata : out std_logic_vector ( 63 downto 0 )
      );
    end component;

    signal State : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);
    signal OperandA : std_logic_vector(31 downto 0);
    signal OperandB : std_logic_vector(31 downto 0);
    signal OperandAValid : std_logic;
    signal OperandBValid : std_logic;
    signal Result : std_logic_vector(63 downto 0);
    signal ResultValid : std_logic;

    signal ToWasmFpgaStackBuf : T_ToWasmFpgaStack;

begin

    ToWasmFpgaStack <= ToWasmFpgaStackBuf;

    ToWasmFpgaMemory <= (
        Run => '0',
        Address => (others => '0'),
        WriteData => (others => '0'),
        WriteEnable => '0'
    );

    process (Clk, nRst) is
    begin
        if (nRst = '0') then
          OperandA <= (others => '0');
          OperandB <= (others => '0');
          OperandAValid <= '0';
          OperandBValid <= '0';
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
          ToWasmFpgaModuleRam <= (
              Run => '0',
              Address => (others => '0')
          );
          FromWasmFpgaInstruction <= (
              Address => (others => '0'),
              Trap => '0',
              Busy => '1'
          );
          PopFromStackState <= StateIdle;
          PushToStackState <= StateIdle;
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                FromWasmFpgaInstruction.Busy <= '0';
                OperandAValid <= '0';
                OperandBValid <= '0';
                if (ToWasmFpgaInstruction.Run = '1') then
                    FromWasmFpgaInstruction.Busy <= '1';
                    ToWasmFpgaModuleRam.Address <= ToWasmFpgaInstruction.Address;
                    State <= State0;
                end if;
            elsif (State = State0) then
                PopFromStack(PopFromStackState,
                             FromWasmFpgaStack,
                             ToWasmFpgaStackBuf);
                if(PopFromStackState = StateEnd) then
                    OperandB <= FromWasmFpgaStack.LowValue;
                    OperandBValid <= '1';
                    State <= State1;
                end if;
            elsif (State = State1) then
                PopFromStack(PopFromStackState,
                             FromWasmFpgaStack,
                             ToWasmFpgaStackBuf);
                if(PopFromStackState = StateEnd) then
                    OperandA <= FromWasmFpgaStack.LowValue;
                    OperandAValid <= '1';
                    State <= State2;
                end if;
            elsif (State = State2) then
                if (ResultValid = '1') then
                    ToWasmFpgaStackBuf.LowValue <= Result(31 downto 0);
                    State <= State3;
                end if;
            elsif (State = State3) then
                PushToStack(PushToStackState,
                            FromWasmFpgaStack,
                            ToWasmFpgaStackBuf);
                if(PushToStackState = StateEnd) then
                    FromWasmFpgaInstruction.Address <= FromWasmFpgaModuleRam.Address;
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

    WasmFpgaDivider32BitSigned_i : WasmFpgaDivider32BitSigned
      port map (
        aclk => Clk,
        s_axis_divisor_tvalid => OperandBValid,
        s_axis_divisor_tready => open,
        s_axis_divisor_tdata => OperandB,
        s_axis_dividend_tvalid => OperandAValid,
        s_axis_dividend_tready => open,
        s_axis_dividend_tdata => OperandA,
        m_axis_dout_tvalid => ResultValid,
        m_axis_dout_tdata => Result
      );

end;