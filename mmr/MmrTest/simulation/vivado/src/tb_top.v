`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03.07.2016 12:23:24
// Design Name:
// Module Name: tb_top
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module tb_top();

	parameter DATA_W_IN_BYTES       = 4;
	parameter ADDR_W_IN_BITS        = 10;
	parameter DCADDR_LOW_BIT_W      = 8;
	parameter DCADDR_STROBE_MEM_SEG = 2;

    parameter PERIOD = 1000;

    // AXI interface control signals
    reg  [(ADDR_W_IN_BITS)-1 : 0]      S_AXI_AWADDR;      // Write channel Protection type. This signal indicates the    // privilege and security level of the transaction; and whether    // the transaction is a data access or an instruction access.
    reg  [2 : 0]                       S_AXI_AWPROT;      // Write address valid. This signal indicates that the master signaling // valid write address and control information.
    reg                                S_AXI_AWVALID;     // Write address ready. This signal indicates that the slave is ready    // to accept an address and associated control signals.
    wire                               S_AXI_AWREADY;     // Write data (issued by master; acceped by Slave)

    reg  [(DATA_W_IN_BYTES*8) - 1:0]   S_AXI_WDATA;       // Write strobes. This signal indicates which byte lanes hold    // valid data. There is one write strobe bit for each eight    // bits of the write data bus.
    reg  [DATA_W_IN_BYTES-1 : 0]       S_AXI_WSTRB;       // Write valid. This signal indicates that valid write    // data and strobes are available.
    reg                                S_AXI_WVALID;      // Write ready. This signal indicates that the slave    // can accept the write data.
    wire                               S_AXI_WREADY;      // Write response. This signal indicates the status    // of the write transaction.

    wire [1 : 0]                       S_AXI_BRESP;       // Write response valid. This signal indicates that the channel    // is signaling a valid write response.
    wire                               S_AXI_BVALID;      // Response ready. This signal indicates that the master    // can accept a write response.
    reg                                S_AXI_BREADY;      // Read address (issued by master; acceped by Slave)

    reg  [(ADDR_W_IN_BITS)-1 : 0]      S_AXI_ARADDR;      // Protection type. This signal indicates the privilege    // and security level of the transaction; and whether the    // transaction is a data access or an instruction access.
    reg  [2 : 0]                       S_AXI_ARPROT;      // Read address valid. This signal indicates that the channel    // is signaling valid read address and control information.
    reg                                S_AXI_ARVALID;     // Read address ready. This signal indicates that the slave is    // ready to accept an address and associated control signals.
    wire                               S_AXI_ARREADY;     // Read data (issued by slave)

    wire [(DATA_W_IN_BYTES*8) - 1:0]   S_AXI_RDATA;       // Read response. This signal indicates the status of the    // read transfer.
    reg  [(DATA_W_IN_BYTES*8) - 1:0]   read_data;         //
    wire [1 : 0]                       S_AXI_RRESP;       // Read valid. This signal indicates that the channel is signaling the required read data.
    wire                               S_AXI_RVALID;      // Read ready. This signal indicates that the master can accept the read data and response information.
    reg                                S_AXI_RREADY;      //

    // Bank IP R/W control strobes
//	wire [DCADDR_STROBE_MEM_SEG - 1:0] bank_rd_start;     // read start strobe
//	wire [DCADDR_STROBE_MEM_SEG - 1:0] bank_rd_done;      // read done  strobe
//	wire [DCADDR_LOW_BIT_W - 1:0]      bank_rd_addr;      // read address bus
//	reg  [(DATA_W_IN_BYTES*8) - 1:0]   bank_rd_data=0;    // read data bus

//	wire [DCADDR_STROBE_MEM_SEG - 1:0] bank_wr_start;     // write start strobe
//	wire [DCADDR_STROBE_MEM_SEG - 1:0] bank_wr_done;      // write done  strobe
//	wire [DCADDR_LOW_BIT_W - 1:0]      bank_wr_addr;      // write address bus
//	wire [(DATA_W_IN_BYTES*8) - 1:0]   bank_wr_data;      // write data bus

    // Clock & reset for registers
	reg   							                 ACLK;              // Clock source
	reg                                  ARESETn;           // Reset source

//    wire [(DATA_W_IN_BYTES*8) - 1:0]   bank_rd_data_bus[DCADDR_STROBE_MEM_SEG-1:0]; // read data bus
//	wire [(ADDR_W_IN_BITS)-1:DCADDR_LOW_BIT_W] decode_rd_addr;    // used external to the block to select the correct returning data

//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
pc_ctrl  #(
	.DATA_W_IN_BYTES       (DATA_W_IN_BYTES       ),
	.ADDR_W_IN_BITS        (ADDR_W_IN_BITS        ),
	.DCADDR_LOW_BIT_W      (DCADDR_LOW_BIT_W      ),
	.DCADDR_STROBE_MEM_SEG (DCADDR_STROBE_MEM_SEG )
) jjreg_top_ctrl_i (
    .S_AXI_AWADDR      (S_AXI_AWADDR  ), // Write channel Protection type. This signal indicates the    // privilege and security level of the transaction, and whether    // the transaction is a data access or an instruction access.
    .S_AXI_AWPROT      (S_AXI_AWPROT  ), // Write address valid. This signal indicates that the master signaling // valid write address and control information.
    .S_AXI_AWVALID     (S_AXI_AWVALID ), // Write address ready. This signal indicates that the slave is ready    // to accept an address and associated control signals.
    .S_AXI_AWREADY     (S_AXI_AWREADY ), // Write data (issued by master, acceped by Slave)

    .S_AXI_WDATA       (S_AXI_WDATA   ), // Write strobes. This signal indicates which byte lanes hold    // valid data. There is one write strobe bit for each eight    // bits of the write data bus.
    .S_AXI_WSTRB       (S_AXI_WSTRB   ), // Write valid. This signal indicates that valid write    // data and strobes are available.
    .S_AXI_WVALID      (S_AXI_WVALID  ), // Write ready. This signal indicates that the slave    // can accept the write data.
    .S_AXI_WREADY      (S_AXI_WREADY  ), // Write response. This signal indicates the status    // of the write transaction.

    .S_AXI_BRESP       (S_AXI_BRESP   ), // Write response valid. This signal indicates that the channel    // is signaling a valid write response.
    .S_AXI_BVALID      (S_AXI_BVALID  ), // Response ready. This signal indicates that the master    // can accept a write response.
    .S_AXI_BREADY      (S_AXI_BREADY  ), // Read address (issued by master, acceped by Slave)

    .S_AXI_ARADDR      (S_AXI_ARADDR  ), // Protection type. This signal indicates the privilege    // and security level of the transaction, and whether the    // transaction is a data access or an instruction access.
    .S_AXI_ARPROT      (S_AXI_ARPROT  ), // Read address valid. This signal indicates that the channel    // is signaling valid read address and control information.
    .S_AXI_ARVALID     (S_AXI_ARVALID ), // Read address ready. This signal indicates that the slave is    // ready to accept an address and associated control signals.
    .S_AXI_ARREADY     (S_AXI_ARREADY ), // Read data (issued by slave)

    .S_AXI_RDATA       (S_AXI_RDATA   ), // Read response. This signal indicates the status of the    // read transfer.
    .S_AXI_RRESP       (S_AXI_RRESP   ), // Read valid. This signal indicates that the channel is signaling the required read data.
    .S_AXI_RVALID      (S_AXI_RVALID  ), // Read ready. This signal indicates that the master can accept the read data and response information.
    .S_AXI_RREADY      (S_AXI_RREADY  ),

	.ACLK              (ACLK          ), // Clock source
	.ARESETn           (ARESETn       )  // Reset source

);


////------------------------------------------------------------------------------
////
////------------------------------------------------------------------------------
//jjreg_axi4lite_regif  #(
//	.DATA_W_IN_BYTES       (DATA_W_IN_BYTES       ),
//	.ADDR_W_IN_BITS        (ADDR_W_IN_BITS        ),
//	.DCADDR_LOW_BIT_W      (DCADDR_LOW_BIT_W      ),
//	.DCADDR_STROBE_MEM_SEG (DCADDR_STROBE_MEM_SEG )
//) jjreg_axi4lite_regif_i (
//    .S_AXI_AWADDR      (S_AXI_AWADDR  ), // Write channel Protection type. This signal indicates the    // privilege and security level of the transaction, and whether    // the transaction is a data access or an instruction access.
//    .S_AXI_AWPROT      (S_AXI_AWPROT  ), // Write address valid. This signal indicates that the master signaling // valid write address and control information.
//    .S_AXI_AWVALID     (S_AXI_AWVALID ), // Write address ready. This signal indicates that the slave is ready    // to accept an address and associated control signals.
//    .S_AXI_AWREADY     (S_AXI_AWREADY ), // Write data (issued by master, acceped by Slave)

//    .S_AXI_WDATA       (S_AXI_WDATA   ), // Write strobes. This signal indicates which byte lanes hold    // valid data. There is one write strobe bit for each eight    // bits of the write data bus.
//    .S_AXI_WSTRB       (S_AXI_WSTRB   ), // Write valid. This signal indicates that valid write    // data and strobes are available.
//    .S_AXI_WVALID      (S_AXI_WVALID  ), // Write ready. This signal indicates that the slave    // can accept the write data.
//    .S_AXI_WREADY      (S_AXI_WREADY  ), // Write response. This signal indicates the status    // of the write transaction.

//    .S_AXI_BRESP       (S_AXI_BRESP   ), // Write response valid. This signal indicates that the channel    // is signaling a valid write response.
//    .S_AXI_BVALID      (S_AXI_BVALID  ), // Response ready. This signal indicates that the master    // can accept a write response.
//    .S_AXI_BREADY      (S_AXI_BREADY  ), // Read address (issued by master, acceped by Slave)

//    .S_AXI_ARADDR      (S_AXI_ARADDR  ), // Protection type. This signal indicates the privilege    // and security level of the transaction, and whether the    // transaction is a data access or an instruction access.
//    .S_AXI_ARPROT      (S_AXI_ARPROT  ), // Read address valid. This signal indicates that the channel    // is signaling valid read address and control information.
//    .S_AXI_ARVALID     (S_AXI_ARVALID ), // Read address ready. This signal indicates that the slave is    // ready to accept an address and associated control signals.
//    .S_AXI_ARREADY     (S_AXI_ARREADY ), // Read data (issued by slave)

//    .S_AXI_RDATA       (S_AXI_RDATA   ), // Read response. This signal indicates the status of the    // read transfer.
//    .S_AXI_RRESP       (S_AXI_RRESP   ), // Read valid. This signal indicates that the channel is signaling the required read data.
//    .S_AXI_RVALID      (S_AXI_RVALID  ), // Read ready. This signal indicates that the master can accept the read data and response information.
//    .S_AXI_RREADY      (S_AXI_RREADY  ),

//	.reg_bank_rd_start (bank_rd_start ), // read start strobe
//	.reg_bank_rd_done  (bank_rd_done  ), // read done  strobe
//	.reg_bank_rd_addr  (bank_rd_addr  ), // read address bus
//	.reg_bank_rd_data  (bank_rd_data  ), // read data bus
//	.decode_rd_addr    (decode_rd_addr),

//	.reg_bank_wr_start (bank_wr_start ), // write start strobe
//	.reg_bank_wr_done  (bank_wr_done  ), // write done  strobe
//	.reg_bank_wr_addr  (bank_wr_addr  ), // write address bus
//	.reg_bank_wr_data  (bank_wr_data  ), // write data bus

//	.ACLK              (ACLK          ), // Clock source
//	.ARESETn           (ARESETn       )  // Reset source

//);

//always @(*) begin
//   case(decode_rd_addr)
//   0:bank_rd_data = bank_rd_data_bus[0];
//   1:bank_rd_data = bank_rd_data_bus[1];
//   2:bank_rd_data = bank_rd_data_bus[2];
//   default:bank_rd_data = bank_rd_data_bus[0];
//   endcase
//end


//jjreg_tmp_reg_basic #(
//	.DATA_W_IN_BYTES       (DATA_W_IN_BYTES       ),
//	.ADDR_W_IN_BITS        (ADDR_W_IN_BITS        ),
//	.DCADDR_LOW_BIT_W      (DCADDR_LOW_BIT_W      )
//) jjreg_tmp_reg_basic_0_i (

//	.reg_bank_rd_start (bank_rd_start[0]    ), // read start strobe
//	.reg_bank_rd_done  (bank_rd_done[0]     ), // read done  strobe
//	.reg_bank_rd_addr  (bank_rd_addr        ), // read address bus
//	.reg_bank_rd_data  (bank_rd_data_bus[0] ), // read data bus

//	.reg_bank_wr_start (bank_wr_start[0]    ), // write start strobe
//	.reg_bank_wr_done  (bank_wr_done[0]     ), // write done  strobe
//	.reg_bank_wr_addr  (bank_wr_addr        ), // write address bus
//	.reg_bank_wr_data  (bank_wr_data        ), // write data bus

//	.ACLK              (ACLK                ), // Clock source
//	.ARESETn           (ARESETn             )  // Reset source
//);

//jjreg_tmp_reg_basic #(
//	.DATA_W_IN_BYTES       (DATA_W_IN_BYTES       ),
//	.ADDR_W_IN_BITS        (ADDR_W_IN_BITS        ),
//	.DCADDR_LOW_BIT_W      (DCADDR_LOW_BIT_W      )
//) jjreg_tmp_reg_basic_1_i (

//	.reg_bank_rd_start (bank_rd_start[1]    ), // read start strobe
//	.reg_bank_rd_done  (bank_rd_done[1]     ), // read done  strobe
//	.reg_bank_rd_addr  (bank_rd_addr        ), // read address bus
//	.reg_bank_rd_data  (bank_rd_data_bus[1] ), // read data bus

//	.reg_bank_wr_start (bank_wr_start[1]    ), // write start strobe
//	.reg_bank_wr_done  (bank_wr_done[1]     ), // write done  strobe
//	.reg_bank_wr_addr  (bank_wr_addr        ), // write address bus
//	.reg_bank_wr_data  (bank_wr_data        ), // write data bus

//	.ACLK              (ACLK                ), // Clock source
//	.ARESETn           (ARESETn             )  // Reset source
//);

//jjreg_tmp_reg_basic #(
//	.DATA_W_IN_BYTES       (DATA_W_IN_BYTES       ),
//	.ADDR_W_IN_BITS        (ADDR_W_IN_BITS        ),
//	.DCADDR_LOW_BIT_W      (DCADDR_LOW_BIT_W      )
//) jjreg_tmp_reg_basic_2_i (

//	.reg_bank_rd_start (bank_rd_start[2]    ), // read start strobe
//	.reg_bank_rd_done  (bank_rd_done[2]     ), // read done  strobe
//	.reg_bank_rd_addr  (bank_rd_addr        ), // read address bus
//	.reg_bank_rd_data  (bank_rd_data_bus[2] ), // read data bus

//	.reg_bank_wr_start (bank_wr_start[2]    ), // write start strobe
//	.reg_bank_wr_done  (bank_wr_done[2]     ), // write done  strobe
//	.reg_bank_wr_addr  (bank_wr_addr        ), // write address bus
//	.reg_bank_wr_data  (bank_wr_data        ), // write data bus

//	.ACLK              (ACLK                ), // Clock source
//	.ARESETn           (ARESETn             )  // Reset source
//);

//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
always begin
   ACLK = 1'b0;
   #(PERIOD/2) ACLK = 1'b1;
   #(PERIOD/2);
end

//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
initial begin
   wait_aclk_cycles_for_to(200);
end

initial begin
   ARESETn = 0;
   initialise_axi_inputs();
   wait_aclk_cycles(20);
   ARESETn = 1;
   wait_aclk_cycles(20);
//   bank_rd_data = 44;
   axi_read('h20,read_data);
   axi_write('h20,33);
//   bank_rd_data = 49;
   axi_read('h20,read_data);
   wait_aclk_cycles(20);
   axi_write('h00_00,'h0);
   axi_write('h00_00,'hff);
   axi_write('h01_00,'h1);
   axi_write('h02_00,'h2);
   axi_read('h00_00,read_data);
   axi_read('h01_00,read_data);
   axi_read('h02_00,read_data);
   axi_read('h04_00,read_data);

   $stop;
end

task initialise_axi_inputs;
   begin
   S_AXI_AWADDR  = 'd0;
   S_AXI_AWPROT  = 'd0;
   S_AXI_AWVALID = 'd0;

   S_AXI_WDATA   = 'd0;
   S_AXI_WSTRB   = 'd0;
   S_AXI_WVALID  = 'd0;

   S_AXI_BREADY  = 'd0;

   S_AXI_ARADDR  = 'd0;
   S_AXI_ARPROT  = 'd0;
   S_AXI_ARVALID = 'd0;

   S_AXI_RREADY  = 'd0;
   end
endtask

//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
task axi_read;
   input  [(ADDR_W_IN_BITS)-1 : 0] ADDR;
   output [(DATA_W_IN_BYTES*8) - 1:0] DATA;
   begin
   @(posedge ACLK);
   S_AXI_ARADDR  <= ADDR;
   S_AXI_ARPROT  <= 'd0;
   S_AXI_ARVALID <= 'd1;
   S_AXI_RREADY  <= 'd1; // This can be high as xfer starts

   @(posedge ACLK);
   while( S_AXI_ARREADY == 'd0 )
      @(posedge ACLK);

   S_AXI_ARVALID <= 'd0;

   while( S_AXI_RVALID == 'd0 )
      @(posedge ACLK);

   S_AXI_RREADY <= 'd0;
   DATA         <= S_AXI_RDATA;
//   S_AXI_RRESP
   end
endtask

task axi_write;
   input  [(ADDR_W_IN_BITS)-1 : 0] ADDR;
   input  [(DATA_W_IN_BYTES*8) - 1:0] DATA;
   begin
   @(posedge ACLK);
   S_AXI_AWADDR  <= ADDR;
   S_AXI_AWPROT  <= 'd0;
   S_AXI_AWVALID <= 'd1;
   S_AXI_WVALID  <= 'd1;
   S_AXI_WDATA   <= DATA;

   @(posedge ACLK);
   while( (S_AXI_AWREADY & S_AXI_WREADY) == 'd0 )
      @(posedge ACLK);

   S_AXI_AWVALID <= 'd0;
   S_AXI_WVALID  <= 'd0;

   S_AXI_BREADY <= 'd1;
   while( S_AXI_BVALID == 'd0 )
      @(posedge ACLK);

   S_AXI_BREADY <= 'd0;
//   @(posedge ACLK);
//   S_AXI_BREADY <= 'd0;
   end
endtask

task wait_aclk_cycles_for_to;
   input  [31 : 0] cycles;
   begin
      while( cycles > 'd0 ) begin
         @(posedge ACLK);
         cycles = cycles - 'd1;
      end
   $display("---ERROR simulation timeout!");
   $stop;
   end
endtask


task wait_aclk_cycles;
   input  [31 : 0] cycles;
   begin
      while( cycles > 'd0 ) begin
         @(posedge ACLK);
         cycles = cycles - 'd1;
      end
   end
endtask
endmodule
