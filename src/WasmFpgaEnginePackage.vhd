library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package WasmFpgaEnginePackage is

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

    function ctz(value: std_logic_vector) return std_logic_vector;

    function clz(value: std_logic_vector) return std_logic_vector;

    function popcnt(value: std_logic_vector) return std_logic_vector;

end;

package body WasmFpgaEnginePackage is

    function ctz(value: std_logic_vector)
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

    function clz(value: std_logic_vector)
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

    function popcnt(value: std_logic_vector)
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

end;
