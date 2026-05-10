`timescale 1ns / 1ps

module crossbar_tb;

    // Testbench signals
    logic               clk;
    logic               rst_n;
    logic               load_en;
    logic signed [1:0]  weight_in [0:3][0:3];
    logic signed [7:0]  in [0:3];
    logic signed [15:0] out [0:3];

    // Instantiate the Device Under Test (DUT)
    crossbar_mac dut (
        .clk(clk),
        .rst_n(rst_n),
        .load_en(load_en),
        .weight_in(weight_in),
        .in(in),
        .out(out)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // 1. Initialize Signals & Reset
        rst_n = 0;
        load_en = 0;
        for(int i=0; i<4; i++) begin
            in[i] = 0;
            for(int j=0; j<4; j++) begin
                weight_in[i][j] = 0;
            end
        end

        // Hold reset for a few cycles, then release
        #20;
        rst_n = 1; 
        #10;

        // 2. Load the 4x4 Weights Matrix
        // (+1 is 2'b01, -1 is 2'b11 in 2-bit signed logic)
        
        // Row 0: [ 1, -1,  1, -1]
        weight_in[0][0] = 2'b01; weight_in[0][1] = 2'b11; weight_in[0][2] = 2'b01; weight_in[0][3] = 2'b11;
        // Row 1: [ 1,  1, -1, -1]
        weight_in[1][0] = 2'b01; weight_in[1][1] = 2'b01; weight_in[1][2] = 2'b11; weight_in[1][3] = 2'b11;
        // Row 2: [-1,  1,  1, -1]
        weight_in[2][0] = 2'b11; weight_in[2][1] = 2'b01; weight_in[2][2] = 2'b01; weight_in[2][3] = 2'b11;
        // Row 3: [-1, -1, -1,  1]
        weight_in[3][0] = 2'b11; weight_in[3][1] = 2'b11; weight_in[3][2] = 2'b11; weight_in[3][3] = 2'b01;
        
        // Assert load_en for one clock cycle to latch weights
        load_en = 1;
        #10;
        load_en = 0; 
        #10;

        // 3. Apply Inputs: [10, 20, 30, 40]
        in[0] = 8'sd10;
        in[1] = 8'sd20;
        in[2] = 8'sd30;
        in[3] = 8'sd40;

        // 4. Wait one clock cycle for the computation to latch into output registers
        #10;

        // 5. Verify the outputs against hand-calculated MVM results
        $display("\n--- Crossbar MAC Simulation Results ---");
        $display("Inputs applied: [%0d, %0d, %0d, %0d]", in[0], in[1], in[2], in[3]);
        $display("Hardware Output: out[0]=%0d, out[1]=%0d, out[2]=%0d, out[3]=%0d", 
                 out[0], out[1], out[2], out[3]);
                 
        // Expected Hand Calculations: 
        // out[0] = 10(1) + 20(1) + 30(-1) + 40(-1) = -40
        // out[1] = 10(-1) + 20(1) + 30(1) + 40(-1) = 0
        // out[2] = 10(1) + 20(-1) + 30(1) + 40(-1) = -20
        // out[3] = 10(-1) + 20(-1) + 30(-1) + 40(1) = -20

        if (out[0] == -40 && out[1] == 0 && out[2] == -20 && out[3] == -20) begin
            $display("STATUS: PASS! The hardware output perfectly matches the expected MVM.");
        end else begin
            $display("STATUS: FAIL! Check your logic, outputs do not match.");
        end
        $display("---------------------------------------\n");
        
        $finish;
    end

endmodule
