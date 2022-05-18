module booth (
    input  wire        clk  ,
	input  wire        rst_n,
	input  wire [15:0] x    ,
	input  wire [15:0] y    ,
	input  wire        start,
	output reg  [31:0] z    ,
	output wire        busy 
);

//double signed bit
reg [31:0]	x_reg;
reg [31:0]	x_reg_neg;
reg [0:16]	y_reg;
reg [31:0]	z_temp;

//Whether the x_reg or y_reg has been assigned.
reg			busy_flag;
reg	[31:0]		times;

assign busy = busy_flag;

//Initialize and assign the regs
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		x_reg <= 0;
		x_reg_neg <= 0;
		y_reg <= {16'h0000,1'b0};
		z_temp <= 0;
		busy_flag <= 0;
	end

	

	else if(start) begin
		x_reg <= {x,16'h0000};
		x_reg_neg <= (~x + 1) << 16;
		y_reg <= {y,1'b0};
		z_temp <= 0;
		busy_flag <= 1;
	end
end


//Start computing
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		times <= 0;
	end
	if(start)	begin
		times <= 0;
	end
	if(busy_flag) begin
		if(times >= 16) begin
			z <= z_temp;
			busy_flag <= 0;
		end
		// else if(times == 15) begin
		// 	if(y_reg[15] == 0 & y_reg[16] == 0) begin
		// 		z_temp <= z_temp;
		// 	end
		// 	else if(y_reg[15] == 0 & y_reg[16] == 1) begin
		// 		z_temp <= (z_temp + x_reg);
		// 	end
		// 	else if(y_reg[15] == 1 & y_reg[16] == 0) begin
		// 		z_temp <= (z_temp + x_reg_neg);
		// 	end
		// 	else if(y_reg[15] == 1 & y_reg[16] == 1) begin
		// 		z_temp <= z_temp;
		// 	end
		// 	else	;
		// end
		else if(y_reg[15] == 0 & y_reg[16] == 0) begin
			z_temp <= {z_temp[31],z_temp[31:1]} ;
		end
		else if(y_reg[15] == 0 & y_reg[16] == 1) begin
			// if(z_temp + x_reg > 32'h8000_0000)	z_temp <= (z_temp + x_reg) >> 1 + 32'h8000_0000;
			// else								z_temp <= (z_temp + x_reg) >> 1;
			z_temp = z_temp + x_reg;
			z_temp = {z_temp[31], z_temp[31:1]};
		end
		else if(y_reg[15] == 1 & y_reg[16] == 0) begin
			// if(z_temp + x_reg_neg > 32'h8000_0000)	z_temp <= (z_temp + x_reg_neg) >> 1 + 32'h8000_0000;
			// else									z_temp <= (z_temp + x_reg_neg) >> 1;
			z_temp = z_temp +x_reg_neg;
			z_temp = {z_temp[31], z_temp[31:1]};
		end
		else if(y_reg[15] == 1 & y_reg[16] == 1) begin
			z_temp <= {z_temp[31],z_temp[31:1]};
		end
		else begin
			busy_flag <= 0;
		end

		y_reg <= y_reg >>1;
		times <= times + 1;
	end
end



endmodule
