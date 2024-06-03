
package wb_intercon_pkg;

    typedef enum {
        STATE_WAIT_FOR_BUS_CLAIM,
        STATE_WAIT_FOR_CYCLE_END
    } state_t;

endpackage

module wb_bus (
    input wire rst_i,
    input wire clk_i,

    //
    // master -> intercon
    //
    input wire [MASTERS_NUM-1:0] m2i_cyc_i,
    input wire [MASTERS_NUM-1:0] m2i_stb_i,
    input wire [MASTERS_NUM-1:0] m2i_we_i,
    input wire [MASTERS_NUM*ADDR_WIDTH-1:0] m2i_adr_i,
    input wire [MASTERS_NUM*DATA_WIDTH-1:0] m2i_dat_i,

    //
    // intercon -> master
    //
    output wire [MASTERS_NUM-1:0] i2m_ack_o,
    output wire [MASTERS_NUM-1:0] i2m_err_o,
    // shared between all masters
    output wire [DATA_WIDTH-1:0] i2m_dat_o,
    //
    // slave -> intercon
    //
    input wire [SLAVES_NUM-1:0] s2i_ack_i,
    input wire [SLAVES_NUM-1:0] s2i_err_i,
    input wire [SLAVES_NUM*DATA_WIDTH-1:0] s2i_dat_i,
    //
    // intercon -> slave
    //
    // each slave gets it's own stb signal
    output wire [SLAVES_NUM-1:0] i2s_stb_o,
    //  and these are all shared across all slaves
    output wire i2s_cyc_o,
    output wire [ADDR_WIDTH-1:0] i2s_adr_o,
    output wire [DATA_WIDTH-1:0] i2s_dat_o,
    output wire [3:0] i2s_sel_o,
    output wire i2s_we_o,

    // so we don't have to care about the ','
    output wire nc
);

    parameter MASTERS_NUM = 2;
    parameter SLAVES_NUM = 4;
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 32;
    localparam SEL_WIDTH = 8;
    import wb_intercon_pkg::*;

    state_t state = STATE_WAIT_FOR_BUS_CLAIM;
    reg [$clog2(MASTERS_NUM)-1:0] grant = 0;

    wire [$clog2(SLAVES_NUM)-1:0] selected_slave;

    // upper 4 bits of granted master's adr_o select the slave
    assign selected_slave = m2i_adr_i[ADDR_WIDTH*grant+ADDR_WIDTH-4+:4];

    // distribute the stb_o signal only to the one slave
    assign i2s_stb_o = m2i_stb_i[grant] << selected_slave;
    // distribute the rest of signals, which are shared across all slaves
    assign i2s_cyc_o = {SLAVES_NUM{m2i_cyc_i[grant]}};
    assign i2s_adr_o = m2i_adr_i[ADDR_WIDTH*grant+:ADDR_WIDTH] & 12'hfff;
    assign i2s_dat_o = m2i_dat_i[DATA_WIDTH*grant+:DATA_WIDTH];
    assign i2s_sel_o = 4'hF;
    assign i2s_we_o = m2i_we_i[grant];

    // distribute the ack and err signals coming back from the slave to the blessed master
    assign i2m_ack_o = s2i_ack_i[selected_slave] << grant;
    assign i2m_err_o = s2i_err_i[selected_slave] << grant;
    // distribute the output data of the selected slave to all masters
    assign i2m_dat_o = s2i_dat_i[DATA_WIDTH*selected_slave+:DATA_WIDTH];

    int n, i;
    bit found_next_master;

    always @(posedge clk_i) begin
        if (rst_i) begin
            state <= STATE_WAIT_FOR_BUS_CLAIM;
            grant <= 0;
        end else begin
            case (state)
                STATE_WAIT_FOR_BUS_CLAIM: begin
                    // reduction OR - check if at least one bit is set
                    if (|m2i_cyc_i) begin
                        found_next_master = 0;
                        // find the next right-most bit, starting from 'grant' bit
                        i = grant;
                        for (n = 0; n < MASTERS_NUM && !found_next_master; n++) begin
                            if (m2i_cyc_i[i]) begin
                                found_next_master = 1;
                                state <= STATE_WAIT_FOR_CYCLE_END;
                                grant <= i;
                            end

                            i = (i + 1) % MASTERS_NUM;
                        end
                    end
                end
                STATE_WAIT_FOR_CYCLE_END: begin
                    if (~m2i_cyc_i[grant]) begin
                        state <= STATE_WAIT_FOR_BUS_CLAIM;
                        grant <= (grant + 1) % MASTERS_NUM;
                    end
                end
            endcase
        end
    end

endmodule