module baud_controller (input wire Reset, Clock, 
                        input wire [2:0] baud_select,
                        output reg sample_ENABLE);
  
  integer cycles;
  reg[13:0] count;
  
  always @(posedge Clock)
    begin
      case(baud_select)
        3'b000 : cycles = 10416;
        3'b001 : cycles = 2604;
        3'b010 : cycles = 651;
        3'b011 : cycles = 325;
        3'b100 : cycles = 163;
        3'b101 : cycles = 81;
        3'b110 : cycles = 53;
        3'b111 : cycles = 26;
      endcase
    end
  
  always @ (posedge Clock or negedge Reset)
    begin
      if (!Reset)
        count <= 14'b0;
      else
        begin
          count <= count + 1;
          sample_ENABLE <= 0;
          if (count == cycles)
            begin
              count <= 14'b0;
              sample_ENABLE <= 1;
            end
        end
     end
  
endmodule