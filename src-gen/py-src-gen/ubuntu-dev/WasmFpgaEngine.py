	
class WasmFpgaEngine():
    
	def __init__(self, stm):
		self.stm = stm
	
	# including  "../resources/wasm_fpga_engine_indirect.stm"
	# including  "../resources/wasm_fpga_engine_debug_indirect.stm"
	# including  "../../wasm-fpga-stack/hxs_gen/simstm_gen/indirect/wasm_fpga_stack_indirect.stm"
	# including  "WasmFpgaEngineDefines.stm"
	# including  "WasmFpgaEngineHelper.stm"
	# including  "WasmFpgaEngineTests.stm"
	# including  "instructions/Call.stm"
	# including  "instructions/Select.stm"
	# including  "instructions/I32Add.stm"
	# including  "instructions/I32Sub.stm"
	# including  "instructions/I32Mul.stm"
	# including  "instructions/I32Divu.stm"
	# including  "instructions/I32Divs.stm"
	# including  "instructions/I32Remu.stm"
	# including  "instructions/I32Rems.stm"
	
	# self.MAIN()
	self.stm.bind.Finish("file:///home/ubuntu-dev/git/webassembly/wasm-fpga-engine/simstm/WasmFpgaEngine.stm#//@statements.1")
	    
	def MAIN(self):
		self.stm.bind.MessagePrint(0,
		    "TESTBENCH: WASM_FPGA_ENGINE",
		    [
		    ]
		)
		self.stm.bind.SetMessageLevel(0)
		self.stm.Call.TEST_CALL()
		return
