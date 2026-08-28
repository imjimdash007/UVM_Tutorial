//This is to prove the concept

module simple_design(input bit clk,input bit rst, input int a, input bit en, output int b);
 bit [2:0] count;
  always@(posedge clk)
   begin
     if(rst)
       count <= 0;
     else
       if(en)
         count <= count+1;   //some time wasting logic
   end
  always@(posedge clk)
     begin
      if(count == 4)
       begin
        if (a == 1234)
         b = 5678;          
        if( a == 3456)
         b = 1234;
       end
   end
endmodule

module sv_task;
  bit clk;
  bit rst;
  bit en;
  simple_design DUT(.clk(clk),.rst(rst),.en(en)); //derive the clock
 
  //task to read file and apply to a design
  task read_file();
    int fd,fa,fb,fr;
    fd = $fopen("my_file.txt", "r");  
    while (!$feof(fd)) begin  
      fr =$fscanf(fd, "%d %d", fa, fb);
//       $display("%d" ,fa);
//       $display("%d",fb);
           force DUT.a = fa;
            @(DUT.b)
           if(fb == DUT.b)
             $display("Test , passed !!");
          if(DUT.b == 1234) begin 
            #500;  
            $stop; // Last Entry in file
           end
       end
   $fclose(fd);  
  endtask

  task for_en();
   en = 0;
   #200;
   en = 1;
  endtask
 
  initial begin
    clk = 0;
    rst = 1;
    #200;
    rst = 0;
   fork
    read_file();
    for_en();
   join
  end

  initial begin
    forever begin
      #(50) clk = ~clk;
    end
  end
endmodule