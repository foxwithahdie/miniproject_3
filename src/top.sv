`include "src/memory.sv"
`include "src/led_matrix.sv"
`include "src/controller.sv"
`include "src/game.sv"

// led_matrix top level module

module top(
    input logic     clk,
    output logic    _48b, 
    output logic    _45a
);

    logic [7:0] red_data;
    logic [63:0] red_board;
    logic [63:0] next_red_board;
    logic [7:0] green_data;
    logic [63:0] green_board;
    logic [63:0] next_green_board;
    logic [7:0] blue_data;
    logic [63:0] blue_board;
    logic [63:0] next_blue_board;
    logic red_writing_board_done;
    logic green_writing_board_done;
    logic blue_writing_board_done;

    logic [5:0] pixel;
    logic [5:0] address;

    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;

    assign address = pixel;

    // Instance sample memory for red channel
    memory #(
        .INIT_STATE     ("data/red.txt")
    ) red_memory (
        .clk            (clk), 
        .read_address   (address),
        .next_state     (next_red_board),
        .curr_state     (red_board),
        .read_data      (red_data),
        .write_board_state (transmit_pixel),
        .writing_board_done (red_writing_board_done)
    );

    // Instance sample memory for green channel
    memory #(
        .INIT_STATE     ("data/green.txt")
    ) green_memory (
        .clk            (clk), 
        .read_address   (address),
        .next_state     (next_green_board),
        .curr_state     (green_board),
        .read_data      (green_data),
        .write_board_state (transmit_pixel),
        .writing_board_done (green_writing_board_done)
    );

    // Instance sample memory for blue channel
    memory #(
        .INIT_STATE     ("data/blue.txt")
    ) blue_memory (
        .clk            (clk), 
        .read_address   (address),
        .next_state     (next_blue_board),
        .curr_state     (blue_board), 
        .read_data      (blue_data),
        .write_board_state (transmit_pixel),
        .writing_board_done (blue_writing_board_done)

    );

    // Instance the WS2812B output driver
    led_matrix led_matrix_push (
        .clk            (clk), 
        .serial_in      (shift_reg[23]), 
        .transmit       (transmit_pixel), 
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    // Instance the controller
    controller main_controller (
        .clk            (clk), 
        .load_sreg      (load_sreg), 
        .transmit_pixel (transmit_pixel), 
        .pixel          (pixel)
    );

    game red_game (
        .clk (clk),
        .board (red_board),
        .next_state (next_red_board),
        .write_board_state (transmit_pixel),
        .writing_board_done (red_writing_board_done)
    );

    game green_game (
        .clk (clk),
        .board (green_board),
        .next_state (next_green_board),
        .write_board_state (transmit_pixel),
        .writing_board_done (green_writing_board_done)
    );

    game blue_game (
        .clk (clk),
        .board (blue_board),
        .next_state (next_blue_board),
        .write_board_state (transmit_pixel),
        .writing_board_done (blue_writing_board_done)
    );

    always_ff @(posedge clk) begin
        if (load_sreg) begin
            shift_reg <= { green_data, red_data, blue_data };
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule
