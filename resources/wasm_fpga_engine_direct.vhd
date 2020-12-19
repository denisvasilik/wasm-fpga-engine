

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library work;
use work.WasmFpgaEngineWshBn_Package.all;

entity tb_WshBnWasmFpgaEngine_Top is
generic (                                                                
       stimulus_file: string := "src_hdl_tb/stimuli_FileIo/init.stm"  
      );                                                                 
end tb_WshBnWasmFpgaEngine_Top;

architecture arch_for_test of tb_WshBnWasmFpgaEngine_Top is

    component tb_WshBn_FileIo is                                                      
        generic (                                                                     
         		stimulus_file: string;                                                 
                tb_clk_freq_period_half : time;                                       
                tb_num_dflt_clk_ack_timeout : natural;                                
                tb_address_width : natural;                                           
                tb_cyc_width : natural                                                
        );                                                                            
        port (                                                                        
            WshBnRst     : in   std_logic;                                            
            WshBnClk     : in   std_logic;                                            
            WshBnAdr     : out   std_logic_vector(tb_address_width-1 downto 0);       
            WshBnSel     : out   std_logic_vector(3 downto 0);                        
            WshBnDatIn   : out   std_logic_vector(31 downto 0);                       
            WshBnWe      : out   std_logic;                                           
            WshBnStb     : out   std_logic;                                           
            WshBnCyc     : out   std_logic_vector(tb_cyc_width-1 downto 0);           
            WshBnDatOut  : in    std_logic_vector(31 downto 0);                       
            WshBnAck     : in    std_logic                                            
        );                                                                            
    end component;                                                                    
                                                                                      
    component tb_WshBnClkRstGen is                                                    
       generic (                                                                      
            OscPeriod : time;                                                         
            NumOfClksRstInitialActive : natural                                       
        );                                                                            
       port (                                                                         
            Rst : out std_logic;                                                      
            Clk : out std_logic                                                       
       );                                                                             
    end component;                                                                    
                                                                                      
    constant tb_clk_freq_period_half : time := 5 ns;                                  
    constant tb_num_dflt_clk_ack_timeout : natural := 16;                             
    constant tb_address_width : natural := 24; 
    constant tb_cyc_width : natural := 1; 
                                                                                      
    signal Rst          : std_logic := '0';                                                  
    signal Clk          : std_logic := '0';                                                  
    signal WshBnAdr     : std_logic_vector(tb_address_width-1 downto 0);              
    signal WshBnDatIn   : std_logic_vector(31 downto 0);                              
    signal WshBnWe      : std_logic;                                                  
    signal WshBnStb     : std_logic;                                                  
    signal WshBnCyc     : std_logic_vector(tb_cyc_width-1 downto 0);                  
    signal WshBnDatOut  : std_logic_vector(31 downto 0);                              
    signal WshBnAck     : std_logic;                                                  


    component WasmFpgaEngineWshBn is
        port (
            Clk : in std_logic;
            Rst : in std_logic;
            WasmFpgaEngineWshBnDn : in T_WasmFpgaEngineWshBnDn;
            WasmFpgaEngineWshBnUp : out T_WasmFpgaEngineWshBnUp;
            WasmFpgaEngineWshBn_UnOccpdRcrd : out T_WasmFpgaEngineWshBn_UnOccpdRcrd;
            WasmFpgaEngineWshBn_EngineBlk : out T_WasmFpgaEngineWshBn_EngineBlk;
            EngineBlk_WasmFpgaEngineWshBn : in T_EngineBlk_WasmFpgaEngineWshBn
         );
    end component; 


    signal WshDn : T_WasmFpgaEngineWshBnDn;
    signal WshUp : T_WasmFpgaEngineWshBnUp;
    signal Wsh_UnOccpdRcrd : T_WasmFpgaEngineWshBn_UnOccpdRcrd;
    signal Wsh_EngineBlk : T_WasmFpgaEngineWshBn_EngineBlk;
    signal EngineBlk_Wsh : T_EngineBlk_WasmFpgaEngineWshBn;



begin 


    -- connect wishbone to testbench                                       
    WshDn.Adr   <=  WshBnAdr  ;                                         
    WshDn.DatIn <=  WshBnDatIn;                                         
    WshDn.We    <=  WshBnWe   ;                                         
    WshDn.Stb   <=  WshBnStb  ;                                         
    WshDn.Cyc        <= WshBnCyc;     
    WshBnDatOut  <= WshUp.DatOut;                                       
    WshBnAck     <= WshUp.Ack   ;                                       
                                                                           
    -- ---------- map clock and reset generator component ----------       
    i_tb_WshBnClkRstGen : tb_WshBnClkRstGen                                
    generic map(                                                           
        OscPeriod => tb_clk_freq_period_half * 2,                          
        NumOfClksRstInitialActive => 16                                    
    )                                                                      
    port map (                                                             
        Rst => Rst,                                                        
        Clk => Clk                                                         
    );                                                                     
                                                                           
    -- ---------- map wishbone fileio component ----------                 
    i_tb_WshBn_FileIo : tb_WshBn_FileIo                                    
    generic map(                                                           
    	stimulus_file => stimulus_file,                                      
        tb_clk_freq_period_half => tb_clk_freq_period_half,                
        tb_num_dflt_clk_ack_timeout => tb_num_dflt_clk_ack_timeout,        
        tb_address_width => tb_address_width,                              
        tb_cyc_width => tb_cyc_width                                       
    )                                                                      
    port map (                                                             
        WshBnRst        => Rst,                                            
        WshBnClk        => Clk,                                            
        WshBnAdr        => WshBnAdr,                                       
        WshBnDatIn      => WshBnDatIn,                                     
        WshBnWe         => WshBnWe,                                        
        WshBnStb        => WshBnStb,                                       
        WshBnCyc        => WshBnCyc,                                       
        WshBnDatOut     => WshBnDatOut,                                    
        WshBnAck        => WshBnAck                                        
    );                                                                     
                                                                           
    -- ---------- map wishbone component ----------                        


    -- ---------- map wishbone component ---------- 

    i_WasmFpgaEngineWshBn :  WasmFpgaEngineWshBn
     port map (
        Rst => Rst,
        Clk => Clk,
        WasmFpgaEngineWshBnDn => WshDn,
        WasmFpgaEngineWshBnUp => WshUp,
        WasmFpgaEngineWshBN_UnOccpdRcrd => Wsh_UnOccpdRcrd,
        WasmFpgaEngineWshBn_EngineBlk => Wsh_EngineBlk,
        EngineBlk_WasmFpgaEngineWshBn => EngineBlk_Wsh
        );

    -- ---------- assign defaults to all wishbone inputs ---------- 

    -- ------------------- general additional signals ------------------- 

    -- ------------------- EngineBlk ------------------- 
    -- ControlReg  
    -- StatusReg  
    EngineBlk_Wsh.Trap <= '0';
    EngineBlk_Wsh.Busy <= '0';



end architecture;

