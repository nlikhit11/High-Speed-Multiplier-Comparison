module shift_add_multiplier (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [31:0] multiplicand,
    input wire [31:0] multiplier,
    output reg [63:0] product,
    output reg done,
    output reg overflow
);

    // State definitions
    localparam IDLE = 2'b00;
    localparam MULTIPLY = 2'b01;
    localparam FINISH = 2'b10;

    reg [1:0] state, next_state;
    reg [31:0] multiplier_reg;
    reg [63:0] multiplicand_reg;
    reg [5:0] count;
    reg sign_a, sign_b;
    reg [63:0] temp_product;
    
    // Helper function to get absolute value
    function [31:0] get_abs;
        input [31:0] value;
        begin
            get_abs = value[31] ? (-value) : value;
        end
    endfunction

    // State machine and control logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            overflow <= 0;
            count <= 0;
            product <= 64'b0;
            multiplier_reg <= 32'b0;
            multiplicand_reg <= 64'b0;
            temp_product <= 64'b0;
        end
        else begin
            state <= next_state;
            
            case (state)
                IDLE: begin
                    if (start) begin
                        // Store signs
                        sign_a <= multiplicand[31];
                        sign_b <= multiplier[31];
                        
                        // Convert to positive numbers
                        multiplier_reg <= get_abs(multiplier);
                        multiplicand_reg <= {{32{1'b0}}, get_abs(multiplicand)};
                        
                        count <= 0;
                        temp_product <= 64'b0;
                        done <= 0;
                        overflow <= 0;
                    end
                end

                MULTIPLY: begin
                    if (count < 32) begin
                        if (multiplier_reg[0]) begin
                            temp_product <= temp_product + multiplicand_reg;
                        end
                        multiplicand_reg <= multiplicand_reg << 1;
                        multiplier_reg <= multiplier_reg >> 1;
                        count <= count + 1;
                    end
                end

                FINISH: begin
                    // Final sign adjustment
                    if (sign_a ^ sign_b) begin
                        product <= -temp_product;
                    end
                    else begin
                        product <= temp_product;
                    end
                    
                    // Overflow detection for signed multiplication
                    if (sign_a ^ sign_b) begin
                        // For negative results
                        if (temp_product > 64'h8000000000000000) begin
                            overflow <= 1;
                        end
                    end
                    else begin
                        // For positive results
                        if (temp_product > 64'h7FFFFFFFFFFFFFFF) begin
                            overflow <= 1;
                        end
                    end
                    
                    done <= 1;
                end
            endcase
        end
    end

    // Next state logic
    always @(*) begin
        case (state)
            IDLE: 
                next_state = start ? MULTIPLY : IDLE;
            MULTIPLY: 
                next_state = (count == 32) ? FINISH : MULTIPLY;
            FINISH: 
                next_state = IDLE;
            default: 
                next_state = IDLE;
        endcase
    end

endmodule
