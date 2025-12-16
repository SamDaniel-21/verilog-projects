module ram_dp_async_read
#(parameter w=8, parameter d=16, parameter d_log=$clog2(d))
(

    input [w-1:0]data_in,
    input [d_log-1:0]addr_rd,
    input [d_log-1:0]addr_wr,
    input wr,
    input clk,
    output [w-1:0]data_out

);

reg [w-1:0] ram [0:d-1];

always @(posedge clk) begin
    if(wr) begin
        ram[addr_wr]<=data_in;
    end
end

assign data_out=ram[addr_rd];

endmodule
