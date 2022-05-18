module booth2 (
    input  wire        clk  ,
	input  wire        rst_n,
	input  wire [15:0] x    ,
	input  wire [15:0] y    ,
	input  wire        start,
	output reg [31:0] z    ,
	output wire        busy 
);

//double signed bit
reg [31:0]	x_reg;
reg [31:0]	x_reg_neg;

reg [15:0]	x_reg_double_temp;
reg [15:0]	x_reg_neg_double_temp;
reg [31:0]	x_reg_double;
reg [31:0]	x_reg_neg_double;

reg [0:16]	y_reg;
reg [31:0]	z_temp;

reg			busy_flag;
reg	[31:0]	times;

assign busy = busy_flag;

//Initialize and assign the regs
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		x_reg <= 0;
		x_reg_neg <= 0;
		x_reg_double <= 0;
		x_reg_neg_double <= 0;
		y_reg <= {16'h0000,1'b0};
		busy_flag <= 0;
	end

	else if(start) begin
		x_reg <= {x,16'h0000};
		x_reg_neg <= (~x + 1) << 16;
		y_reg <= {y,1'b0};
		busy_flag <= 1;

		x_reg_double_temp = x + x;
		x_reg_neg_double_temp = (~x+1) + (~x+1);

		x_reg_double = {x_reg_double_temp, 16'h0000};
		x_reg_neg_double = {x_reg_neg_double_temp, 16'h0000};
	end
end



//Start computing
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		times <= 0;
		z_temp <= 0;
	end
	if(start)	begin
		times <= 0;
		z_temp <= 0;
	end
	if(busy_flag) begin
		if(times > 8) begin
			z <= z_temp;
			busy_flag <= 0;
		end

		else if(times == 8) begin
				case (y_reg[14:16])
				000:	begin
				end 
				001:	begin
					z_temp = z_temp + x_reg;
				end
				010:	begin
					z_temp = z_temp + x_reg;
				end
				011:	begin
					z_temp = z_temp + x_reg + x_reg;
				end
				100:	begin
					z_temp = z_temp + x_reg_neg + x_reg_neg;
				end
				101:	begin
					z_temp = z_temp + x_reg_neg;
				end
				110:		begin
					z_temp = z_temp + x_reg_neg;
				end
				111:		begin
				end
				default: z_temp <= z_temp;
			endcase
		end

		else begin
			case (y_reg[14:16])
				000:	begin
					z_temp <= {{2{z_temp[31]}}, z_temp[31:2]};
				end 
				001:	begin
					z_temp = z_temp + x_reg;
					z_temp = {{2{z_temp[31]}}, z_temp[31:2]};
				end
				010:	begin
					z_temp = z_temp + x_reg;
					z_temp = {{2{z_temp[31]}}, z_temp[31:2]};
				end
				011:	begin
					z_temp = z_temp + x_reg + x_reg;
					z_temp = {{2{z_temp[31]}}, z_temp[31:2]};
				end
				100:	begin
					z_temp = z_temp + x_reg_neg + x_reg_neg;
					z_temp = {{2{z_temp[31]}}, z_temp[31:2]};					
				end
				101:	begin
					z_temp = z_temp + x_reg_neg;
					z_temp = {{2{z_temp[31]}}, z_temp[31:2]};						
				end
				110:		begin
					z_temp = z_temp + x_reg_neg;
					z_temp = {{2{z_temp[31]}}, z_temp[31:2]};
				end
				111:		begin
					z_temp <= {{2{z_temp[31]}}, z_temp[31:2]};					
				end
				default: z_temp <= z_temp;
			endcase
		end

		y_reg <= y_reg >> 3;
		times <= times + 1;
	end

end


endmodule
