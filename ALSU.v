module ALSU(A,B,opc,cin,sin,dir,ropA,ropB,bpA,bpB,clk,rst,out,leds);
/* sin >>>serial in
din >>>> direction in
ropA , ropB >>>> read_op_A , read_op_B
bpA , bpB >>>>> bypass_A , bypass_B
*/

//parameters
parameter INPUT_PRIORITY = "A";
parameter FULL_ADDER = "ON";

//decleration of inputs and outputs
input [2:0] A, B ;
input [2:0] opc;
input cin,sin,dir,ropA,ropB,bpA,bpB,clk,rst;
output  [15:0] leds;
output  [5:0] out;

//decleration of wires for dff
reg [2:0] A_tmp , B_tmp , opcode_tmp;
reg cin_tmp , sin_tmp , dir_tmp, ropA_tmp , ropB_tmp , bpA_tmp , bpB_tmp ;
reg [15:0]  leds_tmp;
reg [5:0] out_tmp ;

always @(posedge clk or posedge rst) begin
    if (rst)begin
        A_tmp <= 0; 
        B_tmp <= 0; 
        opcode_tmp <= 0;
        cin_tmp <= 0;
        sin_tmp <= 0;
        dir_tmp <= 0;
        ropA_tmp <= 0;
        ropB_tmp <= 0;
        bpA_tmp <= 0;
        bpB_tmp <= 0;
        out_tmp <= 6'b0;
        leds_tmp <= 16'b0;
    end 
    else begin
        A_tmp <= A; 
        B_tmp <= B; 
        opcode_tmp <= opc;
        cin_tmp <= cin;
        sin_tmp <= sin;
        dir_tmp <= dir;
        ropA_tmp <= ropA;
        ropB_tmp <= ropB;
        bpA_tmp <= bpA;
        bpB_tmp <= bpB;
        //check the reset status
        if (rst)begin
            out_tmp <= 16'b0;
        end

    //check bypass status
        else  if (bpA_tmp && !bpB_tmp) out_tmp <= A_tmp;

        else if (bpB_tmp && !bpA_tmp) out_tmp <= B_tmp;

        else if (bpA_tmp && bpB_tmp) begin
            if (INPUT_PRIORITY == "A") out_tmp <= A_tmp;
            else if (INPUT_PRIORITY == "B") out_tmp <= B_tmp;
        end

    //check opcode status
        else begin
            case (opcode_tmp)

                3'b000: if (ropA_tmp) out_tmp <= &A_tmp;
                else if (ropB_tmp) out_tmp <= &B_tmp;
                else out_tmp <= A_tmp & B_tmp ;

                3'b001: if (ropA_tmp) out_tmp <= ^A_tmp;
                else if (ropB_tmp) out_tmp <= ^B_tmp;
                else out_tmp <= A_tmp ^ B_tmp ;

                3'b010: if (FULL_ADDER == "ON") out_tmp <= A_tmp + B_tmp + cin_tmp;
                else out_tmp <= A_tmp + B_tmp ;

                3'b011: out_tmp <= A_tmp * B_tmp ;


                3'b100: if (dir_tmp) out_tmp <= {out_tmp[4:0],sin_tmp};
                else out_tmp <= {sin_tmp,out_tmp[5:1]};

                3'b101:if (dir_tmp) out_tmp <= {out_tmp[4:0],out_tmp[5]};
                else out_tmp <= {out_tmp[0],out_tmp[5:1]};

                3'b110 | 3'b111:if (bpA_tmp && !bpB_tmp) out_tmp <= A_tmp;
                else if (bpB_tmp && !bpA_tmp) out_tmp <= B_tmp; 
                else if (bpA_tmp && bpB_tmp) begin
                    if (INPUT_PRIORITY == "A") out_tmp <= A_tmp;
                    else if (INPUT_PRIORITY == "B") out_tmp <= B_tmp;
                end
                else begin
                    out_tmp <= 6'b0;
                    if (opcode_tmp == 3'b110 | opcode_tmp== 3'b111 ) leds_tmp <= ~leds_tmp;
                    else leds_tmp <= 16'b0;
                end
                default: out_tmp <= 6'b0 ;
            endcase
        end    
    end    
end

//outputs
assign out = out_tmp;
assign leds = leds_tmp;

// always @(*) begin

//     out_tmp <= 6'b0;
//     leds_tmp <= 16'b0;

// //check the reset status
//     if (rst)begin
//         out_tmp <= 16'b0;
//     end

// //check bypass status
//     else  if (bpA_tmp && !bpB_tmp) out_tmp <= A_tmp;

//     else if (bpB_tmp && !bpA_tmp) out_tmp <= B_tmp;

//     else if (bpA_tmp && bpB_tmp) begin
//         if (INPUT_PRIORITY == "A") out_tmp <= A_tmp;
//         else if (INPUT_PRIORITY == "B") out_tmp <= B_tmp;
//     end

// //check opcode status
//     else begin
//         case (opcode_tmp)

//             3'b000: if (ropA_tmp) out_tmp <= &A_tmp;
//             else if (ropB_tmp) out_tmp <= &B_tmp;
//             else out_tmp <= A_tmp & B_tmp ;

//             3'b001: if (ropA_tmp) out_tmp <= ^A_tmp;
//             else if (ropB_tmp) out_tmp <= ^B_tmp;
//             else out_tmp <= A_tmp ^ B_tmp ;

//             3'b010: if (FULL_ADDER == "ON") out_tmp <= A_tmp + B_tmp + cin_tmp;
//             else out_tmp <= A_tmp + B_tmp ;

//             3'b011: out_tmp <= A_tmp * B_tmp ;


//             3'b100: if (dir_tmp) out_tmp <= {out_tmp[4:0],sin_tmp};
//             else out_tmp <= {sin_tmp,out_tmp[5:1]};

//             3'b101:if (dir_tmp) out_tmp <= {out_tmp[4:0],out_tmp[5]};
//             else out_tmp <= {out_tmp[0],out_tmp[5:1]};

//             3'b110 | 3'b111:if (bpA_tmp && !bpB_tmp) out_tmp <= A_tmp;
//             else if (bpB_tmp && !bpA_tmp) out_tmp <= B_tmp; 
//             else if (bpA_tmp && bpB_tmp) begin
//                 if (INPUT_PRIORITY == "A") out_tmp <= A_tmp;
//                 else if (INPUT_PRIORITY == "B") out_tmp <= B_tmp;
//             end
//             else begin
//                  out_tmp <= 6'b0;
//                 leds_tmp <= ~leds_tmp;
//             end
//             default: out_tmp <= 6'b0 ;
//         endcase
//     end    
// end

//outputs
// assign out = out_tmp;
// assign leds = leds_tmp;

endmodule