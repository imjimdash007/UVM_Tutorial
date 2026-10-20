module counter (
    input wire	     clk,
    input wire	     rst,
    input wire	     load, 
    input wire [3:0] count_in,  // Changed input from reg to wire (standard practice)
    output reg [3:0] count_out		
);
    // Removed "posedge load" so load behaves as a proper synchronous signal
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count_out <= 4'b0000;      // 1. Reset takes highest priority
	end else if (load) begin
            count_out <= count_in;     // 2. Load takes second priority
        end else begin
            count_out <= count_out + 1; // 3. Increments properly when rst/load are 0
        end
    end
endmodule



