PWD=$(shell pwd)
WASM_APP_NAME=return_app


all: package

convert:
	wat2wasm resources/${WASM_APP_NAME}.wat -o resources/${WASM_APP_NAME}.wasm
	wat2wasm resources/${WASM_APP_NAME}.wat -v 2> resources/${WASM_APP_NAME}.txt
	tools/bin2coe.py --input resources/${WASM_APP_NAME}.wasm --output resources/${WASM_APP_NAME}.coe
	tools/bin2simstm.py --input resources/${WASM_APP_NAME}.wasm --output resources/${WASM_APP_NAME}.stm
	rm ${WASM_APP_NAME}.wasm

simstm:
	tools/bin2simstm.py --input resources/${WASM_APP_NAME}.wasm --output resources/${WASM_APP_NAME}.stm

prepare:
	@mkdir -p work

project: prepare fetch-definitions hxs
	@vivado -mode batch -source scripts/create_project.tcl -notrace -nojournal -tempDir work -log work/vivado.log

package: hxs
	python3 setup.py sdist bdist_wheel

clean: clean-ip
	@rm -rf .Xil vivado*.log vivado*.str vivado*.jou
	@rm -rf work \
		dist \
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
               -v ${PWD}/hxs/wasm_fpga_engine.hxs:/work/src/wasm_fpga_engine.hxs \
               -v ${PWD}/hxs_gen:/work/gen \
               registry.build.aug:5000/docker/hxs_generator:latest
	cp hxs_gen/simstm_gen/indirect/wasm_fpga_engine_indirect.stm resources/wasm_fpga_engine_indirect.stm
	cp hxs_gen/vhd_gen/header/wasm_fpga_engine_header.vhd resources/wasm_fpga_engine_header.vhd
	cp hxs_gen/vhd_gen/wishbone/wasm_fpga_engine_wishbone.vhd resources/wasm_fpga_engine_wishbone.vhd
	docker run -t \
               -v ${PWD}/hxs/wasm_fpga_engine_debug.hxs:/work/src/wasm_fpga_engine_debug.hxs \
               -v ${PWD}/hxs_gen:/work/gen \
               registry.build.aug:5000/docker/hxs_generator:latest
	cp hxs_gen/simstm_gen/indirect/wasm_fpga_engine_debug_indirect.stm resources/wasm_fpga_engine_debug_indirect.stm
	cp hxs_gen/vhd_gen/header/wasm_fpga_engine_debug_header.vhd resources/wasm_fpga_engine_debug_header.vhd
	cp hxs_gen/vhd_gen/wishbone/wasm_fpga_engine_debug_wishbone.vhd resources/wasm_fpga_engine_debug_wishbone.vhd

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

.PHONY: all prepare project package hxs clean clean-ip simstm
