`include "src/led_matrix.sv"
`include "src/controller.sv"
`include "src/game.sv"
`include "src/memory.sv"

module top (
    input logic clk,
    output logic _48b,
    output logic _45a
);

logic [63:0] red_state;
logic [63:0] next_red_state;
// logic [63:0] green_state;
// logic [63:0] next_green_state;
// logic [63:0] blue_state;
// logic [63:0] next_blue_state;

logic curr_cell;
logic [2:0] prev_cell_row = 3'b0;
logic [2:0] prev_cell_col = 3'b0;
logic [2:0] cell_row;
logic [2:0] cell_col;

logic write_board_state;
logic push_cell;
logic led_matrix_push;

logic place_in_led_matrix;

    memory #(
        .INIT_FILE      ("initial_cond.txt")
    ) u1 (
        .clk             (clk),
        .board           (red_state)
    );

    // memory #(
    //     .INIT_FILE      ("initial_cond.txt")
    // ) u2 (
    //     .clk            (clk), 
    //     .read_cell_row  (cell_row),
    //     .read_cell_col  (cell_col),
    //     .board          (green_state),
    //     .curr_cell      (curr_cell)
    // );

    // memory #(
    //     .INIT_FILE      ("initial_cond.txt")
    // ) u3 (
    //     .clk            (clk), 
    //     .read_cell_row   (cell_row),
    //     .read_cell_col   (cell_col),
    //     .board           (blue_state),
    //     .curr_cell       (curr_cell)
    // );

    controller #(
    ) u4 (
        .clk (clk),
        .prev_cell_row (prev_cell_row),
        .prev_cell_col (prev_cell_col),
        .cell_row (cell_row),
        .cell_col (cell_col),
        .curr_cell (curr_cell),
        .write_board_state (write_board_state),
        .push_cell (push_cell)
    );

    game #() u7 (
        .clk (clk),
        .board (red_state),
        .curr_cell (curr_cell),
        .read_cell_row (cell_row),
        .read_cell_col (cell_col),
        .write_board_state (write_board_state),
        .next_state (next_red_state)
    );

    // game #() u8 (
    //     .clk (clk),
    //     .board (green_state),
    //     .curr_cell (curr_cell),
    //     .read_cell_row (cell_row),
    //     .read_cell_col (cell_col),
    //     .write_board_state (write_board_state),
    //     .next_state (next_green_state)
    // );

    // game #() u9 (
    //     .clk (clk),
    //     .board (blue_state),
    //     .curr_cell (curr_cell),
    //     .read_cell_row (cell_row),
    //     .read_cell_col (cell_col),
    //     .write_board_state (write_board_state),
    //     .next_state (next_blue_state)
    // );

    led_matrix #() u10 (
        .clk (clk),
        .curr_cell (curr_cell),
        .push_cell (push_cell),
        .led_matrix_push (led_matrix_push),
        .place_in_led_matrix (place_in_led_matrix)
    );

    always_comb begin
        prev_cell_row = cell_row;
        prev_cell_col = cell_col;
    end

    assign _45a = ~led_matrix_push;
    assign _48b = led_matrix_push;
    // controller #(
    // ) u5 (
    //     .clk (clk)
    //     .prev_cell_row (cell_row),
    //     .prev_cell_col (cell_col),
    //     .cell_row (cell_row),
    //     .cell_col (cell_col),
    //     .curr_cell (curr_cell),
    //     .write_board_state (write_board_state),
    //     .push_cell (push_cell)
    // );

    // controller #(
    // ) u6 (
    //     .clk (clk)
    //     .prev_cell_row (cell_row),
    //     .prev_cell_col (cell_col),
    //     .cell_row (cell_row),
    //     .cell_col (cell_col),
    //     .curr_cell (curr_cell),
    //     .write_board_state (write_board_state),
    //     .push_cell (push_cell)
    // );


endmodule
