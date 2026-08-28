class operation_addition extends uvm_sequence #(instruction);
   

  instruction req;

  int fd;                   //file reading 
  string line;              //content of the line 
 // typedef enum {PUSH_A,PUSH_B,PUSH_E,PUSH_F,ADD,SUB,MUL,DIV,POP_C,POP_D} local_inst;
 // local_inst instructions;
  string abc;

  function new(string name="operation_addition");
    super.new(name);
  endfunction
  
  `uvm_sequence_utils(operation_addition, instruction_sequencer)    

  virtual task body();

    `ifndef FILE_READ                      // Normal Sequence 
     begin 
      req = instruction::type_id::create("req");
      wait_for_grant();
      assert(req.randomize() with {
         inst == instruction::PUSH_A;
      });
      send_request(req);
      wait_for_item_done();
      //get_response(res); This is optional. Not using in this example.

      req = instruction::type_id::create("req");
      wait_for_grant();
      req.inst = instruction::PUSH_B;
      send_request(req);
      wait_for_item_done();
      //get_response(res); 

      req = instruction::type_id::create("req");
      wait_for_grant();
      req.inst = instruction::ADD;
      send_request(req);
      wait_for_item_done();
      //get_response(res); 

      req = instruction::type_id::create("req");
      wait_for_grant();
      req.inst = instruction::POP_C;
      send_request(req);
      wait_for_item_done();
      //get_response(res); 
     end
    `else                       //Sequence rerading from a file --> Say ATE file 
      begin 
        $display("Hi There, i shall be reading sequences from file Sequences.txt ");
        fd = $fopen("./Sequences.txt","r");
        if(fd) $display("File was opened successfully : %d",fd);
        else   $display("File was NOT opened successfully : %d",fd);
        
        while(!$feof(fd)) begin 
            $fgets(line,fd);
            //$display("Line = %s",line);
            //instructions = PUSH_E;
            //abc = string'(instructions.name);
            //$display("abc  = %s",abc);
            line = line.substr(0,line.len()-2); // remove the new line character from the string 
            //$display("line = %s",line);
            //$display("Check the string %d", (line == abc));
            //$display("Check the string %d", (line=="PUSH_E"));
            if(line == "PUSH_E") begin
               req = instruction::type_id::create("req");
               wait_for_grant();
               assert(req.randomize() with {
                    inst == instruction::PUSH_E;
                });
                send_request(req);
                wait_for_item_done();
              //  $display("Send item E");
            end
            if(line == "PUSH_F") begin
              req = instruction::type_id::create("req");
              wait_for_grant();
              assert(req.randomize() with {
                   inst == instruction::PUSH_F;
               });
               send_request(req);
               wait_for_item_done();
             //  $display("Send item F");
            end
            if(line == "SUB") begin
              req = instruction::type_id::create("req");
              wait_for_grant();
              assert(req.randomize() with {
                   inst == instruction::SUB;
               });
               send_request(req);
               wait_for_item_done();
             //  $display("Send item SUB");
            end
            if(line == "POP_D") begin
              req = instruction::type_id::create("req");
              wait_for_grant();
              assert(req.randomize() with {
                   inst == instruction::POP_D;
               });
               send_request(req);
               wait_for_item_done();
              // $display("Send item D");
            end
        end
        $fclose(fd);
      end
    `endif
    endtask
  
endclass 

