#include "WasmFpgaEngine.h"

// #include "../resources/wasm_fpga_engine_indirect.c"
// #include "../resources/wasm_fpga_engine_debug_indirect.c"
// #include "../../wasm-fpga-stack/hxs_gen/simstm_gen/indirect/wasm_fpga_stack_indirect.c"
// #include "WasmFpgaEngineDefines.c"
// #include "WasmFpgaEngineHelper.c"
// #include "WasmFpgaEngineTests.c"
// #include "instructions/Call.c"
// #include "instructions/Select.c"
// #include "instructions/I32Add.c"
// #include "instructions/I32Sub.c"
// #include "instructions/I32Mul.c"
// #include "instructions/I32Divu.c"
// #include "instructions/I32Divs.c"
// #include "instructions/I32Remu.c"
// #include "instructions/I32Rems.c"
// MAIN();

void MAIN()
{
	termPuts(0, 0,  "TESTBENCH: WASM_FPGA_ENGINE");
	termPuts(0, 0,  "\r\n");
	
	SetMessageLevel(0);
	TEST_CALL();
}		
