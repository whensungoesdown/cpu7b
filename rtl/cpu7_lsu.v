`include "defines.vh"
`include "decoded.vh"

module cpu7_lsu(
   input                              clk,
   input                              resetn,

   input                              valid_e,
   input [`LSOC1K_LSU_CODE_BIT-1:0]   lsu_op,
   input [`GRLEN-1:0]                 base,
   input [`GRLEN-1:0]                 offset,
   input [`GRLEN-1:0]                 wdata,
   input [4:0]                        ecl_lsu_rd_e,
   input                              ecl_lsu_wen_e,

   //memory interface
   output                             lsu_biu_rd_req,
   output [`GRLEN-1:0]                lsu_biu_rd_addr,

   input                              biu_lsu_rd_ack,
   input                              biu_lsu_data_valid,
   input  [63:0]                      biu_lsu_data,

   output                             lsu_biu_wr_req,
   output [`GRLEN-1:0]                lsu_biu_wr_addr,
   output [63:0]                      lsu_biu_wr_data,
   output [7:0]                       lsu_biu_wr_strb,

   input                              biu_lsu_wr_ack,
   input                              biu_lsu_write_done,


   //result 
   output                             lsu_addr_finish, // addr ok
   output [`GRLEN-1:0]                read_result_m,
   output                             lsu_finish_m, // data ok
   output [4:0]                       lsu_ecl_rd_m,
   output                             lsu_ecl_wen_m,
   output                             lsu_ecl_ale_e,
   output [`GRLEN-1:0]                lsu_csr_badv_e
   );

   // tmp
   wire data_scsucceed = 1'b1;

   //wire lsu_except;
   wire lsu_ale_e;
   wire lsu_ale_m;
   

   wire valid_val_e;
   wire valid_val_m;

   wire valid_m;

   dff_s #(1) valid_e2m_reg (
      .din (valid_e),
      .clk (clk),
      .q   (valid_m),
      .se(), .si(), .so());

   assign valid_val_e = valid_e & ~lsu_ale_e;

  
   // valid_val_m is used to send requests to the BIU. The LSU registers all
   // parameters until it receives an acknowledgment, indicating that the BIU
   // has completed arbitration and the parameters are registered.
   dffrle_s #(1) valid_val_e2m_reg (
      .din (valid_val_e),
      .rst_l (resetn),
      .en  (valid_val_e | (biu_lsu_rd_ack | biu_lsu_wr_ack)),
      .clk (clk),
      .q   (valid_val_m),
      .se(), .si(), .so());

   
   // lsu_op needs dff, the following combinational logic is only used when data_data_ok is signaled at _m
   wire [`LSOC1K_LSU_CODE_BIT-1:0]    lsu_op_m;
   
   dffe_s #(`LSOC1K_LSU_CODE_BIT) lsu_op_e2m_reg (
      .din (lsu_op),
      .en  (valid_e),
      .clk (clk),
      .q   (lsu_op_m),
      .se(), .si(), .so());

   // lsu_op is decoded at _e
   // lsu_op_m is decoded at _m

   // LSUop decoder
   wire lsu_am      = lsu_op == `LSOC1K_LSU_AMSWAP_W    || lsu_op == `LSOC1K_LSU_AMSWAP_D    || lsu_op == `LSOC1K_LSU_AMADD_W     || lsu_op == `LSOC1K_LSU_AMADD_D     ||
	              lsu_op == `LSOC1K_LSU_AMAND_W     || lsu_op == `LSOC1K_LSU_AMAND_D     || lsu_op == `LSOC1K_LSU_AMOR_W      || lsu_op == `LSOC1K_LSU_AMOR_D      ||
	              lsu_op == `LSOC1K_LSU_AMXOR_W     || lsu_op == `LSOC1K_LSU_AMXOR_D     || lsu_op == `LSOC1K_LSU_AMMAX_W     || lsu_op == `LSOC1K_LSU_AMMAX_D     ||
	              lsu_op == `LSOC1K_LSU_AMMIN_W     || lsu_op == `LSOC1K_LSU_AMMIN_D     || lsu_op == `LSOC1K_LSU_AMMAX_WU    || lsu_op == `LSOC1K_LSU_AMMAX_DU    ||
	              lsu_op == `LSOC1K_LSU_AMMIN_WU    || lsu_op == `LSOC1K_LSU_AMMIN_DU    || lsu_op == `LSOC1K_LSU_AMSWAP_DB_W || lsu_op == `LSOC1K_LSU_AMSWAP_DB_D ||
	              lsu_op == `LSOC1K_LSU_AMADD_DB_W  || lsu_op == `LSOC1K_LSU_AMADD_DB_D  || lsu_op == `LSOC1K_LSU_AMAND_DB_W  || lsu_op == `LSOC1K_LSU_AMAND_DB_D  ||
	              lsu_op == `LSOC1K_LSU_AMOR_DB_W   || lsu_op == `LSOC1K_LSU_AMOR_DB_D   || lsu_op == `LSOC1K_LSU_AMXOR_DB_W  || lsu_op == `LSOC1K_LSU_AMXOR_DB_D  ||
	              lsu_op == `LSOC1K_LSU_AMMAX_DB_W  || lsu_op == `LSOC1K_LSU_AMMAX_DB_D  || lsu_op == `LSOC1K_LSU_AMMIN_DB_W  || lsu_op == `LSOC1K_LSU_AMMIN_DB_D  ||
	              lsu_op == `LSOC1K_LSU_AMMAX_DB_WU || lsu_op == `LSOC1K_LSU_AMMAX_DB_DU || lsu_op == `LSOC1K_LSU_AMMIN_DB_WU || lsu_op == `LSOC1K_LSU_AMMIN_DB_DU ;

   wire lsu_am_m    = lsu_op_m == `LSOC1K_LSU_AMSWAP_W    || lsu_op_m == `LSOC1K_LSU_AMSWAP_D    || lsu_op_m == `LSOC1K_LSU_AMADD_W     || lsu_op_m == `LSOC1K_LSU_AMADD_D     ||
	              lsu_op_m == `LSOC1K_LSU_AMAND_W     || lsu_op_m == `LSOC1K_LSU_AMAND_D     || lsu_op_m == `LSOC1K_LSU_AMOR_W      || lsu_op_m == `LSOC1K_LSU_AMOR_D      ||
	              lsu_op_m == `LSOC1K_LSU_AMXOR_W     || lsu_op_m == `LSOC1K_LSU_AMXOR_D     || lsu_op_m == `LSOC1K_LSU_AMMAX_W     || lsu_op_m == `LSOC1K_LSU_AMMAX_D     ||
	              lsu_op_m == `LSOC1K_LSU_AMMIN_W     || lsu_op_m == `LSOC1K_LSU_AMMIN_D     || lsu_op_m == `LSOC1K_LSU_AMMAX_WU    || lsu_op_m == `LSOC1K_LSU_AMMAX_DU    ||
	              lsu_op_m == `LSOC1K_LSU_AMMIN_WU    || lsu_op_m == `LSOC1K_LSU_AMMIN_DU    || lsu_op_m == `LSOC1K_LSU_AMSWAP_DB_W || lsu_op_m == `LSOC1K_LSU_AMSWAP_DB_D ||
	              lsu_op_m == `LSOC1K_LSU_AMADD_DB_W  || lsu_op_m == `LSOC1K_LSU_AMADD_DB_D  || lsu_op_m == `LSOC1K_LSU_AMAND_DB_W  || lsu_op_m == `LSOC1K_LSU_AMAND_DB_D  ||
	              lsu_op_m == `LSOC1K_LSU_AMOR_DB_W   || lsu_op_m == `LSOC1K_LSU_AMOR_DB_D   || lsu_op_m == `LSOC1K_LSU_AMXOR_DB_W  || lsu_op_m == `LSOC1K_LSU_AMXOR_DB_D  ||
	              lsu_op_m == `LSOC1K_LSU_AMMAX_DB_W  || lsu_op_m == `LSOC1K_LSU_AMMAX_DB_D  || lsu_op_m == `LSOC1K_LSU_AMMIN_DB_W  || lsu_op_m == `LSOC1K_LSU_AMMIN_DB_D  ||
	              lsu_op_m == `LSOC1K_LSU_AMMAX_DB_WU || lsu_op_m == `LSOC1K_LSU_AMMAX_DB_DU || lsu_op_m == `LSOC1K_LSU_AMMIN_DB_WU || lsu_op_m == `LSOC1K_LSU_AMMIN_DB_DU ;
   
   wire lsu_am_lw   = lsu_op == `LSOC1K_LSU_AMSWAP_W    || lsu_op == `LSOC1K_LSU_AMADD_W     ||
	              lsu_op == `LSOC1K_LSU_AMAND_W     || lsu_op == `LSOC1K_LSU_AMOR_W      ||
	              lsu_op == `LSOC1K_LSU_AMXOR_W     || lsu_op == `LSOC1K_LSU_AMMAX_W     ||
	              lsu_op == `LSOC1K_LSU_AMMIN_W     || lsu_op == `LSOC1K_LSU_AMMAX_WU    ||
	              lsu_op == `LSOC1K_LSU_AMMIN_WU    || lsu_op == `LSOC1K_LSU_AMSWAP_DB_W ||
	              lsu_op == `LSOC1K_LSU_AMADD_DB_W  || lsu_op == `LSOC1K_LSU_AMAND_DB_W  ||
	              lsu_op == `LSOC1K_LSU_AMOR_DB_W   || lsu_op == `LSOC1K_LSU_AMXOR_DB_W  ||
	              lsu_op == `LSOC1K_LSU_AMMAX_DB_W  || lsu_op == `LSOC1K_LSU_AMMIN_DB_W  ||
	              lsu_op == `LSOC1K_LSU_AMMAX_DB_WU || lsu_op == `LSOC1K_LSU_AMMIN_DB_WU ;

   wire lsu_am_lw_m = lsu_op_m == `LSOC1K_LSU_AMSWAP_W    || lsu_op_m == `LSOC1K_LSU_AMADD_W     ||
	              lsu_op_m == `LSOC1K_LSU_AMAND_W     || lsu_op_m == `LSOC1K_LSU_AMOR_W      ||
	              lsu_op_m == `LSOC1K_LSU_AMXOR_W     || lsu_op_m == `LSOC1K_LSU_AMMAX_W     ||
	              lsu_op_m == `LSOC1K_LSU_AMMIN_W     || lsu_op_m == `LSOC1K_LSU_AMMAX_WU    ||
	              lsu_op_m == `LSOC1K_LSU_AMMIN_WU    || lsu_op_m == `LSOC1K_LSU_AMSWAP_DB_W ||
	              lsu_op_m == `LSOC1K_LSU_AMADD_DB_W  || lsu_op_m == `LSOC1K_LSU_AMAND_DB_W  ||
	              lsu_op_m == `LSOC1K_LSU_AMOR_DB_W   || lsu_op_m == `LSOC1K_LSU_AMXOR_DB_W  ||
	              lsu_op_m == `LSOC1K_LSU_AMMAX_DB_W  || lsu_op_m == `LSOC1K_LSU_AMMIN_DB_W  ||
	              lsu_op_m == `LSOC1K_LSU_AMMAX_DB_WU || lsu_op_m == `LSOC1K_LSU_AMMIN_DB_WU ;
   
   wire lsu_am_ld   = lsu_op == `LSOC1K_LSU_AMSWAP_D    || lsu_op == `LSOC1K_LSU_AMADD_D     ||
	              lsu_op == `LSOC1K_LSU_AMAND_D     || lsu_op == `LSOC1K_LSU_AMOR_D      ||
	              lsu_op == `LSOC1K_LSU_AMXOR_D     || lsu_op == `LSOC1K_LSU_AMMAX_D     ||
	              lsu_op == `LSOC1K_LSU_AMMIN_D     || lsu_op == `LSOC1K_LSU_AMMAX_DU    ||
	              lsu_op == `LSOC1K_LSU_AMMIN_DU    || lsu_op == `LSOC1K_LSU_AMSWAP_DB_D ||
	              lsu_op == `LSOC1K_LSU_AMADD_DB_D  || lsu_op == `LSOC1K_LSU_AMAND_DB_D  ||
	              lsu_op == `LSOC1K_LSU_AMOR_DB_D   || lsu_op == `LSOC1K_LSU_AMXOR_DB_D  ||
	              lsu_op == `LSOC1K_LSU_AMMAX_DB_D  || lsu_op == `LSOC1K_LSU_AMMIN_DB_D  ||
	              lsu_op == `LSOC1K_LSU_AMMAX_DB_DU || lsu_op == `LSOC1K_LSU_AMMIN_DB_DU ;

   wire lsu_am_ld_m = lsu_op_m == `LSOC1K_LSU_AMSWAP_D    || lsu_op_m == `LSOC1K_LSU_AMADD_D     ||
	              lsu_op_m == `LSOC1K_LSU_AMAND_D     || lsu_op_m == `LSOC1K_LSU_AMOR_D      ||
	              lsu_op_m == `LSOC1K_LSU_AMXOR_D     || lsu_op_m == `LSOC1K_LSU_AMMAX_D     ||
	              lsu_op_m == `LSOC1K_LSU_AMMIN_D     || lsu_op_m == `LSOC1K_LSU_AMMAX_DU    ||
	              lsu_op_m == `LSOC1K_LSU_AMMIN_DU    || lsu_op_m == `LSOC1K_LSU_AMSWAP_DB_D ||
	              lsu_op_m == `LSOC1K_LSU_AMADD_DB_D  || lsu_op_m == `LSOC1K_LSU_AMAND_DB_D  ||
	              lsu_op_m == `LSOC1K_LSU_AMOR_DB_D   || lsu_op_m == `LSOC1K_LSU_AMXOR_DB_D  ||
	              lsu_op_m == `LSOC1K_LSU_AMMAX_DB_D  || lsu_op_m == `LSOC1K_LSU_AMMIN_DB_D  ||
	              lsu_op_m == `LSOC1K_LSU_AMMAX_DB_DU || lsu_op_m == `LSOC1K_LSU_AMMIN_DB_DU ;
   
   wire lsu_am_sw   = lsu_op == `LSOC1K_LSU_AMSWAP_W    || lsu_op == `LSOC1K_LSU_AMADD_W     ||
	              lsu_op == `LSOC1K_LSU_AMAND_W     || lsu_op == `LSOC1K_LSU_AMOR_W      ||
	              lsu_op == `LSOC1K_LSU_AMXOR_W     || lsu_op == `LSOC1K_LSU_AMMAX_W     ||
	              lsu_op == `LSOC1K_LSU_AMMIN_W     || lsu_op == `LSOC1K_LSU_AMMAX_WU    ||
	              lsu_op == `LSOC1K_LSU_AMMIN_WU    || lsu_op == `LSOC1K_LSU_AMSWAP_DB_W ||
	              lsu_op == `LSOC1K_LSU_AMADD_DB_W  || lsu_op == `LSOC1K_LSU_AMAND_DB_W  ||
	              lsu_op == `LSOC1K_LSU_AMOR_DB_W   || lsu_op == `LSOC1K_LSU_AMXOR_DB_W  ||
	              lsu_op == `LSOC1K_LSU_AMMAX_DB_W  || lsu_op == `LSOC1K_LSU_AMMIN_DB_W  ||
	              lsu_op == `LSOC1K_LSU_AMMAX_DB_WU || lsu_op == `LSOC1K_LSU_AMMIN_DB_WU ;

   wire lsu_am_sw_m = lsu_op_m == `LSOC1K_LSU_AMSWAP_W    || lsu_op_m == `LSOC1K_LSU_AMADD_W     ||
	              lsu_op_m == `LSOC1K_LSU_AMAND_W     || lsu_op_m == `LSOC1K_LSU_AMOR_W      ||
	              lsu_op_m == `LSOC1K_LSU_AMXOR_W     || lsu_op_m == `LSOC1K_LSU_AMMAX_W     ||
	              lsu_op_m == `LSOC1K_LSU_AMMIN_W     || lsu_op_m == `LSOC1K_LSU_AMMAX_WU    ||
	              lsu_op_m == `LSOC1K_LSU_AMMIN_WU    || lsu_op_m == `LSOC1K_LSU_AMSWAP_DB_W ||
	              lsu_op_m == `LSOC1K_LSU_AMADD_DB_W  || lsu_op_m == `LSOC1K_LSU_AMAND_DB_W  ||
	              lsu_op_m == `LSOC1K_LSU_AMOR_DB_W   || lsu_op_m == `LSOC1K_LSU_AMXOR_DB_W  ||
	              lsu_op_m == `LSOC1K_LSU_AMMAX_DB_W  || lsu_op_m == `LSOC1K_LSU_AMMIN_DB_W  ||
	              lsu_op_m == `LSOC1K_LSU_AMMAX_DB_WU || lsu_op_m == `LSOC1K_LSU_AMMIN_DB_WU ;

   wire lsu_am_sd   = lsu_op == `LSOC1K_LSU_AMSWAP_D    || lsu_op == `LSOC1K_LSU_AMADD_D     ||
	              lsu_op == `LSOC1K_LSU_AMAND_D     || lsu_op == `LSOC1K_LSU_AMOR_D      ||
	              lsu_op == `LSOC1K_LSU_AMXOR_D     || lsu_op == `LSOC1K_LSU_AMMAX_D     ||
	              lsu_op == `LSOC1K_LSU_AMMIN_D     || lsu_op == `LSOC1K_LSU_AMMAX_DU    ||
	              lsu_op == `LSOC1K_LSU_AMMIN_DU    || lsu_op == `LSOC1K_LSU_AMSWAP_DB_D ||
	              lsu_op == `LSOC1K_LSU_AMADD_DB_D  || lsu_op == `LSOC1K_LSU_AMAND_DB_D  ||
	              lsu_op == `LSOC1K_LSU_AMOR_DB_D   || lsu_op == `LSOC1K_LSU_AMXOR_DB_D  ||
	              lsu_op == `LSOC1K_LSU_AMMAX_DB_D  || lsu_op == `LSOC1K_LSU_AMMIN_DB_D  ||
	              lsu_op == `LSOC1K_LSU_AMMAX_DB_DU || lsu_op == `LSOC1K_LSU_AMMIN_DB_DU ;

   wire lsu_am_sd_m = lsu_op_m == `LSOC1K_LSU_AMSWAP_D    || lsu_op_m == `LSOC1K_LSU_AMADD_D     ||
	              lsu_op_m == `LSOC1K_LSU_AMAND_D     || lsu_op_m == `LSOC1K_LSU_AMOR_D      ||
	              lsu_op_m == `LSOC1K_LSU_AMXOR_D     || lsu_op_m == `LSOC1K_LSU_AMMAX_D     ||
	              lsu_op_m == `LSOC1K_LSU_AMMIN_D     || lsu_op_m == `LSOC1K_LSU_AMMAX_DU    ||
	              lsu_op_m == `LSOC1K_LSU_AMMIN_DU    || lsu_op_m == `LSOC1K_LSU_AMSWAP_DB_D ||
	              lsu_op_m == `LSOC1K_LSU_AMADD_DB_D  || lsu_op_m == `LSOC1K_LSU_AMAND_DB_D  ||
	              lsu_op_m == `LSOC1K_LSU_AMOR_DB_D   || lsu_op_m == `LSOC1K_LSU_AMXOR_DB_D  ||
	              lsu_op_m == `LSOC1K_LSU_AMMAX_DB_D  || lsu_op_m == `LSOC1K_LSU_AMMIN_DB_D  ||
	              lsu_op_m == `LSOC1K_LSU_AMMAX_DB_DU || lsu_op_m == `LSOC1K_LSU_AMMIN_DB_DU ;

   wire lsu_llw     = lsu_op == `LSOC1K_LSU_LL_W;
   wire lsu_lld     = lsu_op == `LSOC1K_LSU_LL_D;
   wire lsu_scw     = lsu_op == `LSOC1K_LSU_SC_W;
   wire lsu_scd     = lsu_op == `LSOC1K_LSU_SC_D;
   
   wire lsu_llw_m   = lsu_op_m == `LSOC1K_LSU_LL_W;
   wire lsu_lld_m   = lsu_op_m == `LSOC1K_LSU_LL_D;
   wire lsu_scw_m   = lsu_op_m == `LSOC1K_LSU_SC_W;
   wire lsu_scd_m   = lsu_op_m == `LSOC1K_LSU_SC_D;

   wire lsu_lw      = lsu_op == `LSOC1K_LSU_LD_W  || lsu_op == `LSOC1K_LSU_LDX_W  || lsu_op == `LSOC1K_LSU_LDGT_W || lsu_op == `LSOC1K_LSU_LDLE_W || lsu_op == `LSOC1K_LSU_IOCSRRD_W;
   wire lsu_lwu     = lsu_op == `LSOC1K_LSU_LD_WU || lsu_op == `LSOC1K_LSU_LDX_WU ;
   wire lsu_sw      = lsu_op == `LSOC1K_LSU_ST_W  || lsu_op == `LSOC1K_LSU_STX_W  || lsu_op == `LSOC1K_LSU_STGT_W || lsu_op == `LSOC1K_LSU_STLE_W || lsu_op == `LSOC1K_LSU_IOCSRWR_W ||
	              lsu_am_sw;
   wire lsu_lb      = lsu_op == `LSOC1K_LSU_LD_B  || lsu_op == `LSOC1K_LSU_LDX_B  || lsu_op == `LSOC1K_LSU_LDGT_B || lsu_op == `LSOC1K_LSU_LDLE_B || lsu_op == `LSOC1K_LSU_IOCSRRD_B ||
	              lsu_op == `LSOC1K_LSU_PRELD || lsu_op == `LSOC1K_LSU_PRELDX ;
   wire lsu_lbu     = lsu_op == `LSOC1K_LSU_LD_BU || lsu_op == `LSOC1K_LSU_LDX_BU ;
   wire lsu_lh      = lsu_op == `LSOC1K_LSU_LD_H  || lsu_op == `LSOC1K_LSU_LDX_H  || lsu_op == `LSOC1K_LSU_LDGT_H || lsu_op == `LSOC1K_LSU_LDLE_H || lsu_op == `LSOC1K_LSU_IOCSRRD_H;
   wire lsu_ld      = lsu_op == `LSOC1K_LSU_LD_D  || lsu_op == `LSOC1K_LSU_LDX_D  || lsu_op == `LSOC1K_LSU_LDGT_D || lsu_op == `LSOC1K_LSU_LDLE_D || lsu_op == `LSOC1K_LSU_IOCSRRD_D;
   wire lsu_lhu     = lsu_op == `LSOC1K_LSU_LD_HU || lsu_op == `LSOC1K_LSU_LDX_HU ;
   wire lsu_sb      = lsu_op == `LSOC1K_LSU_ST_B  || lsu_op == `LSOC1K_LSU_STX_B  || lsu_op == `LSOC1K_LSU_STGT_B || lsu_op == `LSOC1K_LSU_STLE_B || lsu_op == `LSOC1K_LSU_IOCSRWR_B;
   wire lsu_sh      = lsu_op == `LSOC1K_LSU_ST_H  || lsu_op == `LSOC1K_LSU_STX_H  || lsu_op == `LSOC1K_LSU_STGT_H || lsu_op == `LSOC1K_LSU_STLE_H || lsu_op == `LSOC1K_LSU_IOCSRWR_H;
   wire lsu_sd      = lsu_op == `LSOC1K_LSU_ST_D  || lsu_op == `LSOC1K_LSU_STX_D  || lsu_op == `LSOC1K_LSU_STGT_D || lsu_op == `LSOC1K_LSU_STLE_D || lsu_op == `LSOC1K_LSU_IOCSRWR_D ||
	              lsu_am_sd;

   wire lsu_lw_m    = lsu_op_m == `LSOC1K_LSU_LD_W  || lsu_op_m == `LSOC1K_LSU_LDX_W  || lsu_op_m == `LSOC1K_LSU_LDGT_W || lsu_op_m == `LSOC1K_LSU_LDLE_W || lsu_op_m == `LSOC1K_LSU_IOCSRRD_W;
   wire lsu_lwu_m   = lsu_op_m == `LSOC1K_LSU_LD_WU || lsu_op_m == `LSOC1K_LSU_LDX_WU ;
   wire lsu_sw_m    = lsu_op_m == `LSOC1K_LSU_ST_W  || lsu_op_m == `LSOC1K_LSU_STX_W  || lsu_op_m == `LSOC1K_LSU_STGT_W || lsu_op_m == `LSOC1K_LSU_STLE_W || lsu_op_m == `LSOC1K_LSU_IOCSRWR_W ||
	              lsu_am_sw;
   wire lsu_lb_m    = lsu_op_m == `LSOC1K_LSU_LD_B  || lsu_op_m == `LSOC1K_LSU_LDX_B  || lsu_op_m == `LSOC1K_LSU_LDGT_B || lsu_op_m == `LSOC1K_LSU_LDLE_B || lsu_op_m == `LSOC1K_LSU_IOCSRRD_B ||
	              lsu_op_m == `LSOC1K_LSU_PRELD || lsu_op_m == `LSOC1K_LSU_PRELDX ;
   wire lsu_lbu_m   = lsu_op_m == `LSOC1K_LSU_LD_BU || lsu_op_m == `LSOC1K_LSU_LDX_BU ;
   wire lsu_lh_m    = lsu_op_m == `LSOC1K_LSU_LD_H  || lsu_op_m == `LSOC1K_LSU_LDX_H  || lsu_op_m == `LSOC1K_LSU_LDGT_H || lsu_op_m == `LSOC1K_LSU_LDLE_H || lsu_op_m == `LSOC1K_LSU_IOCSRRD_H;
   wire lsu_ld_m    = lsu_op_m == `LSOC1K_LSU_LD_D  || lsu_op_m == `LSOC1K_LSU_LDX_D  || lsu_op_m == `LSOC1K_LSU_LDGT_D || lsu_op_m == `LSOC1K_LSU_LDLE_D || lsu_op_m == `LSOC1K_LSU_IOCSRRD_D;
   wire lsu_lhu_m   = lsu_op_m == `LSOC1K_LSU_LD_HU || lsu_op_m == `LSOC1K_LSU_LDX_HU ;
   wire lsu_sb_m    = lsu_op_m == `LSOC1K_LSU_ST_B  || lsu_op_m == `LSOC1K_LSU_STX_B  || lsu_op_m == `LSOC1K_LSU_STGT_B || lsu_op_m == `LSOC1K_LSU_STLE_B || lsu_op_m == `LSOC1K_LSU_IOCSRWR_B;
   wire lsu_sh_m    = lsu_op_m == `LSOC1K_LSU_ST_H  || lsu_op_m == `LSOC1K_LSU_STX_H  || lsu_op_m == `LSOC1K_LSU_STGT_H || lsu_op_m == `LSOC1K_LSU_STLE_H || lsu_op_m == `LSOC1K_LSU_IOCSRWR_H;
   wire lsu_sd_m    = lsu_op_m == `LSOC1K_LSU_ST_D  || lsu_op_m == `LSOC1K_LSU_STX_D  || lsu_op_m == `LSOC1K_LSU_STGT_D || lsu_op_m == `LSOC1K_LSU_STLE_D || lsu_op_m == `LSOC1K_LSU_IOCSRWR_D ||
	              lsu_am_sd;

   wire lsu_gt      = lsu_op == `LSOC1K_LSU_LDGT_W || lsu_op == `LSOC1K_LSU_LDGT_B || lsu_op == `LSOC1K_LSU_LDGT_H || lsu_op == `LSOC1K_LSU_LDGT_D ||
	              lsu_op == `LSOC1K_LSU_STGT_W || lsu_op == `LSOC1K_LSU_STGT_B || lsu_op == `LSOC1K_LSU_STGT_H || lsu_op == `LSOC1K_LSU_STGT_D ;
   wire lsu_le      = lsu_op == `LSOC1K_LSU_LDLE_W || lsu_op == `LSOC1K_LSU_LDLE_B || lsu_op == `LSOC1K_LSU_LDLE_H || lsu_op == `LSOC1K_LSU_LDLE_D ||
	              lsu_op == `LSOC1K_LSU_STLE_W || lsu_op == `LSOC1K_LSU_STLE_B || lsu_op == `LSOC1K_LSU_STLE_H || lsu_op == `LSOC1K_LSU_STLE_D ;
   wire lsu_idle    = lsu_op == `LSOC1K_LSU_IDLE;

   wire lsu_gt_m    = lsu_op_m == `LSOC1K_LSU_LDGT_W || lsu_op_m == `LSOC1K_LSU_LDGT_B || lsu_op_m == `LSOC1K_LSU_LDGT_H || lsu_op_m == `LSOC1K_LSU_LDGT_D ||
	              lsu_op_m == `LSOC1K_LSU_STGT_W || lsu_op_m == `LSOC1K_LSU_STGT_B || lsu_op_m == `LSOC1K_LSU_STGT_H || lsu_op_m == `LSOC1K_LSU_STGT_D ;
   wire lsu_le_m    = lsu_op_m == `LSOC1K_LSU_LDLE_W || lsu_op_m == `LSOC1K_LSU_LDLE_B || lsu_op_m == `LSOC1K_LSU_LDLE_H || lsu_op_m == `LSOC1K_LSU_LDLE_D ||
	              lsu_op_m == `LSOC1K_LSU_STLE_W || lsu_op_m == `LSOC1K_LSU_STLE_B || lsu_op_m == `LSOC1K_LSU_STLE_H || lsu_op_m == `LSOC1K_LSU_STLE_D ;
   wire lsu_idle_m  = lsu_op_m == `LSOC1K_LSU_IDLE;

   wire prefetch    = lsu_op == `LSOC1K_LSU_PRELD || lsu_op == `LSOC1K_LSU_PRELDX;
   wire prefetch_m  = lsu_op_m == `LSOC1K_LSU_PRELD || lsu_op == `LSOC1K_LSU_PRELDX;



   

   wire [`GRLEN-1:0]    addr     = base + offset;
   wire [ 2:0]          shift        = addr[2:0];
   wire                 lsu_wr       = lsu_sw || lsu_sb || lsu_sh || lsu_scw || lsu_scd || lsu_sd;


   wire [`GRLEN-1:0]    base_m;
   wire [`GRLEN-1:0]    offset_m;
   
   wire [`GRLEN-1:0]    addr_m       = base_m + offset_m;
   wire [ 2:0]          shift_m      = addr_m[2:0];

   wire                 high32_m     = addr_m[2];
   
   dffe_s #(`GRLEN) base_e2m_reg (
      .din (base),
      .en  (valid_e),
      .clk (clk),
      .q   (base_m),
      .se(), .si(), .so());
   
   dffe_s #(`GRLEN) offset_e2m_reg (
      .din (offset),
      .en  (valid_e),
      .clk (clk),
      .q   (offset_m),
      .se(), .si(), .so());


   wire lsu_wr_m;

   dffe_s #(1) lsu_wr_e2m_reg (
      .din (lsu_wr),
      .en  (valid_e),
      .clk (clk),
      .q   (lsu_wr_m),
      .se(), .si(), .so());


   //result process
   wire [`GRLEN-1:0] data_rdata_input = high32_m ? biu_lsu_data[63:32] : biu_lsu_data[31:0];

   
   wire [4:0] align_mode_m;

   assign align_mode_m[0] = !(lsu_scw_m || lsu_scd_m) && (lsu_ld_m ||lsu_lld_m);
   assign align_mode_m[1] = !(lsu_scw_m || lsu_scd_m) && (lsu_lw_m ||lsu_llw_m||lsu_lwu_m);
   assign align_mode_m[2] = !(lsu_scw_m || lsu_scd_m) && (lsu_lh_m ||lsu_lhu_m);
   assign align_mode_m[3] = !(lsu_scw_m || lsu_scd_m) && (lsu_lb_m ||lsu_lbu_m);
   assign align_mode_m[4] = !(lsu_scw_m || lsu_scd_m) && (lsu_lbu_m||lsu_lhu_m||lsu_lwu_m);

   wire [31:0] lsu_align_res_m = ({32{shift_m[1:0] == 2'b00 && !align_mode_m[4] && align_mode_m[3]}} & {{24{data_rdata_input[ 7]}},data_rdata_input[ 7: 0]}) | // ld.b
	                         ({32{shift_m[1:0] == 2'b01 && !align_mode_m[4] && align_mode_m[3]}} & {{24{data_rdata_input[15]}},data_rdata_input[15: 8]}) |
	                         ({32{shift_m[1:0] == 2'b10 && !align_mode_m[4] && align_mode_m[3]}} & {{24{data_rdata_input[23]}},data_rdata_input[23:16]}) |
	                         ({32{shift_m[1:0] == 2'b11 && !align_mode_m[4] && align_mode_m[3]}} & {{24{data_rdata_input[31]}},data_rdata_input[31:24]}) |
	                         ({32{shift_m[1:0] == 2'b00 &&  align_mode_m[4] && align_mode_m[3]}} & {24'd0,data_rdata_input[ 7: 0]}) |
	                         ({32{shift_m[1:0] == 2'b01 &&  align_mode_m[4] && align_mode_m[3]}} & {24'd0,data_rdata_input[15: 8]}) |
	                         ({32{shift_m[1:0] == 2'b10 &&  align_mode_m[4] && align_mode_m[3]}} & {24'd0,data_rdata_input[23:16]}) |
	                         ({32{shift_m[1:0] == 2'b11 &&  align_mode_m[4] && align_mode_m[3]}} & {24'd0,data_rdata_input[31:24]}) |
	                         ({32{shift_m[1:0] == 2'b00 && !align_mode_m[4] && align_mode_m[2]}} & {{16{data_rdata_input[15]}},data_rdata_input[15: 0]}) | // ld.h
	                         ({32{shift_m[1:0] == 2'b10 && !align_mode_m[4] && align_mode_m[2]}} & {{16{data_rdata_input[31]}},data_rdata_input[31:16]}) |
	                         ({32{shift_m[1:0] == 2'b00 &&  align_mode_m[4] && align_mode_m[2]}} & {16'd0,data_rdata_input[15: 0]}) |
	                         ({32{shift_m[1:0] == 2'b10 &&  align_mode_m[4] && align_mode_m[2]}} & {16'd0,data_rdata_input[31:16]}) |
	                         ({32{shift_m[1:0] == 2'b00 && !align_mode_m[4] && align_mode_m[1]}} & data_rdata_input[31: 0]) | // ld.w|
	                         ({32{shift_m[1:0] == 2'b00 &&  align_mode_m[4] && align_mode_m[1]}} & data_rdata_input[31: 0]) |
	                         ({32{!align_mode_m[4] && !align_mode_m[3] && !align_mode_m[2] && !align_mode_m[1]}} & {31'd0,data_scsucceed}) ;


   assign read_result_m     = lsu_align_res_m; // ensure that read_result always display valid data regardless of data_data_ok

   //assign lsu_res_valid     = data_data_ok || data_exception || res_valid || prefetch || !valid || (lsu_op == `LSOC1K_LSU_IDLE);
   //assign lsu_res_valid     = data_data_ok || data_exception || res_valid || prefetch || (lsu_op == `LSOC1K_LSU_IDLE);

   // if ale, data req is not sent out, so there will be no data_data_ok back
   // lsu_ale is at _e, wait for the next cycle to signal lsu_finish_m

   // uty: review why lsu_ale_m here?
   // A: `(lsu_ale_m & valid_m)` indicates that an ALE event has occurred in
   // the LSU. The LSU needs to complete this process.
   assign lsu_finish_m = (biu_lsu_data_valid | biu_lsu_write_done) | (lsu_ale_m & valid_m);  

   


//
//   assign data_prefetch_in = lsu_op == `LSOC1K_LSU_PRELD || lsu_op == `LSOC1K_LSU_PRELDX;
//   assign data_ll_in       = lsu_llw || lsu_lld;
//   assign data_sc_in       = lsu_scw || lsu_scd;


   wire [ 3:0]         lsu_wstrb;
   wire [`GRLEN-1:0]   lsu_wdata;
   wire                lsu_prefetch;
   wire                lsu_ll;
   wire                lsu_sc;


   assign lsu_wstrb        = {4{lsu_sw||lsu_scw}} & (4'b1111              ) |
			     {4{lsu_sh         }} & (4'b0011 << shift[1:0]) |
			     {4{lsu_sb         }} & (4'b0001 << shift[1:0]) ;
   
   assign lsu_wdata        = {32{lsu_sw||lsu_scw         }} & {wdata[31:0]} |
			     {32{lsu_sh                  }} & {wdata[15:0], wdata[15:0]} |
			     {32{lsu_sb                  }} & {wdata[7:0], wdata[7:0], wdata[7:0], wdata[7:0]};

   assign lsu_prefetch     = lsu_op == `LSOC1K_LSU_PRELD || lsu_op == `LSOC1K_LSU_PRELDX;
   assign lsu_ll           = lsu_llw || lsu_lld;
   assign lsu_sc           = lsu_scw || lsu_scd;



   //===================================================
   // Memory Interface
   //===================================================

   // biu_lsu_rd_ack       : _-_____
   // rd_fin               : _____-_
   //
   // rd_in_prog_in        : _----__
   // rd_in_prog_q         : __----_

   // data read in progress
   wire rd_in_prog_in; 
   wire rd_in_prog_q; 

   wire biu_rd_busy;
   assign biu_rd_busy = rd_in_prog_q; // | others


   wire rd_fin;
   assign rd_fin = biu_lsu_data_valid;

   assign rd_in_prog_in = (rd_in_prog_q & ~rd_fin) | biu_lsu_rd_ack;                

   dffrl_s #(1) rd_in_prog_reg (
      .din   (rd_in_prog_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (rd_in_prog_q),
      .se(), .si(), .so());


   assign lsu_biu_rd_req = (valid_val_m & ~lsu_wr_m) &
                           ~biu_rd_busy;

   assign lsu_biu_rd_addr = addr_m;


   // biu_lsu_wr_ack       : _-_____
   // wr_fin               : _____-_
   //
   // wr_in_prog_in        : _----__
   // wr_in_prog_q         : __----_

   // data write in progress
   wire wr_in_prog_in; 
   wire wr_in_prog_q; 

   wire biu_wr_busy;
   assign biu_wr_busy = wr_in_prog_q; // | others


   wire wr_fin;
   assign wr_fin = biu_lsu_write_done;

   assign wr_in_prog_in = (wr_in_prog_q & ~wr_fin) | biu_lsu_wr_ack;                

   dffrl_s #(1) wr_in_prog_reg (
      .din   (wr_in_prog_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (wr_in_prog_q),
      .se(), .si(), .so());



   assign lsu_biu_wr_req = (valid_val_e & lsu_wr) &
                           ~biu_wr_busy;
   
   wire wr_high32;
   assign wr_high32 = addr[2];

   assign lsu_biu_wr_addr = addr;
   //assign lsu_biu_wr_data = lsu_wdata; //
   //assign lsu_biu_wr_strb = lsu_wstrb; //
   assign lsu_biu_wr_data = wr_high32 ? {lsu_wdata, 32'b0} : {32'b0, lsu_wdata}; 
   assign lsu_biu_wr_strb = wr_high32 ? {lsu_wstrb, 4'b0} : {4'b0, lsu_wstrb};



   // except
   wire lsu_load        = lsu_ld || lsu_lw || lsu_llw || lsu_lld || lsu_lb  || lsu_lbu || lsu_lh || lsu_lhu || lsu_ld || lsu_lwu;
   wire lsu_store       = lsu_sb || lsu_sh || lsu_sd  || lsu_sw  || lsu_scw || lsu_scd;

   wire am_addr_align_exc = (lsu_am_lw || lsu_am_sw || lsu_llw || lsu_scw) && addr[1:0] != 2'd0 ||
	                    (lsu_am_ld || lsu_am_sd || lsu_lld || lsu_scd) && addr[2:0] != 3'd0 ;

   wire cm_addr_align_exc = (lsu_ld||lsu_sd         ) && addr[2:0] != 3'd0 ||
                            (lsu_lw||lsu_lwu||lsu_sw) && addr[1:0] != 2'd0 ||
                            (lsu_lh||lsu_lhu||lsu_sh) && addr[0]   != 1'd0 ;

   wire align_check     = 1'b1;
   
//   wire lsu_bce         = 1'b0; // TODO

  
//   assign lsu_ale       = am_addr_align_exc || align_check && cm_addr_align_exc;
//   assign lsu_adem      = 1'b0;
//   assign lsu_except    = lsu_adem || lsu_ale || lsu_bce;

   
   assign lsu_ale_e       = am_addr_align_exc || align_check && cm_addr_align_exc;

   dff_s #(1) lsu_ale_e2m_reg (
      .din (lsu_ale_e),
      .clk (clk),
      .q   (lsu_ale_m),
      .se(), .si(), .so());
   
   //assign lsu_except    = lsu_ale;

   // ale should go with valid, and valid is actually lsu_dispatch_e, only last one cycle
   assign lsu_ecl_ale_e = lsu_ale_e & valid_e;

   assign lsu_csr_badv_e = addr;


   //assign lsu_addr_finish = lsu_ecl_ale_e && (data_addr_ok || (lsu_op == `LSOC1K_LSU_IDLE));
   assign lsu_addr_finish = lsu_ecl_ale_e && (biu_lsu_wr_ack || (lsu_op == `LSOC1K_LSU_IDLE));




   wire lsu_recv;
   wire lsu_recv_next;

   assign lsu_recv_next = (lsu_recv | (biu_lsu_rd_ack | biu_lsu_wr_ack)) & (~biu_lsu_data_valid); 

   dff_s #(1) lsu_recv_reg (
      .din (lsu_recv_next),
      .clk (clk),
      .q   (lsu_recv),
      .se(), .si(), .so());
   
//   assign data_recv  = lsu_recv;
   

   
   wire [4:0]    lsu_rd_m;
   
   dffe_s #(5) lsu_rd_e2m_reg (
      .din (ecl_lsu_rd_e),
      .en  (valid_e),
      .clk (clk),
      .q   (lsu_rd_m),
      .se(), .si(), .so());

   assign lsu_ecl_rd_m = lsu_rd_m;
   
   wire    lsu_wen_m;
   
   dffe_s #(1) lsu_wen_e2m_reg (
      .din (ecl_lsu_wen_e),
      .en  (valid_e),
      .clk (clk),
      .q   (lsu_wen_m),
      .se(), .si(), .so());
   
   assign lsu_ecl_wen_m = lsu_wen_m;
   
endmodule // lsu
