module game (
    input logic clk,
    input logic [63:0] board,
    input logic curr_cell,
    input logic [2:0] read_cell_row,
    input logic [2:0] read_cell_col,
    input logic write_board_state,
    output logic [63:0] next_state
);

logic [63:0] t_next_state;
logic t_cell;
logic [2:0] above_row, below_row, left_col, right_col;

logic upper_left, upper_mid, upper_right,
      left, right, lower_left, lower_mid,
      lower_right;

logic [5:0] counter;
logic [3:0] neighbors;

    always_comb begin
        above_row = read_cell_row - 1;
        below_row = read_cell_row + 1;
        left_col = read_cell_col - 1;
        right_col = read_cell_col + 1;

        upper_left = calculate_pos(board, above_row, left_col);
        upper_mid = calculate_pos(board, above_row, read_cell_col);
        upper_right = calculate_pos(board, above_row, right_col);
        left = calculate_pos(board, read_cell_row, left_col);
        right = calculate_pos(board, read_cell_row, right_col);
        lower_left = calculate_pos(board, below_row, left_col);
        lower_mid = calculate_pos(board, below_row, read_cell_col);
        lower_right = calculate_pos(board, below_row, right_col);
        neighbors = upper_left + upper_mid + upper_right + left +
                 right + lower_left + lower_mid + lower_right;
    end

    always_ff @(negedge clk) begin
        if (counter != 6'd63 && write_board_state) begin
            if (((neighbors > 4'd2 && neighbors <= 4'd3) && curr_cell == 1'b1) 
            ||  (neighbors == 4'd3) && curr_cell == 1'b0) begin
                t_cell <= 1;
            end else if (neighbors < 4'd2 || neighbors >= 4'd4) begin
                t_cell <= 0;
            end
            t_next_state <= t_next_state | (t_cell << counter);
            counter <= counter + 1;
        end else
            counter <= 0;

    end

        function logic calculate_pos(
            logic [63:0] board,
            logic [2:0] cell_row,
            logic [2:0] cell_col
        );

        calculate_pos = (board >> (cell_row * 8 + cell_col)) & 1'b1;

        endfunction


    assign next_state = t_next_state;




endmodule