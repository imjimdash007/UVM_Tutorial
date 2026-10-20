module apb_fsm_regs (
    // Clock and Reset
    input  logic        pclk,
    input  logic        presetn,

    // APB Interface
    input  logic [31:0] paddr,
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic        pready,
    output logic        pslverr
);

    // State Encoding
    typedef enum logic [1:0] {
        STATE0 = 2'b00,
        STATE1 = 2'b01,
        STATE2 = 2'b10,
        STATE3 = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Configuration Registers (Read/Write)
    logic [3:0] reg0;
    logic [3:0] reg1;
    logic [3:0] reg2;
    logic [3:0] reg3;

    // Status Register (Read-Only)
    logic [3:0] status_reg;

    // APB Internal Signals
    logic apb_write_stroke;
    assign apb_write_stroke = psel && penable && pwrite;
    assign pready  = 1'b1; // Zero wait-state access
    assign pslverr = 1'b0; // No slave error handling

    //---------------------------------------------------------
    // 1. Explicit Address Map Decoder
    //---------------------------------------------------------
    // Masking higher bits to decode word-aligned addresses 0, 4, 8, C, 10
    localparam logic [7:0] ADDR_REG0   = 8'h00;
    localparam logic [7:0] ADDR_REG1   = 8'h04;
    localparam logic [7:0] ADDR_REG2   = 8'h08;
    localparam logic [7:0] ADDR_REG3   = 8'h0C;
    localparam logic [7:0] ADDR_STATUS = 8'h10;

    //---------------------------------------------------------
    // 2. Register Write Interface
    //---------------------------------------------------------
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            reg0 <= 4'b0001;
            reg1 <= 4'b0001;
            reg2 <= 4'b0001;
            reg3 <= 4'b0001;
        end else if (apb_write_stroke) begin
            case (paddr[7:0]) 
                ADDR_REG0: reg0 <= pwdata[3:0];
                ADDR_REG1: reg1 <= pwdata[3:0];
                ADDR_REG2: reg2 <= pwdata[3:0];
                ADDR_REG3: reg3 <= pwdata[3:0];
                // ADDR_STATUS is Read-Only, ignoring APB writes to 0x10
                default: ; 
            endcase
        end
    end

    //---------------------------------------------------------
    // 3. Status Register One-Hot Generation
    //---------------------------------------------------------
    always_comb begin
        status_reg = 4'b0000;
        case (current_state)
            STATE0: status_reg[0] = 1'b1;
            STATE1: status_reg[1] = 1'b1;
            STATE2: status_reg[2] = 1'b1;
            STATE3: status_reg[3] = 1'b1;
            default: status_reg = 4'b0001;
        endcase
    end

    //---------------------------------------------------------
    // 4. Register Read Interface (Data Multiplexer)
    //---------------------------------------------------------
    always_comb begin
        prdata = 32'b0;
        if (psel && !pwrite) begin
            case (paddr[7:0])
                ADDR_REG0:   prdata = {28'b0, reg0};
                ADDR_REG1:   prdata = {28'b0, reg1};
                ADDR_REG2:   prdata = {28'b0, reg2};
                ADDR_REG3:   prdata = {28'b0, reg3};
                ADDR_STATUS: prdata = {28'b0, status_reg};
                default:     prdata = 32'b0;
            endcase
        end
    end

    //---------------------------------------------------------
    // 5. Original FSM State Sequential Logic
    //---------------------------------------------------------
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            current_state <= STATE0;
        end else begin
            current_state <= next_state;
        end
    end

    //---------------------------------------------------------
    // 6. Original FSM Next-State Combinational Logic
    //---------------------------------------------------------
    always_comb begin
        next_state = current_state; 

        case (current_state)
            STATE0: begin
                case (1'b1)
                    reg0[0]: next_state = STATE0;
                    reg0[1]: next_state = STATE1;
                    reg0[2]: next_state = STATE2;
                    reg0[3]: next_state = STATE3;
                    default: next_state = STATE0;
                endcase
            end

            STATE1: begin
                case (1'b1)
                    reg1[0]: next_state = STATE0;
                    reg1[1]: next_state = STATE1;
                    reg1[2]: next_state = STATE2;
                    reg1[3]: next_state = STATE3;
                    default: next_state = STATE1;
                endcase
            end

            STATE2: begin
                case (1'b1)
                    reg2[0]: next_state = STATE0;
                    reg2[1]: next_state = STATE1;
                    reg2[2]: next_state = STATE2;
                    reg2[3]: next_state = STATE3;
                    default: next_state = STATE2;
                endcase
            end

            STATE3: begin
                case (1'b1)
                    reg3[0]: next_state = STATE0;
                    reg3[1]: next_state = STATE1;
                    reg3[2]: next_state = STATE2;
                    reg3[3]: next_state = STATE3;
                    default: next_state = STATE3;
                endcase
            end

            default: next_state = STATE0;
        endcase
    end

endmodule
