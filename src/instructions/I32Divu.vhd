library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- i32.div_s
--
-- If i2​ is 0, then the result is undefined.
-- Else, return the result of dividing i1​ by i2​, truncated toward zero.
--
-- Operation: https://www.w3.org/TR/wasm-core-1/#op-idiv-u
-- Execution: https://www.w3.org/TR/wasm-core-1/#exec-binop
-- Validation: https://www.w3.org/TR/wasm-core-1/#valid-binop
--
entity InstructionI32Divu is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        WasmFpgaInvocation_WasmFpgaInstruction : in T_WasmFpgaInvocation_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaInvocation : out T_WasmFpgaInstruction_WasmFpgaInvocation;
        WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
        WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaModuleRam : buffer T_WasmFpgaInstruction_WasmFpgaModuleRam
    );
end entity;

architecture InstructionI32DivuArchitecture of InstructionI32Divu is

    component WasmFpgaDivider32Bit is
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

    signal Rst : std_logic;
    signal State : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);
    signal OperandA : std_logic_vector(31 downto 0);
    signal OperandB : std_logic_vector(31 downto 0);
    signal OperandAValid : std_logic;
    signal OperandBValid : std_logic;
    signal Result : std_logic_vector(63 downto 0);
    signal ResultValid : std_logic;

begin

    Rst <= not nRst;

    process (Clk, Rst) is
    begin
        if (Rst = '1') then
          WasmFpgaInstruction_WasmFpgaStack.Run <= '0';
          WasmFpgaInstruction_WasmFpgaStack.Action <= '0';
          WasmFpgaInstruction_WasmFpgaStack.TypeValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.HighValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.LowValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaModuleRam.Run <= '0';
          WasmFpgaInstruction_WasmFpgaModuleRam.Address <= (others => '0');
          WasmFpgaInstruction_WasmFpgaInvocation.Address <= (others => '0');
          WasmFpgaInstruction_WasmFpgaInvocation.Trap <= '0';
          WasmFpgaInstruction_WasmFpgaInvocation.Busy <= '1';
          OperandA <= (others => '0');
          OperandB <= (others => '0');
          OperandAValid <= '0';
          OperandBValid <= '0';
          PopFromStackState <= (others => '0');
          PushToStackState <= (others => '0');
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                WasmFpgaInstruction_WasmFpgaInvocation.Busy <= '0';
                OperandAValid <= '0';
                OperandBValid <= '0';
                if (WasmFpgaInvocation_WasmFpgaInstruction.Run = '1') then
                    WasmFpgaInstruction_WasmFpgaInvocation.Busy <= '1';
                    WasmFpgaInstruction_WasmFpgaModuleRam.Address <= WasmFpgaInvocation_WasmFpgaInstruction.Address;
                    State <= State0;
                end if;
            elsif (State = State0) then
                PopFromStack(PopFromStackState,
                             WasmFpgaInstruction_WasmFpgaStack,
                             WasmFpgaStack_WasmFpgaInstruction);
                if(PopFromStackState = StateEnd) then
                    OperandB <= WasmFpgaStack_WasmFpgaInstruction.LowValue;
                    OperandBValid <= '1';
                    State <= State1;
                end if;
            elsif (State = State1) then
                PopFromStack(PopFromStackState,
                             WasmFpgaInstruction_WasmFpgaStack,
                             WasmFpgaStack_WasmFpgaInstruction);
                if(PopFromStackState = StateEnd) then
                    OperandA <= WasmFpgaStack_WasmFpgaInstruction.LowValue;
                    OperandAValid <= '1';
                    State <= State2;
                end if;
            elsif (State = State2) then
                if (ResultValid = '1') then
                    WasmFpgaInstruction_WasmFpgaStack.LowValue <= Result(63 downto 32);
                    State <= State3;
                end if;
            elsif (State = State3) then
                PushToStack(PushToStackState,
                            WasmFpgaInstruction_WasmFpgaStack,
                            WasmFpgaStack_WasmFpgaInstruction);
                if(PushToStackState = StateEnd) then
                    State <= State4;
                end if;
            elsif (State = State4) then
                WasmFpgaInstruction_WasmFpgaInvocation.Address <= WasmFpgaInstruction_WasmFpgaModuleRam.Address;
                State <= StateIdle;
            end if;
        end if;
    end process;

    WasmFpgaDivider32Bit_i : WasmFpgaDivider32Bit
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

end architecture;