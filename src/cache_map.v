module cache_map(
		 input wire [31:0] addr
		 
		 );

   parameter TAG_SIZE = 17;
   
   typedef struct {
      reg [TAG_SIZE-1:0] tag;
      reg dirty;
    } cache_block_meta; 


   
endmodule
