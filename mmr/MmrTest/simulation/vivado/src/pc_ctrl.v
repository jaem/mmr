

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2016 12:04:13
// Design Name: 
// Module Name: pc_ctrl
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

module pc_ctrl #(
  parameter DATA_W_IN_BYTES       = 4,
  parameter ADDR_W_IN_BITS        = (8 + 2),
  parameter DCADDR_LOW_BIT_W      = 8,
  parameter DCADDR_STROBE_MEM_SEG = 2 
) (

   //--------------------------------------------------------------------------
   //  register IO section
   //--------------------------------------------------------------------------

   // Block pm0
   input  wire [31:0]      pm0_accum_low_period,
   input  wire [15:0]      pm0_pulse_per_second,
   input  wire             pm0_ready_to_read   ,

   // Block pm1
   input  wire [31:0]      pm1_accum_low_period,
   input  wire [15:0]      pm1_pulse_per_second,
   input  wire             pm1_ready_to_read   ,

   // Block pm0
   output wire [31:0]      pm0_clk_freq        ,
   output wire [31:0]      pm0_clk_subsample   ,
   output wire             pm0_enable          ,
   output wire             pm0_use_one_pps_in  ,

   // Block pm1
   output wire [31:0]      pm1_clk_freq        ,
   output wire             pm1_clk_subsample   ,
   output wire             pm1_enable          ,
   output wire             pm1_use_one_pps_in  ,

   //--------------------------------------------------------------------------
   //  Control strobe section
   //--------------------------------------------------------------------------
   input  wire [(ADDR_W_IN_BITS)-1 : 0]              S_AXI_AWADDR,      // Write channel Protection type. This signal indicates the privilege and security level of the transaction, and whether    // the transaction is a data access or an instruction access.
   input  wire [2 : 0]                               S_AXI_AWPROT,      // Write address valid. This signal indicates that the master signaling // valid write address and control information.
   input  wire                                       S_AXI_AWVALID,     // Write address ready. This signal indicates that the slave is ready    // to accept an address and associated control signals.
   output wire                                       S_AXI_AWREADY,     // Write data (issued by master, acceped by Slave) 
   
   input  wire [(DATA_W_IN_BYTES*8) - 1:0]           S_AXI_WDATA,       // Write strobes. This signal indicates which byte lanes hold    // valid data. There is one write strobe bit for each eight    // bits of the write data bus.    
   input  wire [DATA_W_IN_BYTES-1 : 0]               S_AXI_WSTRB,       // Write valid. This signal indicates that valid write    // data and strobes are available.
   input  wire                                       S_AXI_WVALID,      // Write ready. This signal indicates that the slave    // can accept the write data.
   output wire                                       S_AXI_WREADY,      // Write response. This signal indicates the status    // of the write transaction.
   
   output wire [1 : 0]                               S_AXI_BRESP,       // Write response valid. This signal indicates that the channel    // is signaling a valid write response.
   output wire                                       S_AXI_BVALID,      // Response ready. This signal indicates that the master    // can accept a write response.
   input  wire                                       S_AXI_BREADY,      // Read address (issued by master, acceped by Slave)
   
   input  wire [(ADDR_W_IN_BITS)-1 : 0]              S_AXI_ARADDR,      // Protection type. This signal indicates the privilege    // and security level of the transaction, and whether the    // transaction is a data access or an instruction access.
   input  wire [2 : 0]                               S_AXI_ARPROT,      // Read address valid. This signal indicates that the channel    // is signaling valid read address and control information.
   input  wire                                       S_AXI_ARVALID,     // Read address ready. This signal indicates that the slave is    // ready to accept an address and associated control signals.
   output wire                                       S_AXI_ARREADY,     // Read data (issued by slave)
   
   output wire [(DATA_W_IN_BYTES*8) - 1:0]           S_AXI_RDATA,       // Read response. This signal indicates the status of the    // read transfer.
   output wire [1 : 0]                               S_AXI_RRESP,       // Read valid. This signal indicates that the channel is signaling the required read data.
   output wire                                       S_AXI_RVALID,      // Read ready. This signal indicates that the master can accept the read data and response information.
   input  wire                                       S_AXI_RREADY,      // 

   input  wire                                       ACLK,              // Clock source 
   input  wire                                       ARESETn            // Reset source

);

//------------------------------------------------------------------------------
// read/write control strobes
//------------------------------------------------------------------------------
wire [DCADDR_STROBE_MEM_SEG - 1:0]         bank_rd_start; // read start strobe
wire [DCADDR_STROBE_MEM_SEG - 1:0]         bank_rd_done;  // read done  strobe
wire [DCADDR_LOW_BIT_W - 1:0]              bank_rd_addr;  // read address bus
reg  [(DATA_W_IN_BYTES*8) - 1:0]           bank_rd_data;  // read data bus
wire [(ADDR_W_IN_BITS)-1:DCADDR_LOW_BIT_W] decode_rd_addr;// used external to the block to select the correct returning data

wire [DCADDR_STROBE_MEM_SEG - 1:0]         bank_wr_start; // write start strobe
wire [DCADDR_STROBE_MEM_SEG - 1:0]         bank_wr_done;  // write done  strobe
wire [DCADDR_LOW_BIT_W - 1:0]              bank_wr_addr;  // write address bus
wire [(DATA_W_IN_BYTES*8) - 1:0]           bank_wr_data;  // write data bus

wire [(DATA_W_IN_BYTES*8) - 1:0]           bank_rd_data_bus[DCADDR_STROBE_MEM_SEG-1:0]; // read data bus

//------------------------------------------------------------------------------
// Register interface control logic. This can be swapped for the appropiate
// protocol.
//------------------------------------------------------------------------------
pc_ctrl_axi4_reg_if #(
  .DATA_W_IN_BYTES       (DATA_W_IN_BYTES       ),
  .ADDR_W_IN_BITS        (ADDR_W_IN_BITS        ),
  .DCADDR_LOW_BIT_W      (DCADDR_LOW_BIT_W      ),
  .DCADDR_STROBE_MEM_SEG (DCADDR_STROBE_MEM_SEG )
) pc_ctrl_axi4_reg_if_0_i (
   .S_AXI_AWADDR      (S_AXI_AWADDR  ), 
   .S_AXI_AWPROT      (S_AXI_AWPROT  ), // Write channel Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
   .S_AXI_AWVALID     (S_AXI_AWVALID ), // Write address valid. This signal indicates that the master signaling valid write address and control information.
   .S_AXI_AWREADY     (S_AXI_AWREADY ), // Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.

   .S_AXI_WDATA       (S_AXI_WDATA   ), // Write data (issued by master, acceped by Slave)     
   .S_AXI_WSTRB       (S_AXI_WSTRB   ), // Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.    
   .S_AXI_WVALID      (S_AXI_WVALID  ), // Write valid. This signal indicates that valid write data and strobes are available.

   .S_AXI_WREADY      (S_AXI_WREADY  ), // Write ready. This signal indicates that the slave can accept the write data.
   .S_AXI_BRESP       (S_AXI_BRESP   ), // Write response. This signal indicates the status of the write transaction.
   .S_AXI_BVALID      (S_AXI_BVALID  ), // Write response valid. This signal indicates that the channel is signaling a valid write response.
   .S_AXI_BREADY      (S_AXI_BREADY  ), // Response ready. This signal indicates that the master can accept a write response.
    
   .S_AXI_ARADDR      (S_AXI_ARADDR  ), // Read address (issued by master, acceped by Slave)
   .S_AXI_ARPROT      (S_AXI_ARPROT  ), // Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
   .S_AXI_ARVALID     (S_AXI_ARVALID ), // Read address valid. This signal indicates that the channel is signaling valid read address and control information.
   .S_AXI_ARREADY     (S_AXI_ARREADY ), // Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
    
   .S_AXI_RDATA       (S_AXI_RDATA   ), // Read data (issued by slave)
   .S_AXI_RRESP       (S_AXI_RRESP   ), // Read response. This signal indicates the status of the read transfer.
   .S_AXI_RVALID      (S_AXI_RVALID  ), // Read valid. This signal indicates that the channel is signaling the required read data.
   .S_AXI_RREADY      (S_AXI_RREADY  ), // Read ready. This signal indicates that the master can accept the read data and response information.

   .reg_bank_rd_start (bank_rd_start ), // read start strobe
   .reg_bank_rd_done  (bank_rd_done  ), // read done strobe
   .reg_bank_rd_addr  (bank_rd_addr  ), // read address bus
   .reg_bank_rd_data  (bank_rd_data  ), // read data bus
   .decode_rd_addr    (decode_rd_addr), // Upper address bits used to select the correct read data back into

   .reg_bank_wr_start (bank_wr_start ), // write start strobe
   .reg_bank_wr_done  (bank_wr_done  ), // write done  strobe
   .reg_bank_wr_addr  (bank_wr_addr  ), // write address bus
   .reg_bank_wr_data  (bank_wr_data  ), // write data bus

   .ACLK              (ACLK          ), // Clock source 
   .ARESETn           (ARESETn       )  // Reset source

);

//------------------------------------------------------------------------------
// Mux the read data lines back into the interface logic.
// DCADDR_STROBE_MEM_SEG defines the number of strobes required. 
//------------------------------------------------------------------------------
always @(*) begin
   case(decode_rd_addr)
   0:bank_rd_data = bank_rd_data_bus[0]; // DECODE FOR instance pm0 of type reg_sync_v
   1:bank_rd_data = bank_rd_data_bus[1]; // DECODE FOR instance pm1 of type reg_sync_v
   default:bank_rd_data = bank_rd_data_bus[0];
   endcase
end

//------------------------------------------------------------------------------
// Data basic register type : pm0
//------------------------------------------------------------------------------
pc_ctrl_pm0 #(
  .DATA_W_IN_BYTES       (DATA_W_IN_BYTES       ),
  .ADDR_W_IN_BITS        (ADDR_W_IN_BITS        ),
  .DCADDR_LOW_BIT_W      (DCADDR_LOW_BIT_W      )
) pc_ctrl_pm0_0_i (

   // Block pm0 Inputs
   .accum_low_period(pm0_accum_low_period),
   .pulse_per_second(pm0_pulse_per_second),
   .ready_to_read   (pm0_ready_to_read   ),

   // Block pm0 Outputs
   .clk_freq        (pm0_clk_freq        ),
   .clk_subsample   (pm0_clk_subsample   ),
   .enable          (pm0_enable          ),
   .use_one_pps_in  (pm0_use_one_pps_in  ),

   .reg_bank_rd_start (bank_rd_start[0]    ), // read start strobe
   .reg_bank_rd_done  (bank_rd_done[0]     ), // read done  strobe
   .reg_bank_rd_addr  (bank_rd_addr        ), // read address bus
   .reg_bank_rd_data  (bank_rd_data_bus[0] ), // read data bus

   .reg_bank_wr_start (bank_wr_start[0]    ), // write start strobe
   .reg_bank_wr_done  (bank_wr_done[0]     ), // write done  strobe
   .reg_bank_wr_addr  (bank_wr_addr        ), // write address bus
   .reg_bank_wr_data  (bank_wr_data        ), // write data bus

   .ACLK              (ACLK                ), // Clock source 
   .ARESETn           (ARESETn             )  // Reset source
);

//------------------------------------------------------------------------------
// Data basic register type : pm1
//------------------------------------------------------------------------------
pc_ctrl_pm1 #(
  .DATA_W_IN_BYTES       (DATA_W_IN_BYTES       ),
  .ADDR_W_IN_BITS        (ADDR_W_IN_BITS        ),
  .DCADDR_LOW_BIT_W      (DCADDR_LOW_BIT_W      )
) pc_ctrl_pm1_1_i (

   // Block pm1 Inputs
   .accum_low_period(pm1_accum_low_period),
   .pulse_per_second(pm1_pulse_per_second),
   .ready_to_read   (pm1_ready_to_read   ),

   // Block pm1 Outputs
   .clk_freq        (pm1_clk_freq        ),
   .clk_subsample   (pm1_clk_subsample   ),
   .enable          (pm1_enable          ),
   .use_one_pps_in  (pm1_use_one_pps_in  ),

   .reg_bank_rd_start (bank_rd_start[1]    ), // read start strobe
   .reg_bank_rd_done  (bank_rd_done[1]     ), // read done  strobe
   .reg_bank_rd_addr  (bank_rd_addr        ), // read address bus
   .reg_bank_rd_data  (bank_rd_data_bus[1] ), // read data bus

   .reg_bank_wr_start (bank_wr_start[1]    ), // write start strobe
   .reg_bank_wr_done  (bank_wr_done[1]     ), // write done  strobe
   .reg_bank_wr_addr  (bank_wr_addr        ), // write address bus
   .reg_bank_wr_data  (bank_wr_data        ), // write data bus

   .ACLK              (ACLK                ), // Clock source 
   .ARESETn           (ARESETn             )  // Reset source
);


endmodule