`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//  Author: myj                                                                 //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//     WEB: http://www.alinx.cn/                                                //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2019,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//   Description:  pl read and write bram
//
//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2018/7/27     myj          1.0         Original
//  2019/2/28     myj          2.0         Adding some comments
//********************************************************************************/


module ram_read_write
    (
	 input              clk,
	 input              rst_n,
	 //bram port
   input      [31:0]  din,	 
	 output reg [31:0]  dout,
	 output reg         en,
	 output reg [3:0]   we,
	 output             rst,
	 output reg [31:0]  addr,
	 //control signal
	 input              start,       //start to read and write bram
   /*
   * yunlang: add the new port waddr, and comment the init_data,
     * because we don't need init_data, the data is from din
   */
   //
	 // input      [31:0]  init_data,   //initial data defined by software 
   input [31:0]       waddr,
	 output reg         start_clr,   //clear start register
	 input      [31:0]  len,         //data count
	 input      [31:0]  start_addr,   //start bram address
	 //Interrupt
	 input              intr_clr,    //clear interrupt
	 output reg         intr         //interrupt

   
    );


assign rst = 1'b0 ;
	
localparam IDLE      = 3'd0 ;
localparam READ_RAM  = 3'd1 ;
localparam READ_END  = 3'd2 ;
localparam WRITE_RAM = 3'd3 ;
localparam WRITE_END = 3'd4 ;

reg [2:0] state ;
reg [31:0] len_tmp ;
reg [31:0] start_addr_tmp ;
// yunlang: add new
reg [31:0] addr_tmp;
reg [31:0] waddr_tmp;


//yunlang: finish a new FSM, for read->write 

always @(posedge clk or negedge rst_n) begin 
  if(~rst_n) begin 
    state      <= IDLE  ;
    dout       <= 32'd0 ;
    en         <= 1'b0  ;
    we         <= 4'd0  ;
    addr       <= 32'd0 ;
    intr       <= 1'b0  ;
    start_clr  <= 1'b0  ;
    len_tmp    <= 32'd0 ;
    start_addr_tmp <= 32'd0 ;
 end
 else begin 
   case(state) 
     IDLE: begin 
      if(start) begin 
        state <= READ_RAM;
        en <= 1'b1;
        we <= 4'd0;
        addr <= start_addr;
        addr_tmp <= start_addr;
        waddr_tmp <= waddr;
        start_addr_tmp <= start_addr;
        len_tmp <= len;
        dout <= 32'b0;
        start_clr <= 1'b1;
      end
      if(intr_clr)
        intr <= 1'b0;
    end

    READ_RAM: begin 
      state <= READ_END;
      en <= 1'b0;
      start_clr <= 1'b0; // what happen
    end

    READ_END: begin 
      state <= WRITE_RAM;
      we <= 4'hf;
      en <= 1'b1;
      addr <= waddr_tmp;
      dout <= din + 32'd1;
      addr_tmp <= addr + 32'd4;   // for next read
    end
    WRITE_RAM: begin 
      if((addr_tmp - start_addr_tmp) == len_tmp) begin 
        state <= WRITE_END;
        dout <= 32'd0;
        en <= 1'b0;
        we <= 4'd0;
      end else begin 
        state <= READ_RAM;
        en <= 1'b1;
        we <= 4'd0;
        addr <= addr_tmp;
        dout <= 32'd0;
        waddr_tmp <= waddr_tmp + 32'd4;
      end
    end
    WRITE_END: begin 
      addr <= 32'd0;
      intr <= 1'b1;
      state <= IDLE;
    end
    default: state <= IDLE;
   endcase 
 end
end





//Main statement
// always @(posedge clk or negedge rst_n)
// begin
//   if (~rst_n)
//   begin
//     state      <= IDLE  ;
//     dout       <= 32'd0 ;
//     en         <= 1'b0  ;
//     we         <= 4'd0  ;
//     addr       <= 32'd0 ;
//     intr       <= 1'b0  ;
//     start_clr  <= 1'b0  ;
//     len_tmp    <= 32'd0 ;
//     start_addr_tmp <= 32'd0 ;
//   end
	
//   else
//   begin
//     case(state)
// 	IDLE    : begin
//           if (start)
// 						begin
//               state <= READ_RAM     ;
// 						  addr  <= start_addr   ;
// 						  start_addr_tmp <= start_addr ;
// 						  len_tmp <= len ;
// 						  dout <= init_data ;
// 						  en    <= 1'b1 ;
// 						  start_clr <= 1'b1 ;
// 						end			
// 						if (intr_clr)
// 							intr <= 1'b0 ;
//             end

    
//     READ_RAM      : begin
//         if ((addr - start_addr_tmp) == len_tmp - 4)      //read completed
// 						begin
// 						  state <= READ_END ;
// 						  en    <= 1'b0     ;
// 						end
// 						else
// 						begin
// 						  addr <= addr + 32'd4 ;				  //address is byte based, for 32bit data width, adding 4		  
// 						end
// 						start_clr <= 1'b0 ;
// 					  end
					  
//     READ_END   : begin
// 	                    addr  <= waddr ; // yunlang: change the start_addr_temp to waddr, for different address between read and write 
// 	                    en <= 1'b1 ;
//                       we <= 4'hf ;
// 					    state <= WRITE_RAM  ;					    
// 					  end
    
// 	WRITE_RAM   : begin
// 	                    if ((waddr - waddr_temp) == len_tmp - 4)   //write completed
// 						begin
// 						  state <= WRITE_END ;
// 						  dout  <= 32'd0 ;
// 						  en    <= 1'b0  ;
// 						  we    <= 4'd0  ;
// 						end
// 						else
// 						begin
// 						  addr <= addr + 32'd4 ;
// 						  dout <= dout + 32'd1 ;
// 						end
// 					  end
					  
// 	WRITE_END       : begin
// 	                    addr <= 32'd0 ;
// 						intr <= 1'b1 ;
// 					    state <= IDLE ;					    
// 					  end	
// 	default         : state <= IDLE ;
// 	endcase
//   end
// end	
	
endmodule
