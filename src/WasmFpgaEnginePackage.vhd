library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
  use work.WasmFpgaStackWshBn_Package.all;

package WasmFpgaEnginePackage is

    --
    -- Sections UIDs
    --
    constant SECTION_UID_TYPE : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"01";
    constant SECTION_UID_IMPORT : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"02";
    constant SECTION_UID_FUNCTION : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"03";
    constant SECTION_UID_TABLE : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"04";
    constant SECTION_UID_MEMORY : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"05";
    constant SECTION_UID_GLOBAL : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"06";
    constant SECTION_UID_EXPORT : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"07";
    constant SECTION_UID_START : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"08";
    constant SECTION_UID_ELEMENT : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"09";
    constant SECTION_UID_CODE : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"0A";
    constant SECTION_UID_DATA : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"0B";

    --
    -- WebAssembly Opcodes
    --
    constant WASM_NO_OPCODE : std_logic_vector(7 downto 0) := x"FF";

    constant WASM_OPCODE_UNREACHABLE : std_logic_vector(7 downto 0) := x"00";
    constant WASM_OPCODE_NOP : std_logic_vector(7 downto 0) := x"01";
    constant WASM_OPCODE_BLOCK : std_logic_vector(7 downto 0) := x"02";
    constant WASM_OPCODE_LOOP : std_logic_vector(7 downto 0) := x"03";
    constant WASM_OPCODE_IF : std_logic_vector(7 downto 0) := x"04";
    constant WASM_OPCODE_ELSE : std_logic_vector(7 downto 0) := x"05";
    constant WASM_OPCODE_END : std_logic_vector(7 downto 0) := x"0B";
    constant WASM_OPCODE_BR : std_logic_vector(7 downto 0) := x"0C";
    constant WASM_OPCODE_BR_IF : std_logic_vector(7 downto 0) := x"0D";
    constant WASM_OPCODE_BR_TABLE : std_logic_vector(7 downto 0) := x"0E";
    constant WASM_OPCODE_RETURN : std_logic_vector(7 downto 0) := x"0F";
    constant WASM_OPCODE_CALL : std_logic_vector(7 downto 0) := x"10";
    constant WASM_OPCODE_CALL_INDIRECT : std_logic_vector(7 downto 0) := x"11";
    constant WASM_OPCODE_DROP : std_logic_vector(7 downto 0) := x"1A";
    constant WASM_OPCODE_SELECT : std_logic_vector(7 downto 0) := x"1B";
    constant WASM_OPCODE_LOCAL_GET : std_logic_vector(7 downto 0) := x"20";
    constant WASM_OPCODE_LOCAL_SET : std_logic_vector(7 downto 0) := x"21";
    constant WASM_OPCODE_LOCAL_TEE : std_logic_vector(7 downto 0) := x"22";
    constant WASM_OPCODE_GLOBAL_GET : std_logic_vector(7 downto 0) := x"23";
    constant WASM_OPCODE_GLOBAL_SET : std_logic_vector(7 downto 0) := x"24";
    constant WASM_OPCODE_I32_LOAD : std_logic_vector(7 downto 0) := x"28";
    constant WASM_OPCODE_I64_LOAD : std_logic_vector(7 downto 0) := x"29";
    constant WASM_OPCODE_F32_LOAD : std_logic_vector(7 downto 0) := x"2A";
    constant WASM_OPCODE_F64_LOAD : std_logic_vector(7 downto 0) := x"2B";
    constant WASM_OPCODE_I32_LOAD8_S : std_logic_vector(7 downto 0) := x"2C";
    constant WASM_OPCODE_I32_LOAD8_U : std_logic_vector(7 downto 0) := x"2D";
    constant WASM_OPCODE_I32_LOAD16_S : std_logic_vector(7 downto 0) := x"2E";
    constant WASM_OPCODE_I32_LOAD16_U : std_logic_vector(7 downto 0) := x"2F";
    constant WASM_OPCODE_I64_LOAD8_S : std_logic_vector(7 downto 0) := x"30";
    constant WASM_OPCODE_I64_LOAD8_U : std_logic_vector(7 downto 0) := x"31";
    constant WASM_OPCODE_I64_LOAD16_S : std_logic_vector(7 downto 0) := x"32";
    constant WASM_OPCODE_I64_LOAD16_U : std_logic_vector(7 downto 0) := x"33";
    constant WASM_OPCODE_I64_LOAD32_S : std_logic_vector(7 downto 0) := x"34";
    constant WASM_OPCODE_I64_LOAD32_U : std_logic_vector(7 downto 0) := x"35";
    constant WASM_OPCODE_I32_STORE : std_logic_vector(7 downto 0) := x"36";
    constant WASM_OPCODE_I64_STORE : std_logic_vector(7 downto 0) := x"37";
    constant WASM_OPCODE_F32_STORE : std_logic_vector(7 downto 0) := x"38";
    constant WASM_OPCODE_F64_STORE : std_logic_vector(7 downto 0) := x"39";
    constant WASM_OPCODE_I32_STORE8 : std_logic_vector(7 downto 0) := x"3A";
    constant WASM_OPCODE_I32_STORE16 : std_logic_vector(7 downto 0) := x"3B";
    constant WASM_OPCODE_I64_STORE8 : std_logic_vector(7 downto 0) := x"3A";
    constant WASM_OPCODE_I64_STORE16 : std_logic_vector(7 downto 0) := x"3D";
    constant WASM_OPCODE_I64_STORE32 : std_logic_vector(7 downto 0) := x"3E";
    constant WASM_OPCODE_MEMORY_SIZE : std_logic_vector(7 downto 0) := x"3F";
    constant WASM_OPCODE_MEMORY_GROW : std_logic_vector(7 downto 0) := x"40";
    constant WASM_OPCODE_I32_CONST : std_logic_vector(7 downto 0) := x"41";
    constant WASM_OPCODE_I64_CONST : std_logic_vector(7 downto 0) := x"42";
    constant WASM_OPCODE_F32_CONST : std_logic_vector(7 downto 0) := x"43";
    constant WASM_OPCODE_F64_CONST : std_logic_vector(7 downto 0) := x"44";
    constant WASM_OPCODE_I32_EQZ : std_logic_vector(7 downto 0) := x"45";
    constant WASM_OPCODE_I32_EQ : std_logic_vector(7 downto 0) := x"46";
    constant WASM_OPCODE_I32_NE : std_logic_vector(7 downto 0) := x"47";
    constant WASM_OPCODE_I32_LT_S : std_logic_vector(7 downto 0) := x"48";
    constant WASM_OPCODE_I32_LT_U : std_logic_vector(7 downto 0) := x"49";
    constant WASM_OPCODE_I32_GT_S : std_logic_vector(7 downto 0) := x"4A";
    constant WASM_OPCODE_I32_GT_U : std_logic_vector(7 downto 0) := x"4B";
    constant WASM_OPCODE_I32_LE_S : std_logic_vector(7 downto 0) := x"4C";
    constant WASM_OPCODE_I32_LE_U : std_logic_vector(7 downto 0) := x"4D";
    constant WASM_OPCODE_I32_GE_S : std_logic_vector(7 downto 0) := x"4E";
    constant WASM_OPCODE_I32_GE_U : std_logic_vector(7 downto 0) := x"4F";
    constant WASM_OPCODE_I64_EQZ : std_logic_vector(7 downto 0) := x"50";
    constant WASM_OPCODE_I64_EQ : std_logic_vector(7 downto 0) := x"51";
    constant WASM_OPCODE_I64_NE : std_logic_vector(7 downto 0) := x"52";
    constant WASM_OPCODE_I64_LT_S : std_logic_vector(7 downto 0) := x"53";
    constant WASM_OPCODE_I64_LT_U : std_logic_vector(7 downto 0) := x"54";
    constant WASM_OPCODE_I64_GT_S : std_logic_vector(7 downto 0) := x"55";
    constant WASM_OPCODE_I64_GT_U : std_logic_vector(7 downto 0) := x"56";
    constant WASM_OPCODE_I64_LE_S : std_logic_vector(7 downto 0) := x"57";
    constant WASM_OPCODE_I64_LE_U : std_logic_vector(7 downto 0) := x"58";
    constant WASM_OPCODE_I64_GE_S : std_logic_vector(7 downto 0) := x"59";
    constant WASM_OPCODE_I64_GE_U : std_logic_vector(7 downto 0) := x"5A";
    constant WASM_OPCODE_F32_EQ : std_logic_vector(7 downto 0) := x"5B";
    constant WASM_OPCODE_F32_NE : std_logic_vector(7 downto 0) := x"5C";
    constant WASM_OPCODE_F32_LT : std_logic_vector(7 downto 0) := x"5D";
    constant WASM_OPCODE_F32_GT : std_logic_vector(7 downto 0) := x"5E";
    constant WASM_OPCODE_F32_LE : std_logic_vector(7 downto 0) := x"5F";
    constant WASM_OPCODE_F32_GE : std_logic_vector(7 downto 0) := x"60";
    constant WASM_OPCODE_F64_EQ : std_logic_vector(7 downto 0) := x"61";
    constant WASM_OPCODE_F64_NE : std_logic_vector(7 downto 0) := x"62";
    constant WASM_OPCODE_F64_LT : std_logic_vector(7 downto 0) := x"63";
    constant WASM_OPCODE_F64_GT : std_logic_vector(7 downto 0) := x"64";
    constant WASM_OPCODE_F64_LE : std_logic_vector(7 downto 0) := x"65";
    constant WASM_OPCODE_F64_GE : std_logic_vector(7 downto 0) := x"66";
    constant WASM_OPCODE_I32_CLZ : std_logic_vector(7 downto 0) := x"67";
    constant WASM_OPCODE_I32_CTZ : std_logic_vector(7 downto 0) := x"68";
    constant WASM_OPCODE_I32_POPCNT : std_logic_vector(7 downto 0) := x"69";
    constant WASM_OPCODE_I32_ADD : std_logic_vector(7 downto 0) := x"6A";
    constant WASM_OPCODE_I32_SUB : std_logic_vector(7 downto 0) := x"6B";
    constant WASM_OPCODE_I32_MUL : std_logic_vector(7 downto 0) := x"6C";
    constant WASM_OPCODE_I32_DIV_S : std_logic_vector(7 downto 0) := x"6D";
    constant WASM_OPCODE_I32_DIV_U : std_logic_vector(7 downto 0) := x"6E";
    constant WASM_OPCODE_I32_REM_S : std_logic_vector(7 downto 0) := x"6F";
    constant WASM_OPCODE_I32_REM_U : std_logic_vector(7 downto 0) := x"70";
    constant WASM_OPCODE_I32_AND : std_logic_vector(7 downto 0) := x"71";
    constant WASM_OPCODE_I32_OR : std_logic_vector(7 downto 0) := x"72";
    constant WASM_OPCODE_I32_XOR : std_logic_vector(7 downto 0) := x"73";
    constant WASM_OPCODE_I32_SHL : std_logic_vector(7 downto 0) := x"74";
    constant WASM_OPCODE_I32_SHR_S : std_logic_vector(7 downto 0) := x"75";
    constant WASM_OPCODE_I32_SHR_U : std_logic_vector(7 downto 0) := x"76";
    constant WASM_OPCODE_I32_ROTL : std_logic_vector(7 downto 0) := x"77";
    constant WASM_OPCODE_I32_ROTR : std_logic_vector(7 downto 0) := x"78";
    constant WASM_OPCODE_I64_CLZ : std_logic_vector(7 downto 0) := x"79";
    constant WASM_OPCODE_I64_CTZ : std_logic_vector(7 downto 0) := x"7A";
    constant WASM_OPCODE_I64_POPCNT : std_logic_vector(7 downto 0) := x"7B";
    constant WASM_OPCODE_I64_ADD : std_logic_vector(7 downto 0) := x"7C";
    constant WASM_OPCODE_I64_SUB : std_logic_vector(7 downto 0) := x"7D";
    constant WASM_OPCODE_I64_MUL : std_logic_vector(7 downto 0) := x"7E";
    constant WASM_OPCODE_I64_DIV_S : std_logic_vector(7 downto 0) := x"7F";
    constant WASM_OPCODE_I64_DIV_U : std_logic_vector(7 downto 0) := x"80";
    constant WASM_OPCODE_I64_REM_S : std_logic_vector(7 downto 0) := x"81";
    constant WASM_OPCODE_I64_REM_U : std_logic_vector(7 downto 0) := x"82";
    constant WASM_OPCODE_I64_AND : std_logic_vector(7 downto 0) := x"83";
    constant WASM_OPCODE_I64_OR : std_logic_vector(7 downto 0) := x"84";
    constant WASM_OPCODE_I64_XOR : std_logic_vector(7 downto 0) := x"85";
    constant WASM_OPCODE_I64_SHL : std_logic_vector(7 downto 0) := x"86";
    constant WASM_OPCODE_I64_SHR_S : std_logic_vector(7 downto 0) := x"87";
    constant WASM_OPCODE_I64_SHR_U : std_logic_vector(7 downto 0) := x"88";
    constant WASM_OPCODE_I64_ROTL : std_logic_vector(7 downto 0) := x"89";
    constant WASM_OPCODE_I64_ROTR : std_logic_vector(7 downto 0) := x"8A";
    constant WASM_OPCODE_F32_ABS : std_logic_vector(7 downto 0) := x"8B";
    constant WASM_OPCODE_F32_NEG : std_logic_vector(7 downto 0) := x"8C";
    constant WASM_OPCODE_F32_CEIL : std_logic_vector(7 downto 0) := x"8D";
    constant WASM_OPCODE_F32_FLOOR : std_logic_vector(7 downto 0) := x"8E";
    constant WASM_OPCODE_F32_TRUNC : std_logic_vector(7 downto 0) := x"8F";
    constant WASM_OPCODE_F32_NEAREST : std_logic_vector(7 downto 0) := x"90";
    constant WASM_OPCODE_F32_SQRT : std_logic_vector(7 downto 0) := x"91";
    constant WASM_OPCODE_F32_ADD : std_logic_vector(7 downto 0) := x"92";
    constant WASM_OPCODE_F32_SUB : std_logic_vector(7 downto 0) := x"93";
    constant WASM_OPCODE_F32_MUL : std_logic_vector(7 downto 0) := x"94";
    constant WASM_OPCODE_F32_DIV : std_logic_vector(7 downto 0) := x"95";
    constant WASM_OPCODE_F32_MIN : std_logic_vector(7 downto 0) := x"96";
    constant WASM_OPCODE_F32_MAX : std_logic_vector(7 downto 0) := x"97";
    constant WASM_OPCODE_F32_COPYSIGN : std_logic_vector(7 downto 0) := x"98";
    constant WASM_OPCODE_F64_ABS : std_logic_vector(7 downto 0) := x"99";
    constant WASM_OPCODE_F64_NEG : std_logic_vector(7 downto 0) := x"9A";
    constant WASM_OPCODE_F64_CEIL : std_logic_vector(7 downto 0) := x"9B";
    constant WASM_OPCODE_F64_FLOOR : std_logic_vector(7 downto 0) := x"9C";
    constant WASM_OPCODE_F64_TRUNC : std_logic_vector(7 downto 0) := x"9D";
    constant WASM_OPCODE_F64_NEAREST : std_logic_vector(7 downto 0) := x"9E";
    constant WASM_OPCODE_F64_SQRT : std_logic_vector(7 downto 0) := x"9F";
    constant WASM_OPCODE_F64_ADD : std_logic_vector(7 downto 0) := x"A0";
    constant WASM_OPCODE_F64_SUB : std_logic_vector(7 downto 0) := x"A1";
    constant WASM_OPCODE_F64_MUL : std_logic_vector(7 downto 0) := x"A2";
    constant WASM_OPCODE_F64_DIV : std_logic_vector(7 downto 0) := x"A3";
    constant WASM_OPCODE_F64_MIN : std_logic_vector(7 downto 0) := x"A4";
    constant WASM_OPCODE_F64_MAX : std_logic_vector(7 downto 0) := x"A5";
    constant WASM_OPCODE_F64_COPYSIGN : std_logic_vector(7 downto 0) := x"A6";
    constant WASM_OPCODE_I32_WRAP_I64 : std_logic_vector(7 downto 0) := x"A7";
    constant WASM_OPCODE_I32_TRuNC_F32_S : std_logic_vector(7 downto 0) := x"A8";
    constant WASM_OPCODE_I32_TRUNC_F32_U : std_logic_vector(7 downto 0) := x"A9";
    constant WASM_OPCODE_I32_TRUNC_F64_S : std_logic_vector(7 downto 0) := x"AA";
    constant WASM_OPCODE_I32_TRUNC_F64_U : std_logic_vector(7 downto 0) := x"AB";
    constant WASM_OPCODE_I64_EXTEND_I32_S : std_logic_vector(7 downto 0) := x"AC";
    constant WASM_OPCODE_I64_EXTEND_I32_U : std_logic_vector(7 downto 0) := x"AD";
    constant WASM_OPCODE_I64_TRUNC_F32_S : std_logic_vector(7 downto 0) := x"AE";
    constant WASM_OPCODE_I64_TRUNC_F32_U : std_logic_vector(7 downto 0) := x"AF";
    constant WASM_OPCODE_I64_TRUNC_F64_S : std_logic_vector(7 downto 0) := x"B0";
    constant WASM_OPCODE_I64_TRUNC_F64_U : std_logic_vector(7 downto 0) := x"B1";
    constant WASM_OPCODE_F32_CONVERT_I32_S : std_logic_vector(7 downto 0) := x"B2";
    constant WASM_OPCODE_F32_CONVERT_I32_U : std_logic_vector(7 downto 0) := x"B3";
    constant WASM_OPCODE_F32_CONVERT_I64_S : std_logic_vector(7 downto 0) := x"B4";
    constant WASM_OPCODE_F32_CONVERT_I64_U : std_logic_vector(7 downto 0) := x"B5";
    constant WASM_OPCODE_F32_DEMOTE_F64 : std_logic_vector(7 downto 0) := x"B6";
    constant WASM_OPCODE_F64_CONVERT_I32_S : std_logic_vector(7 downto 0) := x"B7";
    constant WASM_OPCODE_F64_CONVERT_I32_U : std_logic_vector(7 downto 0) := x"B8";
    constant WASM_OPCODE_F64_CONVERT_I64_S : std_logic_vector(7 downto 0) := x"B9";
    constant WASM_OPCODE_F64_CONVERT_I64_U : std_logic_vector(7 downto 0) := x"BA";
    constant WASM_OPCODE_F64_PROMOTE_F32 : std_logic_vector(7 downto 0) := x"BB";
    constant WASM_OPCODE_I32_REINTERPRET_F32 : std_logic_vector(7 downto 0) := x"BC";
    constant WASM_OPCODE_I64_REINTERPRET_F64 : std_logic_vector(7 downto 0) := x"BD";
    constant WASM_OPCODE_F32_REINTERPRET_I32 : std_logic_vector(7 downto 0) := x"BE";
    constant WASM_OPCODE_F64_REINTERPRET_I64 : std_logic_vector(7 downto 0) := x"BF";

    constant StateIdle : std_logic_vector(15 downto 0) := x"0000";
    constant State0 : std_logic_vector(15 downto 0) := x"0001";
    constant State1 : std_logic_vector(15 downto 0) := x"0002";
    constant State2 : std_logic_vector(15 downto 0) := x"0003";
    constant State3 : std_logic_vector(15 downto 0) := x"0004";
    constant State4 : std_logic_vector(15 downto 0) := x"0005";
    constant State5 : std_logic_vector(15 downto 0) := x"0006";
    constant State6 : std_logic_vector(15 downto 0) := x"0007";
    constant State7 : std_logic_vector(15 downto 0) := x"0008";
    constant State8 : std_logic_vector(15 downto 0) := x"0009";
    constant State9 : std_logic_vector(15 downto 0) := x"000A";
    constant State10 : std_logic_vector(15 downto 0) := x"000B";
    constant State11 : std_logic_vector(15 downto 0) := x"000C";
    constant State12 : std_logic_vector(15 downto 0) := x"000D";
    constant State13 : std_logic_vector(15 downto 0) := x"000E";
    constant State14 : std_logic_vector(15 downto 0) := x"000F";
    constant StateEnd : std_logic_vector(15 downto 0) := x"00F0";
    constant StateTrapped : std_logic_vector(15 downto 0) := x"00FD";
    constant StateNotSupported : std_logic_vector(15 downto 0) := x"00FE";
    constant StateError : std_logic_vector(15 downto 0) := x"00FF";

    type T_WshBnUp is
    record
        DatOut : std_logic_vector(31 downto 0);
        Ack : std_logic;
    end record;

    type T_WshBnDown is
    record
          Adr : std_logic_vector(23 downto 0);
          Sel : std_logic_vector(3 downto 0);
          DatIn : std_logic_vector(31 downto 0);
          We : std_logic;
          Stb : std_logic;
          Cyc : std_logic_vector(0 downto 0);
    end record;

    type T_WasmFpgaModuleRam_WasmFpgaInstruction is
    record
        Busy : std_logic;
        Data : std_logic_vector(31 downto 0);
    end record;

    type T_WasmFpgaInstruction_WasmFpgaModuleRam is
    record
        Run : std_logic;
        Address : std_logic_vector(23 downto 0);
    end record;

    type T_WasmFpgaStack_WasmFpgaInstruction is
    record
        Busy : std_logic;
        HighValue : std_logic_vector(31 downto 0);
        LowValue : std_logic_vector(31 downto 0);
    end record;

    type T_WasmFpgaInstruction_WasmFpgaStack is
    record
        Run : std_logic;
        Action : std_logic;
        ValueType : std_logic_vector(2 downto 0);
        HighValue : std_logic_vector(31 downto 0);
        LowValue : std_logic_vector(31 downto 0);
    end record;

    type T_WasmFpgaInstruction_WasmFpgaInvocation is
    record
        Busy : std_logic;
        Trap : std_logic;
        Address : std_logic_vector(23 downto 0);
    end record;

    type T_WasmFpgaInvocation_WasmFpgaInstruction is
    record
        Run : std_logic;
        Address : std_logic_vector(23 downto 0);
    end record;


    function i32_ctz(value: std_logic_vector) return std_logic_vector;

    function i32_clz(value: std_logic_vector) return std_logic_vector;

    function i32_popcnt(value: std_logic_vector) return std_logic_vector;

    function i32_and(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

    function i32_eqz(a: std_logic_vector) return std_logic_vector;

    function i32_eq(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

    function i32_ne(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

    function i32_or(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

    function i32_lt_s(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

    function i32_xor(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

    function i32_rotl(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

    function i32_rotr(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

    function i32_shl(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

    function i32_shr_s(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

    function i32_shr_u(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

    procedure ReadFromModuleRam(signal State : inout std_logic_vector;
                                 signal CurrentByte : inout std_logic_vector;
                                 signal WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
                                 signal WasmFpgaInstruction_WasmFpgaModuleRam : out T_WasmFpgaInstruction_WasmFpgaModuleRam);

    procedure ReadSignedLEB128(signal State : inout std_logic_vector;
                      signal ReadFromModuleRamState : inout std_logic_vector;
                      signal DecodedValue : inout std_logic_vector;
                      signal CurrentByte : inout std_logic_vector;
                      signal SignBits : inout std_logic_vector;
                      signal WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
                      signal WasmFpgaInstruction_WasmFpgaModuleRam : out T_WasmFpgaInstruction_WasmFpgaModuleRam);

    procedure PopFromStack(signal State : inout std_logic_vector;
                           signal WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
                           signal WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction);

    procedure PushToStack(signal State : inout std_logic_vector;
                          signal WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
                          signal WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction);

end;

package body WasmFpgaEnginePackage is

    --
    -- Read u32 (LEB128 encoded)
    --
    procedure ReadSignedLEB128(signal State : inout std_logic_vector;
                      signal ReadFromModuleRamState : inout std_logic_vector;
                      signal DecodedValue : inout std_logic_vector;
                      signal CurrentByte : inout std_logic_vector;
                      signal SignBits : inout std_logic_vector;
                      signal WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
                      signal WasmFpgaInstruction_WasmFpgaModuleRam : out T_WasmFpgaInstruction_WasmFpgaModuleRam) is
    begin
        if (State = StateIdle) then
            ReadFromModuleRam(ReadFromModuleRamState,
                              CurrentByte,
                              WasmFpgaModuleRam_WasmFpgaInstruction,
                              WasmFpgaInstruction_WasmFpgaModuleRam);
            if (ReadFromModuleRamState = StateEnd) then
                DecodedValue <= (31 downto 7 => '0') & CurrentByte(6 downto 0);
                State <= State0;
            end if;
        elsif (State = State0) then
            if ((CurrentByte and x"80") = x"00") then
                -- 1 byte
                SignBits <= x"FFFFFFC0";
                State <= State4;
            else
                ReadFromModuleRam(ReadFromModuleRamState,
                                  CurrentByte,
                                  WasmFpgaModuleRam_WasmFpgaInstruction,
                                  WasmFpgaInstruction_WasmFpgaModuleRam);
                if (ReadFromModuleRamState = StateEnd) then
                    DecodedValue(13 downto 7) <= CurrentByte(6 downto 0);
                    State <= State1;
                end if;
            end if;
        elsif (State = State1) then
            if ((CurrentByte and x"80") = x"00") then
                -- 2 byte
                SignBits <= x"FFFFE000";
                State <= State4;
            else
                ReadFromModuleRam(ReadFromModuleRamState,
                                  CurrentByte,
                                  WasmFpgaModuleRam_WasmFpgaInstruction,
                                  WasmFpgaInstruction_WasmFpgaModuleRam);
                if (ReadFromModuleRamState = StateEnd) then
                    DecodedValue(20 downto 14) <= CurrentByte(6 downto 0);
                    State <= State2;
                end if;
            end if;
        elsif (State = State2) then
            if ((CurrentByte and x"80") = x"00") then
                -- 3 byte
                SignBits <= x"FFF00000";
                State <= State4;
            else
                ReadFromModuleRam(ReadFromModuleRamState,
                                  CurrentByte,
                                  WasmFpgaModuleRam_WasmFpgaInstruction,
                                  WasmFpgaInstruction_WasmFpgaModuleRam);
                if (ReadFromModuleRamState = StateEnd) then
                    DecodedValue(27 downto 21) <= CurrentByte(6 downto 0);
                    State <= State3;
                end if;
            end if;
        elsif (State = State3) then
            if ((CurrentByte and x"80") = x"00") then
                -- 4 byte
                SignBits <= x"F8000000";
                State <= State4;
            else
                -- Greater than u32 not supported
                DecodedValue <= (others => '0');
                State <= StateNotSupported;
            end if;
        elsif (State = State4) then
            if ((SignBits and DecodedValue) /= x"00000000") then
                DecodedValue <= DecodedValue or SignBits;
            end if;
            State <= StateEnd;
        elsif (State = StateEnd) then
            State <= StateIdle;
        else
            State <= StateError;
        end if;
    end;

    procedure ReadFromModuleRam(signal State : inout std_logic_vector;
                                signal CurrentByte : inout std_logic_vector;
                                signal WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
                                signal WasmFpgaInstruction_WasmFpgaModuleRam : out T_WasmFpgaInstruction_WasmFpgaModuleRam) is
    begin
        if (State = StateIdle) then
            WasmFpgaInstruction_WasmFpgaModuleRam.Run <= '1';
            State <= State0;
        elsif (State = State0) then
            WasmFpgaInstruction_WasmFpgaModuleRam.Run <= '0';
            State <= State1;
        elsif (State = State1) then
            State <= State2;
        elsif (State = State2) then
            State <= State3;
        elsif (State = State3) then
            if (WasmFpgaModuleRam_WasmFpgaInstruction.Busy = '0') then
                if WasmFpgaInstruction_WasmFpgaModuleRam.Address(1 downto 0) = "00" then
                    CurrentByte <= WasmFpgaModuleRam_WasmFpgaInstruction.Data(7 downto 0);
                elsif WasmFpgaInstruction_WasmFpgaModuleRam.Address(1 downto 0) = "01" then
                    CurrentByte <= WasmFpgaModuleRam_WasmFpgaInstruction.Data(15 downto 8);
                elsif WasmFpgaInstruction_WasmFpgaModuleRam.Address(1 downto 0) = "10" then
                    CurrentByte <= WasmFpgaModuleRam_WasmFpgaInstruction.Data(23 downto 16);
                else
                    CurrentByte <= WasmFpgaModuleRam_WasmFpgaInstruction.Data(31 downto 24);
                end if;
                WasmFpgaInstruction_WasmFpgaModuleRam.Address <= std_logic_vector(unsigned(WasmFpgaInstruction_WasmFpgaModuleRam.Address) + 1);
                State <= StateEnd;
            end if;
        elsif (State = StateEnd) then
            State <= StateIdle;
        else
            State <= StateError;
        end if;
    end;

    procedure PopFromStack(signal State : inout std_logic_vector;
                           signal WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
                           signal WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction) is
    begin
        if (State = StateIdle) then
            WasmFpgaInstruction_WasmFpgaStack.Run <= '1';
            WasmFpgaInstruction_WasmFpgaStack.Action <= WASMFPGASTACK_VAL_Pop;
            State <= State0;
        elsif (State = State0) then
            WasmFpgaInstruction_WasmFpgaStack.Run <= '0';
            State <= State1;
        elsif (State = State1) then
            State <= State2;
        elsif (State = State2) then
            State <= State3;
        elsif (State = State3) then
            State <= State4;
        elsif (State = State4) then
            State <= State5;
        elsif (State = State5) then
            if (WasmFpgaStack_WasmFpgaInstruction.Busy = '0') then
                State <= StateEnd;
            end if;
        elsif (State = StateEnd) then
            State <= StateIdle;
        else
            -- Error state by convention
            State <= (others => '1');
        end if;
    end;

    procedure PushToStack(signal State : inout std_logic_vector;
                          signal WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
                          signal WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction) is
    begin
        if (State = StateIdle) then
            WasmFpgaInstruction_WasmFpgaStack.Run <= '1';
            WasmFpgaInstruction_WasmFpgaStack.Action <= WASMFPGASTACK_VAL_Push;
            State <= State0;
        elsif (State = State0) then
            WasmFpgaInstruction_WasmFpgaStack.Run <= '0';
            State <= State1;
        elsif (State = State1) then
            State <= State2;
        elsif (State = State2) then
            State <= State3;
        elsif (State = State3) then
            State <= State4;
        elsif (State = State4) then
            if (WasmFpgaStack_WasmFpgaInstruction.Busy = '0') then
                State <= StateEnd;
            end if;
        elsif (State = StateEnd) then
            State <= StateIdle;
        else
            State <= (others => '1');
        end if;
    end;

    function i32_ctz(value: std_logic_vector)
        return std_logic_vector
    is
        variable total : integer range 0 to value'length := 0;
    begin
        for i in value'reverse_range loop
            if value(i) = '1' then
                exit;
            else
                total := total + 1;
            end if;
        end loop;
        return std_logic_vector(to_unsigned(total, value'length));
    end;

    function i32_clz(value: std_logic_vector)
        return std_logic_vector
    is
        variable total : integer range 0 to value'length := 0;
    begin
        for i in value'range loop
            if value(i) = '1' then
                exit;
            else
                total := total + 1;
            end if;
        end loop;
        return std_logic_vector(to_unsigned(total, value'length));
    end;

    function i32_popcnt(value: std_logic_vector)
        return std_logic_vector
    is
        variable total : integer range 0 to value'length := 0;
    begin
        for i in value'range loop
            if value(i) = '1' then
                total := total + 1;
            end if;
        end loop;
        return std_logic_vector(to_unsigned(total, value'length));
    end;

    function i32_and(a: std_logic_vector; b: std_logic_vector)
        return std_logic_vector
    is
    begin
        return a and b;
    end;

    function i32_or(a: std_logic_vector; b: std_logic_vector)
        return std_logic_vector
    is
    begin
        return a or b;
    end;

    function i32_xor(a: std_logic_vector; b: std_logic_vector)
        return std_logic_vector
    is
    begin
        return a xor b;
    end;

    function i32_rotl(a: std_logic_vector; b: std_logic_vector)
        return std_logic_vector
    is
    begin
        return std_logic_vector(rotate_left(unsigned(a), to_integer(unsigned(b))));
    end;

    function i32_rotr(a: std_logic_vector; b: std_logic_vector)
        return std_logic_vector
    is
    begin
        return std_logic_vector(rotate_right(unsigned(a), to_integer(unsigned(b))));
    end;

    function i32_shl(a: std_logic_vector; b: std_logic_vector)
        return std_logic_vector
    is
    begin
        return std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b))));
    end;

    function i32_shr_s(a: std_logic_vector; b: std_logic_vector)
        return std_logic_vector
    is
    begin
        return std_logic_vector(shift_right(signed(a), to_integer(unsigned(b))));
    end;

    function i32_shr_u(a: std_logic_vector; b: std_logic_vector)
        return std_logic_vector
    is
    begin
        return std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b))));
    end;

    function i32_eqz(a: std_logic_vector)
        return std_logic_vector
    is
    begin
        if (a = x"00000000") then
            return x"00000001";
        else
            return x"00000000";
        end if;
    end;

    function i32_eq(a: std_logic_vector; b: std_logic_vector)
        return std_logic_vector
    is
    begin
        if (a = b) then
            return x"00000001";
        else
            return x"00000000";
        end if;
    end;

    function i32_ne(a: std_logic_vector; b: std_logic_vector)
        return std_logic_vector
    is
    begin
        if (a = b) then
            return x"00000000";
        else
            return x"00000001";
        end if;
    end;

    function i32_lt_s(a: std_logic_vector; b: std_logic_vector)
        return std_logic_vector
    is
    begin
        if (a < b) then
            return x"00000001";
        else
            return x"00000000";
        end if;
    end;

end;