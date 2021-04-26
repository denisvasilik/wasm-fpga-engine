library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity WasmFpgaModuleProxy is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        Adr : out std_logic_vector(23 downto 0);
        Sel : out std_logic_vector(3 downto 0);
        DatIn : out std_logic_vector(31 downto 0);
        We : out std_logic;
        Stb : out std_logic;
        Cyc : out  std_logic_vector(0 downto 0);
        ModuleBlk_DatOut : in std_logic_vector(31 downto 0);
        ModuleBlk_Ack : in std_logic;
        Run : in std_logic;
        Busy : out std_logic;
        Address : in std_logic_vector(23 downto 0);
        Data : out std_logic_vector(31 downto 0)
    );
end entity;

architecture Behavioural of WasmFpgaModuleProxy is

  signal State : std_logic_vector(3 downto 0);

begin

  DatIn <= (others => '0');
  We <= '0';

  Module : process (Clk, Rst) is
    constant StateIdle : std_logic_vector(3 downto 0) := x"0";
    constant StateRead : std_logic_vector(3 downto 0) := x"1";
  begin
    if (Rst = '1') then
      Busy <= '0';
      Stb <= '0';
      Cyc <= (others => '0');
      Adr <= (others => '0');
      Sel <= (others => '0');
      Data <= (others => '0');
      State <= (others => '0');
    elsif rising_edge(Clk) then
      if( State = StateIdle ) then
        Busy <= '0';
        Stb <= '0';
        Cyc <= (others => '0');
        Adr <= (others => '0');
        Sel <= (others => '0');
        if(Run = '1') then
          Busy <= '1';
          Stb <= '1';
          Cyc <= "1";
          Adr <= "00" & Address(23 downto 2);
          Sel <= (others => '1');
          State <= StateRead;
        end if;
      elsif( State = StateRead ) then
        if ( ModuleBlk_Ack = '1' ) then
          Data <= ModuleBlk_DatOut;
          State <= StateIdle;
        end if;
      end if;
    end if;
  end process;

end architecture;