`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2024 06:32:00 PM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module tb();
parameter DATA_WIDTH = 32;

reg rst_i;
reg clk_i;
reg [DATA_WIDTH-1:0] dat_i;
top_soc test(.rst_i(rst_i), .clk_i(clk_i));
reg [11:0] address;
int i,true1,true2,true; 
initial begin
    clk_i = 0;
    rst_i = 1;
    i = 0 ; 
    #10
    rst_i = 0;
    #65;
    $display("-----------------SLAVE 0 CHECKING-----------------");
    test.MASTER.adr_o = 16'h0000; 
    #25;
    if(test.MASTER.dat_i === 32'bx && test.MASTER.ack_i == 1'b1)
        $display("WRITE: Ignore Write");
    else
        $display("Write Failed");
    #15;
    test.MASTER.adr_o = 16'h0010; 
    #25;
    if(test.MASTER.dat_i == 32'haaaa0000 && test.MASTER.ack_i == 1'b1)
        $display("READ: Read successfully, Data = %h",test.MASTER.dat_i);
    else
        $display("Read Failed");   
    #15;
    test.MASTER.adr_o = 16'h0004; 
    #10;
    #25;
    if(test.MASTER.dat_i === 32'bx && test.MASTER.ack_i == 1'b1)
        $display("WRITE: Ignore Write");
    else
        $display("Write Failed");
    #15;
    test.MASTER.adr_o = 16'h0014; 
    #25;
    if(test.MASTER.dat_i == 32'haaaa0000 && test.MASTER.ack_i == 1'b1)
        $display("READ: Read successfully, Data = %h",test.MASTER.dat_i);
    else
        $display("Read Failed");  
    #15;
    $display("-----------------SLAVE 1 CHECKING-----------------");
    test.MASTER.adr_o = 16'h1000; 
    #10;
    #25;
    if(test.MASTER.dat_i === 32'bx && test.MASTER.ack_i == 1'b1)
        $display("WRITE: Ignore Write");
    else
        $display("Write Failed");
    #15;
    test.MASTER.adr_o = 16'h1010; 
    #25;
    if(test.MASTER.dat_i == 32'hbbbb0000 && test.MASTER.ack_i == 1'b1)
        $display("READ: Read successfully, Data = %h",test.MASTER.dat_i);
    else
        $display("Read Failed"); 
    #15;
    test.MASTER.adr_o = 16'h1004; 
    #10;
    #25;
    if(test.MASTER.dat_i === 32'bx && test.MASTER.ack_i == 1'b1)
        $display("WRITE: Ignore Write");
    else
        $display("Write Failed");
    #15;
    test.MASTER.adr_o = 16'h1014; 
    #25;
    if(test.MASTER.dat_i == 32'hbbbb0000 && test.MASTER.ack_i == 1'b1)
        $display("READ: Read successfully, Data = %h",test.MASTER.dat_i);
    else
        $display("Read Failed"); 
    #15;
    $display("-----------------SLAVE 2 CHECKING-----------------");    
    repeat(100) begin 
    $display("Data Transfer #%2d",i);     
    address = $random; 
    test.MASTER.adr_o = {4'b0010,address};
    #35; 
    if(test.MASTER.ack_i == 1'b1 && test.SLAVE2.register_value[address] == test.MASTER.dat_o) begin
        $display("WRITE: write successfully, data = %2d, address = %4h",test.MASTER.dat_o,test.MASTER.adr_o);
        true1 = 1'b1;
        end
    else begin
        $display("Write Failed");
        true1 = 1'b0;
        end
    #40;
    if(test.MASTER.ack_i == 1'b1 && test.MASTER.dat_o == test.SLAVE2.register_value[address]) begin
        $display("READ: read successfully, data = %2d, address = %4h",test.MASTER.dat_i,test.MASTER.adr_o);
        true2 = 1'b1;
        end
    else begin
        $display("Read Failed");
        true2 = 1'b0;
        end
    i = i + 1 ; 
    if (true1&&true2) true = true + 1; 
    #15;   
    end
    $display("Number of correct data transfer cycles: %3d/100", true); 
end
always #5 clk_i = ~clk_i;

endmodule
