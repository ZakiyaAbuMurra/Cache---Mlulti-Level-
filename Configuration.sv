   
package cache_config;

// Parameters for cache size, block size, and address size (in bits)
parameter int DATA_SIZE =32 ; 
parameter int CACHE_SIZE = 2048 ;  // Cache size in bytes
parameter int BLOCK_SIZE = 16;    // Block (line) size in bytes
parameter int ADDR_SIZE  = 32;    // Address size in bits
parameter int CACHE_LINES = CACHE_SIZE / BLOCK_SIZE; 
parameter int WAY_VALUE = 8 ; // Can be 2 , 4 ,8 ,...... 
parameter int SET_VALUE = 32;  
parameter int MEMEORY_SIZE = 2**20;



// Calculating the number of bits for offset, index, and tag
localparam int OFFSET_BITS = $clog2(BLOCK_SIZE);
localparam int INDEX_BITS  =  $clog2(CACHE_SIZE / BLOCK_SIZE);
localparam int TAG_BITS    = ADDR_SIZE - (INDEX_BITS + OFFSET_BITS);
localparam int TAG_BITS_Full    = ADDR_SIZE - OFFSET_BITS;

       
function void print_param();
  $display("Offset Bits: %0d", OFFSET_BITS);
  $display("Index Bits: %0d", INDEX_BITS);
  $display("Tag Bits: %0d", TAG_BITS);
endfunction 

// Cache Line Structure
typedef struct packed{
  bit valid; // Valid bit
  logic [TAG_BITS-1:0] tag; // Tag for direct-mapped and set-associative placement. 
  logic [TAG_BITS_Full-1:0] tag_f; // Tag for Fully Associative placement. 
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