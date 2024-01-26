`include "MainMemory.sv"
`include "Configuration.sv"
import cache_config::*; 
/// Fetch from memory Level 2 
module cache(
  input logic clk,
  input bit fill_cache,
  input logic reset,
  input bit enable_l2,
  input logic rd_wr, // Read (0) or Write (1) operation
  input logic [32-1:0] address, // 16-bit address
  input logic [32-1:0] write_data, // Data to write (8-bit)
  output logic [32-1:0] read_data, // Data read (8-bit)
  output bit hit_miss // Hit (1) or Miss (0)

);
 
  
  MainMemory main_memory; 
  initial  main_memory = new ();

    
  bit isFull =0 ; 
  int lru_value;
  
  logic [INDEX_BITS-1:0] index ; 
  logic [TAG_BITS-1:0] tag; 
  logic [OFFSET_BITS-1:0] block_offset;
  logic [TAG_BITS_Full-1:0] tag_full; 
  logic [INDEX_BITS-1:0] set ; 
  
  // Global variables for counting hits and misses
  int total_accesses = 0;
  int total_hits = 0;
  int total_misses = 0;
  int total_writes = 0 ; 
  int total_reads = 0 ; 
  int hit_read =0 ; 
  int miss_read =0 ; 
  int hit_write =0 ; 
  int miss_write =0 ; 


  // Variable of enum type
  placement_type_e placement_type = DIRECT_MAPPED ; 
 
 
  cache_line_t cache_mem[CACHE_LINES];
 
  cache_line_t cache_mem_set[2**INDEX_BITS - 1][WAY_VALUE];

  
    // Write operation
  function void write(input logic [ADDR_SIZE-1:0] addr, input logic [DATA_SIZE-1:0] data_in);
    cache_mem[addr] = data_in;
  endfunction

  // Read operation
  function logic [DATA_SIZE-1:0] read(input logic [DATA_SIZE-1:0] addr);
    return cache_mem[addr];
  endfunction
  
    
    // Write operation
  function void write_set(input logic [INDEX_BITS-1:0] set, input logic [DATA_SIZE-1:0] data_in , input int i );
    cache_mem_set[set][i] = data_in;
    
  endfunction

  // Read operation
  function logic [DATA_SIZE-1:0] read_set( input logic [INDEX_BITS-1:0] set , input int i );
    return cache_mem_set[set][i];
    endfunction
  
  // Cache Operations
  always@(posedge clk) begin
    if (enable_l2 == 0) begin
      $display("Enable %d",enable_l2); 
    end 
    else begin
    case (placement_type)
      DIRECT_MAPPED: begin
        if (reset == 0 ) begin
          for (int i = 0; i < CACHE_LINES; i++) begin
            cache_mem[i].valid = 0;
            cache_mem[i].tag   = 0 ; 
            cache_mem[i].data = 0;
          end
        end
        else begin 
                   $display("____________+++++++++++++++++++++++++++++++++++++++++++++++_++++++++_+");

          fill_cache_with_random_number();
          handle_direct_map();
           
          end 
      end
      SET_ASSOCIATIVE: begin
        if (reset==0) begin
         for (int i = 0; i < SET_VALUE; i++) begin
            for (int j =0; j < WAY_VALUE; j++) begin
              cache_mem_set[i][j].valid = 0;
              cache_mem_set[i][j].tag   = 0 ; 
              cache_mem_set[i][j].data = 0;
              cache_mem_set[i][j].counter   = 0 ; 
              cache_mem_set[i][j].addr_c = 0;
            end
          end   
         // Set_fill_cache_with_random_number();

        end
        else begin 
        // Set_fill_cache_with_random_number();

          handle_set_associative();
        //  print_set_cache(); 

        end
      end
      
      FULLY_ASSOCIATIVE: begin
        if (reset==0) begin
         
         for (int i = 0; i < CACHE_LINES; i++) begin
            cache_mem[i].valid = 0;
            cache_mem[i].tag_f  = 0; 
            cache_mem[i].data = 0;
            cache_mem[i].addr_c = 0 ; 
          end
        end
        else 
            begin 
              handle_fully_associative();
              //print_cache(); 
            end 
          // Logic for set associative cache
        end
      endcase
      end
    end
  
// -------------------------------------------------------- DIRECT CACHE MAPPING ------------------------------------------// 
 


 function void handle_direct_map();
    
    index = (address >> OFFSET_BITS);
    tag = (address >> (INDEX_BITS + OFFSET_BITS));
    block_offset = (address);
    
    hit_miss = (cache_mem[index].valid == 1) && (cache_mem[index].tag == tag);
    
   total_accesses ++; 
   
    if (rd_wr) begin // Write operation
      cache_mem[index].valid = 1 ; 
      cache_mem[index].tag = tag ;
      cache_mem[index].addr_c = address;
      total_writes ++;
      if (hit_miss) begin // hit case
        total_hits ++; 
        hit_write ++; 
        cache_mem[index].data = write_data;
        $display("- LEVEL2: DIRECT MAPPING (Write operation): Hit case");
      end
      else begin // miss case
        // update both cache and main memory
        total_misses ++ ; 
        miss_write ++; 
        main_memory.write(address,write_data);
        cache_mem[index].data = write_data; 
        $display("- LEVEL2: DIRECT MAPPING (Write operation): Miss case");
      end
    end
    else begin // Read operation
      total_reads ++; 
      if (hit_miss) begin // hit case
        total_hits ++; 
        hit_read ++; 
        read_data = cache_mem[index].data;
        $display("- LEVEL2: DIRECT MAPPING (Read operation): Hit case");
      end
      else begin  // miss case
        total_misses ++ ; 
        miss_read++; 
        read_data = main_memory.read(address);
        cache_mem[index].valid = 1 ; 
        cache_mem[index].tag = tag ;
        cache_mem[index].addr_c = address;
        cache_mem[index].data = read_data ;
        $display("- LEVEL2: DIRECT MAPPING (Read operation): Miss case");
        end 
    end
    endfunction
  
  
  
  function void Performance(); 
    
    real miss_rate; 
    real  hit_rate;
    real write_hit_ratio ; 
    real write_miss_ratio ;
    real read_hit_ratio ; 
    real read_miss_ratio; 

    hit_rate = total_hits / total_accesses; // Assuming hit_rate and miss_rate are of type real
    miss_rate = total_misses / total_accesses;

    // Ensure that the division is performed in real arithmetic
    hit_rate = $itor(total_hits) / $itor(total_accesses);
    miss_rate = $itor(total_misses) / $itor(total_accesses);
    
    
    write_hit_ratio = $itor(hit_write)  / $itor(total_writes) ; 
    write_miss_ratio = $itor(miss_write)  / $itor(total_writes) ; 
    
    read_hit_ratio = $itor(hit_read)  / $itor(total_reads) ; 
    read_miss_ratio = $itor(miss_read)  / $itor(total_reads) ; 


    $display("- LEVEL2: Total hits = %0d Total miss = %0d, total_accesses = %0d", total_hits, total_misses, total_accesses);
    $display("- LEVEL2: Hit Rate: %0.2f%%", hit_rate * 100);
    $display("- LEVEL2: Miss Rate: %0.2f%%", miss_rate * 100);
    $display("- LEVEL2: write_hit_ratio = %0.2f%%" , write_hit_ratio* 100);
    $display("- LEVEL2: write_miss_ratio = %0.2f%%" , write_miss_ratio* 100);
    $display("- LEVEL2: read_hit_ratio = %0.2f%%" , read_hit_ratio* 100);
    $display("- LEVEL2: read_miss_ratio = %0.2f%%" , read_miss_ratio* 100);
  endfunction 

// -------------------------------------------------------- SET ASSOCATIVE CACHE MAPPING ------------------------------------------// 

  function void handle_set_associative();
   
    bit found = 0;
    int cache_line_index =0;
 
    
    // Calculate index and tag
    set = (address >> OFFSET_BITS) % SET_VALUE; // set 
    tag = address >> (OFFSET_BITS + INDEX_BITS); // tag
    total_accesses ++ ; 
    // to check if the set full or not
    isFull = set_is_cache_full();
    $display("- Set number = %d", set);
    for (int i = 0; i < WAY_VALUE; i++) begin
      hit_miss =(cache_mem_set[set][i].valid == 1) && (cache_mem_set[set][i].tag == tag);
      if (isFull == 1 && hit_miss == 0)begin
        total_misses ++; 
        lru_value= set_find_lru(set);
        $display("- LRU %d ",lru_value );
        cache_mem_set[set][lru_value].valid = 1 ;
        cache_mem_set[set][lru_value].tag = tag ;
        cache_mem_set[set][lru_value].addr_c = address;
        
        if (rd_wr) begin // Write operation
          total_writes ++;
          miss_write ++;
          cache_mem_set[set][lru_value].counter = 0;
          cache_mem_set[set][lru_value].data = write_data;
          main_memory.write(address,write_data);
          $display("- LEVEL2: SET ASSOCIATIVE MAPPING (Write operation): Miss case && full cache");
          end
        else begin
          total_reads ++;
          miss_read ++;
          read_data = main_memory.read(address);
          cache_mem_set[set][lru_value].data = read_data; /// important update in all
          cache_mem_set[set][lru_value].counter =  cache_mem_set[set][lru_value].counter +1;
          $display("- LEVEL2: SET ASSOCIATIVE MAPPING (Read operation): Miss case && full cache");

          end
          break ; 
        end
      else begin 
        // hit case
        if (hit_miss == 1) begin
          total_hits++; 
          cache_mem_set[set][i].addr_c = address;
          cache_mem_set[set][i].counter = cache_mem_set[set][i].counter + 1;
          if (rd_wr) begin // Write operation
            total_writes ++;
            hit_write ++;
            cache_mem_set[set][i].valid = 1 ; 
            cache_mem_set[set][i].tag = tag ;
            cache_mem_set[set][i].data = write_data;
            main_memory.write(address,write_data);
            $display("- LEVEL2: SET ASSOCIATIVE MAPPING (Write operation): Hit case");
            end
            else begin
              total_reads ++;
              hit_read ++;
              read_data = cache_mem_set[set][i].data;
              $display("- LEVEL2: SET ASSOCIATIVE MAPPING (Read operation): Miss case && full cache");

              end
            break; 
            end
            else begin
              if ( cache_mem_set[set][i].valid == 0) begin 
                total_misses ++; 
                cache_mem_set[set][i].counter = cache_mem_set[set][i].counter + 1;
                cache_mem_set[set][i].addr_c = address;
                cache_mem_set[set][i].valid = 1 ; 
                cache_mem_set[set][i].tag = tag ;
                if (rd_wr) begin // Write operation
                  total_writes ++;
                  miss_write ++;
                  cache_mem_set[set][i].data = write_data;
                  main_memory.write(address,write_data);
                  $display("- LEVEL2: SET ASSOCIATIVE MAPPING (Write operation): Miss case & not full cache");
                end
                else begin
                  total_reads ++;
                  miss_read ++;
                  read_data = main_memory.read(address);
                  cache_mem_set[set][i].data = read_data; /// important update in all 
                  $display("- LEVEL2: SET ASSOCIATIVE MAPPING (Write operation): Miss case & not full cache");

                end
                break; 
                end
            end
            end 
            end
            endfunction
  
// -------------------------------------------------------- FULLY ASSOCATIVE CACHE MAPPING ------------------------------------------// 

    
function void handle_fully_associative();

  bit found ;
  bit do_replace = 0; 
  int empty_index =0;
  found = 0 ;
  total_accesses ++; 

  tag_full = (address >> OFFSET_BITS);
  // to check if the Cache full or not
  isFull = is_cache_full();
   
  for (int i = 0 ; i < CACHE_LINES ; i++)begin  
    if ((cache_mem[i].valid == 1) && cache_mem[i].tag_f == tag_full ) begin
      total_hits ++; 
      found = 1 ; 
      hit_miss = 1 ;
      cache_mem[i].counter = cache_mem[i].counter + 1 ; 
      if(rd_wr == 1 )begin // write  
        total_writes ++;
        hit_write ++;
        cache_mem[i].addr_c = address; 
        cache_mem[i].data = write_data;
        main_memory.write(address, write_data);
        $display("- LEVEL2: FULLY ASSOCIATIVE MAPPING (Write operation): Hit case");
      end //rd_wr
      else begin 
        total_reads ++;
        hit_read ++;
        read_data = cache_mem[i].data;
        cache_mem[i].addr_c = address; 
        $display("- LEVEL2: FULLY ASSOCIATIVE MAPPING (Read operation): Hit case");
      end //rd_wr else block
      break ;
    end // if tag 
  end //for loop block 
  
  
  if (!found)begin 
    hit_miss = 0 ; 
    if (!isFull)begin  
      // Cache is not full
      empty_index = find_empty_line(); // Function to find the first empty line
      total_misses ++ ; 
      if (rd_wr==1 )begin  // write 
        total_writes ++;
        miss_write ++;
        cache_mem[empty_index].addr_c = address; 
        cache_mem[empty_index].counter = cache_mem[empty_index].counter + 1 ; 
        cache_mem[empty_index].tag_f = tag_full;
        cache_mem[empty_index].data = write_data;
        main_memory.write(address, write_data);
        cache_mem[empty_index].valid = 1 ; 
        $display("- LEVEL2: FULLY ASSOCIATIVE MAPPING (write operation): Miss case & not full cache");
      end 
      else begin 
        total_reads ++;
        miss_read ++;
        cache_mem[empty_index].tag_f = tag_full;
        cache_mem[empty_index].addr_c = address; 
        cache_mem[empty_index].counter = cache_mem[empty_index].counter + 1 ; 
        cache_mem[empty_index].valid = 1 ; 
        read_data = main_memory.read(address);
        cache_mem[empty_index].data = read_data ; 
        $display("- LEVEL2: FULLY ASSOCIATIVE MAPPING (Read operation): Miss case & not full cache");

      end //read 
    end //Not full Block 
    else begin
      total_misses ++; 
      lru_value= find_lru();
      $display("LRU %d ",lru_value );
      cache_mem[lru_value].valid = 1 ;
      cache_mem[lru_value].tag_f = tag_full ;
      cache_mem[lru_value].addr_c = address;
      if (rd_wr) begin // Write operation
        total_writes ++;
        miss_write ++;
        cache_mem[lru_value].counter = 0;
        cache_mem[lru_value].data = write_data;
        main_memory.write(address,write_data);
        $display("- LEVEL2: FULLY ASSOCIATIVE MAPPING (Write operation): Miss case & full cache");
      end
      else begin
        total_reads ++;
        miss_read ++;
        read_data = main_memory.read(address);
        cache_mem_set[set][lru_value].data = read_data; /// important update in all
        cache_mem[lru_value].counter = cache_mem[lru_value].counter +1;
        $display("- LEVEL2: FULLY ASSOCIATIVE MAPPING (Read operation): Miss case & full cache");

      end //read 
    end // full cache block 
  end // Not found Block 
  
 // print_cache();
endfunction
  
  
  function automatic int find_empty_line();
    for (int i = 0; i < CACHE_LINES; i++)begin 
      if (cache_mem[i].valid == 0) begin 
        return i; // Returns the index of the first empty line found
      end
     end 
    return -1; // Returns -1 if no empty line is found
 endfunction

  
function automatic int find_lru();
  int min_val = cache_mem[0].counter;
  int i, j = 0;

  for (i = 1; i < CACHE_LINES; i++) begin 
    if (cache_mem[i].counter < min_val) begin 
      min_val = cache_mem[i].counter;
      j = i;
      end 
    end 
  return j;
  endfunction
  
  
  
  
  function automatic int set_find_lru(int set);
    int min_val = cache_mem_set[set][0].counter;
    int i, j = 0;

    for (i = 0; i < WAY_VALUE; i++) begin 
      if (cache_mem_set[set][i].counter < min_val) begin 
        min_val = cache_mem_set[set][i].counter;
        j = i;
      end 
    end 
  return j;
  endfunction
  
  
  
  
  
  function void lru(int lru_value);
    if (rd_wr) begin // Write operation
      cache_mem[lru_value].data = write_data;
    end 
    else begin // Read operation
      cache_mem[lru_value].data = main_memory.read(address);
    end
    
  endfunction
  
  
  
  function void fill_cache_block(int index);
    cache_mem[index].valid = 1;
    cache_mem[index].tag_f = tag_full;
    cache_mem[index].addr_c = address;
    
  endfunction
  
  function void fill_cache_with_random_number();
    int j =0;
    int i =0;
    if (fill_cache == 0) begin //fill level one
	 for ( i = 0; i < CACHE_LINES; i++) begin
        j  =  $urandom_range(0, (MEMEORY_SIZE/2)-1);
        cache_mem[i].valid = 1;
        if (placement_type == DIRECT_MAPPED || placement_type==SET_ASSOCIATIVE) begin
          cache_mem[i].tag   = (j >> OFFSET_BITS);
        end
        else begin 
          cache_mem[i].tag_f   = (j >> OFFSET_BITS);
        end
        cache_mem[i].data = $random;
        cache_mem[i].addr_c = j;
        cache_mem[i].counter = 0;
        end
      end
    else begin
      for ( i = 0; i < CACHE_LINES; i++) begin
        j  = $urandom_range((MEMEORY_SIZE/2)-1,MEMEORY_SIZE-1);
        cache_mem[i].valid = 1;
        if (placement_type == DIRECT_MAPPED || placement_type==SET_ASSOCIATIVE) begin
          cache_mem[i].tag   = (j >> OFFSET_BITS);
        end
        else begin 
          cache_mem[i].tag_f   = (j >> OFFSET_BITS);
        end
        cache_mem[i].data = $random;
        cache_mem[i].addr_c = j;
        cache_mem[i].counter = 0;
        end
      end
  endfunction

  function void Set_fill_cache_with_random_number();
    int mem_address = 0;
    if (fill_cache == 0) begin //fill level one
      for (int i = 0; i < SET_VALUE; i++) begin
        for (int j = 0; j < WAY_VALUE;j++) begin
          cache_mem_set[i][j].valid = 1;
          cache_mem_set[i][j].tag   = (mem_address >> (INDEX_BITS +OFFSET_BITS));
          cache_mem_set[i][j].data = $random;
          cache_mem_set[i][j].addr_c = mem_address;
          cache_mem_set[i][j].counter = 0;
          mem_address  = $urandom_range(0, (MEMEORY_SIZE/2)-1);
      end
      end
    end
    else begin
      for (int i = 0; i < SET_VALUE; i++) begin
        for (int j = 0; j < WAY_VALUE;j++) begin
          cache_mem_set[i][j].valid = 1;
          cache_mem_set[i][j].tag   = (mem_address >> (INDEX_BITS +OFFSET_BITS));
          cache_mem_set[i][j].data = $random;
          cache_mem_set[i][j].addr_c = mem_address;
          cache_mem_set[i][j].counter = 0;
          mem_address  = $urandom_range((MEMEORY_SIZE/2)-1,MEMEORY_SIZE-1 );
      end
      end
    end
    endfunction

  // check if the cache is full or not 
function bit set_is_cache_full();
  for (int i = 0; i < WAY_VALUE;i ++) begin
    if (!cache_mem_set[set][i].valid) begin
      return 0; // Cache is not full
      end
  end
  return 1; // Cache is full
  endfunction
  
  
  // check if the cache is full or not 
function bit is_cache_full();
  for (int i = 0; i < CACHE_LINES; i++) begin
    if (!cache_mem[i].valid) begin
      return 0; // Cache is not full
    end
  end
  return 1; // Cache is full
endfunction

         

  
  function void  print_cache();
    for (int i = 0; i < CACHE_LINES; i++) begin
      if (placement_type == DIRECT_MAPPED )begin 
        $display("Cache Line %0d : [Address=%0h] , Valid = %0b, Tag = %0h, Data = %h,, counter = %0h", 
                 i, cache_mem[i].addr_c , cache_mem[i].valid, cache_mem[i].tag, cache_mem[i].data,cache_mem[i].counter);
      end 
      else begin 
        $display("Cache Line %0d : [Address=%0h] , Valid = %0b, Tag = %0h, Data = %0h, counter = %0h", 
                  i, cache_mem[i].addr_c , cache_mem[i].valid, cache_mem[i].tag_f, cache_mem[i].data,cache_mem[i].counter);
      end 
      
    end
    endfunction 
  
  
  function void print_set_cache();
    int i = 0;
    for (int i = 0; i < SET_VALUE; i++) begin
            for (int j =0; j < WAY_VALUE; j++) begin
              $display("Cache set %0d : [Address=%0h] , Valid = %0b, Tag = %0h, Data = %0h, counter = %0h", i, cache_mem_set[i][j].addr_c , cache_mem_set[i][j].valid, cache_mem_set[i][j].tag, 
                       cache_mem_set[i][j].data,cache_mem_set[i][j].counter);
            end
          end   
  endfunction
endmodule
