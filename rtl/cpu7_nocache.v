`include "common.vh"
`include "decoded.vh"

module cpu7_nocache(
    input                 clk,
    input                 resetn,            //low active
    
    
    output                inst_req       ,
    output  [ 31:0]       inst_addr      ,
    output                inst_cancel    ,
    input                 inst_addr_ok   ,
    input   [`GRLEN-1:0]  inst_rdata_f   ,
    input                 inst_valid_f   ,
    input   [  1:0]       inst_count     ,
    input                 inst_uncache   ,
    input   [  5:0]       inst_exccode   ,
    input                 inst_exception ,


    // Cache Pipeline Bus
    output                data_req       , 
    output  [`GRLEN-1:0]  data_pc        , 
    output                data_wr        , 
    output  [3 :0]        data_wstrb     , 
    output  [`GRLEN-1:0]  data_addr      , 
    output                data_cancel_ex2,
    output                data_cancel    , 
    output  [`GRLEN-1:0]  data_wdata     , 
    output                data_recv      , 
    output                data_prefetch  , 
    output                data_ll        , 
    output                data_sc        , 

    input   [`GRLEN-1:0]  data_rdata_m   , 
    input                 data_addr_ok   , 
    input                 data_data_ok_m , 
    input   [ 5:0]        data_exccode   , 
    input                 data_exception , 
    input   [`GRLEN-1:0]  data_badvaddr  , 
    input                 data_req_empty , 
    input                 data_scsucceed 

);

   wire                              ifu_exu_valid_d;
   wire [31:0]                       ifu_exu_inst_d;
   wire [`GRLEN-1:0]                 ifu_exu_pc_d;
   wire [`LSOC1K_DECODE_RES_BIT-1:0] ifu_exu_op_d;     
   wire                              ifu_exu_exception_d;
   wire [5:0]                        ifu_exu_exccode_d;
   wire [`GRLEN-3:0]                 ifu_exu_br_target_d;
   wire                              ifu_exu_br_taken_d;
   wire                              ifu_exu_rf_wen_d;     
   wire [4:0]                        ifu_exu_rf_target_d;
   wire [`LSOC1K_PRU_HINT-1:0]       ifu_exu_hint_d;       

   wire [31:0]                       ifu_exu_imm_shifted_d;
   wire [`GRLEN-1:0]                 ifu_exu_c_d;
   wire [`GRLEN-1:0]                 ifu_exu_br_offs;

   wire [`GRLEN-1:0]                 ifu_exu_pc_w;
   wire [`GRLEN-1:0]                 ifu_exu_pc_e;

   wire                              exu_ifu_stall_req;

   wire [`GRLEN-1:0]                 exu_ifu_brpc_e;
   wire                              exu_ifu_br_taken_e;

   // exception
   wire [`GRLEN-1:0]                 exu_ifu_eentry;
   wire                              exu_ifu_except;
   // ertn
   wire [`GRLEN-1:0]                 exu_ifu_era;
   wire                              exu_ifu_ertn_e;
   
   



   
   cpu7_ifu ifu(
      .clock                   (clk                ),
      .resetn                  (resetn             ),

      .pc_init                 (`GRLEN'h1c000000   ),

      .inst_addr               (inst_addr          ),
      .inst_addr_ok            (inst_addr_ok       ),
      .inst_cancel             (inst_cancel        ),
      .inst_count              (inst_count         ),
      .inst_ex                 (inst_exception     ),
      .inst_exccode            (inst_exccode       ),
      .inst_rdata_f            (inst_rdata_f       ),
      .inst_req                (inst_req           ),
      .inst_uncache            (inst_uncache       ),
      .inst_valid_f            (inst_valid_f       ),

      .exu_ifu_br_taken        (exu_ifu_br_taken_e ), // BUG, need to change name
      .exu_ifu_br_target       (exu_ifu_brpc_e     ),

      // exception
      .exu_ifu_eentry          (exu_ifu_eentry       ),
      .exu_ifu_except          (exu_ifu_except       ),
      // ertn
      .exu_ifu_era             (exu_ifu_era          ),
      .exu_ifu_ertn_e          (exu_ifu_ertn_e       ),

      // now only have one port
      .ifu_exu_valid_d         (ifu_exu_valid_d      ),
      .ifu_exu_inst_d          (ifu_exu_inst_d       ),
      .ifu_exu_pc_d            (ifu_exu_pc_d         ),
      .ifu_exu_op_d            (ifu_exu_op_d         ),
      .ifu_exu_exception_d     (ifu_exu_exception_d  ),
      .ifu_exu_exccode_d       (ifu_exu_exccode_d    ),
      .ifu_exu_br_target_d     (ifu_exu_br_target_d  ),
      .ifu_exu_br_taken_d      (ifu_exu_br_taken_d   ),
      .ifu_exu_rf_wen_d        (ifu_exu_rf_wen_d     ),
      .ifu_exu_rf_target_d     (ifu_exu_rf_target_d  ),
      .ifu_exu_hint_d          (ifu_exu_hint_d       ),

      .ifu_exu_imm_shifted_d   (ifu_exu_imm_shifted_d),
      .ifu_exu_c_d             (ifu_exu_c_d          ),
      .ifu_exu_br_offs         (ifu_exu_br_offs      ),

      .ifu_exu_pc_w            (ifu_exu_pc_w         ),
      .ifu_exu_pc_e            (ifu_exu_pc_e         ),

      .exu_ifu_stall_req       (exu_ifu_stall_req    )

      );




   

   cpu7_exu exu(
      .clk                     (clk                  ),
      .resetn                  (resetn               ),

      .ifu_exu_valid_d         (ifu_exu_valid_d      ),
      .ifu_exu_inst_d          (ifu_exu_inst_d       ),
      .ifu_exu_pc_d            (ifu_exu_pc_d         ),
      .ifu_exu_op_d            (ifu_exu_op_d         ),
      .ifu_exu_exception_d     (ifu_exu_exception_d  ),
      .ifu_exu_exccode_d       (ifu_exu_exccode_d    ),
      .ifu_exu_br_target_d     (ifu_exu_br_target_d  ),
      .ifu_exu_br_taken_d      (ifu_exu_br_taken_d   ),
      .ifu_exu_rf_wen_d        (ifu_exu_rf_wen_d     ),
      .ifu_exu_rf_target_d     (ifu_exu_rf_target_d  ),
      .ifu_exu_hint_d          (ifu_exu_hint_d       ),

      .ifu_exu_imm_shifted_d   (ifu_exu_imm_shifted_d),
      .ifu_exu_c_d             (ifu_exu_c_d          ),
      .ifu_exu_br_offs         (ifu_exu_br_offs      ),
      
      .ifu_exu_pc_w            (ifu_exu_pc_w         ),
      .ifu_exu_pc_e            (ifu_exu_pc_e         ),

      // memory interface
      .data_req                (data_req             ),
      .data_addr               (data_addr            ),
      .data_wr                 (data_wr              ),
      .data_wstrb              (data_wstrb           ),
      .data_wdata              (data_wdata           ),
      .data_prefetch           (data_prefetch        ),
      .data_ll                 (data_ll              ),
      .data_sc                 (data_sc              ),
      .data_addr_ok            (data_addr_ok         ),

      .data_recv               (data_recv            ),
      .data_scsucceed          (data_scsucceed       ),
      .data_rdata_m            (data_rdata_m         ),
      .data_exception          (data_exception       ),
      .data_excode             (data_exccode         ),
      .data_badvaddr           (data_badvaddr        ),
      .data_data_ok_m          (data_data_ok_m       ),

      .data_pc                 (data_pc              ),
      .data_cancel             (data_cancel          ),
      .data_cancel_ex2         (data_cancel_ex2      ),
      .data_req_empty          (data_req_empty       ),
      
      .exu_ifu_stall_req       (exu_ifu_stall_req    ),

      .exu_ifu_brpc_e          (exu_ifu_brpc_e       ),
      .exu_ifu_br_taken_e      (exu_ifu_br_taken_e   ),

      //exception
      .exu_ifu_eentry          (exu_ifu_eentry       ),
      .exu_ifu_except          (exu_ifu_except       ),
      //ertn
      .exu_ifu_era             (exu_ifu_era          ),
      .exu_ifu_ertn_e          (exu_ifu_ertn_e       )
      );

   
   
endmodule // cpu7
