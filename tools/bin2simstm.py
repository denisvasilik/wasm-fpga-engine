from binalyzer import Binalyzer

def bin2simstm(input_file, output_file):
    wasm_module_format_url = "https://raw.githubusercontent.com/denisvasilik/binalyzer/master/resources/wasm_module_format.xml"
    binalyzer = Binalyzer(data=input_file)
    binalyzer.xml.from_url(wasm_module_format_url)
    wasm_module = binalyzer.template

    start_section_size_address = wasm_module.start_section.length.absolute_address
    start_funcidx = int.from_bytes(wasm_module.start_section.start_funcidx.value, "little")
    code_section_address = wasm_module.code_section.code.function[start_funcidx].absolute_address

    output_file.write("-- Prepare store to provide a start section entry\n")
    output_file.write("WRITE_RAM $WASM_STORE #x0 #x0 -- Module Instance UID\n")
    output_file.write("WRITE_RAM $WASM_STORE #x1 #x8 -- Section UID of Start Section\n")
    output_file.write("WRITE_RAM $WASM_STORE #x2 #x0 -- Idx\n")
    output_file.write(f"WRITE_RAM $WASM_STORE #x3 #x{start_section_size_address:02X} -- Start Function Address\n\n")

    output_file.write("-- Prepare store to provide a start function address\n")
    output_file.write("WRITE_RAM $WASM_STORE #x4 #x0 -- Module Instance UID\n")
    output_file.write("WRITE_RAM $WASM_STORE #x5 #xA -- Section UID of Code Section\n")
    output_file.write(f"WRITE_RAM $WASM_STORE #x6 #x{start_funcidx:02X} -- Idx\n")
    output_file.write(f"WRITE_RAM $WASM_STORE #x7 #x{code_section_address:02X} -- Start Function Address\n\n")

    for (address, data_byte) in enumerate(binalyzer.template.value):
        output_file.write(f"WRITE_RAM $WASM_MODULE #x{address:06X} #x{data_byte:02X}\n")

if __name__ == "__main__":
    with open("resources/call_app.wasm", 'rb') as input_file:
        with open("resources/call_app.stm", 'w') as output_file:
            bin2simstm(input_file, output_file)
