`default_nettype none

module wb_slave_1 (
    input wire rst_i,
    input wire clk_i,
    input wire stb_i,
    output wire ack_o,
    output wire [31:0] dat_o,
    input wire cyc_i,
    input wire we_i    
);
    state_t state = STATE_IDLE;
    // I believe it doesn't get any simpler than this
    reg err,ack;
    reg [31:0] r_data;
    always @(posedge clk_i) begin
        if (rst_i) begin
            state <= STATE_IDLE;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (stb_i) begin
                        state <= STATE_PROCESS;
                        ack <= 1'h0;
                    end
                end
                STATE_PROCESS: begin
                        if(!we_i)
                        r_data <= 32'hBBBB0000;
                        else
                        r_data <= 32'hx ;
                        ack <= 1'h1;
                        state <= STATE_WAIT_FOR_PHASE_END;
                end
                STATE_WAIT_FOR_PHASE_END: begin
                    if (~stb_i) begin
                        state <= STATE_IDLE;
                        ack <= 1'h0;
                    end
                end
            endcase
        end
    end
    assign ack_o = ack;
    assign dat_o = (!we_i)?r_data:32'hx ;
endmodule

