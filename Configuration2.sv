   
package cache_config2;

// Parameters for cache size, block size, and address size (in bits)
parameter int DATA_SIZE_2 =32 ; 
parameter int CACHE_SIZE_2 = 1024 ;  // Cache size in bytes
parameter int BLOCK_SIZE_2 = 16;    // Block (line) size in bytes
parameter int ADDR_SIZE_2 = 32;    // Address size in bits
parameter int CACHE_LINES_2 = CACHE_SIZE_2/ BLOCK_SIZE_2; 
parameter int WAY_VALUE_2 = 8 ; // Can be 2 , 4 ,8 ,...... 
parameter int SET_VALUE_2 = 32;  
parameter int MEMEORY_SIZE = 2**20;



// Calculating the number of bits for offset, index, and tag
localparam int OFFSET_BITS_2 = $clog2(BLOCK_SIZE_2);
localparam int INDEX_BITS_2  =  $clog2(CACHE_SIZE_2 / BLOCK_SIZE_2);
localparam int TAG_BITS_2    = ADDR_SIZE_2 - (INDEX_BITS_2 + OFFSET_BITS_2);
localparam int TAG_BITS_Full_2    = ADDR_SIZE_2 - OFFSET_BITS_2;

       
function void print_param();
  $display("Offset Bits: %0d", OFFSET_BITS_2);
  $display("Index Bits: %0d", INDEX_BITS_2);
  $display("Tag Bits: %0d", TAG_BITS_2);
endfunction 

// Cache Line Structure
typedef struct packed{
  bit valid; // Valid bit
  logic [TAG_BITS_2-1:0] tag; // Tag for direct-mapped and set-associative placement. 
  logic [TAG_BITS_Full_2-1:0] tag_f; // Tag for Fully Associative placement. 
  logic [32-1:0]data; // 8-byte data block
  logic [32-1:0]addr_c ;
  int counter; 

} cache_line_t;

typedef enum {
  DIRECT_MAPPED,
  FULLY_ASSOCIATIVE,
  SET_ASSOCIATIVE
} placement_type_e;



endpackage 