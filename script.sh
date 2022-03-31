# Compile code using iverilog
iverilog -o hw2 allTogether.v

# Run the simulation and generate vcd file
vvp hw2
