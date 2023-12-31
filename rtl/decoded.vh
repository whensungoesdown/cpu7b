//`include "tlb_defines.vh"

`define LSOC1K_DECODE_RES_BIT  60
`define LSOC1K_GR_WEN          0
`define LSOC1K_RJ_READ         1
`define LSOC1K_RK_READ         2
`define LSOC1K_RD_WRITE        3
`define LSOC1K_MUL_RELATED     4
`define LSOC1K_DIV_RELATED     5
`define LSOC1K_DOUBLE_WORD     6
`define LSOC1K_HIGH_TARGET     7
`define LSOC1K_I5              8
`define LSOC1K_I12             9
`define LSOC1K_I16             10
`define LSOC1K_I20             11
`define LSOC1K_UNSIGN          12
`define LSOC1K_LSU_RELATED     13
`define LSOC1K_BRU_RELATED     14
`define LSOC1K_CSR_RELATED     15
`define LSOC1K_CSR_WRITE       16
`define LSOC1K_CACHE_RELATED   17
`define LSOC1K_TLB_RELATED     18
`define LSOC1K_PC_RELATED      19
`define LSOC1K_RD_READ         20
`define LSOC1K_LSU_ST          21
`define LSOC1K_SA              22
`define LSOC1K_MSBW            23
`define LSOC1K_CPUCFG          24
`define LSOC1K_BREAK           25
`define LSOC1K_SYSCALL         26
`define LSOC1K_ERET            27
`define LSOC1K_OP_CODE         34:28
`define LSOC1K_LUI             35
`define LSOC1K_IMM_SHIFT       38:36
`define LSOC1K_I14             39
`define LSOC1K_CSR_READ        40
`define LSOC1K_CSR_XCHG        41
`define LSOC1K_TRIPLE_READ     42
`define LSOC1K_DOUBLE_READ     43
`define LSOC1K_FLOAT           44
`define LSOC1K_FR_WEN          45
`define LSOC1K_FJ_READ         46
`define LSOC1K_FK_READ         47
`define LSOC1K_FD_READ         48
`define LSOC1K_FF_EXCHANGE     50:49
`define LSOC1K_FPU_STAGE       53:51
`define LSOC1K_DBAR            54
`define LSOC1K_IBAR            55
`define LSOC1K_RD2RJ           56
`define LSOC1K_INE             57
`define LSOC1K_RDTIME          58
`define LSOC1K_WAIT            59

`define LSOC1K_OP_CODE_BIT     7
`define LSOC1K_ALU_CODE        33:28
`define LSOC1K_BRU_CODE        31:28
`define LSOC1K_MDU_CODE        31:28
`define LSOC1K_TLB_CODE        31:28

// ALU encoding
`define LSOC1K_ALU_CODE_BIT    6
`define LSOC1K_ALU_C_BIT       `GRLEN
`define LSOC1K_ALU_LU32I       6'b000000
`define LSOC1K_ALU_ADD         6'b000001
`define LSOC1K_ALU_SUB         6'b000010
`define LSOC1K_ALU_AND         6'b000011
`define LSOC1K_ALU_OR          6'b000100
`define LSOC1K_ALU_XOR         6'b000101
`define LSOC1K_ALU_NOR         6'b000110
`define LSOC1K_ALU_SLT         6'b000111
`define LSOC1K_ALU_SLTU        6'b001000
`define LSOC1K_ALU_SLL         6'b001001
`define LSOC1K_ALU_SRL         6'b001010
`define LSOC1K_ALU_SRA         6'b001011
`define LSOC1K_ALU_ROT         6'b001100
`define LSOC1K_ALU_COUNT_L     6'b001101
`define LSOC1K_ALU_BITSWAP     6'b001110
`define LSOC1K_ALU_EXT         6'b001111
`define LSOC1K_ALU_INS         6'b010000
`define LSOC1K_ALU_SEB         6'b010001
`define LSOC1K_ALU_SEH         6'b010010
`define LSOC1K_ALU_WSBH        6'b010011
`define LSOC1K_ALU_SELNEZ      6'b010100
`define LSOC1K_ALU_SELEQZ      6'b010101
`define LSOC1K_ALU_LSA         6'b010110
`define LSOC1K_ALU_ALIGN       6'b010111
`define LSOC1K_ALU_COUNT_T     6'b011000
`define LSOC1K_ALU_DSHD        6'b011001
`define LSOC1K_ALU_LU52I       6'b011010
`define LSOC1K_ALU_LU12I       6'b011011
`define LSOC1K_ALU_LSAU        6'b011100
`define LSOC1K_ALU_ANDN        6'b011101
`define LSOC1K_ALU_ORN         6'b011110
`define LSOC1K_ALU_BITREV      6'b011111
`define LSOC1K_ALU_REVB        6'b100000
`define LSOC1K_ALU_PCALAU      6'b100001

// IMM SHIFT encoding
`define LSOC1K_IMM_SHIFT_0     3'b000
`define LSOC1K_IMM_SHIFT_2     3'b001
`define LSOC1K_IMM_SHIFT_12    3'b010
`define LSOC1K_IMM_SHIFT_16    3'b011
`define LSOC1K_IMM_SHIFT_18    3'b100
`define LSOC1K_IMM_SHIFT_32    3'b101
`define LSOC1K_IMM_SHIFT_52    3'b110

// BRU encoding
`define LSOC1K_BRU_CODE_BIT    4
`define LSOC1K_BRU_IDLE        4'b0000
`define LSOC1K_BRU_EQ          4'b0001
`define LSOC1K_BRU_NE          4'b0010
`define LSOC1K_BRU_LT          4'b0011
`define LSOC1K_BRU_GE          4'b0100
`define LSOC1K_BRU_JR          4'b0101
`define LSOC1K_BRU_EQZ         4'b0110
`define LSOC1K_BRU_NEZ         4'b0111
`define LSOC1K_BRU_LTU         4'b1000
`define LSOC1K_BRU_GEU         4'b1001
`define LSOC1K_BRU_BL          4'b1010

// LSU encoding
`define LSOC1K_LSU_CODE_BIT    7
`define LSOC1K_LSU_IDLE        7'b0000000
`define LSOC1K_LSU_LD_B        7'b0000001
`define LSOC1K_LSU_LD_H        7'b0000010
`define LSOC1K_LSU_LD_W        7'b0000011
`define LSOC1K_LSU_LD_D        7'b0000100
`define LSOC1K_LSU_ST_B        7'b0000101
`define LSOC1K_LSU_ST_H        7'b0000110
`define LSOC1K_LSU_ST_W        7'b0000111
`define LSOC1K_LSU_ST_D        7'b0001000
`define LSOC1K_LSU_LD_BU       7'b0001001
`define LSOC1K_LSU_LD_HU       7'b0001010
`define LSOC1K_LSU_LD_WU       7'b0001011
`define LSOC1K_LSU_STX_B       7'b0001100
`define LSOC1K_LSU_STX_H       7'b0001101
`define LSOC1K_LSU_STX_W       7'b0001110
`define LSOC1K_LSU_STX_D       7'b0001111
`define LSOC1K_LSU_LDX_B       7'b0010000
`define LSOC1K_LSU_LDX_H       7'b0010001
`define LSOC1K_LSU_LDX_W       7'b0010010
`define LSOC1K_LSU_LDX_D       7'b0010011
`define LSOC1K_LSU_LDX_BU      7'b0010100
`define LSOC1K_LSU_LDX_HU      7'b0010101
`define LSOC1K_LSU_LDX_WU      7'b0010110
`define LSOC1K_LSU_LDGT_B      7'b0010111
`define LSOC1K_LSU_LDGT_H      7'b0011000
`define LSOC1K_LSU_LDGT_W      7'b0011001
`define LSOC1K_LSU_LDGT_D      7'b0011010
`define LSOC1K_LSU_LDLE_B      7'b0011011
`define LSOC1K_LSU_LDLE_H      7'b0011100
`define LSOC1K_LSU_LDLE_W      7'b0011101
`define LSOC1K_LSU_LDLE_D      7'b0011110
`define LSOC1K_LSU_STGT_B      7'b0011111
`define LSOC1K_LSU_STGT_H      7'b0100000
`define LSOC1K_LSU_STGT_W      7'b0100001
`define LSOC1K_LSU_STGT_D      7'b0100010
`define LSOC1K_LSU_STLE_B      7'b0100011
`define LSOC1K_LSU_STLE_H      7'b0100100
`define LSOC1K_LSU_STLE_W      7'b0100101
`define LSOC1K_LSU_STLE_D      7'b0100110
`define LSOC1K_LSU_PRELD       7'b0100111
`define LSOC1K_LSU_PRELDX      7'b0101000
`define LSOC1K_LSU_IOCSRRD_B   7'b0101001
`define LSOC1K_LSU_IOCSRRD_H   7'b0101010
`define LSOC1K_LSU_IOCSRRD_W   7'b0101011
`define LSOC1K_LSU_IOCSRRD_D   7'b0101100
`define LSOC1K_LSU_IOCSRWR_B   7'b0101101
`define LSOC1K_LSU_IOCSRWR_H   7'b0101110
`define LSOC1K_LSU_IOCSRWR_W   7'b0101111
`define LSOC1K_LSU_IOCSRWR_D   7'b0110000
`define LSOC1K_LSU_AMSWAP_W    7'b0110001
`define LSOC1K_LSU_AMSWAP_D    7'b0110010
`define LSOC1K_LSU_AMADD_W     7'b0110011
`define LSOC1K_LSU_AMADD_D     7'b0110100
`define LSOC1K_LSU_AMAND_W     7'b0110101
`define LSOC1K_LSU_AMAND_D     7'b0110110
`define LSOC1K_LSU_AMOR_W      7'b0110111
`define LSOC1K_LSU_AMOR_D      7'b0111000
`define LSOC1K_LSU_AMXOR_W     7'b0111001
`define LSOC1K_LSU_AMXOR_D     7'b0111010
`define LSOC1K_LSU_AMMAX_W     7'b0111011
`define LSOC1K_LSU_AMMAX_D     7'b0111100
`define LSOC1K_LSU_AMMIN_W     7'b0111101
`define LSOC1K_LSU_AMMIN_D     7'b0111110
`define LSOC1K_LSU_AMMAX_WU    7'b0111111
`define LSOC1K_LSU_AMMAX_DU    7'b1000000
`define LSOC1K_LSU_AMMIN_WU    7'b1000001
`define LSOC1K_LSU_AMMIN_DU    7'b1000010
`define LSOC1K_LSU_AMSWAP_DB_W 7'b1000011
`define LSOC1K_LSU_AMSWAP_DB_D 7'b1000100
`define LSOC1K_LSU_AMADD_DB_W  7'b1000101
`define LSOC1K_LSU_AMADD_DB_D  7'b1000110
`define LSOC1K_LSU_AMAND_DB_W  7'b1000111
`define LSOC1K_LSU_AMAND_DB_D  7'b1001000
`define LSOC1K_LSU_AMOR_DB_W   7'b1001001
`define LSOC1K_LSU_AMOR_DB_D   7'b1001010
`define LSOC1K_LSU_AMXOR_DB_W  7'b1001011
`define LSOC1K_LSU_AMXOR_DB_D  7'b1001100
`define LSOC1K_LSU_AMMAX_DB_W  7'b1001101
`define LSOC1K_LSU_AMMAX_DB_D  7'b1001110
`define LSOC1K_LSU_AMMIN_DB_W  7'b1001111
`define LSOC1K_LSU_AMMIN_DB_D  7'b1010000
`define LSOC1K_LSU_AMMAX_DB_WU 7'b1010001
`define LSOC1K_LSU_AMMAX_DB_DU 7'b1010010
`define LSOC1K_LSU_AMMIN_DB_WU 7'b1010011
`define LSOC1K_LSU_AMMIN_DB_DU 7'b1010100
`define LSOC1K_LSU_LL_W        7'b1010101
`define LSOC1K_LSU_SC_W        7'b1010110
`define LSOC1K_LSU_LL_D        7'b1010111
`define LSOC1K_LSU_SC_D        7'b1011000

// MDU encoding
`define LSOC1K_MDU_CODE_BIT    4
`define LSOC1K_MDU_MUL_W       4'b0000
`define LSOC1K_MDU_MULH_W      4'b0001
`define LSOC1K_MDU_MULH_WU     4'b0010
`define LSOC1K_MDU_MUL_D       4'b0011
`define LSOC1K_MDU_MULH_D      4'b0100
`define LSOC1K_MDU_MULH_DU     4'b0101
`define LSOC1K_MDU_MULW_D_W    4'b0110
`define LSOC1K_MDU_MULW_D_WU   4'b0111
`define LSOC1K_MDU_DIV_W       4'b1000
`define LSOC1K_MDU_MOD_W       4'b1001
`define LSOC1K_MDU_DIV_WU      4'b1010
`define LSOC1K_MDU_MOD_WU      4'b1011
`define LSOC1K_MDU_DIV_D       4'b1100
`define LSOC1K_MDU_MOD_D       4'b1101
`define LSOC1K_MDU_DIV_DU      4'b1110
`define LSOC1K_MDU_MOD_DU      4'b1111

// TLBop encoding
`define LSOC1K_TLB_CODE_BIT    4
`define LSOC1K_TLB_TLBFLUSH    `LSOC1K_TLB_CODE_BIT'b0000
`define LSOC1K_TLB_TLBINV      `LSOC1K_TLB_CODE_BIT'b0001
`define LSOC1K_TLB_TLBP        `LSOC1K_TLB_CODE_BIT'b0010
`define LSOC1K_TLB_TLBR        `LSOC1K_TLB_CODE_BIT'b0011
`define LSOC1K_TLB_TLBWI       `LSOC1K_TLB_CODE_BIT'b0100
`define LSOC1K_TLB_TLBWR       `LSOC1K_TLB_CODE_BIT'b0101
`define LSOC1K_TLB_GTLBFLUSH   `LSOC1K_TLB_CODE_BIT'b0110
`define LSOC1K_TLB_GTLBINV     `LSOC1K_TLB_CODE_BIT'b0111
`define LSOC1K_TLB_GTLBP       `LSOC1K_TLB_CODE_BIT'b1000
`define LSOC1K_TLB_GTLBR       `LSOC1K_TLB_CODE_BIT'b1001
`define LSOC1K_TLB_GTLBWI      `LSOC1K_TLB_CODE_BIT'b1010
`define LSOC1K_TLB_GTLBWR      `LSOC1K_TLB_CODE_BIT'b1011
`define LSOC1K_TLB_INVTLB      `LSOC1K_TLB_CODE_BIT'b1100

// CSR encoding
`define LSOC1K_CSR_CODE_BIT    8
`define LSOC1K_CSR_VALID       0
`define LSOC1K_TLB_VALID       1
`define LSOC1K_CACHE_VALID     2
`define LSOC1K_CSR_OP_BIT      5
`define LSOC1K_CSR_OP          7:3
`define LSOC1K_CSR_IDLE        `LSOC1K_CSR_OP_BIT'b00000 
`define LSOC1K_CSR_CSRRD       `LSOC1K_CSR_OP_BIT'b00001 
`define LSOC1K_CSR_CSRWR       `LSOC1K_CSR_OP_BIT'b00010 
`define LSOC1K_CSR_CSRXCHG     `LSOC1K_CSR_OP_BIT'b00011 

// OP FUSION
`define FUSE_INFO_BIT          9
`define FUSE_ORI               0
`define FUSE_LU32I_D           1
`define FUSE_LU52I_D           2
`define FUSE_SLLI_D            3
`define FUSE_SLLI_W            4
`define FUSE_LU12I_W           5
`define FUSE_MUL_W             6
`define FUSE_BSTRPICK_D        7
`define FUSE_ALSL_D            8
