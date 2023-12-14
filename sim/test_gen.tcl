quit -sim


if {[file exists work]} {
  file delete -force work
} 
# ----------------------------------------
# Create compilation libraries
  vlib	work
  vmap	work work
# ----------------------------------------




# set LIB_DIR  E:/pango/PDS_2021.4-SP1.2/arch/vendor/pango/verilog/simulation
# set LIB_DIR  D:/Pango/PDS_2021.4-SP1.2/arch/vendor/pango/verilog/simulation
#set LIB_DIR  D:/Software/Pango_Design_Suite/PDS_2021.4-SP1.2/arch/vendor/pango/verilog/simulation
set LIB_DIR F:/pango/PDS_2021.4-SP1.2/arch/vendor/pango/verilog/simulation

vlog    +define+SIM_ON+SIMULATION+sg15E+x16 \
       -y $LIB_DIR -f ./test_file.f +libext+.v \
       +incdir+../tb/ddr_support/mem 



# ----------------------------------------
# Elaborate the top level design with novopt option


  vsim -voptargs=+acc -L work  test_fpga_top -l sim.log
  
  log  -r /*
  
  run 700us
  
  do wave_show.do
