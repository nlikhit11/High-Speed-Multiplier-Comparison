// Wallace Tree Multiplier for 32-bit signed integers
module wallace_tree_multiplier (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] multiplicand,
    input  logic [31:0] multiplier,
    output logic [63:0] product,
    output logic        overflow
);

    // Internal signals
    logic [63:0] partial_products [32];
    logic sign_a, sign_b;
    logic [31:0] abs_multiplicand, abs_multiplier;
    logic [63:0] temp_product;
    
    // Calculate absolute values combinationally
    assign sign_a = multiplicand[31];
    assign sign_b = multiplier[31];
    
    function automatic logic [31:0] get_absolute(input logic [31:0] value);
        return value[31] ? (~value + 1'b1) : value;
    endfunction

    // Combinational logic for partial products
    always_comb begin
        abs_multiplicand = get_absolute(multiplicand);
        abs_multiplier = get_absolute(multiplier);
        
        // Generate partial products
        for (int i = 0; i < 32; i++) begin
            partial_products[i] = abs_multiplier[i] ? (64'(abs_multiplicand) << i) : '0;
        end
    end

    // Sequential logic for product calculation
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            product <= '0;
            overflow <= 1'b0;
            temp_product <= '0;
        end else begin
            // Sum all partial products
            temp_product = '0;
            for (int i = 0; i < 32; i++) begin
                temp_product = temp_product + partial_products[i];
            end

            // Apply sign correction
            if (sign_a ^ sign_b) begin
                product <= ~temp_product + 1'b1;
            end else begin
                product <= temp_product;
            end

            // Check for overflow
            overflow <= (product[63] != product[62]) && (|product[61:0]);
        end
    end
endmodule
