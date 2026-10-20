import xml.etree.ElementTree as ET
import sys

def parse_ipxact(xml_file):
    # Namespace handling for standard IP-XACT 2009
    ns = {'spirit': 'http://spiritconsortium.org'}
    
    try:
        tree = ET.parse(xml_file)
        root = tree.getroot()
    except Exception as e:
        print(f"Error parsing XML file: {e}")
        sys.exit(1)
        
    registers = []
    
    # Locate all register declarations
    for reg in root.findall('.//spirit:register', ns):
        name = reg.find('spirit:name', ns).text
        offset = reg.find('spirit:addressOffset', ns).text
        
        # Determine access characteristics 
        field = reg.find('.//spirit:field', ns)
        field_name = field.find('spirit:name', ns).text if field is not None else "val"
        width = field.find('spirit:bitWidth', ns).text if field is not None else "32"
        access = field.find('spirit:access', ns).text if field is not None else "read-write"
        
        uvm_access = "RW" if access == "read-write" else "RO"
        is_volatile = 1 if uvm_access == "RO" else 0
        
        registers.append({
            'name': name,
            'offset': offset,
            'field_name': field_name,
            'width': width,
            'access': uvm_access,
            'volatile': is_volatile
        })
        
    return registers

def generate_uvm_ral(registers):
    # Class definitions header
    print("`ifndef APB_FSM_REG_MODEL__SV")
    print("`define APB_FSM_REG_MODEL__SV\n")
    print("import uvm_pkg::*;")
    print('`include "uvm_macros.svh"\n')
    
    # Generate individual uvm_reg classes
    for reg in registers:
        class_name = f"reg_{reg['name']}"
        print(f"class {class_name} extends uvm_reg;")
        print(f"    `uvm_object_utils({class_name})")
        print(f"    rand uvm_reg_field {reg['field_name']};\n")
        
        print(f"    function new(string name = \"{class_name}\");")
        print(f"        super.new(name, 32, UVM_NO_COVERAGE);")
        print(f"    endfunction\n")
        
        print(f"    virtual function void build();")
        print(f"        this.{reg['field_name']} = uvm_reg_field::type_id::create(\"{reg['field_name']}\");")
        print(f"        this.{reg['field_name']}.configure(")
        print(f"            .parent(this),")
        print(f"            .size({reg['width']}),")
        print(f"            .lsb_pos(0),")
        print(f"            .access(\"{reg['access']}\"),")
        print(f"            .volatile({reg['volatile']}),")
        print(f"            .reset(4'h1),") # Resets to LSB high as specified
        print(f"            .has_reset(1),")
        print(f"            .rand_ise(1),")
        print(f"            .individually_accessible(1)")
        print(f"        );")
        print(f"    endfunction")
        print(f"endclass\n")

    # Generate central uvm_reg_block container
    print("class apb_fsm_reg_block extends uvm_reg_block;")
    print("    `uvm_object_utils(apb_fsm_reg_block)")
    
    for reg in registers:
        print(f"    rand reg_{reg['name']} {reg['name']};")
    print("")
    
    print("    function new(string name = \"apb_fsm_reg_block\");")
    print("        super.new(name, UVM_NO_COVERAGE);")
    print("    endfunction\n")
    
    print("    virtual function void build();")
    print("        this.default_map = create_map(\"default_map\", 'h0, 4, UVM_LITTLE_ENDIAN, 0);\n")
    
    for reg in registers:
        print(f"        this.{reg['name']} = reg_{reg['name']}::type_id::create(\"{reg['name']}\");")
        print(f"        this.{reg['name']}.configure(this, null, \"\");")
        print(f"        this.{reg['name']}.build();")
        print(f"        this.default_map.add_reg(this.{reg['name']}, {reg['offset']}, \"{reg['access']}\");\n")
        
    print("        lock_model();")
    print("    endfunction")
    print("endclass\n")
    print("`endif // APB_FSM_REG_MODEL__SV")

if __name__ == "__main__":
    regs = parse_ipxact("apb_fsm_regs.xml")
    generate_uvm_ral(regs)
