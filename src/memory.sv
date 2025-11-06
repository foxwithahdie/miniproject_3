
module memory #(
    parameter INIT_STATE = ""//64'b0000100000001000000010000000000000000000000000000000000000000000
) (
    input logic clk,
    input logic [5:0] read_address,
    input logic [63:0] next_state,
    output logic [63:0] curr_state,
    output logic [7:0] read_data,
    input logic write_board_state,
    input logic writing_board_done
);
    logic [7:0] memh_read [7:0];
    logic [63:0] t_curr_state;
    logic [63:0] init_state_val;
    logic [7:0] mem [0:63];
    logic [5:0] write_board_counter;
    logic write_board_state_prev;

    initial begin
        if (INIT_STATE) begin
            $readmemh(INIT_STATE, memh_read);
        end
        t_curr_state = 64'b0;
        write_board_counter = 0;
    end

    always_ff @(posedge clk) begin
        write_board_state_prev <= write_board_state;

        // initial change
        if (t_curr_state == 64'b0 && write_board_counter == 0) begin
            for (int i = 7; i >= 0; i--) begin
                for (int j = 7; j >= 0; j--) begin
                    t_curr_state[i * 8 + j] <= memh_read[i][j];
                end
            end
        end

        // write board logic
        if (write_board_state_prev && !write_board_state) begin
            if (write_board_counter == 63) begin
                t_curr_state <= next_state;
                write_board_counter <= 0;
            end else begin
                write_board_counter <= write_board_counter + 1;
            end
        end

        // write memory logic
        for (int i = 0; i < 64; i++) begin
            if (t_curr_state[i] == 1'b1) begin
                mem[i] <= 8'b11110000;
            end else begin
                mem[i] <= 8'b00000000;
            end
        end

        read_data <= mem[read_address];
    end
    
    assign curr_state = t_curr_state;

endmodule
