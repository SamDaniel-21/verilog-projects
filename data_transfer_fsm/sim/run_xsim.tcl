# Compile RTL files
exec xvlog ../rtl/top_fsm.v
exec xvlog ../rtl/ram_dp_async_read.v

# Compile testbench
exec xvlog ../tb/tb_top_fsm.v

# Elaborate testbench top
exec xelab tb_top_fsm -debug typical

# Run simulation
exec xsim tb_top_fsm -runall
