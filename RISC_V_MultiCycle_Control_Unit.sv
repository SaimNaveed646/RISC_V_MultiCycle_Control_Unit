`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2026 06:00:37 PM
// Design Name: 
// Module Name: RISC_V_MultiCycle_Control_Unit
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


module RISC_V_MultiCycle_Control_Unit(

    input  logic       clk,
    input  logic       rst,
    input  logic [6:0] Opcode,       // 7-bit RISC-V Opcode

    // Control Signals Output
    output logic       PCWrite,
    output logic       PCWriteCond,
    output logic       IorD,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       IRWrite,
    output logic [1:0] SrcReg,
    output logic [1:0] ALUOp,
    output logic [1:0] ALUSrcB,
    output logic       ALUSrcA,
    output logic       PCSource,
    output logic       RegWrite
);

    // Standard RISC-V 7-bit Opcodes
    localparam R_TYPE = 7'b0110011;                        //localparam is used to define a constant value that cannot be changed after it is defined in the code.
    localparam LW     = 7'b0000011; 
    localparam SW     = 7'b0100011; 
    localparam BEQ    = 7'b1100011; 
    localparam JAL    = 7'b1101111; 

    // FSM States
    typedef enum logic [3:0] {                             //typedef — Creates a new data type.//enum — Defines named values for that data type, such as S0, S1, and S2.
        S0 = 4'd0, 
        S1 = 4'd1, 
        S2 = 4'd2, 
        S3 = 4'd3, 
        S4 = 4'd4, 
        S5 = 4'd5, 
        S6 = 4'd6, 
        S7 = 4'd7, 
        S8 = 4'd8, 
        S9 = 4'd9  
    } state_t;

    state_t current_state, next_state;                    //state_t current_state, next_state; - Declares two variables of that data type.

    // State Register
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Next State Logic
    always_comb begin
        case (current_state)
            S0: next_state = S1;

            S1: begin
                case (Opcode)
                    R_TYPE:  next_state = S2;
                    LW, SW:  next_state = S4;
                    BEQ:     next_state = S8;
                    JAL:     next_state = S9;
                    default: next_state = S0;
                endcase
            end

            S2: next_state = S3;
            S3: next_state = S0;

            S4: begin
                if (Opcode == LW)
                    next_state = S5;
                else if (Opcode == SW)
                    next_state = S7;
                else
                    next_state = S0;
            end

            S5: next_state = S6;
            S6: next_state = S0;
            S7: next_state = S0;
            S8: next_state = S0;
            S9: next_state = S0;

            default: next_state = S0;
        endcase
    end

    // Output Signals Logic
    always_comb begin
        // Defaults
        PCWrite     = 1'b0;
        PCWriteCond = 1'b0;
        IorD        = 1'b0;
        MemRead     = 1'b0;
        MemWrite    = 1'b0;
        IRWrite     = 1'b0;
        SrcReg      = 2'b00;
        ALUOp       = 2'b00;
        ALUSrcB     = 2'b00;
        ALUSrcA     = 1'b0;
        PCSource    = 1'b0;
        RegWrite    = 1'b0;

        case (current_state)
            S0: begin // Fetch
                IorD     = 1'b0;
                MemRead  = 1'b1;
                IRWrite  = 1'b1;
                ALUSrcA  = 1'b0;
                ALUSrcB  = 2'b01;
                ALUOp    = 2'b00;
                PCSource = 1'b0;
                PCWrite  = 1'b0;
            end

            S1: begin // Decode
                PCSource = 1'b1;
                PCWrite  = 1'b1;
                ALUSrcA  = 1'b0;
                ALUSrcB  = 2'b11;
                ALUOp    = 2'b00;
            end

            S2: begin // R-Type Execution
                ALUSrcA  = 1'b1;
                ALUSrcB  = 2'b00;
                ALUOp    = 2'b10;
            end

            S3: begin // R-Type Writeback
                SrcReg   = 2'b00;
                RegWrite = 1'b1;
            end

            S4: begin // Address Computation (LW/SW)
                ALUSrcA  = 1'b1;
                ALUSrcB  = 2'b10;
                ALUOp    = 2'b00;
            end

            S5: begin // LW Read
                IorD    = 1'b1;
                MemRead = 1'b1;
            end

            S6: begin // LW Writeback
                SrcReg   = 2'b01;
                RegWrite = 1'b1;
            end

            S7: begin // SW Write
                IorD     = 1'b1;
                MemWrite = 1'b1;
            end

            S8: begin // Branch
                ALUSrcA     = 1'b1;
                ALUSrcB     = 2'b00;
                ALUOp       = 2'b01;
                PCSource    = 1'b1;
                PCWriteCond = 1'b1;
            end

            S9: begin // JAL
                PCSource = 1'b1;
                PCWrite  = 1'b1;
                SrcReg   = 2'b11;
                RegWrite = 1'b1;
            end

            default: ;
        endcase
    end
    
endmodule
