
    module memory #(
        parameter INIT_FILE = ""
    )(
        input logic clk,
        output logic [63:0] board
    );

        logic tmp_board [0:63];

        initial if (INIT_FILE) begin
            $readmemb(INIT_FILE, tmp_board);
            board = 64'd0;
            for (int i = 0; i < 64; i++) begin
                board = board | (64'(tmp_board[i]) << i);
            end
        end


    endmodule

