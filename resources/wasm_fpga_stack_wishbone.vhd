

-- ========== WebAssembly Stack Block( StackBlk) ========== 

-- This block describes the WebAssembly stack block.
-- BUS: 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaStackWshBn_Package.all;

entity StackBlk_WasmFpgaStack is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        Adr : in std_logic_vector(23 downto 0);
        Sel : in std_logic_vector(3 downto 0);
        DatIn : in std_logic_vector(31 downto 0);
        We : in std_logic;
        Stb : in std_logic;
        Cyc : in  std_logic_vector(0 downto 0);
        StackBlk_DatOut : out std_logic_vector(31 downto 0);
        StackBlk_Ack : out std_logic;
        StackBlk_Unoccupied_Ack : out std_logic;
        Run : out std_logic;
        Action : out std_logic_vector(2 downto 0);
        WRegPulse_ControlReg : out std_logic;
        Busy : in std_logic;
        SizeValue : in std_logic_vector(31 downto 0);
        HighValue_ToBeRead : in std_logic_vector(31 downto 0);
        HighValue_Written : out std_logic_vector(31 downto 0);
        LowValue_ToBeRead : in std_logic_vector(31 downto 0);
        LowValue_Written : out std_logic_vector(31 downto 0);
        Type_ToBeRead : in std_logic_vector(2 downto 0);
        Type_Written : out std_logic_vector(2 downto 0);
        LocalIndex : out std_logic_vector(31 downto 0);
        StackAddress_ToBeRead : in std_logic_vector(31 downto 0);
        StackAddress_Written : out std_logic_vector(31 downto 0);
        WRegPulse_StackAddressReg : out std_logic;
        MaxLocals : out std_logic_vector(31 downto 0);
        MaxResults : out std_logic_vector(31 downto 0);
        ReturnAddress : out std_logic_vector(31 downto 0);
        ModuleInstanceUid : out std_logic_vector(31 downto 0)
     );
end StackBlk_WasmFpgaStack;



architecture arch_for_synthesys of StackBlk_WasmFpgaStack is

    -- ---------- block variables ---------- 
    signal PreMuxAck_Unoccupied : std_logic;
    signal UnoccupiedDec : std_logic_vector(1 downto 0);
    signal StackBlk_PreDatOut : std_logic_vector(31 downto 0);
    signal StackBlk_PreAck : std_logic;
    signal StackBlk_Unoccupied_PreAck : std_logic;
    signal PreMuxDatOut_ControlReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_ControlReg : std_logic;
    signal PreMuxDatOut_StatusReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_StatusReg : std_logic;
    signal PreMuxDatOut_SizeReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_SizeReg : std_logic;
    signal PreMuxDatOut_HighValueReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_HighValueReg : std_logic;
    signal PreMuxDatOut_LowValueReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_LowValueReg : std_logic;
    signal PreMuxDatOut_TypeReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_TypeReg : std_logic;
    signal PreMuxDatOut_LocalIndexReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_LocalIndexReg : std_logic;
    signal PreMuxDatOut_StackAddressReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_StackAddressReg : std_logic;
    signal PreMuxDatOut_MaxLocalsReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_MaxLocalsReg : std_logic;
    signal PreMuxDatOut_MaxResultsReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_MaxResultsReg : std_logic;
    signal PreMuxDatOut_ReturnAddressReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_ReturnAddressReg : std_logic;
    signal PreMuxDatOut_ModuleInstanceUidReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_ModuleInstanceUidReg : std_logic;

    signal WriteDiff_ControlReg : std_logic;
    signal ReadDiff_ControlReg : std_logic;
     signal DelWriteDiff_ControlReg: std_logic;


    signal WriteDiff_StatusReg : std_logic;
    signal ReadDiff_StatusReg : std_logic;


    signal WriteDiff_SizeReg : std_logic;
    signal ReadDiff_SizeReg : std_logic;


    signal WriteDiff_HighValueReg : std_logic;
    signal ReadDiff_HighValueReg : std_logic;


    signal WriteDiff_LowValueReg : std_logic;
    signal ReadDiff_LowValueReg : std_logic;


    signal WriteDiff_TypeReg : std_logic;
    signal ReadDiff_TypeReg : std_logic;


    signal WriteDiff_LocalIndexReg : std_logic;
    signal ReadDiff_LocalIndexReg : std_logic;


    signal WriteDiff_StackAddressReg : std_logic;
    signal ReadDiff_StackAddressReg : std_logic;
     signal DelWriteDiff_StackAddressReg: std_logic;


    signal WriteDiff_MaxLocalsReg : std_logic;
    signal ReadDiff_MaxLocalsReg : std_logic;


    signal WriteDiff_MaxResultsReg : std_logic;
    signal ReadDiff_MaxResultsReg : std_logic;


    signal WriteDiff_ReturnAddressReg : std_logic;
    signal ReadDiff_ReturnAddressReg : std_logic;


    signal WriteDiff_ModuleInstanceUidReg : std_logic;
    signal ReadDiff_ModuleInstanceUidReg : std_logic;


    signal WReg_Run : std_logic;
    signal WReg_Action : std_logic_vector(2 downto 0);
    signal WReg_HighValue_Written : std_logic_vector(31 downto 0);
    signal WReg_LowValue_Written : std_logic_vector(31 downto 0);
    signal WReg_Type_Written : std_logic_vector(2 downto 0);
    signal WReg_LocalIndex : std_logic_vector(31 downto 0);
    signal WReg_StackAddress_Written : std_logic_vector(31 downto 0);
    signal WReg_MaxLocals : std_logic_vector(31 downto 0);
    signal WReg_MaxResults : std_logic_vector(31 downto 0);
    signal WReg_ReturnAddress : std_logic_vector(31 downto 0);
    signal WReg_ModuleInstanceUid : std_logic_vector(31 downto 0);

begin 

    -- ---------- block DatOut mux ----------

    gen_unoccupied_ack : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_Unoccupied <= '0';
            UnoccupiedDec <= "00";
        elsif rising_edge(Clk) then
            UnoccupiedDec(0) <= UnoccupiedDec(1); 
            UnoccupiedDec(1)  <= (Cyc(0)  and Stb);
            PreMuxAck_Unoccupied <= UnoccupiedDec(1) and not UnoccupiedDec(0);
        end if;
    end process;

    StackBlk_DatOut <= StackBlk_PreDatOut;
    StackBlk_Ack <=  StackBlk_PreAck;
    StackBlk_Unoccupied_Ack <= StackBlk_Unoccupied_PreAck;

    mux_data_ack_out : process (Cyc, Adr, 
                                PreMuxDatOut_ControlReg,
                                PreMuxAck_ControlReg,
                                PreMuxDatOut_StatusReg,
                                PreMuxAck_StatusReg,
                                PreMuxDatOut_SizeReg,
                                PreMuxAck_SizeReg,
                                PreMuxDatOut_HighValueReg,
                                PreMuxAck_HighValueReg,
                                PreMuxDatOut_LowValueReg,
                                PreMuxAck_LowValueReg,
                                PreMuxDatOut_TypeReg,
                                PreMuxAck_TypeReg,
                                PreMuxDatOut_LocalIndexReg,
                                PreMuxAck_LocalIndexReg,
                                PreMuxDatOut_StackAddressReg,
                                PreMuxAck_StackAddressReg,
                                PreMuxDatOut_MaxLocalsReg,
                                PreMuxAck_MaxLocalsReg,
                                PreMuxDatOut_MaxResultsReg,
                                PreMuxAck_MaxResultsReg,
                                PreMuxDatOut_ReturnAddressReg,
                                PreMuxAck_ReturnAddressReg,
                                PreMuxDatOut_ModuleInstanceUidReg,
                                PreMuxAck_ModuleInstanceUidReg,
                                PreMuxAck_Unoccupied
                                )
    begin 
        StackBlk_PreDatOut <= x"0000_0000"; -- default statements
        StackBlk_PreAck <= '0'; 
        StackBlk_Unoccupied_PreAck <= '0';
        if ( (Cyc(0) = '1') 
              and (unsigned(Adr) >= unsigned(WASMFPGASTACK_ADR_BLK_BASE_StackBlk) )
              and (unsigned(Adr) <= (unsigned(WASMFPGASTACK_ADR_BLK_BASE_StackBlk) + unsigned(WASMFPGASTACK_ADR_BLK_SIZE_StackBlk) - 1)) )
        then 
            if ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTACK_ADR_ControlReg)) ) then
                 StackBlk_PreDatOut <= PreMuxDatOut_ControlReg;
                StackBlk_PreAck <= PreMuxAck_ControlReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTACK_ADR_StatusReg)) ) then
                 StackBlk_PreDatOut <= PreMuxDatOut_StatusReg;
                StackBlk_PreAck <= PreMuxAck_StatusReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTACK_ADR_SizeReg)) ) then
                 StackBlk_PreDatOut <= PreMuxDatOut_SizeReg;
                StackBlk_PreAck <= PreMuxAck_SizeReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTACK_ADR_HighValueReg)) ) then
                 StackBlk_PreDatOut <= PreMuxDatOut_HighValueReg;
                StackBlk_PreAck <= PreMuxAck_HighValueReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTACK_ADR_LowValueReg)) ) then
                 StackBlk_PreDatOut <= PreMuxDatOut_LowValueReg;
                StackBlk_PreAck <= PreMuxAck_LowValueReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTACK_ADR_TypeReg)) ) then
                 StackBlk_PreDatOut <= PreMuxDatOut_TypeReg;
                StackBlk_PreAck <= PreMuxAck_TypeReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTACK_ADR_LocalIndexReg)) ) then
                 StackBlk_PreDatOut <= PreMuxDatOut_LocalIndexReg;
                StackBlk_PreAck <= PreMuxAck_LocalIndexReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTACK_ADR_StackAddressReg)) ) then
                 StackBlk_PreDatOut <= PreMuxDatOut_StackAddressReg;
                StackBlk_PreAck <= PreMuxAck_StackAddressReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTACK_ADR_MaxLocalsReg)) ) then
                 StackBlk_PreDatOut <= PreMuxDatOut_MaxLocalsReg;
                StackBlk_PreAck <= PreMuxAck_MaxLocalsReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTACK_ADR_MaxResultsReg)) ) then
                 StackBlk_PreDatOut <= PreMuxDatOut_MaxResultsReg;
                StackBlk_PreAck <= PreMuxAck_MaxResultsReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTACK_ADR_ReturnAddressReg)) ) then
                 StackBlk_PreDatOut <= PreMuxDatOut_ReturnAddressReg;
                StackBlk_PreAck <= PreMuxAck_ReturnAddressReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTACK_ADR_ModuleInstanceUidReg)) ) then
                 StackBlk_PreDatOut <= PreMuxDatOut_ModuleInstanceUidReg;
                StackBlk_PreAck <= PreMuxAck_ModuleInstanceUidReg;
            else 
                StackBlk_PreAck <= PreMuxAck_Unoccupied;
                StackBlk_Unoccupied_PreAck <= PreMuxAck_Unoccupied;
            end if;
        end if;
    end process;


    -- ---------- block functions ---------- 


    -- .......... ControlReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_ControlReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_ControlReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_ControlReg) ) then 
            WriteDiff_ControlReg <=  We and Stb and Cyc(0) and not PreMuxAck_ControlReg;
        else
            WriteDiff_ControlReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_ControlReg) ) then 
            ReadDiff_ControlReg <= not We and Stb and Cyc(0) and not PreMuxAck_ControlReg;
        else
            ReadDiff_ControlReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_ControlReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
             DelWriteDiff_ControlReg <= '0'; 
            PreMuxAck_ControlReg <= '0';
            WReg_Run <= '0';
            WReg_Action <= "000";
        elsif rising_edge(Clk) then
             DelWriteDiff_ControlReg <= WriteDiff_ControlReg;
            PreMuxAck_ControlReg <= WriteDiff_ControlReg or ReadDiff_ControlReg; 
            if (WriteDiff_ControlReg = '1') then
                if (Sel(0) = '1') then WReg_Run <= DatIn(3); end if;
                if (Sel(0) = '1') then WReg_Action(2 downto 0) <= DatIn(2 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_ControlReg0 : process (
            WReg_Run,
            WReg_Action
            )
    begin 
         PreMuxDatOut_ControlReg <= x"0000_0000";
         PreMuxDatOut_ControlReg(3) <= WReg_Run;
         PreMuxDatOut_ControlReg(2 downto 0) <= WReg_Action;
    end process;



    WRegPulse_ControlReg <= DelWriteDiff_ControlReg;

    Run <= WReg_Run;
    Action <= WReg_Action;

    -- .......... StatusReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_StatusReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_StatusReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_StatusReg) ) then 
            WriteDiff_StatusReg <=  We and Stb and Cyc(0) and not PreMuxAck_StatusReg;
        else
            WriteDiff_StatusReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_StatusReg) ) then 
            ReadDiff_StatusReg <= not We and Stb and Cyc(0) and not PreMuxAck_StatusReg;
        else
            ReadDiff_StatusReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_StatusReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_StatusReg <= '0';
        elsif rising_edge(Clk) then
            PreMuxAck_StatusReg <= WriteDiff_StatusReg or ReadDiff_StatusReg; 
        end if;
    end process;

    mux_premuxdatout_StatusReg0 : process (
            Busy
            )
    begin 
         PreMuxDatOut_StatusReg <= x"0000_0000";
         PreMuxDatOut_StatusReg(0) <= Busy;
    end process;





    -- .......... SizeReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_SizeReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_SizeReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_SizeReg) ) then 
            WriteDiff_SizeReg <=  We and Stb and Cyc(0) and not PreMuxAck_SizeReg;
        else
            WriteDiff_SizeReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_SizeReg) ) then 
            ReadDiff_SizeReg <= not We and Stb and Cyc(0) and not PreMuxAck_SizeReg;
        else
            ReadDiff_SizeReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_SizeReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_SizeReg <= '0';
        elsif rising_edge(Clk) then
            PreMuxAck_SizeReg <= WriteDiff_SizeReg or ReadDiff_SizeReg; 
        end if;
    end process;

    mux_premuxdatout_SizeReg0 : process (
            SizeValue
            )
    begin 
         PreMuxDatOut_SizeReg <= x"0000_0000";
         PreMuxDatOut_SizeReg(31 downto 0) <= SizeValue;
    end process;





    -- .......... HighValueReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_HighValueReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_HighValueReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_HighValueReg) ) then 
            WriteDiff_HighValueReg <=  We and Stb and Cyc(0) and not PreMuxAck_HighValueReg;
        else
            WriteDiff_HighValueReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_HighValueReg) ) then 
            ReadDiff_HighValueReg <= not We and Stb and Cyc(0) and not PreMuxAck_HighValueReg;
        else
            ReadDiff_HighValueReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_HighValueReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_HighValueReg <= '0';
            WReg_HighValue_Written <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
            PreMuxAck_HighValueReg <= WriteDiff_HighValueReg or ReadDiff_HighValueReg; 
            if (WriteDiff_HighValueReg = '1') then
                if (Sel(3) = '1') then WReg_HighValue_Written(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_HighValue_Written(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_HighValue_Written(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_HighValue_Written(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_HighValueReg0 : process (
            HighValue_ToBeRead
            )
    begin 
         PreMuxDatOut_HighValueReg <= x"0000_0000";
         PreMuxDatOut_HighValueReg(31 downto 0) <= HighValue_ToBeRead;
    end process;




    HighValue_Written <= WReg_HighValue_Written;

    -- .......... LowValueReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_LowValueReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_LowValueReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_LowValueReg) ) then 
            WriteDiff_LowValueReg <=  We and Stb and Cyc(0) and not PreMuxAck_LowValueReg;
        else
            WriteDiff_LowValueReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_LowValueReg) ) then 
            ReadDiff_LowValueReg <= not We and Stb and Cyc(0) and not PreMuxAck_LowValueReg;
        else
            ReadDiff_LowValueReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_LowValueReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_LowValueReg <= '0';
            WReg_LowValue_Written <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
            PreMuxAck_LowValueReg <= WriteDiff_LowValueReg or ReadDiff_LowValueReg; 
            if (WriteDiff_LowValueReg = '1') then
                if (Sel(3) = '1') then WReg_LowValue_Written(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_LowValue_Written(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_LowValue_Written(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_LowValue_Written(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_LowValueReg0 : process (
            LowValue_ToBeRead
            )
    begin 
         PreMuxDatOut_LowValueReg <= x"0000_0000";
         PreMuxDatOut_LowValueReg(31 downto 0) <= LowValue_ToBeRead;
    end process;




    LowValue_Written <= WReg_LowValue_Written;

    -- .......... TypeReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_TypeReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_TypeReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_TypeReg) ) then 
            WriteDiff_TypeReg <=  We and Stb and Cyc(0) and not PreMuxAck_TypeReg;
        else
            WriteDiff_TypeReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_TypeReg) ) then 
            ReadDiff_TypeReg <= not We and Stb and Cyc(0) and not PreMuxAck_TypeReg;
        else
            ReadDiff_TypeReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_TypeReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_TypeReg <= '0';
            WReg_Type_Written <= "000";
        elsif rising_edge(Clk) then
            PreMuxAck_TypeReg <= WriteDiff_TypeReg or ReadDiff_TypeReg; 
            if (WriteDiff_TypeReg = '1') then
                if (Sel(0) = '1') then WReg_Type_Written(2 downto 0) <= DatIn(2 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_TypeReg0 : process (
            Type_ToBeRead
            )
    begin 
         PreMuxDatOut_TypeReg <= x"0000_0000";
         PreMuxDatOut_TypeReg(2 downto 0) <= Type_ToBeRead;
    end process;




    Type_Written <= WReg_Type_Written;

    -- .......... LocalIndexReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_LocalIndexReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_LocalIndexReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_LocalIndexReg) ) then 
            WriteDiff_LocalIndexReg <=  We and Stb and Cyc(0) and not PreMuxAck_LocalIndexReg;
        else
            WriteDiff_LocalIndexReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_LocalIndexReg) ) then 
            ReadDiff_LocalIndexReg <= not We and Stb and Cyc(0) and not PreMuxAck_LocalIndexReg;
        else
            ReadDiff_LocalIndexReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_LocalIndexReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_LocalIndexReg <= '0';
            WReg_LocalIndex <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
            PreMuxAck_LocalIndexReg <= WriteDiff_LocalIndexReg or ReadDiff_LocalIndexReg; 
            if (WriteDiff_LocalIndexReg = '1') then
                if (Sel(3) = '1') then WReg_LocalIndex(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_LocalIndex(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_LocalIndex(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_LocalIndex(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_LocalIndexReg0 : process (
            WReg_LocalIndex
            )
    begin 
         PreMuxDatOut_LocalIndexReg <= x"0000_0000";
         PreMuxDatOut_LocalIndexReg(31 downto 0) <= WReg_LocalIndex;
    end process;




    LocalIndex <= WReg_LocalIndex;

    -- .......... StackAddressReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_StackAddressReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_StackAddressReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_StackAddressReg) ) then 
            WriteDiff_StackAddressReg <=  We and Stb and Cyc(0) and not PreMuxAck_StackAddressReg;
        else
            WriteDiff_StackAddressReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_StackAddressReg) ) then 
            ReadDiff_StackAddressReg <= not We and Stb and Cyc(0) and not PreMuxAck_StackAddressReg;
        else
            ReadDiff_StackAddressReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_StackAddressReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
             DelWriteDiff_StackAddressReg <= '0'; 
            PreMuxAck_StackAddressReg <= '0';
            WReg_StackAddress_Written <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
             DelWriteDiff_StackAddressReg <= WriteDiff_StackAddressReg;
            PreMuxAck_StackAddressReg <= WriteDiff_StackAddressReg or ReadDiff_StackAddressReg; 
            if (WriteDiff_StackAddressReg = '1') then
                if (Sel(3) = '1') then WReg_StackAddress_Written(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_StackAddress_Written(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_StackAddress_Written(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_StackAddress_Written(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_StackAddressReg0 : process (
            StackAddress_ToBeRead
            )
    begin 
         PreMuxDatOut_StackAddressReg <= x"0000_0000";
         PreMuxDatOut_StackAddressReg(31 downto 0) <= StackAddress_ToBeRead;
    end process;



    WRegPulse_StackAddressReg <= DelWriteDiff_StackAddressReg;

    StackAddress_Written <= WReg_StackAddress_Written;

    -- .......... MaxLocalsReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_MaxLocalsReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_MaxLocalsReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_MaxLocalsReg) ) then 
            WriteDiff_MaxLocalsReg <=  We and Stb and Cyc(0) and not PreMuxAck_MaxLocalsReg;
        else
            WriteDiff_MaxLocalsReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_MaxLocalsReg) ) then 
            ReadDiff_MaxLocalsReg <= not We and Stb and Cyc(0) and not PreMuxAck_MaxLocalsReg;
        else
            ReadDiff_MaxLocalsReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_MaxLocalsReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_MaxLocalsReg <= '0';
            WReg_MaxLocals <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
            PreMuxAck_MaxLocalsReg <= WriteDiff_MaxLocalsReg or ReadDiff_MaxLocalsReg; 
            if (WriteDiff_MaxLocalsReg = '1') then
                if (Sel(3) = '1') then WReg_MaxLocals(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_MaxLocals(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_MaxLocals(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_MaxLocals(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_MaxLocalsReg0 : process (
            WReg_MaxLocals
            )
    begin 
         PreMuxDatOut_MaxLocalsReg <= x"0000_0000";
         PreMuxDatOut_MaxLocalsReg(31 downto 0) <= WReg_MaxLocals;
    end process;




    MaxLocals <= WReg_MaxLocals;

    -- .......... MaxResultsReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_MaxResultsReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_MaxResultsReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_MaxResultsReg) ) then 
            WriteDiff_MaxResultsReg <=  We and Stb and Cyc(0) and not PreMuxAck_MaxResultsReg;
        else
            WriteDiff_MaxResultsReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_MaxResultsReg) ) then 
            ReadDiff_MaxResultsReg <= not We and Stb and Cyc(0) and not PreMuxAck_MaxResultsReg;
        else
            ReadDiff_MaxResultsReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_MaxResultsReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_MaxResultsReg <= '0';
            WReg_MaxResults <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
            PreMuxAck_MaxResultsReg <= WriteDiff_MaxResultsReg or ReadDiff_MaxResultsReg; 
            if (WriteDiff_MaxResultsReg = '1') then
                if (Sel(3) = '1') then WReg_MaxResults(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_MaxResults(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_MaxResults(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_MaxResults(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_MaxResultsReg0 : process (
            WReg_MaxResults
            )
    begin 
         PreMuxDatOut_MaxResultsReg <= x"0000_0000";
         PreMuxDatOut_MaxResultsReg(31 downto 0) <= WReg_MaxResults;
    end process;




    MaxResults <= WReg_MaxResults;

    -- .......... ReturnAddressReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_ReturnAddressReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_ReturnAddressReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_ReturnAddressReg) ) then 
            WriteDiff_ReturnAddressReg <=  We and Stb and Cyc(0) and not PreMuxAck_ReturnAddressReg;
        else
            WriteDiff_ReturnAddressReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_ReturnAddressReg) ) then 
            ReadDiff_ReturnAddressReg <= not We and Stb and Cyc(0) and not PreMuxAck_ReturnAddressReg;
        else
            ReadDiff_ReturnAddressReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_ReturnAddressReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_ReturnAddressReg <= '0';
            WReg_ReturnAddress <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
            PreMuxAck_ReturnAddressReg <= WriteDiff_ReturnAddressReg or ReadDiff_ReturnAddressReg; 
            if (WriteDiff_ReturnAddressReg = '1') then
                if (Sel(3) = '1') then WReg_ReturnAddress(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_ReturnAddress(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_ReturnAddress(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_ReturnAddress(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_ReturnAddressReg0 : process (
            WReg_ReturnAddress
            )
    begin 
         PreMuxDatOut_ReturnAddressReg <= x"0000_0000";
         PreMuxDatOut_ReturnAddressReg(31 downto 0) <= WReg_ReturnAddress;
    end process;




    ReturnAddress <= WReg_ReturnAddress;

    -- .......... ModuleInstanceUidReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_ModuleInstanceUidReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_ModuleInstanceUidReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_ModuleInstanceUidReg) ) then 
            WriteDiff_ModuleInstanceUidReg <=  We and Stb and Cyc(0) and not PreMuxAck_ModuleInstanceUidReg;
        else
            WriteDiff_ModuleInstanceUidReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTACK_ADR_ModuleInstanceUidReg) ) then 
            ReadDiff_ModuleInstanceUidReg <= not We and Stb and Cyc(0) and not PreMuxAck_ModuleInstanceUidReg;
        else
            ReadDiff_ModuleInstanceUidReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_ModuleInstanceUidReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_ModuleInstanceUidReg <= '0';
            WReg_ModuleInstanceUid <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
            PreMuxAck_ModuleInstanceUidReg <= WriteDiff_ModuleInstanceUidReg or ReadDiff_ModuleInstanceUidReg; 
            if (WriteDiff_ModuleInstanceUidReg = '1') then
                if (Sel(3) = '1') then WReg_ModuleInstanceUid(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_ModuleInstanceUid(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_ModuleInstanceUid(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_ModuleInstanceUid(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_ModuleInstanceUidReg0 : process (
            WReg_ModuleInstanceUid
            )
    begin 
         PreMuxDatOut_ModuleInstanceUidReg <= x"0000_0000";
         PreMuxDatOut_ModuleInstanceUidReg(31 downto 0) <= WReg_ModuleInstanceUid;
    end process;




    ModuleInstanceUid <= WReg_ModuleInstanceUid;


end architecture;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaStackWshBn_Package.all;

-- ========== Wishbone for WasmFpgaStack (WasmFpgaStackWishbone) ========== 

entity WasmFpgaStackWshBn is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        WasmFpgaStackWshBnDn : in T_WasmFpgaStackWshBnDn;
        WasmFpgaStackWshBnUp : out T_WasmFpgaStackWshBnUp;
        WasmFpgaStackWshBn_UnOccpdRcrd : out T_WasmFpgaStackWshBn_UnOccpdRcrd;
        WasmFpgaStackWshBn_StackBlk : out T_WasmFpgaStackWshBn_StackBlk;
        StackBlk_WasmFpgaStackWshBn : in T_StackBlk_WasmFpgaStackWshBn
     );
end WasmFpgaStackWshBn;



architecture arch_for_synthesys of WasmFpgaStackWshBn is

    component StackBlk_WasmFpgaStack is
        port (
            Clk : in std_logic;
            Rst : in std_logic;
            Adr : in std_logic_vector(23 downto 0);
            Sel : in std_logic_vector(3 downto 0);
            DatIn : in std_logic_vector(31 downto 0);
            We : in std_logic;
            Stb : in std_logic;
            Cyc : in  std_logic_vector(0 downto 0);
            StackBlk_DatOut : out std_logic_vector(31 downto 0);
            StackBlk_Ack : out std_logic;
            StackBlk_Unoccupied_Ack : out std_logic;
            Run : out std_logic;
            Action : out std_logic_vector(2 downto 0);
            WRegPulse_ControlReg : out std_logic;
            Busy : in std_logic;
            SizeValue : in std_logic_vector(31 downto 0);
            HighValue_ToBeRead : in std_logic_vector(31 downto 0);
            HighValue_Written : out std_logic_vector(31 downto 0);
            LowValue_ToBeRead : in std_logic_vector(31 downto 0);
            LowValue_Written : out std_logic_vector(31 downto 0);
            Type_ToBeRead : in std_logic_vector(2 downto 0);
            Type_Written : out std_logic_vector(2 downto 0);
            LocalIndex : out std_logic_vector(31 downto 0);
            StackAddress_ToBeRead : in std_logic_vector(31 downto 0);
            StackAddress_Written : out std_logic_vector(31 downto 0);
            WRegPulse_StackAddressReg : out std_logic;
            MaxLocals : out std_logic_vector(31 downto 0);
            MaxResults : out std_logic_vector(31 downto 0);
            ReturnAddress : out std_logic_vector(31 downto 0);
            ModuleInstanceUid : out std_logic_vector(31 downto 0)
         );
    end component; 


    -- ---------- internal wires ----------

    signal Sel : std_logic_vector(3 downto 0);
    signal StackBlk_DatOut : std_logic_vector(31 downto 0);
    signal StackBlk_Ack : std_logic;
    signal StackBlk_Unoccupied_Ack : std_logic;


begin 


    -- ---------- Connect register instances ----------

    i_StackBlk_WasmFpgaStack :  StackBlk_WasmFpgaStack
     port map (
        Clk => Clk,
        Rst => Rst,
        Adr => WasmFpgaStackWshBnDn.Adr,
        Sel => Sel,
        DatIn => WasmFpgaStackWshBnDn.DatIn,
        We =>  WasmFpgaStackWshBnDn.We,
        Stb => WasmFpgaStackWshBnDn.Stb,
        Cyc => WasmFpgaStackWshBnDn.Cyc,
        StackBlk_DatOut => StackBlk_DatOut,
        StackBlk_Ack => StackBlk_Ack,
        StackBlk_Unoccupied_Ack => StackBlk_Unoccupied_Ack,
        Run => WasmFpgaStackWshBn_StackBlk.Run,
        Action => WasmFpgaStackWshBn_StackBlk.Action,
        WRegPulse_ControlReg => WasmFpgaStackWshBn_StackBlk.WRegPulse_ControlReg,
        Busy => StackBlk_WasmFpgaStackWshBn.Busy,
        SizeValue => StackBlk_WasmFpgaStackWshBn.SizeValue,
        HighValue_ToBeRead => StackBlk_WasmFpgaStackWshBn.HighValue_ToBeRead,
        HighValue_Written => WasmFpgaStackWshBn_StackBlk.HighValue_Written,
        LowValue_ToBeRead => StackBlk_WasmFpgaStackWshBn.LowValue_ToBeRead,
        LowValue_Written => WasmFpgaStackWshBn_StackBlk.LowValue_Written,
        Type_ToBeRead => StackBlk_WasmFpgaStackWshBn.Type_ToBeRead,
        Type_Written => WasmFpgaStackWshBn_StackBlk.Type_Written,
        LocalIndex => WasmFpgaStackWshBn_StackBlk.LocalIndex,
        StackAddress_ToBeRead => StackBlk_WasmFpgaStackWshBn.StackAddress_ToBeRead,
        StackAddress_Written => WasmFpgaStackWshBn_StackBlk.StackAddress_Written,
        WRegPulse_StackAddressReg => WasmFpgaStackWshBn_StackBlk.WRegPulse_StackAddressReg,
        MaxLocals => WasmFpgaStackWshBn_StackBlk.MaxLocals,
        MaxResults => WasmFpgaStackWshBn_StackBlk.MaxResults,
        ReturnAddress => WasmFpgaStackWshBn_StackBlk.ReturnAddress,
        ModuleInstanceUid => WasmFpgaStackWshBn_StackBlk.ModuleInstanceUid
     );


    Sel <= WasmFpgaStackWshBnDn.Sel;                                                      

    WasmFpgaStackWshBn_UnOccpdRcrd.forRecord_Adr <= WasmFpgaStackWshBnDn.Adr;
    WasmFpgaStackWshBn_UnOccpdRcrd.forRecord_Sel <= Sel;
    WasmFpgaStackWshBn_UnOccpdRcrd.forRecord_We <= WasmFpgaStackWshBnDn.We;
    WasmFpgaStackWshBn_UnOccpdRcrd.forRecord_Cyc <= WasmFpgaStackWshBnDn.Cyc;

    -- ---------- Or all DataOuts and Acks of blocks ----------

     WasmFpgaStackWshBnUp.DatOut <= 
        StackBlk_DatOut;

     WasmFpgaStackWshBnUp.Ack <= 
        StackBlk_Ack;

     WasmFpgaStackWshBn_UnOccpdRcrd.Unoccupied_Ack <= 
        StackBlk_Unoccupied_Ack;





end architecture;



