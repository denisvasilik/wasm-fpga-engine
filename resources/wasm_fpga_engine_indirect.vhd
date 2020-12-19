

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaEngineWshBn_Package.all;

entity tb_WasmFpgaEngineWshBn is
end tb_WasmFpgaEngineWshBn;

architecture arch_for_test of tb_WasmFpgaEngineWshBn is

    component tbs_WshFileIo is              
    generic (                               
         inp_file  : string;                
         outp_file : string                 
        );                                  
    port(                                   
        clock        : in    std_logic;     
        reset        : in    std_logic;     
        WshDn        : out   T_WshDn;       
        WshUp        : in    T_WshUp        
        );                                  
    end component;                          



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


    signal Clk : std_logic := '0';                                         
    signal Rst : std_logic := '1';                                         



    signal WshDn : T_WshDn;
    signal WshUp : T_WshUp;
    signal Wsh_UnOccpdRcrd : T_Wsh_UnOccpdRcrd;
    signal Wsh_EngineBlk : T_Wsh_EngineBlk;
    signal EngineBlk_Wsh : T_EngineBlk_Wsh;



begin 


    i_tbs_WshFileIo : tbs_WshFileIo            
    generic map (                              
        inp_file  => "tb_mC_stimuli.txt",      
        outp_file => "src/tb_mC_trace.txt")    
    port map (                                 
        clock   => Clk,                        
        reset   => Rst,                        
        WshDn   => WshDn,                      
        WshUp   => WshUp                       
    );                                         



    -- ---------- map wishbone component ---------- 

    i_WasmFpgaEngineWshBn :  WasmFpgaEngineWshBn
     port map (
        WshDn => WshDn,
        WshUp => WshUp,
        Wsh_UnOccpdRcrd => Wsh_UnOccpdRcrd,
        Wsh_EngineBlk => Wsh_EngineBlk,
        EngineBlk_Wsh => EngineBlk_Wsh
        );

    -- ---------- assign defaults to all wishbone inputs ---------- 

    -- ------------------- general additional signals ------------------- 

    -- ------------------- EngineBlk ------------------- 
    -- ControlReg  
    -- StatusReg  
    EngineBlk_Wsh.Trap <= '0';
    EngineBlk_Wsh.Busy <= '0';



    WshDn.Clk <= Clk;                                                  
    WshDn.Rst <= Rst;                                                  
    -- ---------- drive testbench time --------------------                       
    Clk   <= TRANSPORT NOT Clk AFTER 12500 ps;  -- 40Mhz                       
    Rst   <= TRANSPORT '0' AFTER 100 ns;                                       


end architecture;

