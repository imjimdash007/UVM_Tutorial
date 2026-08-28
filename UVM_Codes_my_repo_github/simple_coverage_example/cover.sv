program test();
integer count = 0; 
class MyClass; 
    rand logic [1:0] m_i, m_j; 
    logic [1:0] m_k; 
    event cov_event; 
    covergroup MyCov 
    @(cov_event); 
        cp0 : coverpoint m_i {
            bins m_i_s0 = { 0 } ;
            bins m_i_s1 = { 1 } ;
            bins m_i_s2 = { 2 } ;
            bins m_i_s3 = { 3 } ;
        }
        cp1 : coverpoint m_k {
            bins m_k_s0 = { 0 } ;
            bins m_k_s1 = { 1 } ;
            bins m_k_s2 = { 2 } ;
        }
		  cp2 : coverpoint m_j {
            bins m_j_s0 = { 0 } ;
            bins m_j_s1 = { 1 } ;
            bins m_j_s2 = { 2 } ;
        }
        mycross0 : cross cp0, cp1, cp2;
    endgroup
    function automatic new; 
      begin
        MyCov = new;
      end
    endfunction
endclass 

integer vtb_temp_reg;
initial begin 
MyClass obj1 = new; 
    
    repeat(18) 
    begin 
        #10
        vtb_temp_reg = obj1.randomize(); 
        -> obj1.cov_event; 
        $display("%d, %d, %d", obj1.m_i, obj1.m_k, obj1.m_j); 
        if(count==4)
			  obj1.m_k =2;
        $display("After change!");
        $display("%d, %d, %d count %d--> %t", obj1.m_i, obj1.m_k, obj1.m_j,$time,count); 
        vtb_temp_reg = count++; 
    end 
end  
endprogram