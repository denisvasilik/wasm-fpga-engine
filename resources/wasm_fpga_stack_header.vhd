


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



package WasmFpgaStackWshBn_Package is


-- type decalarations ---------------------------------                    

    type WasmFpgaStack_arr_of_std_logic_vector_2_t is                                        
      array (natural range <>) of std_logic_vector(1 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_3_t is                                        
      array (natural range <>) of std_logic_vector(1 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_4_t is                                        
      array (natural range <>) of std_logic_vector(3 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_5_t is                                        
      array (natural range <>) of std_logic_vector(4 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_6_t is                                        
      array (natural range <>) of std_logic_vector(5 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_7_t is                                        
      array (natural range <>) of std_logic_vector(6 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_8_t is                                        
      array (natural range <>) of std_logic_vector(7 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_9_t is                                        
      array (natural range <>) of std_logic_vector(8 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_10_t is                                    
      array (natural range <>) of std_logic_vector(9 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_11_t is                                    
      array (natural range <>) of std_logic_vector(10 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_12_t is                                    
      array (natural range <>) of std_logic_vector(11 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_13_t is                                    
      array (natural range <>) of std_logic_vector(12 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_14_t is                                    
      array (natural range <>) of std_logic_vector(13 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_15_t is                                    
      array (natural range <>) of std_logic_vector(14 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_16_t is                                    
      array (natural range <>) of std_logic_vector(15 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_24_t is                                    
      array (natural range <>) of std_logic_vector(23 downto 0);     

    type WasmFpgaStack_arr_of_std_logic_vector_32_t is                                    
      array (natural range <>) of std_logic_vector(31 downto 0);    


    type T_WasmFpgaStackWshBnDn is
    record
        Adr :   std_logic_vector(23 downto 0);
        Sel :   std_logic_vector(3 downto 0);
        DatIn :   std_logic_vector(31 downto 0);
        We :   std_logic;
        Stb :   std_logic;
        Cyc :   std_logic_vector(0 downto 0);
    end record;

    type array_of_T_WasmFpgaStackWshBnDn is
      array (natural range <>) of T_WasmFpgaStackWshBnDn;


    type T_WasmFpgaStackWshBnUp is
    record
        DatOut :   std_logic_vector(31 downto 0);
        Ack :   std_logic;
    end record;

    type array_of_T_WasmFpgaStackWshBnUp is
      array (natural range <>) of T_WasmFpgaStackWshBnUp;

    type T_WasmFpgaStackWshBn_UnOccpdRcrd is
    record
        forRecord_Adr :   std_logic_vector(23 downto 0);
        forRecord_Sel :   std_logic_vector(3 downto 0);
        forRecord_We :   std_logic;
        forRecord_Cyc :   std_logic_vector(0 downto 0);
        Unoccupied_Ack :   std_logic;
    end record;

    type array_of_T_WasmFpgaStackWshBn_UnOccpdRcrd is
      array (natural range <>) of T_WasmFpgaStackWshBn_UnOccpdRcrd;

    type T_WasmFpgaStackWshBn_StackBlk is
    record
        Run :   std_logic;
        Action :   std_logic_vector(1 downto 0);
        WRegPulse_ControlReg :   std_logic;
        HighValue_Written :   std_logic_vector(31 downto 0);
        LowValue_Written :   std_logic_vector(31 downto 0);
        Type_Written :   std_logic_vector(2 downto 0);
        LocalIndex :   std_logic_vector(31 downto 0);
        StackAddress_Written :   std_logic_vector(31 downto 0);
        WRegPulse_StackAddressReg :   std_logic;
    end record;

    type array_of_T_WasmFpgaStackWshBn_StackBlk is
      array (natural range <>) of T_WasmFpgaStackWshBn_StackBlk;


    type T_StackBlk_WasmFpgaStackWshBn is
    record
        Busy :   std_logic;
        SizeValue :   std_logic_vector(31 downto 0);
        HighValue_ToBeRead :   std_logic_vector(31 downto 0);
        LowValue_ToBeRead :   std_logic_vector(31 downto 0);
        Type_ToBeRead :   std_logic_vector(2 downto 0);
        StackAddress_ToBeRead :   std_logic_vector(31 downto 0);
    end record;

    type array_of_T_StackBlk_WasmFpgaStackWshBn is
      array (natural range <>) of T_StackBlk_WasmFpgaStackWshBn;




    -- ---------- WebAssembly Stack Block( StackBlk ) ----------
    -- BUS: 

    constant WASMFPGASTACK_ADR_BLK_BASE_StackBlk                                                     : std_logic_vector(23 downto 0) := x"000000";
    constant WASMFPGASTACK_ADR_BLK_SIZE_StackBlk                                                     : std_logic_vector(23 downto 0) := x"000020";

        -- ControlReg: Control Register 
        constant WASMFPGASTACK_WIDTH_ControlReg                                                      : integer := 32;
        constant WASMFPGASTACK_ADR_ControlReg                                                        : std_logic_vector(23 downto 0) := std_logic_vector(x"000000" + unsigned(WASMFPGASTACK_ADR_BLK_BASE_StackBlk));

            -- 
            constant WASMFPGASTACK_BUS_MASK_Run                                                      : std_logic_vector(31 downto 0) := x"00000004";

                -- Do nothing.
                constant WASMFPGASTACK_VAL_DoNotRun                                                  : std_logic := '0';
                -- Perform stack action.
                constant WASMFPGASTACK_VAL_DoRun                                                     : std_logic := '1';


            -- 
            constant WASMFPGASTACK_BUS_MASK_Action                                                   : std_logic_vector(31 downto 0) := x"00000003";

                -- Push a value onto the stack.
                constant WASMFPGASTACK_VAL_Push                                                      : std_logic_vector(1 downto 0) := b"00";
                -- Pop a value from the stack.
                constant WASMFPGASTACK_VAL_Pop                                                       : std_logic_vector(1 downto 0) := b"01";
                -- Get local of current activation frame.
                constant WASMFPGASTACK_VAL_LocalGet                                                  : std_logic_vector(1 downto 0) := b"10";
                -- Set local of current activation frame.
                constant WASMFPGASTACK_VAL_LocalSet                                                  : std_logic_vector(1 downto 0) := b"11";


        -- StatusReg: Status Register 
        constant WASMFPGASTACK_WIDTH_StatusReg                                                       : integer := 32;
        constant WASMFPGASTACK_ADR_StatusReg                                                         : std_logic_vector(23 downto 0) := std_logic_vector(x"000004" + unsigned(WASMFPGASTACK_ADR_BLK_BASE_StackBlk));

            -- 
            constant WASMFPGASTACK_BUS_MASK_Busy                                                     : std_logic_vector(31 downto 0) := x"00000001";

                -- Stack is idle.
                constant WASMFPGASTACK_VAL_IsNotBusy                                                 : std_logic := '0';
                -- Stack is busy.
                constant WASMFPGASTACK_VAL_IsBusy                                                    : std_logic := '1';


        -- SizeReg: Size Register 
        constant WASMFPGASTACK_WIDTH_SizeReg                                                         : integer := 32;
        constant WASMFPGASTACK_ADR_SizeReg                                                           : std_logic_vector(23 downto 0) := std_logic_vector(x"000008" + unsigned(WASMFPGASTACK_ADR_BLK_BASE_StackBlk));

            -- 

            constant WASMFPGASTACK_BUS_MASK_SizeValue                                                : std_logic_vector(31 downto 0) := x"FFFFFFFF";

        -- HighValueReg: High Value Register 
        constant WASMFPGASTACK_WIDTH_HighValueReg                                                    : integer := 32;
        constant WASMFPGASTACK_ADR_HighValueReg                                                      : std_logic_vector(23 downto 0) := std_logic_vector(x"00000C" + unsigned(WASMFPGASTACK_ADR_BLK_BASE_StackBlk));

            -- 

            constant WASMFPGASTACK_BUS_MASK_HighValue                                                : std_logic_vector(31 downto 0) := x"FFFFFFFF";

        -- LowValueReg: Low Value Register 
        constant WASMFPGASTACK_WIDTH_LowValueReg                                                     : integer := 32;
        constant WASMFPGASTACK_ADR_LowValueReg                                                       : std_logic_vector(23 downto 0) := std_logic_vector(x"000010" + unsigned(WASMFPGASTACK_ADR_BLK_BASE_StackBlk));

            -- 

            constant WASMFPGASTACK_BUS_MASK_LowValue                                                 : std_logic_vector(31 downto 0) := x"FFFFFFFF";

        -- TypeReg: Type Register 
        constant WASMFPGASTACK_WIDTH_TypeReg                                                         : integer := 32;
        constant WASMFPGASTACK_ADR_TypeReg                                                           : std_logic_vector(23 downto 0) := std_logic_vector(x"000014" + unsigned(WASMFPGASTACK_ADR_BLK_BASE_StackBlk));

            -- 
            constant WASMFPGASTACK_BUS_MASK_Type                                                     : std_logic_vector(31 downto 0) := x"00000007";

                -- 32 Bit Integer
                constant WASMFPGASTACK_VAL_i32                                                       : std_logic_vector(2 downto 0) := b"000";
                -- 64 Bit Integer
                constant WASMFPGASTACK_VAL_i64                                                       : std_logic_vector(2 downto 0) := b"001";
                -- 32 Bit Floating Point Data
                constant WASMFPGASTACK_VAL_f32                                                       : std_logic_vector(2 downto 0) := b"010";
                -- 64 Bit Floarting Point Data
                constant WASMFPGASTACK_VAL_f64                                                       : std_logic_vector(2 downto 0) := b"011";
                -- Structured Control Instructions
                constant WASMFPGASTACK_VAL_Label                                                     : std_logic_vector(2 downto 0) := b"100";
                -- Call Frame
                constant WASMFPGASTACK_VAL_Activation                                                : std_logic_vector(2 downto 0) := b"101";


        -- LocalIndexReg: Local Index Register 
        constant WASMFPGASTACK_WIDTH_LocalIndexReg                                                   : integer := 32;
        constant WASMFPGASTACK_ADR_LocalIndexReg                                                     : std_logic_vector(23 downto 0) := std_logic_vector(x"000018" + unsigned(WASMFPGASTACK_ADR_BLK_BASE_StackBlk));

            -- 

            constant WASMFPGASTACK_BUS_MASK_LocalIndex                                               : std_logic_vector(31 downto 0) := x"FFFFFFFF";

        -- StackAddressReg: Stack Address Register 
        constant WASMFPGASTACK_WIDTH_StackAddressReg                                                 : integer := 32;
        constant WASMFPGASTACK_ADR_StackAddressReg                                                   : std_logic_vector(23 downto 0) := std_logic_vector(x"00001C" + unsigned(WASMFPGASTACK_ADR_BLK_BASE_StackBlk));

            -- 

            constant WASMFPGASTACK_BUS_MASK_StackAddress                                             : std_logic_vector(31 downto 0) := x"FFFFFFFF";




end WasmFpgaStackWshBn_Package;
