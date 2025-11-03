module controller (
    input logic clk,
    input logic [2:0] prev_cell_row,
    input logic [2:0] prev_cell_col,
    output logic [2:0] cell_row,
    output logic [2:0] cell_col,
    output logic curr_cell,
    output logic write_board_state,
    output logic push_cell
);
    localparam PUSHING_STATE = 1'b0;
    localparam BUILDING_STATE = 1'b1;
    localparam [8:0] PUSHING_CYCLES    = 9'd360;       // = 24 bits / pixel x 15 cycles / bit
    localparam [19:0] BUILDING_CYCLES = 20'd351832;   // = 375000 - 64 x (360 + 2) for 32 frames / second
    localparam [19:0] CHANGE_CELL = 20'd5497; // 351832 cycles / 64 different positions
    
    localparam [2:0] READ_BOARD_STATE = 3'b001;
    localparam [2:0] WRITE_BOARD_STATE = 3'b010;
    localparam [2:0] PUSH_CELL = 3'b100;

    logic control_state = PUSHING_STATE;
    logic next_control_state;

    logic [2:0] pushing_phase = READ_BOARD_STATE;
    logic [2:0] next_pushing_phase;

    logic [5:0] cell_counter = 6'd63;
    logic [8:0] pushing_counter = 9'd0;
    logic [19:0] building_counter = 20'd0;

    logic pushing_state_done;
    logic building_state_done;

    assign pushing_state_done = (pushing_counter == PUSHING_CYCLES - 1); // assigning boolean to check when done
    assign building_state_done = (building_counter == BUILDING_CYCLES - 1);

    logic [2:0] tmp_row, tmp_col;


    always_ff @(posedge clk) begin
        control_state <= next_control_state;
        pushing_phase <= next_pushing_phase;
    end

    always_comb begin
        next_control_state = 1'bx;
        unique case (control_state)
            PUSHING_STATE:
                if ((cell_counter == 6'd0) && (pushing_state_done))
                    next_control_state = BUILDING_STATE;
                else
                    next_control_state = PUSHING_STATE;
            BUILDING_STATE:
                if (building_state_done)
                    next_control_state = PUSHING_STATE;
                else
                    next_control_state = BUILDING_STATE;
        endcase
    end

    always_comb begin
        next_pushing_phase = READ_BOARD_STATE;
        if (control_state == PUSHING_STATE) begin
            case (pushing_phase)
                READ_BOARD_STATE:
                    next_pushing_phase = WRITE_BOARD_STATE;
                WRITE_BOARD_STATE:
                    next_pushing_phase = PUSH_CELL;
                PUSH_CELL:
                    next_pushing_phase = building_state_done ? READ_BOARD_STATE : WRITE_BOARD_STATE;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if ((control_state == PUSHING_STATE) && pushing_state_done) begin
            cell_counter <= cell_counter - 1;
        end
    end

    always_ff @(posedge clk) begin
        if (pushing_phase == PUSH_CELL) begin
            pushing_counter <= pushing_counter + 1;
        end
        else begin
            pushing_counter <= 9'd0;
        end
    end

    always_ff @(posedge clk) begin
        if (building_counter == CHANGE_CELL) begin
            if (prev_cell_row == 7) begin
                tmp_row <= 0;
            end else begin
                tmp_row <= prev_cell_row + 1;
            end
            if (prev_cell_col == 7) begin
                tmp_col <= 0;
                tmp_row <= tmp_row + 1;
            end
            else begin
                tmp_col <= prev_cell_col + 1;
            end
        end else if (control_state == BUILDING_STATE) begin
            building_counter <= building_counter + 1;
        end else begin
            building_counter <= 20'd0;
        end
    end
    assign cell_row = tmp_row;
    assign cell_col = tmp_col;
    assign curr_cell = cell_counter;
    assign write_board_state = pushing_phase == WRITE_BOARD_STATE;
    assign push_cell = pushing_phase == PUSH_CELL;

endmodule