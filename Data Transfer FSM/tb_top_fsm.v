`timescale 1ns/1ps
module tb_top_fsm();

reg clk;
reg rst_n;
reg [7:0]data_wr; 
reg wr_en;
reg [4:0]wr_add;
reg [3:0]rd_add;
reg op_mode;
wire [15:0]data_out;
wire done;

integer cases=0, success=0, failure=0;
integer i;

initial begin
    clk=1'b0;
    forever begin
        #0.5 clk = ~clk;
    end
end
    
top_fsm TF1( .clk(clk), .rst_n(rst_n), .data_wr(data_wr), .wr_en(wr_en), .wr_add(wr_add), .rd_add(rd_add), .op_mode(op_mode), .data_out(data_out), .done(done) );

task write_data( input [4:0]add, input [7:0]data_in );
    begin
        wr_en=1'b1;
        wr_add=add;
        data_wr=data_in;
    
        @(posedge clk);
    
        wr_en=1'b0;
    end
endtask

task read_data( input [3:0]address, output [15:0]out);
    begin
        rd_add=address;
        @(posedge clk);
        out=data_out;
    end
endtask

task compare( input integer idx, input [15:0] data_actual,input [15:0]golden_data);
    if(idx == 0) // separate block to test the first word
        begin
            if(data_actual[7:0] === golden_data[7:0]) begin
                success = success+1;
            end
            else begin
                failure = failure+1;
            end
                cases = cases+1;
    end
    
    else 
        begin
            if(data_actual === golden_data) begin
                success = success+1;
            end
            else begin
                failure = failure+1;
            end
                cases = cases+1;
        end
endtask


reg [15:0] check [0:15];
reg [15:0]read_word;
reg [7:0]hi;
reg [7:0]low;
        
initial begin

    rst_n=1'b0;
    data_wr=8'b0;
    wr_en=1'b0;
    wr_add=5'b0; 
    op_mode=1'b0;
    
    #10; rst_n=1'b1;
    
    for(i=0; i<32; i=i+1) begin
        write_data( i, (2*i+1) );
    end
    #20;
    
    @(posedge clk);
    op_mode=1'b1;
    @(posedge clk);
    op_mode=1'b0;
    
    for( i=0; i<16; i=i+1) begin
        hi=4*i+1;
        low=4*i+3;
        check[i]= { hi, low };
    end
    
    wait(done === 1'b1) ;
    for(i=0; i<16; i=i+1) begin
        read_data(i, read_word);
        compare(i, read_word, check[i]) ;
    end
    $display("Cases =%d\tSuccess =%d\tFailure =%d\tSuccess rate =%d", cases,success, failure, (success/cases)*100 );
end
          
    
endmodule