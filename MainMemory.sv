class MainMemory;

  //logic [DATA_WIDTH-1:0] mem_array [0:MEM_DEPTH-1];
  logic [32-1:0] mem_array[MEMEORY_SIZE -1 :0];

  // Constructor
 function new();
    // Initialize memory 
    for (int i = 0; i <= $size(mem_array)-1; i++) begin
     	mem_array[i] = $random;
      end
    endfunction
   

  // Write operation
  function void write(input logic [ADDR_SIZE-1:0] addr, input logic [DATA_SIZE-1:0] data_in);
    //$display("Main memory\n\n***************Address : %0h " ,addr );
    mem_array[addr] = data_in;
    //$display("data in : %0h mem_array[addr] = %0h" ,data_in,mem_array[addr] );
    endfunction

  // Read operation
  function logic [DATA_SIZE-1:0] read(input logic [DATA_SIZE-1:0] addr);
    return mem_array[addr];
    endfunction
  
  function void printMainMemory();
    for (int i = 0 ;i <=  $size(mem_array)-1; i++) begin
      //$display("mem_array[%0h] = %0h", i, mem_array[i]);
     end
    $display("The last address = %0h" , $size(mem_array)-1 );
    $display("Addres[]= %0h" , mem_array[$size(mem_array)-1]);
  endfunction
    
  
endclass 
