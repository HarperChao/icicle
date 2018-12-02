TRELLIS  ?= /usr/share/trellis
LPF       = boards/$(BOARD).lpf
FREQ_PLL  = $(FREQ_OSC)

progmem_syn.hex:
	touch $@

$(PLL): dummy-pll.sv
	cp $< $@

$(ASC_SYN): $(JSON) $(LPF)
	nextpnr-ecp5 $(QUIET) --$(DEVICE) --basecfg $(TRELLIS)/misc/basecfgs/empty_$(BASECFG).config --json $< --lpf $(LPF) --freq $(FREQ_PLL) --textcfg $@

$(ASC): $(ASC_SYN) progmem_syn.hex progmem.hex
	cp $< $@

$(BIN): $(ASC)
	ecppack $< $@

$(SVF): $(BIN)
	$(TRELLIS)/tools/bit_to_svf.py $< $@

$(TIME_RPT):
	touch $@

$(STAT):
	touch $@

flash: $(SVF) $(TIME_RPT)
	openocd -f boards/$(BOARD)-openocd.cfg -c 'transport select jtag; init; svf $<; exit'