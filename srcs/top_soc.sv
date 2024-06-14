`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/22/2024 01:59:00 PM
// Design Name: 
// Module Name: top_soc
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
`default_nettype none
parameter ADDR_WIDTH = 16;
parameter DATA_WIDTH = 32;
parameter MASTERS_NUM = 1;
parameter SLAVES_NUM = 3;
localparam SEL_WIDTH = 1;
module top_soc(
    input  wire rst_i,
    input  wire clk_i
    );
//MASTER WIRE
    wire [DATA_WIDTH-1:0] dat_i;
    wire stb_o;
    wire cyc_o;
    wire  we_o;
    wire  [ADDR_WIDTH-1:0] adr_o;
    wire  [DATA_WIDTH-1:0] dat_o;
    wire ack_i;
    wire err_i; 
//BUS WIRE : nhan dia chi, select chon slave, tin hieu nao quyet dinh select ? 
    wire [MASTERS_NUM-1:0] m2i_cyc_i;
    wire [MASTERS_NUM-1:0] m2i_stb_i;
    wire [MASTERS_NUM-1:0] m2i_we_i;
    wire [MASTERS_NUM*ADDR_WIDTH-1:0] m2i_adr_i;
    wire [MASTERS_NUM*DATA_WIDTH-1:0] m2i_dat_i;
    wire [MASTERS_NUM*SEL_WIDTH-1:0] m2i_sel_i;
        // intercon -> master
    wire [MASTERS_NUM-1:0] i2m_ack_o;
    wire [MASTERS_NUM-1:0] i2m_err_o;
        // shared between all masters
    wire [DATA_WIDTH-1:0] i2m_dat_o;
        // slave -> intercon
    wire [SLAVES_NUM-1:0] s2i_ack_i;
    wire [SLAVES_NUM-1:0] s2i_err_i;
    wire [SLAVES_NUM*DATA_WIDTH-1:0] s2i_dat_i;
        // intercon -> slave
        // each slave gets it's own stb signal
    wire [SLAVES_NUM-1:0] i2s_stb_o;
        //  and these are all shared across all slaves
    wire i2s_cyc_o;

    wire [ADDR_WIDTH-1:0] i2s_adr_o;
    wire [DATA_WIDTH-1:0] i2s_dat_o;
    wire [3:0] i2s_sel_o;
    wire i2s_we_o;
        // so we don't have to care about the ','
    wire nc;
//SLAVE0 WIRE
    wire cyc_i_s;
    wire stb_i_0;
    wire cyc_i_0;
    wire we_i ;
    wire [DATA_WIDTH-1:0] s_dat_o_0;
//SLAVE1 WIRE
    wire stb_i_1;
    wire cyc_i_1;
    wire [DATA_WIDTH-1:0] s_dat_o_1;
//SLAVE2 WIRE
    wire [ADDR_WIDTH-1:0] adr_i_2;
    wire [DATA_WIDTH-1:0] dat_i_2;
    wire [DATA_WIDTH-1:0] s_dat_o_2;
    wire [3:0] sel_i_s;
    wire stb_i_2;
    wire ack_o_0,ack_o_1,ack_o_2;
    wire err_o_2;
    wire cyc_i_2;
//--------------MASTER-------------------------------------------------//
wb_master_mem_access MASTER(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .stb_o(stb_o),
    .cyc_o(cyc_o),
    .we_o(we_o),
    .adr_o(adr_o),
    .dat_o(dat_o),
    .dat_i(dat_i),
    .ack_i(ack_i),
    .err_i(err_i)
    );
assign dat_i = i2m_dat_o ; 
assign ack_i = i2m_ack_o ; 
assign err_i = i2m_err_o ; 
//--------------BUS---------------------------------------------------//

wb_bus BUS(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .m2i_cyc_i(m2i_cyc_i),
    .m2i_stb_i(m2i_stb_i),
    .m2i_we_i(m2i_we_i),
    .m2i_adr_i(m2i_adr_i),
    .m2i_dat_i(m2i_dat_i),
    .i2m_ack_o(i2m_ack_o),
    .i2m_err_o(i2m_err_o),
    .i2m_dat_o(i2m_dat_o),
    .s2i_ack_i(s2i_ack_i),
    .s2i_err_i(s2i_err_i),
    .s2i_dat_i(s2i_dat_i),
    .i2s_stb_o(i2s_stb_o),
    .i2s_cyc_o(i2s_cyc_o),
    .i2s_adr_o(i2s_adr_o),
    .i2s_dat_o(i2s_dat_o),
    .i2s_sel_o(i2s_sel_o),
    .i2s_we_o(i2s_we_o),
    .nc(nc)
    );

assign m2i_cyc_i = cyc_o; 
assign m2i_stb_i = stb_o;
assign m2i_we_i = we_o; 
assign m2i_adr_i = adr_o;
assign m2i_sel_i = 8'hFF;
assign s2i_dat_i = {s_dat_o_2,s_dat_o_1,s_dat_o_0};
assign s2i_ack_i = {ack_o_2,ack_o_1,ack_o_0};
assign s2i_err_i = err_o_2;
assign we_i = i2s_we_o;
assign m2i_dat_i = dat_o; 
//--------------SLAVE0---------------------------------------------------//
assign stb_i_0 = i2s_stb_o[0];
assign stb_i_1 = i2s_stb_o[1];
assign stb_i_2 = i2s_stb_o[2];
assign cyc_i_s = i2s_cyc_o;
assign dat_i_2 = i2s_dat_o;
wb_slave_0 SLAVE0(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .stb_i(stb_i_0),
    .ack_o(ack_o_0),
    .cyc_i(cyc_i_s),
    .dat_o(s_dat_o_0),
    .we_i(we_i)
    );
//--------------SLAVE1---------------------------------------------------//
wb_slave_1 SLAVE1(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .stb_i(stb_i_1),
    .ack_o(ack_o_1),
    .cyc_i(cyc_i_s),
    .dat_o(s_dat_o_1),
    .we_i(we_i)
    );
//--------------SLAVE2---------------------------------------------------//
assign adr_i_2 = i2s_adr_o;
wb_slave_2 SLAVE2(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .adr_i(adr_i_2),
    .dat_i(dat_i_2),
    .dat_o(s_dat_o_2),
    .sel_i(sel_i_s),
    .we_i(we_i),
    .stb_i(stb_i_2),
    .ack_o(ack_o_2),
    .err_o(err_o_2),
    .cyc_i(cyc_i_s)
    );
assign sel_i_s = i2s_sel_o;
endmodule

