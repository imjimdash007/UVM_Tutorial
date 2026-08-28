module simple_design(input int a, output int b);
    always@(a)
     begin 
       if (a == 1234) 
         b = 5678;           
        if( a == 3456)
         b = 1234;
     end
endmodule 

module sv_task;
  int x;
 
  simple_design DUT();
 
  //task to add two integer numbers.
  task sum(input int a,b,output int c);
    c = a+b;  
  endtask
 
  //task to read file and apply to a design
  task read_file();
    int fd,status;
    int fa,fb,r;
    string line;
    string first_word_column [];
    fd = $fopen("my_file.txt", "r");  
    while (! $feof(fd)) begin  
       r =$fscanf(fd, "%d %d", fa, fb);
       $display("%d" ,fa);
       $display("%d",fb);
       force DUT.a = fa;
       @(DUT.b)
       if(fb == DUT.b)
          $display("Test , passed !!");
      #100;
     end
   $fclose(fd);  
  endtask;

  initial begin
    read_file();
    
  
  end
endmodule