// Testbench for Wallace Tree Multiplier
module wallace_tree_multiplier_tb;
    reg clk;
    reg reset;
    reg signed [31:0] multiplicand; // Declared as signed
    reg signed [31:0] multiplier;   // Declared as signed
    wire signed [63:0] product;     // Declared as signed
    wire overflow;
    
    // Instantiate the multiplier
    wallace_tree_multiplier WTM (
        .clk(clk),
        .reset(reset),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product),
        .overflow(overflow)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
 
    
    // Test vectors
    initial begin

        multiplicand = 32'sd0; // Use signed decimal format
        multiplier = 32'sd0;  // Use signed decimal format
          #10;
      $display("Test Case : %d * %d = %d", multiplicand, multiplier, product);
    
      
        
        // Test Case 1: Positive * Positive
        multiplicand = 32'sd123;
        multiplier = 32'sd456;
         #10;
      $display("Test Case : %d * %d = %d", multiplicand, multiplier, product);
     
        
        // Test Case 2: Negative * Positive
        multiplicand = -32'sd123;
        multiplier = 32'sd456;
   #10 ;
      $display("Test Case : %d * %d = %d", multiplicand, multiplier, product);
        
        // Test Case 3: Negative * Negative
        multiplicand = -32'sd123;
        multiplier = -32'sd456;
         #10 ;
      $display("Test Case : %d * %d = %d", multiplicand, multiplier, product);
        
        // Test Case 4: Zero multiplication
        multiplicand = 32'sd0;
        multiplier = 32'sd456;
         #10;
      $display("Test Case : %d * %d = %d", multiplicand, multiplier, product);

        
        // Test Case 5: Maximum positive numbers
        multiplicand = 32'sh7FFFFFFF; // Maximum signed 32-bit number
        multiplier = 32'sh7FFFFFFF;
         #10 ;
      $display("Test Case : %d * %d = %d", multiplicand, multiplier, product);
        
        // Test Case 6: Minimum negative numbers
        multiplicand = 32'sb10000000000000000000000000000000; // Minimum signed 32-bit number
        multiplier = 32'sb10000000000000000000000000000000;
         #10 ;
      $display("Test Case : %d * %d = %d", multiplicand, multiplier, product);
 $finish;

    end
    
   
endmodule
