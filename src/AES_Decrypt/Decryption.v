module Decryption#(parameter Nr=10,parameter Nk=4)(clk,plain_text,key,cipher_text);
  input clk;
  input wire[127:0] plain_text;
  input wire [32*Nk-1:0] key;
  output [127:0] cipher_text;
  wire [128*Nr-1:0] fullkeys;
  wire [127:0] Instates;
  reg [127:0] InstatesReg = 0;
  assign Instates = InstatesReg;

  wire [127:0] Outstates;

  wire [127:0] subBytesFinalStateWire;
  reg [127:0] subBytesFinalStateReg;
  assign subBytesFinalStateWire = subBytesFinalStateReg;
  wire [127:0] afterSubBFinal;
  wire [127:0] afterShiftRowsFinal;
  integer roundNum=0;
  keySchedule #(Nr,Nk) ke (key,fullkeys);


  //intermediate steps
  Decryption_Round rndx(Instates,fullkeys[(roundNum)*128+:128],Outstates);

  //final rounds' steps
  InvSubBytes s_final(subBytesFinalStateWire, afterSubBFinal);
  InverseShiftRows sr_final(afterSubBFinal, afterShiftRowsFinal);
  assign cipher_text = addRoundKey(afterShiftRowsFinal, key);


  always@(posedge clk)
  begin
    if(roundNum ==0)
    begin
      InstatesReg=plain_text^fullkeys[0+:128];
      roundNum=roundNum+1;
    end
    else if(roundNum <Nr-1)
    begin
      InstatesReg=Outstates;
      roundNum=roundNum+1;
    end
    else if(roundNum==Nr-1)
    begin
      subBytesFinalStateReg=Outstates;
    end
  end

  function [127:0]addRoundKey;
    input [127:0] crtState;
    input [127:0] crtRoundKey;
    begin
      addRoundKey = crtState^crtRoundKey;
    end
  endfunction
endmodule


module keySchedule#(parameter Nr = 12, Nk =6 ) ( input wire[32*Nk-1:0] inputKey, output wire[0:128*(Nr)-1] roundKeysWire);
  function [7:0] sbox;
    input [7:0] givenData;
    begin
      case(givenData)
        8'h00:
          sbox = 8'h63;
        8'h01:
          sbox = 8'h7c;
        8'h02:
          sbox = 8'h77;
        8'h03:
          sbox = 8'h7b;
        8'h04:
          sbox = 8'hf2;
        8'h05:
          sbox = 8'h6b;
        8'h06:
          sbox = 8'h6f;
        8'h07:
          sbox = 8'hc5;
        8'h08:
          sbox = 8'h30;
        8'h09:
          sbox = 8'h01;
        8'h0a:
          sbox = 8'h67;
        8'h0b:
          sbox = 8'h2b;
        8'h0c:
          sbox = 8'hfe;
        8'h0d:
          sbox = 8'hd7;
        8'h0e:
          sbox = 8'hab;
        8'h0f:
          sbox = 8'h76;
        8'h10:
          sbox = 8'hca;
        8'h11:
          sbox = 8'h82;
        8'h12:
          sbox = 8'hc9;
        8'h13:
          sbox = 8'h7d;
        8'h14:
          sbox = 8'hfa;
        8'h15:
          sbox = 8'h59;
        8'h16:
          sbox = 8'h47;
        8'h17:
          sbox = 8'hf0;
        8'h18:
          sbox = 8'had;
        8'h19:
          sbox = 8'hd4;
        8'h1a:
          sbox = 8'ha2;
        8'h1b:
          sbox = 8'haf;
        8'h1c:
          sbox = 8'h9c;
        8'h1d:
          sbox = 8'ha4;
        8'h1e:
          sbox = 8'h72;
        8'h1f:
          sbox = 8'hc0;
        8'h20:
          sbox = 8'hb7;
        8'h21:
          sbox = 8'hfd;
        8'h22:
          sbox = 8'h93;
        8'h23:
          sbox = 8'h26;
        8'h24:
          sbox = 8'h36;
        8'h25:
          sbox = 8'h3f;
        8'h26:
          sbox = 8'hf7;
        8'h27:
          sbox = 8'hcc;
        8'h28:
          sbox = 8'h34;
        8'h29:
          sbox = 8'ha5;
        8'h2a:
          sbox = 8'he5;
        8'h2b:
          sbox = 8'hf1;
        8'h2c:
          sbox = 8'h71;
        8'h2d:
          sbox = 8'hd8;
        8'h2e:
          sbox = 8'h31;
        8'h2f:
          sbox = 8'h15;
        8'h30:
          sbox = 8'h04;
        8'h31:
          sbox = 8'hc7;
        8'h32:
          sbox = 8'h23;
        8'h33:
          sbox = 8'hc3;
        8'h34:
          sbox = 8'h18;
        8'h35:
          sbox = 8'h96;
        8'h36:
          sbox = 8'h05;
        8'h37:
          sbox = 8'h9a;
        8'h38:
          sbox = 8'h07;
        8'h39:
          sbox = 8'h12;
        8'h3a:
          sbox = 8'h80;
        8'h3b:
          sbox = 8'he2;
        8'h3c:
          sbox = 8'heb;
        8'h3d:
          sbox = 8'h27;
        8'h3e:
          sbox = 8'hb2;
        8'h3f:
          sbox = 8'h75;
        8'h40:
          sbox = 8'h09;
        8'h41:
          sbox = 8'h83;
        8'h42:
          sbox = 8'h2c;
        8'h43:
          sbox = 8'h1a;
        8'h44:
          sbox = 8'h1b;
        8'h45:
          sbox = 8'h6e;
        8'h46:
          sbox = 8'h5a;
        8'h47:
          sbox = 8'ha0;
        8'h48:
          sbox = 8'h52;
        8'h49:
          sbox = 8'h3b;
        8'h4a:
          sbox = 8'hd6;
        8'h4b:
          sbox = 8'hb3;
        8'h4c:
          sbox = 8'h29;
        8'h4d:
          sbox = 8'he3;
        8'h4e:
          sbox = 8'h2f;
        8'h4f:
          sbox = 8'h84;
        8'h50:
          sbox = 8'h53;
        8'h51:
          sbox = 8'hd1;
        8'h52:
          sbox = 8'h00;
        8'h53:
          sbox = 8'hed;
        8'h54:
          sbox = 8'h20;
        8'h55:
          sbox = 8'hfc;
        8'h56:
          sbox = 8'hb1;
        8'h57:
          sbox = 8'h5b;
        8'h58:
          sbox = 8'h6a;
        8'h59:
          sbox = 8'hcb;
        8'h5a:
          sbox = 8'hbe;
        8'h5b:
          sbox = 8'h39;
        8'h5c:
          sbox = 8'h4a;
        8'h5d:
          sbox = 8'h4c;
        8'h5e:
          sbox = 8'h58;
        8'h5f:
          sbox = 8'hcf;
        8'h60:
          sbox = 8'hd0;
        8'h61:
          sbox = 8'hef;
        8'h62:
          sbox = 8'haa;
        8'h63:
          sbox = 8'hfb;
        8'h64:
          sbox = 8'h43;
        8'h65:
          sbox = 8'h4d;
        8'h66:
          sbox = 8'h33;
        8'h67:
          sbox = 8'h85;
        8'h68:
          sbox = 8'h45;
        8'h69:
          sbox = 8'hf9;
        8'h6a:
          sbox = 8'h02;
        8'h6b:
          sbox = 8'h7f;
        8'h6c:
          sbox = 8'h50;
        8'h6d:
          sbox = 8'h3c;
        8'h6e:
          sbox = 8'h9f;
        8'h6f:
          sbox = 8'ha8;
        8'h70:
          sbox = 8'h51;
        8'h71:
          sbox = 8'ha3;
        8'h72:
          sbox = 8'h40;
        8'h73:
          sbox = 8'h8f;
        8'h74:
          sbox = 8'h92;
        8'h75:
          sbox = 8'h9d;
        8'h76:
          sbox = 8'h38;
        8'h77:
          sbox = 8'hf5;
        8'h78:
          sbox = 8'hbc;
        8'h79:
          sbox = 8'hb6;
        8'h7a:
          sbox = 8'hda;
        8'h7b:
          sbox = 8'h21;
        8'h7c:
          sbox = 8'h10;
        8'h7d:
          sbox = 8'hff;
        8'h7e:
          sbox = 8'hf3;
        8'h7f:
          sbox = 8'hd2;
        8'h80:
          sbox = 8'hcd;
        8'h81:
          sbox = 8'h0c;
        8'h82:
          sbox = 8'h13;
        8'h83:
          sbox = 8'hec;
        8'h84:
          sbox = 8'h5f;
        8'h85:
          sbox = 8'h97;
        8'h86:
          sbox = 8'h44;
        8'h87:
          sbox = 8'h17;
        8'h88:
          sbox = 8'hc4;
        8'h89:
          sbox = 8'ha7;
        8'h8a:
          sbox = 8'h7e;
        8'h8b:
          sbox = 8'h3d;
        8'h8c:
          sbox = 8'h64;
        8'h8d:
          sbox = 8'h5d;
        8'h8e:
          sbox = 8'h19;
        8'h8f:
          sbox = 8'h73;
        8'h90:
          sbox = 8'h60;
        8'h91:
          sbox = 8'h81;
        8'h92:
          sbox = 8'h4f;
        8'h93:
          sbox = 8'hdc;
        8'h94:
          sbox = 8'h22;
        8'h95:
          sbox = 8'h2a;
        8'h96:
          sbox = 8'h90;
        8'h97:
          sbox = 8'h88;
        8'h98:
          sbox = 8'h46;
        8'h99:
          sbox = 8'hee;
        8'h9a:
          sbox = 8'hb8;
        8'h9b:
          sbox = 8'h14;
        8'h9c:
          sbox = 8'hde;
        8'h9d:
          sbox = 8'h5e;
        8'h9e:
          sbox = 8'h0b;
        8'h9f:
          sbox = 8'hdb;
        8'ha0:
          sbox = 8'he0;
        8'ha1:
          sbox = 8'h32;
        8'ha2:
          sbox = 8'h3a;
        8'ha3:
          sbox = 8'h0a;
        8'ha4:
          sbox = 8'h49;
        8'ha5:
          sbox = 8'h06;
        8'ha6:
          sbox = 8'h24;
        8'ha7:
          sbox = 8'h5c;
        8'ha8:
          sbox = 8'hc2;
        8'ha9:
          sbox = 8'hd3;
        8'haa:
          sbox = 8'hac;
        8'hab:
          sbox = 8'h62;
        8'hac:
          sbox = 8'h91;
        8'had:
          sbox = 8'h95;
        8'hae:
          sbox = 8'he4;
        8'haf:
          sbox = 8'h79;
        8'hb0:
          sbox = 8'he7;
        8'hb1:
          sbox = 8'hc8;
        8'hb2:
          sbox = 8'h37;
        8'hb3:
          sbox = 8'h6d;
        8'hb4:
          sbox = 8'h8d;
        8'hb5:
          sbox = 8'hd5;
        8'hb6:
          sbox = 8'h4e;
        8'hb7:
          sbox = 8'ha9;
        8'hb8:
          sbox = 8'h6c;
        8'hb9:
          sbox = 8'h56;
        8'hba:
          sbox = 8'hf4;
        8'hbb:
          sbox = 8'hea;
        8'hbc:
          sbox = 8'h65;
        8'hbd:
          sbox = 8'h7a;
        8'hbe:
          sbox = 8'hae;
        8'hbf:
          sbox = 8'h08;
        8'hc0:
          sbox = 8'hba;
        8'hc1:
          sbox = 8'h78;
        8'hc2:
          sbox = 8'h25;
        8'hc3:
          sbox = 8'h2e;
        8'hc4:
          sbox = 8'h1c;
        8'hc5:
          sbox = 8'ha6;
        8'hc6:
          sbox = 8'hb4;
        8'hc7:
          sbox = 8'hc6;
        8'hc8:
          sbox = 8'he8;
        8'hc9:
          sbox = 8'hdd;
        8'hca:
          sbox = 8'h74;
        8'hcb:
          sbox = 8'h1f;
        8'hcc:
          sbox = 8'h4b;
        8'hcd:
          sbox = 8'hbd;
        8'hce:
          sbox = 8'h8b;
        8'hcf:
          sbox = 8'h8a;
        8'hd0:
          sbox = 8'h70;
        8'hd1:
          sbox = 8'h3e;
        8'hd2:
          sbox = 8'hb5;
        8'hd3:
          sbox = 8'h66;
        8'hd4:
          sbox = 8'h48;
        8'hd5:
          sbox = 8'h03;
        8'hd6:
          sbox = 8'hf6;
        8'hd7:
          sbox = 8'h0e;
        8'hd8:
          sbox = 8'h61;
        8'hd9:
          sbox = 8'h35;
        8'hda:
          sbox = 8'h57;
        8'hdb:
          sbox = 8'hb9;
        8'hdc:
          sbox = 8'h86;
        8'hdd:
          sbox = 8'hc1;
        8'hde:
          sbox = 8'h1d;
        8'hdf:
          sbox = 8'h9e;
        8'he0:
          sbox = 8'he1;
        8'he1:
          sbox = 8'hf8;
        8'he2:
          sbox = 8'h98;
        8'he3:
          sbox = 8'h11;
        8'he4:
          sbox = 8'h69;
        8'he5:
          sbox = 8'hd9;
        8'he6:
          sbox = 8'h8e;
        8'he7:
          sbox = 8'h94;
        8'he8:
          sbox = 8'h9b;
        8'he9:
          sbox = 8'h1e;
        8'hea:
          sbox = 8'h87;
        8'heb:
          sbox = 8'he9;
        8'hec:
          sbox = 8'hce;
        8'hed:
          sbox = 8'h55;
        8'hee:
          sbox = 8'h28;
        8'hef:
          sbox = 8'hdf;
        8'hf0:
          sbox = 8'h8c;
        8'hf1:
          sbox = 8'ha1;
        8'hf2:
          sbox = 8'h89;
        8'hf3:
          sbox = 8'h0d;
        8'hf4:
          sbox = 8'hbf;
        8'hf5:
          sbox = 8'he6;
        8'hf6:
          sbox = 8'h42;
        8'hf7:
          sbox = 8'h68;
        8'hf8:
          sbox = 8'h41;
        8'hf9:
          sbox = 8'h99;
        8'hfa:
          sbox = 8'h2d;
        8'hfb:
          sbox = 8'h0f;
        8'hfc:
          sbox = 8'hb0;
        8'hfd:
          sbox = 8'h54;
        8'hfe:
          sbox = 8'hbb;
        8'hff:
          sbox = 8'h16;
      endcase
    end
  endfunction
  function [31:0]subWord;
    input[31:0] incData;
    begin
      subWord[31:24] = sbox(incData[31:24]);
      subWord[23:16] = sbox(incData[23:16]);
      subWord[15:8] = sbox(incData[15:8]);
      subWord[7:0] = sbox(incData[7:0]);
    end
  endfunction
  function [31:0]rcon;
    input [31:0] crtRoundNumber;
    begin
      if(crtRoundNumber==0)
        rcon= 32'h00_00_00_00;
      if(crtRoundNumber>=Nk && crtRoundNumber<2*Nk)
        rcon= 32'h01_00_00_00;
      if(crtRoundNumber>=2*Nk&& crtRoundNumber<3*Nk)
        rcon= 32'h02_00_00_00;
      if(crtRoundNumber>=3*Nk&& crtRoundNumber<4*Nk)
        rcon= 32'h04_00_00_00;
      if(crtRoundNumber>=4*Nk&& crtRoundNumber<5*Nk)
        rcon= 32'h08_00_00_00;
      if(crtRoundNumber>=5*Nk&& crtRoundNumber<6*Nk)
        rcon= 32'h10_00_00_00;
      if(crtRoundNumber>=6*Nk&& crtRoundNumber<7*Nk)
        rcon= 32'h20_00_00_00;
      if(crtRoundNumber>=7*Nk&& crtRoundNumber<8*Nk)
        rcon= 32'h40_00_00_00;
      if(crtRoundNumber>=8*Nk&& crtRoundNumber<9*Nk)
        rcon= 32'h80_00_00_00;
      if(crtRoundNumber>=9*Nk&& crtRoundNumber<10*Nk)
        rcon= 32'h1B_00_00_00;
      if(crtRoundNumber>=10*Nk&& crtRoundNumber<11*Nk)
        rcon= 32'h36_00_00_00;
    end
  endfunction

  reg [31:0]temp1; //w at i-1

  reg [31:0]temp2;

  reg [31:0]temp4;
  wire [31:0]temp4Wire;
  reg [0:128*(Nr+1)-1]roundKeys=0;
  assign roundKeysWire = roundKeys[128:128*(Nr+1)-1];

  integer idxOfWord=Nk;  // Use integer or reg for loop variable

  always @*
  begin
    roundKeys[0:Nk*32-1] = inputKey;
    for (idxOfWord = Nk; idxOfWord < 4 * (Nr + 1); idxOfWord = idxOfWord + 1)
    begin
      temp1 = roundKeys[(idxOfWord-1) * 32 +: 32];

      if (idxOfWord % Nk == 0)
      begin
        temp2 = subWord(temp1);
        temp2 = {temp2[23:0], temp2[31:24]};
        temp4 = temp2 ^ rcon(idxOfWord);
        roundKeys[idxOfWord*32+: 32] = roundKeys[(idxOfWord-Nk) * 32 +: 32] ^ temp4;
      end
      else if (Nk > 6 && idxOfWord%Nk==4)
      begin
        temp4 = subWord(temp1);
        roundKeys[idxOfWord*32+: 32] = roundKeys[(idxOfWord-Nk) * 32 +: 32] ^ temp4;

      end
      else
        roundKeys[idxOfWord*32+: 32] = roundKeys[(idxOfWord-Nk) * 32 +: 32] ^ temp1;
    end
  end

endmodule


module OrgMixColumns(A,B);

  input [127:0] A;
  output [127:0] B;

  // Split the 128-bit input into four 32-bit segments
  wire [31:0] input_wires[3:0];
  assign input_wires[0] = A[127:96];
  assign input_wires[1] = A[95:64];
  assign input_wires[2] = A[63:32];
  assign input_wires[3] = A[31:0];

  // Outputs for each MixColumns instance
  wire [31:0] output_wires[3:0];

  // Instantiate the MixColumns module four times
  InvMixColumns mix0(input_wires[0][31:24], input_wires[0][23:16], input_wires[0][15:8], input_wires[0][7:0],
                     output_wires[3][31:24], output_wires[3][23:16], output_wires[3][15:8], output_wires[3][7:0]);

  InvMixColumns mix1(input_wires[1][31:24], input_wires[1][23:16], input_wires[1][15:8], input_wires[1][7:0],
                     output_wires[2][31:24], output_wires[2][23:16], output_wires[2][15:8], output_wires[2][7:0]);

  InvMixColumns mix2(input_wires[2][31:24], input_wires[2][23:16], input_wires[2][15:8], input_wires[2][7:0],
                     output_wires[1][31:24], output_wires[1][23:16], output_wires[1][15:8], output_wires[1][7:0]);

  InvMixColumns mix3(input_wires[3][31:24], input_wires[3][23:16], input_wires[3][15:8], input_wires[3][7:0],
                     output_wires[0][31:24], output_wires[0][23:16], output_wires[0][15:8], output_wires[0][7:0]);

  // Combine the 32-bit segments into the 128-bit output
  assign B[127:96] = output_wires[3];
  assign B[95:64] = output_wires[2];
  assign B[63:32] = output_wires[1];
  assign B[31:0] = output_wires[0];

endmodule


module InvMixColumns (A0,A1,A2,A3,B0,B1,B2,B3);

  input [7:0]A0;
  input [7:0]A1;
  input [7:0]A2;
  input [7:0]A3;

  output [7:0]B0;
  output [7:0]B1;
  output [7:0]B2;
  output [7:0]B3;

  function [7:0] xtime(input [7:0] A,input integer n);
    integer i;
    begin
      for(i = 0;i < n;i = i + 1)
      begin
        A = (A << 1) ^ (((A >> 7) & 1) * 8'h1b);
      end
      xtime = A;
    end
  endfunction

  function [7:0] xtime0e(input [7:0] A);
    begin
      xtime0e = xtime(A,3) ^ xtime(A,2) ^ xtime(A,1);
    end
  endfunction
  function [7:0] xtime0b(input [7:0] A);
    begin
      xtime0b = xtime(A,3) ^ xtime(A,1) ^ A;
    end
  endfunction
  function [7:0] xtime0d(input [7:0] A);
    begin
      xtime0d = xtime(A,3) ^ xtime(A,2) ^ A;
    end
  endfunction
  function [7:0] xtime09(input [7:0] A);
    begin
      xtime09 = xtime(A,3) ^ A;
    end
  endfunction


  assign B0 = xtime0e(A0) ^ xtime0b(A1) ^ xtime0d(A2) ^ xtime09(A3);
  assign B1 = xtime09(A0) ^ xtime0e(A1) ^ xtime0b(A2) ^ xtime0d(A3);
  assign B2 = xtime0d(A0) ^ xtime09(A1) ^ xtime0e(A2) ^ xtime0b(A3);
  assign B3 = xtime0b(A0) ^ xtime0d(A1) ^ xtime09(A2) ^ xtime0e(A3);


endmodule

module InverseShiftRows (shiftedState, originalState);
  input [0:127] shiftedState;
  output [0:127] originalState;

  // First row (r = 0) is not shifted
  assign originalState[0+:8] = shiftedState[0+:8];
  assign originalState[32+:8] = shiftedState[32+:8];
  assign originalState[64+:8] = shiftedState[64+:8];
  assign originalState[96+:8] = shiftedState[96+:8];

  // Second row (r = 1) is cyclically right shifted by 1 offset
  assign originalState[8+:8] = shiftedState[104+:8];
  assign originalState[40+:8] = shiftedState[8+:8];
  assign originalState[72+:8] = shiftedState[40+:8];
  assign originalState[104+:8] = shiftedState[72+:8];

  // Third row (r = 2) is cyclically right shifted by 2 offsets
  assign originalState[16+:8] = shiftedState[80+:8];
  assign originalState[48+:8] = shiftedState[112+:8];
  assign originalState[80+:8] = shiftedState[16+:8];
  assign originalState[112+:8] = shiftedState[48+:8];

  // Fourth row (r = 3) is cyclically right shifted by 3 offsets
  assign originalState[24+:8] = shiftedState[56+:8];
  assign originalState[56+:8] = shiftedState[88+:8];
  assign originalState[88+:8] = shiftedState[120+:8];
  assign originalState[120+:8] = shiftedState[24+:8];

endmodule

module InvSubBytes(input [127:0] state , output [127:0] newState);

  inverse_sbox b0(state[7:0] , newState[7:0]);
  inverse_sbox b1(state[15:8] , newState[15:8]);
  inverse_sbox b2(state[23:16] , newState[23:16]);
  inverse_sbox b3(state[31:24] , newState[31:24]);
  inverse_sbox b4(state[39:32] , newState[39:32]);
  inverse_sbox b5(state[47:40] , newState[47:40]);
  inverse_sbox b6(state[55:48] , newState[55:48]);
  inverse_sbox b7(state[63:56] , newState[63:56]);
  inverse_sbox b8(state[71:64] , newState[71:64]);
  inverse_sbox b9(state[79:72] , newState[79:72]);
  inverse_sbox b10(state[87:80] , newState[87:80]);
  inverse_sbox b11(state[95:88] , newState[95:88]);
  inverse_sbox b12(state[103:96] , newState[103:96]);
  inverse_sbox b13(state[111:104] , newState[111:104]);
  inverse_sbox b14(state[119:112] , newState[119:112]);
  inverse_sbox b15(state[127:120] , newState[127:120]);
endmodule


module inverse_sbox( input wire [7:0] givenData, output wire [7:0] sboxRes);

  assign sboxRes = (givenData == 8'h63) ? 8'h00 :
         (givenData == 8'h7c) ? 8'h01 :
         (givenData == 8'h77) ? 8'h02 :
         (givenData == 8'h7b) ? 8'h03 :
         (givenData == 8'hf2) ? 8'h04 :
         (givenData == 8'h6b) ? 8'h05 :
         (givenData == 8'h6f) ? 8'h06 :
         (givenData == 8'hc5) ? 8'h07 :
         (givenData == 8'h30) ? 8'h08 :
         (givenData == 8'h01) ? 8'h09 :
         (givenData == 8'h67) ? 8'h0a :
         (givenData == 8'h2b) ? 8'h0b :
         (givenData == 8'hfe) ? 8'h0c :
         (givenData == 8'hd7) ? 8'h0d :
         (givenData == 8'hab) ? 8'h0e :
         (givenData == 8'h76) ? 8'h0f :
         (givenData == 8'hca) ? 8'h10 :
         (givenData == 8'h82) ? 8'h11 :
         (givenData == 8'hc9) ? 8'h12 :
         (givenData == 8'h7d) ? 8'h13 :
         (givenData == 8'hfa) ? 8'h14 :
         (givenData == 8'h59) ? 8'h15 :
         (givenData == 8'h47) ? 8'h16 :
         (givenData == 8'hf0) ? 8'h17 :
         (givenData == 8'had) ? 8'h18 :
         (givenData == 8'hd4) ? 8'h19 :
         (givenData == 8'ha2) ? 8'h1a :
         (givenData == 8'haf) ? 8'h1b :
         (givenData == 8'h9c) ? 8'h1c :
         (givenData == 8'ha4) ? 8'h1d :
         (givenData == 8'h72) ? 8'h1e :
         (givenData == 8'hc0) ? 8'h1f :
         (givenData == 8'hb7) ? 8'h20 :
         (givenData == 8'hfd) ? 8'h21 :
         (givenData == 8'h93) ? 8'h22 :
         (givenData == 8'h26) ? 8'h23 :
         (givenData == 8'h36) ? 8'h24 :
         (givenData == 8'h3f) ? 8'h25 :
         (givenData == 8'hf7) ? 8'h26 :
         (givenData == 8'hcc) ? 8'h27 :
         (givenData == 8'h34) ? 8'h28 :
         (givenData == 8'ha5) ? 8'h29 :
         (givenData == 8'he5) ? 8'h2a :
         (givenData == 8'hf1) ? 8'h2b :
         (givenData == 8'h71) ? 8'h2c :
         (givenData == 8'hd8) ? 8'h2d :
         (givenData == 8'h31) ? 8'h2e :
         (givenData == 8'h15) ? 8'h2f :
         (givenData == 8'h04) ? 8'h30 :
         (givenData == 8'hc7) ? 8'h31 :
         (givenData == 8'h23) ? 8'h32 :
         (givenData == 8'hc3) ? 8'h33 :
         (givenData == 8'h18) ? 8'h34 :
         (givenData == 8'h96) ? 8'h35 :
         (givenData == 8'h05) ? 8'h36 :
         (givenData == 8'h9a) ? 8'h37 :
         (givenData == 8'h07) ? 8'h38 :
         (givenData == 8'h12) ? 8'h39 :
         (givenData == 8'h80) ? 8'h3a :
         (givenData == 8'he2) ? 8'h3b :
         (givenData == 8'heb) ? 8'h3c :
         (givenData == 8'h27) ? 8'h3d :
         (givenData == 8'hb2) ? 8'h3e :
         (givenData == 8'h75) ? 8'h3f :
         (givenData == 8'h09) ? 8'h40 :
         (givenData == 8'h83) ? 8'h41 :
         (givenData == 8'h2c) ? 8'h42 :
         (givenData == 8'h1a) ? 8'h43 :
         (givenData == 8'h1b) ? 8'h44 :
         (givenData == 8'h6e) ? 8'h45 :
         (givenData == 8'h5a) ? 8'h46 :
         (givenData == 8'ha0) ? 8'h47 :
         (givenData == 8'h52) ? 8'h48 :
         (givenData == 8'h3b) ? 8'h49 :
         (givenData == 8'hd6) ? 8'h4a :
         (givenData == 8'hb3) ? 8'h4b :
         (givenData == 8'h29) ? 8'h4c :
         (givenData == 8'he3) ? 8'h4d :
         (givenData == 8'h2f) ? 8'h4e :
         (givenData == 8'h84) ? 8'h4f :
         (givenData == 8'h53) ? 8'h50 :
         (givenData == 8'hd1) ? 8'h51 :
         (givenData == 8'h00) ? 8'h52 :
         (givenData == 8'hed) ? 8'h53 :
         (givenData == 8'h20) ? 8'h54 :
         (givenData == 8'hfc) ? 8'h55 :
         (givenData == 8'hb1) ? 8'h56 :
         (givenData == 8'h5b) ? 8'h57 :
         (givenData == 8'h6a) ? 8'h58 :
         (givenData == 8'hcb) ? 8'h59 :
         (givenData == 8'hbe) ? 8'h5a :
         (givenData == 8'h39) ? 8'h5b :
         (givenData == 8'h4a) ? 8'h5c :
         (givenData == 8'h4c) ? 8'h5d :
         (givenData == 8'h58) ? 8'h5e :
         (givenData == 8'hcf) ? 8'h5f :
         (givenData == 8'hd0) ? 8'h60 :
         (givenData == 8'hef) ? 8'h61 :
         (givenData == 8'haa) ? 8'h62 :
         (givenData == 8'hfb) ? 8'h63 :
         (givenData == 8'h43) ? 8'h64 :
         (givenData == 8'h4d) ? 8'h65 :
         (givenData == 8'h33) ? 8'h66 :
         (givenData == 8'h85) ? 8'h67 :
         (givenData == 8'h45) ? 8'h68 :
         (givenData == 8'hf9) ? 8'h69 :
         (givenData == 8'h02) ? 8'h6a :
         (givenData == 8'h7f) ? 8'h6b :
         (givenData == 8'h50) ? 8'h6c :
         (givenData == 8'h3c) ? 8'h6d :
         (givenData == 8'h9f) ? 8'h6e :
         (givenData == 8'ha8) ? 8'h6f :
         (givenData == 8'h51) ? 8'h70 :
         (givenData == 8'ha3) ? 8'h71 :
         (givenData == 8'h40) ? 8'h72 :
         (givenData == 8'h8f) ? 8'h73 :
         (givenData == 8'h92) ? 8'h74 :
         (givenData == 8'h9d) ? 8'h75 :
         (givenData == 8'h38) ? 8'h76 :
         (givenData == 8'hf5) ? 8'h77 :
         (givenData == 8'hbc) ? 8'h78 :
         (givenData == 8'hb6) ? 8'h79 :
         (givenData == 8'hda) ? 8'h7a :
         (givenData == 8'h21) ? 8'h7b :
         (givenData == 8'h10) ? 8'h7c :
         (givenData == 8'hff) ? 8'h7d :
         (givenData == 8'hf3) ? 8'h7e :
         (givenData == 8'hd2) ? 8'h7f :
         (givenData == 8'hcd) ? 8'h80 :
         (givenData == 8'h0c) ? 8'h81 :
         (givenData == 8'h13) ? 8'h82 :
         (givenData == 8'hec) ? 8'h83 :
         (givenData == 8'h5f) ? 8'h84 :
         (givenData == 8'h97) ? 8'h85 :
         (givenData == 8'h44) ? 8'h86 :
         (givenData == 8'h17) ? 8'h87 :
         (givenData == 8'hc4) ? 8'h88 :
         (givenData == 8'ha7) ? 8'h89 :
         (givenData == 8'h7e) ? 8'h8a :
         (givenData == 8'h3d) ? 8'h8b :
         (givenData == 8'h64) ? 8'h8c :
         (givenData == 8'h5d) ? 8'h8d :
         (givenData == 8'h19) ? 8'h8e :
         (givenData == 8'h73) ? 8'h8f :
         (givenData == 8'h60) ? 8'h90 :
         (givenData == 8'h81) ? 8'h91 :
         (givenData == 8'h4f) ? 8'h92 :
         (givenData == 8'hdc) ? 8'h93 :
         (givenData == 8'h22) ? 8'h94 :
         (givenData == 8'h2a) ? 8'h95 :
         (givenData == 8'h90) ? 8'h96 :
         (givenData == 8'h88) ? 8'h97 :
         (givenData == 8'h46) ? 8'h98 :
         (givenData == 8'hee) ? 8'h99 :
         (givenData == 8'hb8) ? 8'h9a :
         (givenData == 8'h14) ? 8'h9b :
         (givenData == 8'hde) ? 8'h9c :
         (givenData == 8'h5e) ? 8'h9d :
         (givenData == 8'h0b) ? 8'h9e :
         (givenData == 8'hdb) ? 8'h9f :
         (givenData == 8'he0) ? 8'ha0 :
         (givenData == 8'h32) ? 8'ha1 :
         (givenData == 8'h3a) ? 8'ha2 :
         (givenData == 8'h0a) ? 8'ha3 :
         (givenData == 8'h49) ? 8'ha4 :
         (givenData == 8'h06) ? 8'ha5 :
         (givenData == 8'h24) ? 8'ha6 :
         (givenData == 8'h5c) ? 8'ha7 :
         (givenData == 8'hc2) ? 8'ha8 :
         (givenData == 8'hd3) ? 8'ha9 :
         (givenData == 8'hac) ? 8'haa :
         (givenData == 8'h62) ? 8'hab :
         (givenData == 8'h91) ? 8'hac :
         (givenData == 8'h95) ? 8'had :
         (givenData == 8'he4) ? 8'hae :
         (givenData == 8'h79) ? 8'haf :
         (givenData == 8'he7) ? 8'hb0 :
         (givenData == 8'hc8) ? 8'hb1 :
         (givenData == 8'h37) ? 8'hb2 :
         (givenData == 8'h6d) ? 8'hb3 :
         (givenData == 8'h8d) ? 8'hb4 :
         (givenData == 8'hd5) ? 8'hb5 :
         (givenData == 8'h4e) ? 8'hb6 :
         (givenData == 8'ha9) ? 8'hb7 :
         (givenData == 8'h6c) ? 8'hb8 :
         (givenData == 8'h56) ? 8'hb9 :
         (givenData == 8'hf4) ? 8'hba :
         (givenData == 8'hea) ? 8'hbb :
         (givenData == 8'h65) ? 8'hbc :
         (givenData == 8'h7a) ? 8'hbd :
         (givenData == 8'hae) ? 8'hbe :
         (givenData == 8'h08) ? 8'hbf :
         (givenData == 8'hba) ? 8'hc0 :
         (givenData == 8'h78) ? 8'hc1 :
         (givenData == 8'h25) ? 8'hc2 :
         (givenData == 8'h2e) ? 8'hc3 :
         (givenData == 8'h1c) ? 8'hc4 :
         (givenData == 8'ha6) ? 8'hc5 :
         (givenData == 8'hb4) ? 8'hc6 :
         (givenData == 8'hc6) ? 8'hc7 :
         (givenData == 8'he8) ? 8'hc8 :
         (givenData == 8'hdd) ? 8'hc9 :
         (givenData == 8'h74) ? 8'hca :
         (givenData == 8'h1f) ? 8'hcb :
         (givenData == 8'h4b) ? 8'hcc :
         (givenData == 8'hbd) ? 8'hcd :
         (givenData == 8'h8b) ? 8'hce :
         (givenData == 8'h8a) ? 8'hcf :
         (givenData == 8'h70) ? 8'hd0 :
         (givenData == 8'h3e) ? 8'hd1 :
         (givenData == 8'hb5) ? 8'hd2 :
         (givenData == 8'h66) ? 8'hd3 :
         (givenData == 8'h48) ? 8'hd4 :
         (givenData == 8'h03) ? 8'hd5 :
         (givenData == 8'hf6) ? 8'hd6 :
         (givenData == 8'h0e) ? 8'hd7 :
         (givenData == 8'h61) ? 8'hd8 :
         (givenData == 8'h35) ? 8'hd9 :
         (givenData == 8'h57) ? 8'hda :
         (givenData == 8'hb9) ? 8'hdb :
         (givenData == 8'h86) ? 8'hdc :
         (givenData == 8'hc1) ? 8'hdd :
         (givenData == 8'h1d) ? 8'hde :
         (givenData == 8'h9e) ? 8'hdf :
         (givenData == 8'he1) ? 8'he0 :
         (givenData == 8'hf8) ? 8'he1 :
         (givenData == 8'h98) ? 8'he2 :
         (givenData == 8'h11) ? 8'he3 :
         (givenData == 8'h69) ? 8'he4 :
         (givenData == 8'hd9) ? 8'he5 :
         (givenData == 8'h8e) ? 8'he6 :
         (givenData == 8'h94) ? 8'he7 :
         (givenData == 8'h9b) ? 8'he8 :
         (givenData == 8'h1e) ? 8'he9 :
         (givenData == 8'h87) ? 8'hea :
         (givenData == 8'he9) ? 8'heb :
         (givenData == 8'hce) ? 8'hec :
         (givenData == 8'h55) ? 8'hed :
         (givenData == 8'h28) ? 8'hee :
         (givenData == 8'hdf) ? 8'hef :
         (givenData == 8'h8c) ? 8'hf0 :
         (givenData == 8'ha1) ? 8'hf1 :
         (givenData == 8'h89) ? 8'hf2 :
         (givenData == 8'h0d) ? 8'hf3 :
         (givenData == 8'hbf) ? 8'hf4 :
         (givenData == 8'he6) ? 8'hf5 :
         (givenData == 8'h42) ? 8'hf6 :
         (givenData == 8'h68) ? 8'hf7 :
         (givenData == 8'h41) ? 8'hf8 :
         (givenData == 8'h99) ? 8'hf9 :
         (givenData == 8'h2d) ? 8'hfa :
         (givenData == 8'h0f) ? 8'hfb :
         (givenData == 8'hb0) ? 8'hfc :
         (givenData == 8'h54) ? 8'hfd :
         (givenData == 8'hbb) ? 8'hfe : 8'hff;

endmodule

module Decryption_Round(in,key,out);

  input [127:0] in;
  output [127:0] out;
  input [127:0] key;

  function [127:0]addRoundKey;
    input [127:0] crtState;
    input [127:0] crtRoundKey;
    begin
      addRoundKey = crtState^crtRoundKey;
    end
  endfunction

  wire [127:0] afterSubBytes;
  wire [127:0] afterShiftRows;
  wire [127:0] afterMixColumns;
  wire [127:0] afterAddroundKey;

  InvSubBytes s(in,afterSubBytes);
  InverseShiftRows r(afterSubBytes,afterShiftRows);
  OrgMixColumns m(afterShiftRows,afterMixColumns);
  assign out = addRoundKey (afterMixColumns,key);

endmodule
