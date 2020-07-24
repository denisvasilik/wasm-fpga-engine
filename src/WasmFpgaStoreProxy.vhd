library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaStoreWshBn_Package.all;
  use work.WasmFpgaBusWshBn_Package.all;

entity WasmFpgaEngine_StoreBlk is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        Adr : out std_logic_vector(23 downto 0);
        Sel : out std_logic_vector(3 downto 0);
        DatIn : out std_logic_vector(31 downto 0);
        We : out std_logic;
        Stb : out std_logic;
        Cyc : out  std_logic_vector(0 downto 0);
        StoreBlk_DatOut : in std_logic_vector(31 downto 0);
        StoreBlk_Ack : in std_logic;
        Operation : in std_logic;
        Run : in std_logic;
        Busy : out std_logic;
        ModuleInstanceUID : in std_logic_vector(31 downto 0);
        SectionUID : in std_logic_vector(31 downto 0);
        Idx : in std_logic_vector(31 downto 0);
        Address_ToBeRead : out std_logic_vector(31 downto 0);
        Address_Written : in std_logic_vector(31 downto 0)
    );
end entity;

architecture Behavioural of WasmFpgaEngine_StoreBlk is

  signal Ack : std_logic;
  signal DatOut : std_logic_vector(31 downto 0);
  signal State : std_logic_vector(7 downto 0);

begin

  Ack <= StoreBlk_Ack;
  DatOut <= StoreBlk_DatOut;

  process (Clk, Rst) is
    constant Idle : std_logic_vector(7 downto 0) := x"00";
    constant WriteModuleInstanceUid : std_logic_vector(7 downto 0) := x"01";
    constant WriteSectionId0 : std_logic_vector(7 downto 0) := x"02";
    constant WriteSectionId1 : std_logic_vector(7 downto 0) := x"07";
    constant WriteIdx0 : std_logic_vector(7 downto 0) := x"04";
    constant WriteIdx1 : std_logic_vector(7 downto 0) := x"05";
    constant WriteAddress0 : std_logic_vector(7 downto 0) := x"06";
    constant WriteAddress1 : std_logic_vector(7 downto 0) := x"07";
    constant WriteControlReg0 : std_logic_vector(7 downto 0) := x"08";
    constant WriteControlReg1 : std_logic_vector(7 downto 0) := x"09";
    constant WriteControlReg2 : std_logic_vector(7 downto 0) := x"0A";
    constant WriteControlReg3 : std_logic_vector(7 downto 0) := x"0B";
    constant ReadStatusReg0 : std_logic_vector(7 downto 0) := x"0C";
    constant ReadStatusReg1 : std_logic_vector(7 downto 0) := x"0D";
    constant ReadAddressReg0 : std_logic_vector(7 downto 0) := x"0E";
    constant ReadAddressReg1 : std_logic_vector(7 downto 0) := x"0F";
  begin
    if (Rst = '1') then
      Busy <= '0';
      Cyc <= (others => '0');
      Stb <= '0';
      Adr <= (others => '0');
      Sel <= (others => '0');
      We <= '0';
      DatIn <= (others => '0');
      Address_ToBeRead <= (others => '0');
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
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StoreArea) +
                                  unsigned(WASMFPGASTORE_ADR_ModuleInstanceUidReg));
          DatIn <= ModuleInstanceUID;
          State <= WriteModuleInstanceUid;
        end if;
      elsif( State = WriteModuleInstanceUid ) then
        if ( Ack = '1' ) then
          Cyc <= "0";
          Stb <= '0';
          We <= '0';
          State <= WriteSectionId0;
        end if;
      elsif( State = WriteSectionId0 ) then
          Cyc <= "1";
          Stb <= '1';
          Sel <= (others => '1');
          We <= '1';
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StoreArea) +
                                  unsigned(WASMFPGASTORE_ADR_SectionUidReg));
          DatIn <= SectionUID;
          State <= WriteSectionId1;
      elsif( State = WriteSectionId1 ) then
        if ( Ack = '1' ) then
          Cyc <= "0";
          Stb <= '0';
          We <= '0';
          State <= WriteIdx0;
        end if;
      elsif( State = WriteIdx0 ) then
          Cyc <= "1";
          Stb <= '1';
          Sel <= (others => '1');
          We <= '1';
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StoreArea) +
                                  unsigned(WASMFPGASTORE_ADR_IdxReg));
          DatIn <= Idx;
          State <= WriteIdx1;
      elsif( State = WriteIdx1 ) then
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
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StoreArea) +
                                  unsigned(WASMFPGASTORE_ADR_ControlReg));
          DatIn <= (31 downto 2 => '0') & 
                   WASMFPGASTORE_VAL_Read & 
                   WASMFPGASTORE_VAL_DoRun;
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
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StoreArea) +
                                  unsigned(WASMFPGASTORE_ADR_ControlReg));
          DatIn <= (31 downto 2 => '0') &
                   WASMFPGASTORE_VAL_Read &
                   WASMFPGASTORE_VAL_DoNotRun;
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
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StoreArea) +
                                  unsigned(WASMFPGASTORE_ADR_StatusReg));
          State <= ReadStatusReg1;
      elsif( State = ReadStatusReg1 ) then
        if ( Ack = '1' ) then
          Cyc <= "0";
          Stb <= '0';
          if (DatOut(0) = WASMFPGASTORE_VAL_IsNotBusy) then
            State <= ReadAddressReg0;
          else
            State <= ReadStatusReg0;
          end if;
        end if;
      elsif( State = ReadAddressReg0 ) then
          Cyc <= "1";
          Stb <= '1';
          Sel <= (others => '1');
          We <= '0';
          Adr <= std_logic_vector(unsigned(WASMFPGABUS_ADR_BASE_StoreArea) +
                                  unsigned(WASMFPGASTORE_ADR_AddressReg));
          State <= ReadAddressReg1;
      elsif( State = ReadAddressReg1 ) then
        if ( Ack = '1' ) then
          Cyc <= "0";
          Stb <= '0';
          Address_ToBeRead <= DatOut;
          State <= Idle;
        end if;
      end if;
    end if;
  end process;

end architecture;