

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2016 12:04:13
// Design Name: 
// Module Name: pm1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module pc_ctrl_pm1 #(
  parameter DATA_W_IN_BYTES           = 4,
  parameter ADDR_W_IN_BITS            = 32,
  parameter DCADDR_LOW_BIT_W          = 8
) (

  input  wire [31:0]      accum_low_period,
  input  wire [15:0]      pulse_per_second,
  input  wire             ready_to_read   ,

  output reg  [31:0]      clk_freq         = 32'd100000000,
  output reg              clk_subsample    = 1'd0,
  output reg              enable           = 1'd1,
  output reg              use_one_pps_in   = 1'd1,

  input  wire                                       reg_bank_rd_start, // read start strobe
  output wire                                       reg_bank_rd_done,  // read done  strobe
  input  wire [DCADDR_LOW_BIT_W - 1:0]              reg_bank_rd_addr,  // read address bus
  output reg  [(DATA_W_IN_BYTES*8) - 1:0]           reg_bank_rd_data=0,// read data bus

  input  wire                                       reg_bank_wr_start, // write start strobe
  output wire                                       reg_bank_wr_done,  // write done  strobe
  input  wire [DCADDR_LOW_BIT_W - 1:0]              reg_bank_wr_addr,  // write address bus
  input  wire [(DATA_W_IN_BYTES*8) - 1:0]           reg_bank_wr_data,  // write data bus

  input  wire                                       ACLK             , // Clock source 
  input  wire                                       ARESETn            // Reset source

);

//------------------------------------------------------------------------------
// Declare registers
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// In the basic bank these are completed straight away. Recall ....XX_start is
// a registered signal.
//------------------------------------------------------------------------------
assign reg_bank_wr_done = reg_bank_wr_start;
assign reg_bank_rd_done = reg_bank_rd_start;

//------------------------------------------------------------------------------
// Write logic
//------------------------------------------------------------------------------
always @(posedge ACLK) begin
   if(!ARESETn) begin
      clk_freq         <= 32'd100000000;
      clk_subsample    <= 1'd0;
      enable           <= 1'd1;
      use_one_pps_in   <= 1'd1;
   end else begin
      if(reg_bank_wr_start) begin
         case (reg_bank_wr_addr[DCADDR_LOW_BIT_W-1:2])
         0 : begin
             enable           <= reg_bank_wr_data[0:0];
         end
         1 : begin
             use_one_pps_in   <= reg_bank_wr_data[0:0];
         end
         2 : begin
             clk_freq         <= reg_bank_wr_data[31:0];
         end
         3 : begin
             clk_subsample    <= reg_bank_wr_data[0:0];
         end
         endcase
      end
   end
end

//------------------------------------------------------------------------------
// READ logic
//------------------------------------------------------------------------------
always @(*) begin
    // Zero the complete bus. We will set specific bits in the case
    reg_bank_rd_data = 'd0;
    case (reg_bank_rd_addr[DCADDR_LOW_BIT_W-1:2])
    0 : begin
         reg_bank_rd_data[0:0]    = enable;
    end
    1 : begin
         reg_bank_rd_data[0:0]    = use_one_pps_in;
    end
    2 : begin
         reg_bank_rd_data[31:0]   = clk_freq;
    end
    3 : begin
         reg_bank_rd_data[0:0]    = clk_subsample;
    end
    4 : begin
         reg_bank_rd_data[15:0]   = pulse_per_second;
    end
    5 : begin
         reg_bank_rd_data[31:0]   = accum_low_period;
    end
    6 : begin
         reg_bank_rd_data[0:0]    = ready_to_read;
    end
    endcase
end

endmodule