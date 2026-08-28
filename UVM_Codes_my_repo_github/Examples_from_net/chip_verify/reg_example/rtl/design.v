//--------------------------------------------------------------------------------
// Try to model control registers for a peripheral block : This is only for example
// purposes and hence no effort has been put into make this synthesizable
// This block has an APB interface
//--------------------------------------------------------------------------------
 
module periphA (  input          pclk,
                  input          prstn,
                  input [31:0]   paddr,
                  input [31:0]   pwdata,
                  input          psel,
                  input          pwrite,
                  input          penable,
 
                  // Outputs
                  output [31:0]  prdata);
 
   parameter DEF_CTL    = 32'h2C,
             DEF_INTEN  = 32'hFACE,
             DEF_STAT   = 32'hF000_DA7A;
 
   // Control registers
   reg [6:0]      ctl_reg;
   reg [31:0]     stat_reg;  
   reg [31:0]     inten_reg;
 
   reg [31:0]     data_in;
   reg [31:0]     rdata_tmp;
 
   reg set_ctl;
   reg set_stat;
   reg set_inten;
 
   always @ (posedge pclk) begin
      if (!prstn) begin
         data_in <= 0;
         ctl_reg  <= DEF_CTL;
         stat_reg <= DEF_STAT;
         inten_reg <= DEF_INTEN; 
      end
   end
 
   // Capture write data
   always @ (posedge pclk) begin
      if (prstn & psel & penable) 
         if (pwrite) 
            case (paddr)
               0   : ctl_reg <= pwdata;
               4   : inten_reg <= pwdata;
               8   : stat_reg <= pwdata;
            endcase
   end
 
   always @ (penable) begin
      if (psel & !pwrite) 
         case (paddr)
            0 : rdata_tmp <= ctl_reg;
            4 : rdata_tmp <= inten_reg;
            8 : rdata_tmp <= stat_reg;
         endcase
   end
 
   assign prdata = (psel & penable & !pwrite) ? rdata_tmp : 'hz;
 
endmodule