


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



package WasmFpgaBusWshBn_Package is


-- type decalarations ---------------------------------                    

    type WasmFpgaBus_arr_of_std_logic_vector_2_t is                                        
      array (natural range <>) of std_logic_vector(1 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_3_t is                                        
      array (natural range <>) of std_logic_vector(1 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_4_t is                                        
      array (natural range <>) of std_logic_vector(3 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_5_t is                                        
      array (natural range <>) of std_logic_vector(4 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_6_t is                                        
      array (natural range <>) of std_logic_vector(5 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_7_t is                                        
      array (natural range <>) of std_logic_vector(6 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_8_t is                                        
      array (natural range <>) of std_logic_vector(7 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_9_t is                                        
      array (natural range <>) of std_logic_vector(8 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_10_t is                                    
      array (natural range <>) of std_logic_vector(9 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_11_t is                                    
      array (natural range <>) of std_logic_vector(10 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_12_t is                                    
      array (natural range <>) of std_logic_vector(11 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_13_t is                                    
      array (natural range <>) of std_logic_vector(12 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_14_t is                                    
      array (natural range <>) of std_logic_vector(13 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_15_t is                                    
      array (natural range <>) of std_logic_vector(14 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_16_t is                                    
      array (natural range <>) of std_logic_vector(15 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_24_t is                                    
      array (natural range <>) of std_logic_vector(23 downto 0);     

    type WasmFpgaBus_arr_of_std_logic_vector_32_t is                                    
      array (natural range <>) of std_logic_vector(31 downto 0);    


    type T_WasmFpgaBusWshBnDn is
    record
        Adr :   std_logic_vector(23 downto 0);
        Sel :   std_logic_vector(3 downto 0);
        DatIn :   std_logic_vector(31 downto 0);
        We :   std_logic;
        Stb :   std_logic;
        Cyc :   std_logic_vector(0 downto 0);
    end record;

    type array_of_T_WasmFpgaBusWshBnDn is
      array (natural range <>) of T_WasmFpgaBusWshBnDn;


    type T_WasmFpgaBusWshBnUp is
    record
        DatOut :   std_logic_vector(31 downto 0);
        Ack :   std_logic;
    end record;

    type array_of_T_WasmFpgaBusWshBnUp is
      array (natural range <>) of T_WasmFpgaBusWshBnUp;

    type T_WasmFpgaBusWshBn_UnOccpdRcrd is
    record
        forRecord_Adr :   std_logic_vector(23 downto 0);
        forRecord_Sel :   std_logic_vector(3 downto 0);
        forRecord_We :   std_logic;
        forRecord_Cyc :   std_logic_vector(0 downto 0);
        Unoccupied_Ack :   std_logic;
    end record;

    type array_of_T_WasmFpgaBusWshBn_UnOccpdRcrd is
      array (natural range <>) of T_WasmFpgaBusWshBn_UnOccpdRcrd;

    type T_WasmFpgaBusWshBn_BusBlk is
    record
        ModuleArea_Adr : std_logic_vector(23 downto 0);
        ModuleArea_Sel : std_logic_vector(3 downto 0);
        ModuleArea_We : std_logic;
        ModuleArea_Stb : std_logic;
        ModuleArea_DatOut : std_logic_vector(31 downto 0);
        ModuleArea_Cyc : std_logic;
        StackArea_Adr : std_logic_vector(23 downto 0);
        StackArea_Sel : std_logic_vector(3 downto 0);
        StackArea_We : std_logic;
        StackArea_Stb : std_logic;
        StackArea_DatOut : std_logic_vector(31 downto 0);
        StackArea_Cyc : std_logic;
        StoreArea_Adr : std_logic_vector(23 downto 0);
        StoreArea_Sel : std_logic_vector(3 downto 0);
        StoreArea_We : std_logic;
        StoreArea_Stb : std_logic;
        StoreArea_DatOut : std_logic_vector(31 downto 0);
        StoreArea_Cyc : std_logic;
        MemoryArea_Adr : std_logic_vector(23 downto 0);
        MemoryArea_Sel : std_logic_vector(3 downto 0);
        MemoryArea_We : std_logic;
        MemoryArea_Stb : std_logic;
        MemoryArea_DatOut : std_logic_vector(31 downto 0);
        MemoryArea_Cyc : std_logic;
    end record;

    type array_of_T_WasmFpgaBusWshBn_BusBlk is
      array (natural range <>) of T_WasmFpgaBusWshBn_BusBlk;


    type T_BusBlk_WasmFpgaBusWshBn is
    record
        ModuleArea_DatIn: std_logic_vector(31 downto 0);
        ModuleArea_Ack : std_logic;
        StackArea_DatIn: std_logic_vector(31 downto 0);
        StackArea_Ack : std_logic;
        StoreArea_DatIn: std_logic_vector(31 downto 0);
        StoreArea_Ack : std_logic;
        MemoryArea_DatIn: std_logic_vector(31 downto 0);
        MemoryArea_Ack : std_logic;
    end record;

    type array_of_T_BusBlk_WasmFpgaBusWshBn is
      array (natural range <>) of T_BusBlk_WasmFpgaBusWshBn;




    -- ---------- WebAssembly Bus Block( BusBlk ) ----------
    -- BUS: 

    constant WASMFPGABUS_ADR_BLK_BASE_BusBlk                                                         : std_logic_vector(23 downto 0) := x"000000";
    constant WASMFPGABUS_ADR_BLK_SIZE_BusBlk                                                         : std_logic_vector(23 downto 0) := x"020000";

        -- ModuleArea: WebAssembly Module 
        constant WASMFPGABUS_ADR_BASE_ModuleArea                                                     : std_logic_vector(23 downto 0) := std_logic_vector(x"000000" + unsigned(WASMFPGABUS_ADR_BLK_BASE_BusBlk));
        constant WASMFPGABUS_ADR_SIZE_ModuleArea                                                     : std_logic_vector(23 downto 0) := x"000100";

        -- StackArea: WebAssembly Stack 
        constant WASMFPGABUS_ADR_BASE_StackArea                                                      : std_logic_vector(23 downto 0) := std_logic_vector(x"000100" + unsigned(WASMFPGABUS_ADR_BLK_BASE_BusBlk));
        constant WASMFPGABUS_ADR_SIZE_StackArea                                                      : std_logic_vector(23 downto 0) := x"000100";

        -- StoreArea: WebAssembly Store 
        constant WASMFPGABUS_ADR_BASE_StoreArea                                                      : std_logic_vector(23 downto 0) := std_logic_vector(x"000200" + unsigned(WASMFPGABUS_ADR_BLK_BASE_BusBlk));
        constant WASMFPGABUS_ADR_SIZE_StoreArea                                                      : std_logic_vector(23 downto 0) := x"000100";

        -- MemoryArea: WebAssembly Memory Index 0 (1 Page) 
        constant WASMFPGABUS_ADR_BASE_MemoryArea                                                     : std_logic_vector(23 downto 0) := std_logic_vector(x"010000" + unsigned(WASMFPGABUS_ADR_BLK_BASE_BusBlk));
        constant WASMFPGABUS_ADR_SIZE_MemoryArea                                                     : std_logic_vector(23 downto 0) := x"010003";




end WasmFpgaBusWshBn_Package;
