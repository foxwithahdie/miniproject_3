// Test file for top.
`timescale 10ns/10ns
`include "src/top.sv"
`include "tests/setup.v"

module test_top;
    // Determined by compilation process. Read Makefile for more.
    output logic [255 * 8 - 1 : 0] file_name;

    setup u0(
        .file_name (file_name)
    );

    // Give fake values of all of these, instead of them going to the iceBlinkPico.
    logic clk = 0;
    logic _48b;
    logic _45a;

    // Run top
    top #(
    ) test_u0 (
        .clk (clk),
        ._48b (_48b),
        ._45a (_45a)
    );

    // Dump file and variables into a program
   initial begin
        $dumpfile(file_name);
        $dumpvars(0, test_top);
        #100000000
        $finish;
    end

    // Automatically run clock
    always begin
        // The simulation is run at 12.5MHz instead of 12MHz, 
        // but it should theoretically run with the same behavior.
        #4
        clk = ~clk;
    end

endmodule