`timescale 1ns / 1ps

module crossbar_mac (
    input  logic               clk,
    input  logic               rst_n,                // Active-low reset
    input  logic               load_en,              // Signal to load weights into registers
    input  logic signed [1:0]  weight_in [0:3][0:3], // 2-bit signed (+1 is 2'b01, -1 is 2'b11)
    input  logic signed [7:0]  in [0:3],             // 4 input lines, 8-bit signed
    output logic signed [15:0] out [0:3]             // 4 output lines (accumulator)
);

    // 4x4 register array to store the binary weights
    logic signed [1:0] weight_reg [0:3][0:3];

    // Combinational logic for the Matrix-Vector Multiplication (MVM)
    logic signed [15:0] dot_product [0:3];

    always_comb begin
        for (int j = 0; j < 4; j++) begin
            dot_product[j] = 16'sd0; // Initialize column sum to zero
            for (int i = 0; i < 4; i++) begin
                // out[j] = Sum(in[i] * weight[i][j])
                dot_product[j] = dot_product[j] + (in[i] * weight_reg[i][j]);
            end
        end
    end

    // Sequential logic for weight registers and output accumulator
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Clear weights and outputs on reset
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    weight_reg[i][j] <= 2'sd0;
                end
                out[i] <= 16'sd0;
            end
        end else begin
            // Update weight registers if load is enabled (iverilog loop workaround)
            if (load_en) begin
                for (int i = 0; i < 4; i++) begin
                    for (int j = 0; j < 4; j++) begin
                        weight_reg[i][j] <= weight_in[i][j];
                    end
                end
            end
            
            // Latch the computed MVM result into the output registers (iverilog loop workaround)
            for (int j = 0; j < 4; j++) begin
                out[j] <= dot_product[j];
            end
        end
    end

endmodule
