library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaStackWshBn_Package.all;
  use work.WasmFpgaBusWshBn_Package.all;

entity WasmFpgaEngine_StackBlk is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        Adr : out std_logic_vector(23 downto 0);
        Sel : out std_logic_vector(3 downto 0);
        DatIn : out std_logic_vector(31 downto 0);
        We : out std_logic;
        Stb : out std_logic;
        Cyc : out  std_logic_vector(0 downto 0);
        StackBlk_DatOut : in std_logic_vector(31 downto 0);
        StackBlk_Ack : in std_logic;
        Run : in std_logic;
        Busy : out std_logic;
        Action : in std_logic_vector(1 downto 0);
        ValueType : in std_logic_vector(2 downto 0);
        SizeValue : out std_logic_vector(31 downto 0);
        HighValue_ToBeRead : out std_logic_vector(31 downto 0);
        HighValue_Written : in std_logic_vector(31 downto 0);
        LowValue_ToBeRead : out std_logic_vector(31 downto 0);
        LowValue_Written : in std_logic_vector(31 downto 0)
    );
end entity;

architecture Behavioural of WasmFpgaEngine_StackBlk is

  signal Ack : std_logic;
  signal DatOut : std_logic_vector(31 downto 0);
  signal State : std_logic_vector(7 downto 0);

begin

  Ack <= StackBlk_Ack;
  DatOut <= StackBlk_DatOut;

  SizeValue <= (others => '0');

  Stack : process (Clk, Rst) is
    constant Idle : std_logic_vector(7 downto 0) := x"00";
    constant WriteHighValueReg0 : std_logic_vector(7 downto 0) := x"01";
    constant WriteHighValueReg1 : std_logic_vector(7 downto 0) := x"02";
    constant WriteLowValueReg0 : std_logic_vector(7 downto 0) := x"03";
    constant WriteLowValueReg1 : std_logic_vector(7 downto 0) := x"04";
    constant WriteControlReg0 : std_logic_vector(7 downto 0) := x"05";
    constant WriteControlReg1 : std_logic_vector(7 downto 0) := x"06";
    constant WriteControlReg2 : std_logic_vector(7 downto 0) := x"07";
    constant WriteControlReg3 : std_logic_vector(7 downto 0) := x"08";
    constant ReadStatusReg0 : std_logic_vector(7 downto 0) := x"09";
    constant ReadStatusReg1 : std_logic_vector(7 downto 0) := x"0A";
    constant ReadLowValueReg0 : std_logic_vector(7 downto 0) := x"0B";
    constant ReadLowValueReg1 : std_logic_vector(7 downto 0) := x"0C";
    constant ReadHighValueReg0 : std_logic_vector(7 downto 0) := x"0D";
    constant ReadHighValueReg1 : std_logic_vector(7 downto 0) := x"0E";
  begin
    if (Rst = '1') then
      Busy <= '0';
      Cyc <= (others => '0');
      Stb <= '0';
      Adr <= (others => '0');
      Sel <= (others => '0');
      We <= '0';
      DatIn <= (others => '0');
      HighValue_ToBeRead <= (others => '0');
      LowValue_ToBeRead <= (others => '0');
      State <= (others => '0');
    elsif rising_edge(Clk) then
      if( State = Idle ) then
        Busy <= '0';
        Cyc <= (others => '0');
        Stb <= '0';
        Adr <= (others => '0');
        Sel <= (others => '0');
        if( Run = '1' ) then
          Busy <= '1';
          Cyc <= "1";
          Stb <= '1';
          Sel <= (others => '1');
          We <= '1';
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StackArea) +
                                  unsigned(WASMFPGASTACK_ADR_HighValueReg));
          DatIn <= HighValue_Written;
          State <= WriteHighValueReg0;
        end if;
      elsif( State = WriteHighValueReg0 ) then
        if ( Ack = '1' ) then
          Cyc <= "0";
          Stb <= '0';
          We <= '0';
          State <= WriteLowValueReg0;
        end if;
      elsif( State = WriteLowValueReg0 ) then
          Cyc <= "1";
          Stb <= '1';
          Sel <= (others => '1');
          We <= '1';
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StackArea) +
                                  unsigned(WASMFPGASTACK_ADR_LowValueReg));
          DatIn <= LowValue_Written;
          State <= WriteLowValueReg1;
      elsif( State = WriteLowValueReg1 ) then
        if ( Ack = '1' ) then
          Cyc <= "0";
          Stb <= '0';
          We <= '0';
          State <= WriteControlReg0;
        end if;
      elsif( State = WriteControlReg0 ) then
          Cyc <= "1";
          Stb <= '1';
          Sel <= (others => '1');
          We <= '1';
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StackArea) +
                                  unsigned(WASMFPGASTACK_ADR_ControlReg));
          DatIn <= (31 downto 6 => '0') &
                   WASMFPGASTACK_VAL_DoRun &
                   Action &
                   ValueType;
          State <= WriteControlReg1;
      elsif( State = WriteControlReg1 ) then
        if ( Ack = '1' ) then
          Cyc <= "0";
          Stb <= '0';
          We <= '0';
          State <= WriteControlReg2;
        end if;
      elsif( State = WriteControlReg2 ) then
          Cyc <= "1";
          Stb <= '1';
          Sel <= (others => '1');
          We <= '1';
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StackArea) +
                                  unsigned(WASMFPGASTACK_ADR_ControlReg));
          DatIn <= (31 downto 6 => '0') &
                   WASMFPGASTACK_VAL_DoNotRun &
                   Action &
                   ValueType;
          State <= WriteControlReg3;
      elsif( State = WriteControlReg3 ) then
        if ( Ack = '1' ) then
          Cyc <= "0";
          Stb <= '0';
          We <= '0';
          State <= ReadStatusReg0;
        end if;
      elsif( State = ReadStatusReg0 ) then
          Cyc <= "1";
          Stb <= '1';
          Sel <= (others => '1');
          We <= '0';
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StackArea) +
                                  unsigned(WASMFPGASTACK_ADR_StatusReg));
          State <= ReadStatusReg1;
      elsif( State = ReadStatusReg1 ) then
        if ( Ack = '1' ) then
          Cyc <= "0";
          Stb <= '0';
          if (DatOut(0) = WASMFPGASTACK_VAL_IsNotBusy) then
            State <= ReadLowValueReg0;
          else
            State <= ReadStatusReg0;
          end if;
        end if;
      elsif( State = ReadLowValueReg0 ) then
          Cyc <= "1";
          Stb <= '1';
          Sel <= (others => '1');
          We <= '0';
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StackArea) +
                                  unsigned(WASMFPGASTACK_ADR_LowValueReg));
          State <= ReadLowValueReg1;
      elsif( State = ReadLowValueReg1 ) then
        if ( Ack = '1' ) then
          Cyc <= "0";
          Stb <= '0';
          LowValue_ToBeRead <= DatOut;
          State <= ReadHighValueReg0;
        end if;
      elsif( State = ReadHighValueReg0 ) then
          Cyc <= "1";
          Stb <= '1';
          Sel <= (others => '1');
          We <= '0';
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StackArea) +
                                  unsigned(WASMFPGASTACK_ADR_HighValueReg));
          State <= ReadHighValueReg1;
      elsif( State = ReadHighValueReg1 ) then
        if ( Ack = '1' ) then
          Cyc <= "0";
          Stb <= '0';
          HighValue_ToBeRead <= DatOut;
          State <= Idle;
        end if;
      end if;
    end if;
  end process;

end architecture;