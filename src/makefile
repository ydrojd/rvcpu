a.out: cpu.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v uart_dev.v uart_tx_path.v multiplier_wrapper.v divider_wrapper.v

	verilator -O0 --binary -j 16 cpu.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v comparitor.v uart_tx_path.v uart_dev.v multiplier_wrapper.v divider_wrapper.v

rtype_tb: tests/rtype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	verilator -O0 --binary -Wno-lint -j 16 tests/rtype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

rtype_fw_tb: tests/rtype_fw_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	verilator -O0 --binary -Wno-lint -j 16 tests/rtype_fw_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

btype_tb: tests/btype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	verilator -O0 --binary -Wno-lint -j 16 --trace tests/btype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

stype_tb: tests/stype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	verilator -O0 --binary -Wno-lint -j 16 tests/stype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

ltype_tb: tests/ltype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	verilator -O0 --binary -Wno-lint -j 16 tests/ltype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

mixed_tb: mixed_tb.v cpu.v instruction_decoder.v register_file.v alu.v data_port.v ram_wrapper.v instruction_fetcher.v
	verilator -O0 --binary -Wno-lint -j 16 --trace mixed_tb.v cpu.v instruction_decoder.v register_file.v alu.v data_port.v ram_wrapper.v instruction_fetcher.v

alu_tb: alu_tb.v alu.v
	verilator -O0 --binary -Wno-lint -j 16 alu_tb.v alu.v multiplier_block_wrapper

jtype_tb: tests/jtype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	verilator -O0 --binary -Wno-lint -j 16 --trace tests/jtype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

jrtype_tb: tests/jrtype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	verilator -O0 --binary -Wno-lint -j 16 --trace tests/jrtype_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

mixed2_tb: tests/mixed2_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	verilator -O0 --binary -Wno-lint -j 16 --trace tests/mixed2_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

ext_ex_tb: tests/ext_ex_tb.v cpu.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	verilator -O0 --binary -Wno-lint -j 16 --trace tests/ext_ex_tb.v cpu.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

mixed_fw_tb: tests/mixed_fw_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v

	verilator -O0 --binary -Wno-lint -j 16 --trace tests/mixed_fw_tb.v base_pipeline.v instruction_decoder.v register_file.v alu.v ram_port.v ram_wrapper.v instruction_fetcher.v
