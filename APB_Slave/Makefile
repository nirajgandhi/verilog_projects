organise:
	mkdir ./exe_file
	mkdir ./vcd_file

comp.d:
	iverilog -o ./exe_file/exe apb_slave.v apb_slave_tb.v 

comp.t:
	./exe_file/./exe
	mv *.vcd ./vcd_file
comp.d_t:
	gtkwave ./vcd_file/*.vcd
