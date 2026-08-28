module top;

    typedef enum {alpha, beta, gamma, delta, epsilon} my_enum;
    string   my_string;
    my_enum  state;
    
    initial begin
      state = beta;
      my_string = string'(state.name);
      $display("string = %s", my_string);
    end
    
endmodule