comp = verilator -O0 --binary -Wno-lint -j 16

pipeline_deps = base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v multiplier_block_wrapper.v divider_wrapper.v divider.v

cpu_deps = $(pipeline_deps) cpu.v uart_dev.v uart_tx_path.v

a.out: $(cpu_deps)

	$(comp) -top-module cpu $(cpu_deps)

rtype_tb: tests/rtype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	$(comp) tests/rtype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

rtype_fw_tb: tests/rtype_fw_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	$(comp) tests/rtype_fw_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

btype_tb: tests/btype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	$(comp) --trace tests/btype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

stype_tb: tests/stype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	$(comp) tests/stype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

ltype_tb: tests/ltype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	$(comp) tests/ltype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

mixed_tb: mixed_tb.v cpu.v instruction_decoder.v register_file.v alu.v data_port.v ram_wrapper.v instruction_fetcher.v
	$(comp) --trace mixed_tb.v cpu.v instruction_decoder.v register_file.v alu.v data_port.v ram_wrapper.v instruction_fetcher.v

alu_tb: alu_tb.v alu.v
	$(comp) alu_tb.v alu.v multiplier_block_wrapper

jtype_tb: tests/jtype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	$(comp) --trace tests/jtype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

jrtype_tb: tests/jrtype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	$(comp) --trace tests/jrtype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

mixed2_tb: tests/mixed2_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	$(comp) --trace tests/mixed2_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

mixed_fw_tb: tests/mixed_fw_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	$(comp) --trace tests/mixed_fw_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

mp_tb: tests/mp_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	$(comp) --trace tests/mp_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

div_tb: tests/div_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v divider.v divider_wrapper.v

	$(comp) --trace tests/div_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v divider.v divider_wrapper.v

bus_tb: tests/bus_tb.v cpu.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	$(comp) --trace tests/bus_tb.v cpu.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v
