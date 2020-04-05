PWD=$(shell pwd)

all: package

convert:
	wat2wasm resources/debug.wat -o resources/debug.wasm
	wat2wasm resources/debug.wat -v > resources/debug.text
	tools/bin2coe.py --input resources/debug.wasm --output resources/debug.coe

prepare:
	@mkdir -p work

project: prepare hxs fetch-definitions
	@vivado -mode batch -source scripts/create_project.tcl -notrace -nojournal -tempDir work -log work/vivado.log

package: prepare hxs
	@vivado -mode batch -source scripts/package_ip.tcl -notrace -nojournal -tempDir work -log work/vivado.log

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

fetch-definitions:
	cp ../wasm-fpga-stack/hxs_gen/vhd_gen/header/* resources
	cp ../wasm-fpga-stack/hxs_gen/vhd_gen/wishbone/* resources
	cp ../wasm-fpga-store/hxs_gen/vhd_gen/header/* resources
	cp ../wasm-fpga-store/hxs_gen/vhd_gen/wishbone/* resources
	cp ../wasm-fpga-bus/hxs_gen/vhd_gen/header/* resources
	cp ../wasm-fpga-bus/hxs_gen/vhd_gen/wishbone/* resources

.PHONY: all prepare project package hxs clean clean-ip 
