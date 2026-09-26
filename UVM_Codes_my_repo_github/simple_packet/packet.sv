// CODE:
class packet;

    local bit [7:0] addr;
    local bit [31:0] data;

    function void set_values(bit [7:0] a, bit [31:0] d);
        addr = a;
        data = d;
    endfunction

    function void display();
        $display("Address = %0h, Data = %0h", addr, data);
    endfunction

endclass

// TESTBENCH:
module encapsulation_tb;

    packet pkt;

    initial begin
        pkt = new();
        pkt.set_values(8'h12, 32'hAABBCCDD);
        pkt.display();
        $finish;
    end

endmodule
//qverilog -sv packet.sv
