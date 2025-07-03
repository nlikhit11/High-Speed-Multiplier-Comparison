module shift_add_multiplier_tb;
    reg clk, rst, start;
    reg [31:0] multiplicand, multiplier;
    wire [63:0] product;
    wire done, overflow;
    
    // Expected results (calculated using standard multiplication)
    reg [63:0] expected_product;
    
    // Instantiate the multiplier
    shift_add_multiplier uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product),
        .done(done),
        .overflow(overflow)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Task to perform multiplication test
    task test_multiply;
        input [31:0] a;
        input [31:0] b;
        input [63:0] expected;
        begin
            multiplicand = a;
            multiplier = b;
            expected_product = expected;
            start = 1;
            @(posedge clk);
            start = 0;
            @(posedge done);
          $display("Test: %d * %d = %d", 
                    $signed(multiplicand), 
                    $signed(multiplier), 
                    $signed(product));
            

            
            @(posedge clk);
        end
    endtask

    // Test vectors
    initial begin
        // Initialize
        rst = 1;
        start = 0;
        multiplicand = 0;
        multiplier = 0;
        @(posedge clk);
        rst = 0;
        @(posedge clk);

        // Test Case 1: Small positive numbers
        test_multiply(32'd123, 32'd456, 64'd56088);

        // Test Case 2: Negative * Positive
        test_multiply(-32'd123, 32'd456, -64'd56088);

        // Test Case 3: Negative * Negative
        test_multiply(-32'd123, -32'd456, 64'd56088);

        // Test Case 4: Zero cases
        test_multiply(32'd12345, 32'd0, 64'd0);
        test_multiply(32'd0, 32'd12345, 64'd0);

        // Test Case 5: Small negative numbers
        test_multiply(-32'd5, -32'd7, 64'd35);
        test_multiply(-32'd5, 32'd7, -64'd35);

        // Test Case 6: Maximum positive numbers
        test_multiply(32'h7FFFFFFF, 32'd2, 64'h0000000000000001FFFFFFFE);

        // Test Case 7: Minimum negative numbers
        test_multiply(32'h80000000, 32'd1, 64'h0000000080000000);

        // Test Case 8: Mixed boundary cases
      test_multiply(32'h7FFFFFFF, -32'h80000000,64'hC000000000000000);

        // End simulation
        #10;
        $display("Simulation completed");
        $finish;
    end

endmodule