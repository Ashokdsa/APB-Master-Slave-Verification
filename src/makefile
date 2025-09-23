QUESTA := /home/share/questa.csh
SHELL := /bin/csh

.ONESHELL:	
all:
	source $(QUESTA)
	make clean
	make compile
	make simulate
	vcover report -html apb_coverage.ucdb -htmldir covReport -details

clean:
	rm -rf work/ transcript vsim.wlf wave.vcd
	rm -rf covReport apb_coverage.ucdb
	rm apb.log simulation.log
	rm apb_coverage.ucdb
	clear
	clear
	clear

compile:
	source $(QUESTA)
	vlog -sv +acc +cover +fcover -l apb.log apb_top.sv

wave:
	source $(QUESTA)
	vlog -sv +acc +cover +fcover -l simulation.log apb_top.sv
	vsim -novopt work.top

simulate:
	vsim -vopt work.top -voptargs=+acc=npr -assertdebug -l simulation.log -coverage -c -do "coverage save -onexit -assert -directive -cvg -codeAll apb_coverage.ucdb; run -all; exit"  

view:
	firefox ./covReport/index.html
