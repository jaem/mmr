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

module axi4_task_sim #(

  parameter DATA_W_IN_BYTES       = 4,
  parameter ADDR_W_IN_BITS        = 10,
  parameter DCADDR_LOW_BIT_W      = 8,
  parameter DCADDR_STROBE_MEM_SEG = 2,
  parameter CLK_GEN_PERIOD_IN_PS  = 10000

) (

    // AXI interface control signals
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim AWADDR" *)  output reg  [(ADDR_W_IN_BITS)-1 : 0]      S_AXI_AWADDR    ,  // Write channel Protection type. This signal indicates the    // privilege and security level of the transaction and whether    // the transaction is a data access or an instruction access.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim AWPROT" *)  output reg  [2 : 0]                       S_AXI_AWPROT    ,  // Write address valid. This signal indicates that the master signaling // valid write address and control information.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim AWVALID" *) output reg                                S_AXI_AWVALID   ,  // Write address ready. This signal indicates that the slave is ready    // to accept an address and associated control signals.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim AWREADY" *) input  wire                               S_AXI_AWREADY   ,  // Write data (issued by master acceped by Slave)

  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim WDATA" *)   output reg  [(DATA_W_IN_BYTES*8) - 1:0]   S_AXI_WDATA     ,  // Write strobes. This signal indicates which byte lanes hold    // valid data. There is one write strobe bit for each eight    // bits of the write data bus.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim WSTRB" *)   output reg  [DATA_W_IN_BYTES-1 : 0]       S_AXI_WSTRB     ,  // Write valid. This signal indicates that valid write    // data and strobes are available.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim WVALID" *)  output reg                                S_AXI_WVALID    ,  // Write ready. This signal indicates that the slave    // can accept the write data.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim WREADY" *)  input  wire                               S_AXI_WREADY    ,  // Write response. This signal indicates the status    // of the write transaction.

  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim BRESP" *)   input  wire [1 : 0]                       S_AXI_BRESP     ,  // Write response valid. This signal indicates that the channel    // is signaling a valid write response.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim BVALID" *)  input  wire                               S_AXI_BVALID    ,  // Response ready. This signal indicates that the master    // can accept a write response.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim BREADY" *)  output reg                                S_AXI_BREADY    ,  // Read address (issued by master acceped by Slave)

  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim ARADDR" *)  output reg  [(ADDR_W_IN_BITS)-1 : 0]      S_AXI_ARADDR    ,  // Protection type. This signal indicates the privilege    // and security level of the transaction and whether the    // transaction is a data access or an instruction access.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim ARPROT" *)  output reg  [2 : 0]                       S_AXI_ARPROT    ,  // Read address valid. This signal indicates that the channel    // is signaling valid read address and control information.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim ARVALID" *) output reg                                S_AXI_ARVALID   ,  // Read address ready. This signal indicates that the slave is    // ready to accept an address and associated control signals.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim ARREADY" *) input  wire                               S_AXI_ARREADY   ,  // Read data (issued by slave)

  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim RDATA" *)   input  wire [(DATA_W_IN_BYTES*8) - 1:0]   S_AXI_RDATA     ,  // Read response. This signal indicates the status of the    // read transfer.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim RRESP" *)   input  wire [1 : 0]                       S_AXI_RRESP     ,  // Read valid. This signal indicates that the channel is signaling the required read data.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim RVALID" *)  input  wire                               S_AXI_RVALID    ,  // Read ready. This signal indicates that the master can accept the read data and response information.
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi4_task_sim RREADY" *)  output reg                                S_AXI_RREADY    ,  //

  // Clock & reset for registers
  output reg                         ACLK,              // Clock source
  output reg                         ARESETn            // Reset source

);

// internal signals
reg  [(DATA_W_IN_BYTES*8) - 1:0]   read_data;         //

//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
always begin
   ACLK = 1'b0;
   #(CLK_GEN_PERIOD_IN_PS/2) ACLK = 1'b1;
   #(CLK_GEN_PERIOD_IN_PS/2);
end

//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
initial begin
   wait_aclk_cycles_for_to(200);
end

initial begin
   initialise_axi_inputs();
   ARESETn = 1;
   wait_aclk_cycles(2);
   ARESETn = 0;
   wait_aclk_cycles(20);
   ARESETn = 1;

   wait_aclk_cycles(60);
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

   axi_write('h1_0000,'h2);
   axi_read('h1_0000,read_data);
   axi_read('h1_0000,read_data);
   axi_read('h1_0000,read_data);

   $stop;
end

//------------------------------------------------------------------------------
// Initialise IO
//------------------------------------------------------------------------------
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
   reg    [1:0]  got_flags;
   begin
   got_flags=0;
   @(posedge ACLK);
   S_AXI_AWADDR  <= ADDR;
   S_AXI_AWPROT  <= 'd0;
   S_AXI_AWVALID <= 'd1;
   S_AXI_WVALID  <= 'd1;
   S_AXI_WDATA   <= DATA;

   @(posedge ACLK);
//   while( (S_AXI_AWREADY & S_AXI_WREADY) == 'd0 )
//      @(posedge ACLK);

   // Keep a record of both ready signals reception. We need to loop until both
   // have been received
   got_flags = got_flags | {S_AXI_AWREADY,S_AXI_WREADY}; 

   while( got_flags != 'd3 ) begin
      got_flags = got_flags | {S_AXI_AWREADY,S_AXI_WREADY}; 
      if (S_AXI_AWREADY)
         S_AXI_AWVALID <= 1'd0;
      if (S_AXI_WREADY)
         S_AXI_WVALID <= 1'd0;
      @(posedge ACLK);
   end

   // We still need these as if the ready signals came back strsight away, the while
   // loop is not executed and the signals not cleared
   S_AXI_AWVALID <= 'd0;
   S_AXI_WVALID  <= 'd0;

   while( S_AXI_BREADY == 'd0 )begin
      if (S_AXI_BVALID)
         S_AXI_BREADY <= 'd1;
      @(posedge ACLK);
   end

   S_AXI_BREADY <= 'd0;
//   @(posedge ACLK);
//   S_AXI_BREADY <= 'd0;
   end
endtask

task wait_aclk_cycles_for_to;
   input reg [31 : 0] cycles;
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
   input reg [31 : 0] cycles;
   begin
      while( cycles > 'd0 ) begin
         @(posedge ACLK);
         cycles = cycles - 'd1;
      end
   end
endtask
endmodule
