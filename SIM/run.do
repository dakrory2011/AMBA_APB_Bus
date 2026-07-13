vlib work
vlog -f src_files.list +define+SIM +cover=btf -covercells -sv
vsim -voptargs=+acc -assertdebug top -cover +assertcover
vlog -cover bcs -f src_files.list
add wave /top/a_if/*
add wave -position insertpoint  \
sim:/top/DUT/des/addr \
sim:/top/DUT/des/byte_en \
sim:/top/DUT/des/done \
sim:/top/DUT/des/error \
sim:/top/DUT/des/PADDR \
sim:/top/DUT/des/PCLK \
sim:/top/DUT/des/PENABLE \
sim:/top/DUT/des/PPROT \
sim:/top/DUT/des/PRDATA \
sim:/top/DUT/des/PRDATA0 \
sim:/top/DUT/des/PRDATA1 \
sim:/top/DUT/des/PRDATA2 \
sim:/top/DUT/des/PRDATA3 \
sim:/top/DUT/des/PREADY \
sim:/top/DUT/des/PREADY0 \
sim:/top/DUT/des/PREADY1 \
sim:/top/DUT/des/PREADY2 \
sim:/top/DUT/des/PREADY3 \
sim:/top/DUT/des/PRESETn \
sim:/top/DUT/des/prot \
sim:/top/DUT/des/PSEL \
sim:/top/DUT/des/PSEL0 \
sim:/top/DUT/des/PSEL1 \
sim:/top/DUT/des/PSEL2 \
sim:/top/DUT/des/PSEL3 \
sim:/top/DUT/des/PSEL_ERR \
sim:/top/DUT/des/PSLVERR \
sim:/top/DUT/des/PSLVERR0 \
sim:/top/DUT/des/PSLVERR1 \
sim:/top/DUT/des/PSLVERR2 \
sim:/top/DUT/des/PSLVERR3 \
sim:/top/DUT/des/PSTRB \
sim:/top/DUT/des/PWDATA \
sim:/top/DUT/des/PWRITE \
sim:/top/DUT/des/rdata \
sim:/top/DUT/des/rw \
sim:/top/DUT/des/start \
sim:/top/DUT/des/wdata
run -all
coverage save top.ucdb -onexit