module control (
    input logic Clk, run, M0, M1, reset,
    
    output logic shift, fn, LoadA, clearXA
);
    //Need M0, and M1 because when we go to a shift state, it sets the SHIFT signal high
    //but it also determines where to go next, before the shift is actually carried out
    //so we need to look at B_val[1] not B_val[0]
    //But at the start we don't have this problem so use B_val[0] because nothing is moved yet

    //Declare signals cur_state, next_state based on this enum
	enum logic [4:0] {
		s_start, 
		resetXA,     //need this state to clear XA is we doing b2b computations,
		s_count0_shift,          //cant be above bc would clear A immediatly after finishing
        s_count0_add,
		s_count1_shift,
        s_count1_add, 
        s_count2_shift, 
        s_count2_add,
		s_count3_shift,
        s_count3_add, 
        s_count4_shift, 
        s_count4_add,
		s_count5_shift,
        s_count5_add, 
        s_count6_shift, 
        s_count6_add,
		s_count7_shift,
        s_count7_sub,
		s_done
	} curr_state, next_state; 
    

    always_comb begin
        clearXA = 1'b0;     //default don't clear XA
		unique case (curr_state) 
			s_start: 
			begin
                LoadA = 1'b0;
				shift = 1'b0;
                fn = 1'b0;
			end
			resetXA:
			begin
			     LoadA = 1'b0;
			     shift = 1'b0;
			     fn = 1'b0;
			     clearXA = 1'b1;         //only state that clears XA
			end

            s_count0_add:
            begin
                LoadA = 1'b1;
                shift = 1'b0;
                fn = 1'b0;
            end
            s_count1_add:
            begin
                LoadA = 1'b1;
                shift = 1'b0;
                fn = 1'b0;
            end
            s_count2_add:
            begin
                LoadA = 1'b1;
                shift = 1'b0;
                fn = 1'b0;
            end
            s_count3_add:
            begin
                LoadA = 1'b1;
                shift = 1'b0;
                fn = 1'b0;
            end
            s_count4_add:
            begin
                LoadA = 1'b1;
                shift = 1'b0;
                fn = 1'b0;
            end
            s_count5_add:
            begin
                LoadA = 1'b1;
                shift = 1'b0;
                fn = 1'b0;
            end
            s_count6_add:
            begin
                LoadA = 1'b1;
                shift = 1'b0;
                fn = 1'b0;
            end
            s_count7_sub:
            begin
                LoadA = 1'b1;
                shift = 1'b0;
                fn = 1'b1;
            end

            s_count0_shift:
            begin
                LoadA = 1'b0;
                shift = 1'b1;
                fn = 1'b0;
            end
            s_count1_shift:
            begin
                LoadA = 1'b0;
                shift = 1'b1;
                fn = 1'b0;
            end
            s_count2_shift:
            begin
                LoadA = 1'b0;
                shift = 1'b1;
                fn = 1'b0;
            end
            s_count3_shift:
            begin
                LoadA = 1'b0;
                shift = 1'b1;
                fn = 1'b0;
            end
            s_count4_shift:
            begin
                LoadA = 1'b0;
                shift = 1'b1;
                fn = 1'b0;
            end
            s_count5_shift:
            begin
                LoadA = 1'b0;
                shift = 1'b1;
                fn = 1'b0;
            end
            s_count6_shift:
            begin
                LoadA = 1'b0;
                shift = 1'b1;
                fn = 1'b0;
            end
            s_count7_shift:
            begin
                LoadA = 1'b0;
                shift = 1'b1;
                fn = 1'b0;
            end

			s_done: 
			begin
                LoadA = 1'b0;
                shift = 1'b0;
                fn = 1'b0;
			end

			default:  //default case, can also have default assignments for Ld_A
			begin 
				LoadA = 1'b0;
                shift = 1'b0;
                fn = 1'b0;
                clearXA = 1'b0;
			end
		endcase
    end


    // Assign outputs based on state
	always_comb
	begin

		next_state  = curr_state;	//required because I haven't enumerated all possibilities below. Synthesis would infer latch without this
		unique case (curr_state) 

			s_start :    
			begin
				if (run)
			    begin
			         next_state = resetXA;
			    end
			end
			
			resetXA:
			begin
			     if (M0 == 0)
			     begin
			         next_state = s_count0_shift;
			     end else
			     begin
			         next_state = s_count0_add;
			     end
			end


            s_count0_shift :
            begin
                if (M1 == 0)
                begin
                    next_state = s_count1_shift;
                end
                else if (M1==1) 
                begin
                    next_state = s_count1_add;
                end
            end 

            s_count1_shift :
            begin
                if (M1 == 0)
                begin
                    next_state = s_count2_shift;
                end
                else if (M1==1) 
                begin
                    next_state = s_count2_add;
                end
            end 

            s_count2_shift :
            begin
                if (M1 == 0)
                begin
                    next_state = s_count3_shift;
                end
                else if (M1==1) 
                begin
                    next_state = s_count3_add;
                end
            end 

            s_count3_shift :
            begin
                if (M1 == 0)
                begin
                    next_state = s_count4_shift;
                end
                else if (M1==1) 
                begin
                    next_state = s_count4_add;
                end
            end 

            s_count4_shift :
            begin
                if (M1 == 0)
                begin
                    next_state = s_count5_shift;
                end
                else if (M1==1) 
                begin
                    next_state = s_count5_add;
                end
            end 

            s_count5_shift :
            begin
                if (M1 == 0)
                begin
                    next_state = s_count6_shift;
                end
                else if (M1==1) 
                begin
                    next_state = s_count6_add;
                end
            end 

            s_count6_shift :
            begin
                if (M1 == 0)
                begin
                    next_state = s_count7_shift;
                end
                else if (M1==1) 
                begin
                    next_state = s_count7_sub;
                end
            end 

            s_count7_shift :
            begin
                next_state = s_done;
            end 

			s_count0_add :    next_state = s_count0_shift;
			s_count1_add :    next_state = s_count1_shift;
			s_count2_add :    next_state = s_count2_shift;
			s_count3_add :    next_state = s_count3_shift;
            s_count4_add :    next_state = s_count4_shift;
            s_count5_add :    next_state = s_count5_shift;
            s_count6_add :    next_state = s_count6_shift;
            s_count7_sub :    next_state = s_count7_shift;

			s_done :    
			begin
				if (~run) 
				begin
					next_state = s_start;
				end
			end
					
		endcase
	end


    //updates flip flop, current state is the only one
    always_ff @(posedge Clk)    
    begin
        if (reset)
        begin
            curr_state <= s_start;
        end
        else
        begin
            curr_state <= next_state;
        end
    end

endmodule