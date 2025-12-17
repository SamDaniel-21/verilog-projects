`timescale 1ns/1ps
module top_fsm( input clk, input rst_n, input [7:0]data_wr, input wr_en, input [4:0]wr_add, input [3:0]rd_add, input op_mode, output [15:0]data_out, 
output reg done
);

parameter [3:0] IDLE = 4'b0001, 
    READ_BYTE0=4'b0010,
    READ_BYTE1=4'b0100,
    WRITE_BYTE12=4'b1000;

reg [3:0]state, next_state;
reg [4:0] ram_pointer;
wire [7:0]fsm_in_data;
reg [4:0]fsm_in_add;
reg we;
reg [7:0] read_0;
reg [7:0] read_1;
reg [3:0] fsm_out_add;

//RAM instantiation
ram_dp_async_read #(.w(8), .d(32) ) R1( .data_in(data_wr), .wr(wr_en), .clk(clk), .addr_wr(wr_add), .addr_rd(fsm_in_add), .data_out(fsm_in_data));

ram_dp_async_read #(.w(16), .d(16)) R2( .data_in({read_1,read_0}), .wr(we), .clk(clk), .addr_wr(fsm_out_add), .addr_rd(rd_add), .data_out(data_out));

always @(*) begin
    next_state=IDLE;
    fsm_in_add=0;
    we=0;
    case(state) 

        IDLE: begin
            if(op_mode == 1'b1) next_state=READ_BYTE0;
        end

        READ_BYTE0: begin
            fsm_in_add=ram_pointer;
            next_state=READ_BYTE1;
        end

        READ_BYTE1: begin
            fsm_in_add=ram_pointer;
            next_state=WRITE_BYTE12;
        end

        WRITE_BYTE12: begin
            if(done == 1'b0) begin
                next_state=READ_BYTE0;
            end
            else begin
                next_state=IDLE;
            end
            we=1; 
        end

        default: begin
            next_state=IDLE; //prevents latch creation
        end  
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state<=IDLE;
    end
    else begin
        state<=next_state;
    end
end

//ram_pointer counter
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ram_pointer <= 5'b0;
    end
    else if( (state == READ_BYTE0) || (state ==  READ_BYTE1) ) begin
        ram_pointer <= ram_pointer+1'b1;
    end
end

//fsm_out_add logic
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fsm_out_add <= 4'b0;
    end
    else if ( state == READ_BYTE0) begin
        fsm_out_add <= (ram_pointer>>1) ;
    end
end

//done logic
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        done<=1'b0;
    end 
    else if (op_mode) begin 
        done<=1'b0;
    end
    else if (ram_pointer == 5'd31 ) begin //task is completed
        done<=1'b1;
    end
end

//pipelining
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        read_0 <= 8'b0;
        read_1 <= 8'b0;
    end
    else begin
        read_0 <= fsm_in_data;
        read_1 <= read_0;
    end
end
endmodule
        
    
        

    
