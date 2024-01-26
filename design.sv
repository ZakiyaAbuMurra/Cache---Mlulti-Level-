// Code your design here

`include "Level1.sv"

module TopCache(
  input logic clk,
  input logic reset,
  input logic rd_wr, // Read (0) or Write (1) operation
  input logic [32-1:0] address, // 16-bit address
  input logic [32-1:0] write_data, // Data to write (8-bit)
  output logic [32-1:0] read_data, // Data read (8-bit)
  output bit hit_miss // Hit (1) or Miss (0)
);
  
 
  
  // Instantiate the cache
    cache_level1 L1_cache (
      .clk(clk),
      .fill_cache(0),
      .reset(reset),
      .rd_wr(rd_wr),
      .address(address),
      .write_data(write_data),
      .read_data(read_data),
      .hit_miss(hit_miss)
    );
 
  initial L1_cache.Performance(); 
  

  // Logic to handle hit or miss in L1 and L2
  always@(posedge clk) begin
    if (reset == 0)begin 
     L1_cache.fill_cache_with_random_number();
     // L1_cache.Set_fill_cache_with_random_number();
     

    end 
    else begin 
    //  L1_cache.print_cache();
      L1_cache.Performance(); 
    end 
  end 

endmodule
  
  
  
  
  
  
  
  
  
  
  
  
  
