# Preload `helloworld.spm.elf` through serial link
#set BINARY ../../../sw/tests/helloworld.dram.elf
set BINARY ../../../sw/tests/xbar_tc.dram.elf
#set BINARY ../../../sw/tests/xbar_tc.dram.elf
#set BINARY /home/nwistoff/projects/julia-llc/helloworld_72.elf
#set BINARY /home/nwistoff/projects/julia-llc/helloworld_96.elf
set BOOTMODE 0
set PRELMODE 1
#set SELCFG 3

#set BOOTMODE 2
#set PRELMODE 0
set SELCFG 3
#set IMAGE ../../../sw/tests/helloworld.gpt.memh

#set VOPTARGS "+acc"

set VSIMARGS "-wlf work/vsim.wlf"

# Compile design
source compile.cheshire_soc.tcl

# Start and run simulation
source start.cheshire_soc.tcl

#add wave -position insertpoint {sim:/tb_cheshire_soc/fix/dut/i_axi_xbar/gen_mst_port_mux[1]/i_axi_mux/gen_mux/i_ar_arbiter/*}
#add wave -position insertpoint {sim:/tb_cheshire_soc/fix/dut/i_axi_xbar/gen_mst_port_mux[1]/i_axi_mux/gen_mux/i_ar_arbiter/gen_arbiter/*}
#add wave -position insertpoint {sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/csr_regfile_i/cycle_q}
#add wave -position insertpoint {sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/pc_commit}
#add wave -position insertpoint {sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/selfinval}
#log -r /*
run -all
