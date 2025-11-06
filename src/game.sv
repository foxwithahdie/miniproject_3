module game (
    input logic clk,
    input logic [63:0] board,
    input logic write_board_state,
    output logic [63:0] next_state,
    output logic writing_board_done
);

logic [63:0] t_next_state;
logic [2:0] above_row, below_row, left_col, right_col;

logic [2:0] row, col;
logic pos;

logic upper_left, upper_mid, upper_right,
      left, right, lower_left, lower_mid,
      lower_right;

logic [5:0] counter;
logic [3:0] neighbors;

initial begin
    counter = 63;
    writing_board_done = 1'b0;
    t_next_state = 64'd0;
end

always_comb begin
    above_row = (row == 0) ? 7 : row - 1;
    below_row = (row == 7) ? 0 : row + 1;
    left_col  = (col == 0) ? 7 : col - 1;
    right_col = (col == 7) ? 0 : col + 1;

    pos = board[counter];

    upper_left = board[above_row * 8 + left_col];
    upper_mid = board[above_row * 8 + col];
    upper_right = board[above_row * 8 + right_col];
    left = board[row * 8 + left_col];
    right = board[row * 8 + right_col];
    lower_left = board[below_row * 8 + left_col];
    lower_mid = board[below_row * 8 + col];
    lower_right = board[below_row * 8 + right_col];

    neighbors = upper_left + upper_mid + upper_right + left +
                right + lower_left + lower_mid + lower_right;
end

    always_ff @(posedge clk) begin
        if (counter != 0) begin
            if ((((neighbors == 2 || neighbors == 3) && pos == 1'b1)) 
            ||  (((neighbors == 3) && pos == 1'b0))) begin
                    t_next_state[counter] = 1'b1;
            end else if (neighbors < 4'd2 || neighbors >= 4'd4) begin
                    t_next_state[counter] = 1'b0;
            end

            counter <= counter - 1;
            writing_board_done <= 1'b0;
            if ((counter + 1) % 8 == 0 && counter != 63) begin
                row <= row - 1;
                col <= 7;
            end
            col <= col - 1;
        end else if (write_board_state) begin
            counter <= 63;
            writing_board_done <= 1'b1;
            row <= 7;
            col <= 7;
        end

    end

    assign next_state = t_next_state;

endmodule
