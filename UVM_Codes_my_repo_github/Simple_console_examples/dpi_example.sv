module top;
  import "DPI-C" function string getenv(input string env_name);
  string TC_ACT;
  string TC_EXP ="Ajay is cute !!"; //incase of unix it will be back-slash 
  
  initial begin

    TC_ACT = getenv("TC");
    $display("TC actual   = %s\n", TC_ACT);
    $display("TC expected = %s\n", TC_EXP);

    if(TC_ACT == TC_EXP) begin 
     $display("Actual is same as Expected");
     // Ajay :<put your assertion to be fired in case of wanted testcases>
      end 
    else begin
     $display("Home actual is different then home expected"); 
     // Ajay:<put your assertion to be fired in case of the rest of the testcases>
      end
  end
endmodule

// Windows setting 
// set TC="Ajay is cute !!" <in a terminal>
// echo %TC%
// qverilog -sv this file name <dpi_examp[le.sv>
// rmdir work /q/s
// run the above program and you should see the output

