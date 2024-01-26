`include "Cache.sv"
`timescale 1ns / 1ps

module cache_tb;
    // Inputs to the cache
  logic clk;
  logic reset;
  logic rd_wr;
  logic [32-1:0] address;
  logic [32-1:0] write_data;

    // Outputs from the cache
  logic [32-1:0] read_data;
  logic hit_miss;

    // Instantiate the cache
    cache uut (
        .clk(clk),
        .reset(reset),
        .rd_wr(rd_wr),
        .address(address),
        .write_data(write_data),
        .read_data(read_data),
        .hit_miss(hit_miss)
    );

  
  initial begin 
     // Initialize Inputs
        clk = 0;
        reset = 0;
        rd_wr = 0;
      	address = 'h0;
        write_data = 0;
    end 
    // Clock generation
  always #5 clk = ~clk;

    // Initialize the waveform dump
  
  initial begin
    $dumpfile("waveform.vcd");  // Name of the VCD file
    $dumpvars(0, cache_tb);     // Dump all variables in the testbench 
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
    address = 'hfffff ;
    write_data = 'hffff; 
    
    #10;
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
    
    // Finish simulation
    #10 ; 
    //uut.print_cache(); 
 //   uut.print_set_cache();
        uut.Performance();

    $finish;
  end
  
 /* initial begin 
    reset <=1 ; 
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
    $dumpvars(0, cache_tb);     // Dump all variables in the testbench 

     // Finish simulation
    #500 ; 
    //uut.print_cache(); 
 //   uut.print_set_cache();
        uut.Performance();

    $finish;         
              
  end*/

  initial begin
    $monitor("Time = %t, Reset = %b, Read/Write = %b, Address = %h, Write Data = %h, Read Data = %h, Hit/Miss = %b",
             $time, reset, rd_wr, address, write_data, read_data, hit_miss);
    end
  
  
  endmodule
