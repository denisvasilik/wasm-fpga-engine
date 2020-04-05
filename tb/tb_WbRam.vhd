library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity WbRam is
    port ( 
        Clk : in std_logic;
        nRst : in std_logic;
        Adr : in std_logic_vector(23 downto 0);
        Sel : in std_logic_vector(3 downto 0);
        DatIn : in std_logic_vector(31 downto 0); 
        We : in std_logic;
        Stb : in std_logic; 
        Cyc : in std_logic_vector(0 downto 0);
        DatOut : out std_logic_vector(31 downto 0);
        Ack : out std_logic
    );
end entity WbRam;

architecture WbRamArchitecture of WbRam is

  component WasmFpgaTestBenchRam is
    port ( 
      clka : in std_logic;
      ena : in std_logic;
      wea : in std_logic_vector( 0 to 0 );
      addra : in std_logic_vector( 9 downto 0 );
      dina : in std_logic_vector( 31 downto 0 );
      douta : out std_logic_vector(31 downto 0);
      clkb : in std_logic;
      enb : in std_logic;
      web : in std_logic_vector(0 to 0);
      addrb : in std_logic_vector(9 downto 0);
      dinb : in std_logic_vector(31 downto 0);
      doutb : out std_logic_vector(31 downto 0)
    );
  end component;

  signal Rst : std_logic;
  signal Enable : std_logic;
  signal WriteEnable : std_logic_vector(0 downto 0);
  signal ReadData : std_logic_vector(31 downto 0);
  signal WriteData : std_logic_vector(31 downto 0);
  signal Address : std_logic_vector(9 downto 0);
  signal WbState : unsigned(7 downto 0);

  constant WbStateIdle0 : natural := 0;
  constant WbStateRead0 : natural := 1;
  constant WbStateRead1 : natural := 2;
  constant WbStateRead2 : natural := 3;
  constant WbStateRead3 : natural := 4;
  constant WbStateWrite0 : natural := 5;
  constant WbStateWrite1 : natural := 6;

begin

  Rst <= not nRst;

  MemoryAccess : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      Ack <= '0';
      DatOut <= (others => '0');
      Enable <= '0';
      WriteEnable <= "0";
      Address <= (others => '0');
      WbState <= (others => '0');
    elsif rising_edge(Clk) then
      if(WbState = WbStateIdle0) then
        Ack <= '0';
        Enable <= '0';
        if (Cyc = "1" and We = '0') then
            Enable <= '1';
            Address <= Adr(9 downto 0);
            WbState <= to_unsigned(WbStateRead0, WbState'LENGTH);
        elsif (Cyc = "1" and We = '1') then
            Enable <= '1';
            WriteEnable <= "1";
            WriteData <= DatIn;
            Address <= Adr(9 downto 0);
            WbState <= to_unsigned(WbStateWrite0, WbState'LENGTH);
        end if;
      elsif(WbState = WbStateRead0) then
        WbState <= to_unsigned(WbStateRead1, WbState'LENGTH);
      elsif(WbState = WbStateRead1) then
        WbState <= to_unsigned(WbStateRead2, WbState'LENGTH);
      elsif(WbState = WbStateRead2) then
        DatOut <= ReadData;
        Ack <= '1';
        WbState <= to_unsigned(WbStateRead3, WbState'LENGTH);
      elsif(WbState = WbStateRead3) then
        Ack <= '0';
        WbState <= to_unsigned(WbStateIdle0, WbState'LENGTH);
      elsif(WbState = WbStateWrite0) then
        WriteEnable <= "0";
        Ack <= '1';
        WbState <= to_unsigned(WbStateWrite1, WbState'LENGTH);
      elsif(WbState = WbStateWrite1) then
        Ack <= '0';
        WbState <= to_unsigned(WbStateIdle0, WbState'LENGTH);
      end if;
    end if;
  end process;

  WasmFpgaTestBenchRam_i : WasmFpgaTestBenchRam
    port map ( 
      clka => Clk,
      ena => Enable,
      wea => WriteEnable,
      addra => Address,
      dina => WriteData,
      douta => ReadData,
      clkb => Clk,
      enb => '0',
      web => "0",
      addrb => (others => '0'),
      dinb => (others => '0'),
      doutb => open
    );

end;
