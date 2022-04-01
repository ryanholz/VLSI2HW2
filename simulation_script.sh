# Compile code using iverilog
iverilog -o hw2 ../rtl/cache_coherency_RTL.v

# Run the simulation and generate vcd file
vvp hw2
