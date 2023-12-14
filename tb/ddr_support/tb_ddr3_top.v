module tb_ddr3_top #(
    parameter MEM_A_WIDTH       =   15              ,
    parameter MEM_DM_WIDTH      =   2               ,
    parameter TOTAL_DQ_WIDTH    =   32              ,
    parameter MEM_DQ_WIDTH      =   16              ,
    parameter MEM_DQS_WIDTH     =   2               ,
    parameter DELAY_PCB         =   0.1             ,
    
    parameter TOTAL_A_WIDTH = MEM_A_WIDTH           ,

    parameter TOTAL_DDR_NUM = TOTAL_DQ_WIDTH / MEM_DQ_WIDTH,

    parameter TOTAL_DM_WIDTH = MEM_DM_WIDTH * TOTAL_DDR_NUM,

    parameter TOTAL_DQS_WIDTH = MEM_DQS_WIDTH * TOTAL_DDR_NUM
    
)(
    input   wire [TOTAL_A_WIDTH-1:0]    mem_a       ,
    input   wire [2:0]                  mem_ba      ,

    inout   wire [TOTAL_DQ_WIDTH-1:0]   mem_dq      ,
    inout   wire [TOTAL_DQS_WIDTH-1:0]  mem_dqs     ,
    inout   wire [TOTAL_DQS_WIDTH-1:0]  mem_dqs_n   ,

    input   wire [TOTAL_DM_WIDTH-1:0]   mem_dm      ,

    input   wire                        mem_ck      ,
    input   wire                        mem_ck_n    ,
    input   wire                        mem_cke     ,
    input   wire                        mem_cs_n    ,
    input   wire                        mem_ras_n   ,
    input   wire                        mem_cas_n   ,
    input   wire                        mem_we_n    ,
    input   wire                        mem_odt     ,

    input   wire                        mem_reset_n 
);




wire [MEM_A_WIDTH-1:0] dly_mem_a;  
wire [2:0]  dly_mem_ba;  

assign #(DELAY_PCB) dly_mem_reset_n =  mem_reset_n;  
assign #(DELAY_PCB) dly_mem_a       =  mem_a;        
assign #(DELAY_PCB) dly_mem_ba      =  mem_ba;       
assign #(DELAY_PCB) dly_mem_ras_n   =  mem_ras_n;    
assign #(DELAY_PCB) dly_mem_cas_n   =  mem_cas_n;    
assign #(DELAY_PCB) dly_mem_we_n    =  mem_we_n;    
assign #(DELAY_PCB) dly_mem_cs_n    =  mem_cs_n;    
assign #(DELAY_PCB) dly_mem_ck      =  mem_ck;       
assign #(DELAY_PCB) dly_mem_ck_n    =  mem_ck_n;     
assign #(DELAY_PCB) dly_mem_cke     =  mem_cke;      
assign #(DELAY_PCB) dly_mem_odt     =  mem_odt; 

genvar gen_i;

generate
    for (gen_i = 0; gen_i < TOTAL_DDR_NUM; gen_i = gen_i + 1)

      ddr3 I_ddr3 (
        .rst_n       (dly_mem_reset_n),
        .ck          (dly_mem_ck),
        .ck_n        (dly_mem_ck_n),
        .cke         (dly_mem_cke),
        .cs_n        (dly_mem_cs_n),
        .ras_n       (dly_mem_ras_n),
        .cas_n       (dly_mem_cas_n),
        .we_n        (dly_mem_we_n),
        .dm_tdqs     (mem_dm[(gen_i + 1) * MEM_DM_WIDTH - 1 : gen_i * MEM_DM_WIDTH]),
        .ba          (dly_mem_ba),
        .addr        (dly_mem_a),
        .dq          (mem_dq[(gen_i + 1) * MEM_DQ_WIDTH - 1 : gen_i * MEM_DQ_WIDTH]),
        .dqs         (mem_dqs[(gen_i + 1) * MEM_DQS_WIDTH - 1 : gen_i * MEM_DQS_WIDTH]),
        .dqs_n       (mem_dqs_n[(gen_i + 1) * MEM_DQS_WIDTH - 1 : gen_i * MEM_DQS_WIDTH]),
        .tdqs_n      (),
        .odt         (dly_mem_odt)
    );
endgenerate

endmodule