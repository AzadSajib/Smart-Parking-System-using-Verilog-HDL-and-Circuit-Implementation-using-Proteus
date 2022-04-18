module top_module(clock,register, gl_reset, car_exit, exit_from, exit_code, 
					car_arrival,available_slots,can_park,
					l0,l1,l2,l3,l4,l5,l6,l7);

input clock, gl_reset;				//clock pulse and global reset 
input car_arrival, car_exit;		//pulse when car arrives or exits
input [2:0]exit_from;				//the spot from which car is exiting
input [7:0]exit_code;				//entering the passscode from the exiting spot
output reg [2:0]available_slots;	//how many slots are available
output reg can_park;				//1 if there slot available for parking, 0 if there is not							
output reg [7:1]register;			//temporary memory to remember the spot where cars are parked
reg [2:0]spot;						//car has been allowed to exit
reg [7:0] temp;						//holding the passcodes for designated spots
integer i;
output reg [7:0]l0,l1,l2,l3,l4,l5,l6,l7; //memories to hold the passcodes for each spot
reg match;
always @ (posedge clock)
begin
	if (car_exit)					//this will execute is there is a pulse in car_exit variable
	begin
		//find the number from which the car is exiting, and check if the code input from 
		//exit_code matches the proper case
		case(exit_from)				
			7:begin 
				if (exit_code == l7) match =1;
				else match = 0;
				end
			6:begin 
				if (exit_code == l6) match =1;
				else match = 0;
				end
			5:begin 
				if (exit_code == l5) match =1;
				else match = 0;
				end
			4:begin 
				if (exit_code == l4) match =1;
				else match = 0;
				end
			3:begin 
				if (exit_code == l3) match =1;
				else match = 0;
				end
			2:begin 
				if (exit_code == l2) match =1;
				else match = 0;
				end
			1:begin 
				if (exit_code == l1) match =1;
				else match = 0;
				end
			0:begin 
				if (exit_code == l0) match =1;
				else match = 0;
				end
		endcase
		if(match)			//if there is a match in the code given and the passcode, this will execute
		begin
			available_slots <= available_slots + 1; //increase the number of available spots if a car exits
			can_park <= 1;			//if a car exits, the slot becomes available for parking
			register[exit_from] <= 0; //putting zero in that slot of the register to denote it's empty
		end
		else				//if the exit_code doesn't match the passcode, the car will not be allowed
							//exit
		begin	
			available_slots <= available_slots; //no of available slots remains the same
			register[exit_from] <= register[exit_from]; //the slot is not emptied
		end
	end
	
	if(gl_reset)					//synchronous resetting
	begin
		available_slots <= 3'b111;	//all the slots are available
		register <= 0;
		can_park <= 1;
	end
	else if(!available_slots)		//if no slots available, car cannot be parked
		can_park <= 0;
	else if(car_arrival)			//if a car arrives and the former two conditions are not met
									//this will execute
	begin
		can_park <= 1;
		available_slots <= available_slots - 1;	//number of slots will decrease by 1
		//the for loop will check for MSB in register variable that is zero
		//and then will park the car in that spot
		for(i=1;i<=7;i = i+1)
		begin
			if(register[i]==0)
				spot = i;
		end
		register[spot] <= 1;
		
		task_passcode (spot, temp); //calling the passcode generation task for the spot
									//where the car is parked
		begin
		//assigning the passcode to the designated memory
		case(spot)
			7 : l7 = temp;
			6 : l6 = temp;
			5 : l5 = temp;
			4 : l4 = temp;
			3 : l3 = temp;
			2 : l2 = temp;
			1 : l1 = temp;
			0 : l0 = temp;
		endcase
		end
	end
end	

task task_passcode;
input [2:0]slot_number;
output reg [7:0]Q;
//generating passcode for each slots, according to fibonacci sequence
begin
	case(slot_number)
		3'b111: Q = 1+2+3+5+8+13+21+34;
		3'b110: Q = 1+2+3+5+8+13+21;
		3'b101: Q = 1+2+3+5+8+13;
		3'b100: Q = 1+2+3+5+8;
		3'b011: Q = 1+2+3+5;
		3'b010: Q = 1+2+3;
		3'b001: Q = 1+2;
		3'b000: Q = 1;
	endcase
end
endtask

endmodule
