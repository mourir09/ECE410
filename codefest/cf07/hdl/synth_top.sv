`timescale 1ns / 1ps

// `include "interface.sv"
// `include "compute_core.sv"

module synth_top (
    input  logic               clk,
    input  logic               rst,

    // AXI4-Stream Subordinate (Inbound)
    input  logic               s_axis_tvalid,
    output logic               s_axis_tready,
    input  logic [15:0]        s_axis_tdata,

    // AXI4-Stream Manager (Outbound)
    output logic               m_axis_tvalid,
    input  logic               m_axis_tready,
    output logic [31:0]        m_axis_tdata
);

    // Internal wires connecting the interface to the compute core
    logic               core_valid_in;
    logic signed [7:0]  core_a_in;
    logic signed [7:0]  core_b_in;
    logic               core_valid_out;
    logic signed [31:0] core_result;

    // Instantiate the AXI Interface
    axi_interface intf_inst (
        .clk(clk),
        .rst(rst),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .core_valid_in(core_valid_in),
        .core_a_in(core_a_in),
        .core_b_in(core_b_in),
        .core_valid_out(core_valid_out),
        .core_result(core_result)
    );

    // Instantiate the Compute Core
    compute_core core_inst (
        .clk(clk),
        .rst(rst),
        .valid_in(core_valid_in),
        .a_in(core_a_in),
        .b_in(core_b_in),
        .valid_out(core_valid_out),
        .result(core_result)
    );

endmodule
