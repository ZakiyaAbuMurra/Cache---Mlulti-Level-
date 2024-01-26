`timescale 1ns/1ps


module TopCache_tb;

  // Testbench signals
  logic clk;
  logic reset;
  logic rd_wr;
  logic [31:0] address;
  logic [31:0] write_data;
  logic [31:0] read_data;
  bit hit_miss;

  // Instantiate the TopCache module
  TopCache uut (
    .clk(clk),
    .reset(reset),
    .rd_wr(rd_wr),
    .address(address),
    .write_data(write_data),
    .read_data(read_data),
    .hit_miss(hit_miss)
  );

  // Clock generation
  always #5 clk = ~clk; // 100MHz clock

  // Test sequence
 /* initial begin
    // Initilize signals
    clk = 0;
    reset = 0;
    rd_wr = 0;
    address = 0;
    write_data = 0;

    // Reset the system
    #10;
    reset = 0;
    #10;
     //Reset the cache
    #10;
    reset = 1;
    #10;
    rd_wr = 0;
    address = 'h47a48  ;
    #10;
    rd_wr = 0;
    address = 'hca55c ;
    #10;
    rd_wr = 0;
    address = 'h5064d;
    #10;
    rd_wr = 0;
    address = 'h47a48  ;
    #10;
    rd_wr = 0;
    address = 'hca55c ;
    #10;
    rd_wr = 0;
    address = 'h47a48 ;
    #10;
    rd_wr = 0;
    address = 'h5064d;
  
   
    #10; 
    rd_wr = 0 ; 
    address = 'h2e47f ; 
    
      #10; 
    rd_wr = 0 ;
    address = 'h11111 ; 
    #10;
    rd_wr = 1;
    address = 'hca55c ;
    write_data = 'h333333;
    #10;
    rd_wr = 1;
    address = 'h47a49 ;
    write_data = 'h666666;
    
    #10; 
    rd_wr = 1 ;
    address = 'hadf87  ;
    write_data = 'hffff; 
 
    #20;
    rd_wr = 0 ; 
    address = 'h22521 ; 
    
    #10; 
    rd_wr = 1 ; 
    address = 'h3d21 ; 
    write_data = 'he8a2; 
    
    #10; 
    rd_wr = 0; 
    address = 'h24d21; 
    
    #10; 
    rd_wr=1; 
    address = 'hab47; 
    write_data = 'h129a; 
    
    #10; 
    rd_wr = 0; 
    address = 'hdf553ebe;
    
    #10; 
       rd_wr = 0 ;
    address = 'hadf87  ;
    #10
    rd_wr = 0 ;
    address = 'hca55c ;
   // write_data = 'hffff; 
    
    
    // Finish simulation
    #30 ; 
    //uut.print_cache(); 
 //   uut.print_set_cache();
      // uut.Performance();
    $finish;
  end*/ 
    
  
    // Initilize signals
  initial begin
    clk = 0;
    reset = 0;
    rd_wr = 0;
    address = 0;
    write_data = 0;
  end
    initial begin 
    reset = 0  ;
      #40
       reset =1 ; 
      
    forever begin 
      @(posedge clk)begin 
        rd_wr <= $urandom_range(0,1);
        address <= $urandom_range(0, 2**10 -1);
        write_data <= $random();       
      end 
    end 
  end 
  
  initial begin
    $dumpfile("waveform.vcd"); 
    $dumpvars(0, TopCache_tb);     // Dump all variables in the testbench 

     // Finish simulation
    #2000 ; 
    //uut.print_cache(); 
 //   uut.print_set_cache();
        //uut.Performance();

    $finish;         
              
  end
	  initial begin
    $monitor("Time = %t, Reset = %b, Read/Write = %b, Address = %h, Write Data = %h, Read Data = %h, Hit/Miss = %b",
             $time, reset, rd_wr, address, write_data, read_data, hit_miss);
    end
  // Optionally, add a waveform dump
  initial begin
    $dumpfile("TopCache_tb.vcd");
    $dumpvars(0, TopCache_tb);
  end

endmodule