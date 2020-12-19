PWD=$(shell pwd)

all: package

convert:
	wat2wasm resources/debug.wat -o resources/debug.wasm
	wat2wasm resources/debug.wat -v > resources/debug.text
	tools/bin2coe.py --input resources/debug.wasm --output resources/debug.coe

prepare:
	@mkdir -p work

project: prepare fetch-definitions hxs
	@vivado -mode batch -source scripts/create_project.tcl -notrace -nojournal -tempDir work -log work/vivado.log

package:
	python3 setup.py sdist bdist_wheel

clean: clean-ip
	@rm -rf .Xil vivado*.log vivado*.str vivado*.jou
	@rm -rf work \
		src-gen \
		hxs_gen

clean-ip:
	@find ip ! -iname *.xci -type f -exec rm {} +
	@rm -rf ip/**/hdl \
		ip/**/synth \
		ip/**/example_design \
		ip/**/sim \
		ip/**/simulation \
		ip/**/misc \
		ip/**/doc

hxs:
	docker run -t \
               -v ${PWD}/hxs:/work/src \
               -v ${PWD}/hxs_gen:/work/gen \
               registry.build.aug:5000/docker/hxs_generator:latest
	cp hxs_gen/vhd_gen/header/wasm_fpga_engine_header.vhd resources/wasm_fpga_engine_header.vhd
	cp hxs_gen/vhd_gen/wishbone/wasm_fpga_engine_wishbone.vhd resources/wasm_fpga_engine_wishbone.vhd
	cp hxs_gen/vhd_gen/testbench/direct/wasm_fpga_engine_direct.vhd resources/wasm_fpga_engine_direct.vhd
	cp hxs_gen/vhd_gen/testbench/indirect/wasm_fpga_engine_indirect.vhd resources/wasm_fpga_engine_indirect.vhd

fetch-definitions:
	cp ../wasm-fpga-stack/hxs_gen/vhd_gen/header/* resources
	cp ../wasm-fpga-stack/hxs_gen/vhd_gen/wishbone/* resources
	cp ../wasm-fpga-store/hxs_gen/vhd_gen/header/* resources
	cp ../wasm-fpga-store/hxs_gen/vhd_gen/wishbone/* resources
	cp ../wasm-fpga-bus/hxs_gen/vhd_gen/header/* resources
	cp ../wasm-fpga-bus/hxs_gen/vhd_gen/wishbone/* resources

install-from-test-pypi:
	pip3 install --upgrade -i https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple wasm-fpga-stack

upload-to-test-pypi: package
	python3 -m twine upload --repository-url https://test.pypi.org/legacy/ dist/*

upload-to-pypi: package
	python3 -m twine upload --repository pypi dist/*

.PHONY: all prepare project package hxs clean clean-ip
