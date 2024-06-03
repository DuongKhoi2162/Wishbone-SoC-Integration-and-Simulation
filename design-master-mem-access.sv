`default_nettype none

package wb_master_mem_access_pkg;

typedef enum int {
    STATE_INIT,
    STATE_START,
    STATE_WAIT_FOR_ACK_AFTER_WRITE,
    STATE_WAIT_BEFORE_READ,
    STATE_WAIT_FOR_ACK_AFTER_READ,
    STATE_IDLE
} state_t;

endpackage

module wb_master_mem_access (
    input  wire rst_i,
    input  wire clk_i,
    output wire stb_o,
    output wire cyc_o,
    output reg  we_o,
    output reg  [2*ADDR_WIDTH-1:0] adr_o,
    output reg  [DATA_WIDTH-1:0] dat_o,
    input  wire [DATA_WIDTH-1:0] dat_i,
    input  wire ack_i,
    input  wire err_i,
    output wire sel_o
);

    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 32;
    parameter START_ADDR = 0;
    
    parameter END_ADDR = 15; // inclusive
    parameter STEP = 1;

    import wb_master_mem_access_pkg::*;

    state_t state = STATE_INIT;

    reg stb = 0;
    reg cyc = 0;

    reg [ADDR_WIDTH-1:0] curr_addr = 0;
    reg [DATA_WIDTH-1:0] curr_data;
    reg [2:0] init_cycles = 0;

    assign stb_o = stb;
    assign cyc_o = cyc;

    always @(posedge clk_i) begin
        if (rst_i) begin
            state <= STATE_IDLE;
        end else begin
            case (state)
                STATE_INIT: begin
                    if (init_cycles[2] == 1'b1)
                        state <= STATE_START;

                    init_cycles <= init_cycles + 1;
                end
                STATE_IDLE: begin
                        state <= STATE_INIT;
                end
                STATE_START: begin
                    state <= STATE_WAIT_FOR_ACK_AFTER_WRITE;
                    stb <= 1;
                    cyc <= 1;
                    we_o <= 1'b1;
                    dat_o <= $urandom_range(16);
                    curr_data <= dat_o;
                end
                STATE_WAIT_FOR_ACK_AFTER_WRITE: begin
                    if (ack_i) begin
                        state <= STATE_WAIT_BEFORE_READ;
                        stb <= 0;
                        we_o <= 1'b0;
                    end else if (err_i) begin
                        // essentially retry
                        state <= STATE_START;
                        stb <= 0;
                        cyc <= 0;
                        we_o <= 1'b0;
                    end
                end
                STATE_WAIT_BEFORE_READ: begin
                    state <= STATE_WAIT_FOR_ACK_AFTER_READ;
                    stb <= 1;
                end
                STATE_WAIT_FOR_ACK_AFTER_READ: begin
                    if (ack_i) begin
                        state <= STATE_START;
                        stb <= 0;
                        cyc <= 0;
                    end
                end
            endcase
        end
    end

endmodule
