module mac_tb;
    logic clk;
    logic rst;
    logic signed [7:0] a;
    logic signed [7:0] b;
    logic signed [31:0] out;

    // Instantiate the device under test (DUT)
    mac dut (.clk(clk), .rst(rst), .a(a), .b(b), .out(out));

    // 10ns clock period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, mac_tb);
        
        // Watch and print the signals
        $monitor("Time=%0t | rst=%b | a=%3d, b=%3d | out=%d", $time, rst, a, b, out);
        
        // Initialize
        clk = 0; rst = 1; a = 0; b = 0;
        #10;
        
        // Test sequence 1: a=3, b=4 for 3 cycles
        rst = 0; a = 3; b = 4;
        #30; 
        
        // Assert reset
        rst = 1;
        #10; 
        
        // Test sequence 2: a=-5, b=2 for 2 cycles
        rst = 0; a = -5; b = 2;
        #20; 
        
        $finish;
    end
endmodule
