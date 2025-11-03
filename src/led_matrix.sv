module led_matrix (
    input logic clk,
    input logic curr_cell,
    input logic push_cell,
    output logic led_matrix_push,
    output logic place_in_led_matrix
);

localparam BUILDING_STATE = 1'b0;
localparam PUSHING_STATE = 1'b1;
localparam T0_CYCLE_COUNT = 6'd20;
localparam T1_CYCLE_COUNT = 6'd41;
localparam MAX_CYCLE_COUNT = 6'd63;

logic [5:0] cycle_count = 6'd0;

logic state = BUILDING_STATE;

logic bit_being_sent = 1'b0;

always_ff @(negedge clk) begin
    unique case (state)
        BUILDING_STATE:
            if (push_cell) begin
                state <= PUSHING_STATE;
                cycle_count <= 4'd0;
                bit_being_sent <= curr_cell;
            end
        PUSHING_STATE:
            if (~push_cell) begin
                state <= BUILDING_STATE;
            end else if (cycle_count == MAX_CYCLE_COUNT - 1) begin
                cycle_count <= 4'd0;
                bit_being_sent <= curr_cell;
            end else begin
                cycle_count <= cycle_count + 1;
            end
    endcase
end

always_comb begin
    if (state == PUSHING_STATE)
        if (bit_being_sent == 1'b0)
            led_matrix_push = (cycle_count < T0_CYCLE_COUNT);
        else
            led_matrix_push = (cycle_count < T1_CYCLE_COUNT);
    else
        led_matrix_push = 1'b0;
end

assign place_in_led_matrix = (state == PUSHING_STATE) && (cycle_count == 4'd0);


endmodule