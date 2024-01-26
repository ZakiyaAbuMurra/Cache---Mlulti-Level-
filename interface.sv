interface CacheInterface;
    logic rd_wr;
    logic [31:0] address;
    logic [31:0] write_data;
    logic [31:0] read_data;
    bit hit_miss;

    modport master (
        output rd_wr, address, write_data,
        input read_data, hit_miss
    );

    modport slave (
        input rd_wr, address, write_data,
        output read_data, hit_miss
    );
endinterface
