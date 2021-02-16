`timescale 1ns / 1ps

//import axi4stream_vip_v1_0_0_pkg::*;
//import ex_sim_axi4stream_vip_mst_0_pkg::*;
//import ex_sim_axi4stream_vip_slv_0_pkg::*;
//import ex_sim_axi4stream_vip_passthrough_0_pkg::*;

module tb;
    reg tb_ACLK;
    reg tb_ARESETn;
   

    
    
    wire temp_clk;
    wire temp_rstn; 
    
    wire temp_scl;
    wire temp_sda;
    
    reg resp;
    

    initial 
    begin       
        tb_ACLK = 1'b0;
    end

    //------------------------------------------------------------------------
    // Simple Clock Generator
    //------------------------------------------------------------------------
    
    always #1 tb_ACLK = !tb_ACLK;
    initial
    begin
    
        $display ("running the tb");
        
        
        tb_ARESETn = 1'b0;
        repeat(20)@(posedge tb_ACLK);        
        tb_ARESETn = 1'b1;
        @(posedge tb_ACLK);

        repeat(5) @(posedge tb_ACLK);
        
        
        //Reset the PL
        tb.zynq_sys.design_1_i.processing_system7_0.inst.fpga_soft_reset(32'h1);
        tb.zynq_sys.design_1_i.processing_system7_0.inst.fpga_soft_reset(32'h0);

        

        tb.zynq_sys.design_1_i.processing_system7_0.inst.write_data(32'h43c00000,4, 32'h00000007, resp);
                  
        #100 
        
        $display ("Simulation completed");
//        $stop;
    end

    assign temp_clk = tb_ACLK;
    assign temp_rstn = tb_ARESETn;
//    assign temp_scl = scl;
//    assign temp_sda = sda;

    
   
  design_1_wrapper zynq_sys
         (.DDR_addr(),
          .DDR_ba(),
          .DDR_cas_n(),
          .DDR_ck_n(),
          .DDR_ck_p(),
          .DDR_cke(),
          .DDR_cs_n(),
          .DDR_dm(),
          .DDR_dq(),
          .DDR_dqs_n(),
          .DDR_dqs_p(),
          .DDR_odt(),
          .DDR_ras_n(),
          .DDR_reset_n(),
          .DDR_we_n(),
          .FIXED_IO_ddr_vrn(),
          .FIXED_IO_ddr_vrp(),
          .FIXED_IO_mio(),
          .FIXED_IO_ps_clk(temp_clk),
          .FIXED_IO_ps_porb(temp_rstn),
          .FIXED_IO_ps_srstb(temp_rstn),
          .scl(temp_scl),
          .sda(temp_sda));

endmodule