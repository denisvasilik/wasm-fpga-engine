library STD;
use STD.textio.all;

library IEEE;
library ieee_proposed;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library work;
use work.tb_STD_LOGIC_1164_additions.all;
use work.tb_pkg.all;
use work.tb_pkg_helper.all;
use work.tb_types.all;

entity tb_FileIo is
  generic (
    stimulus_path: in string;
    stimulus_file: in string
  );
  port (
    Clk : in std_logic;
    Rst : in std_logic;
    nRst : out std_logic;
    WasmFpgaEngine_FileIO : in T_WasmFpgaEngine_FileIO;
    FileIO_WasmFpgaEngine : out T_FileIO_WasmFpgaEngine;
    WasmFpgaBus_FileIO : in T_WasmFpgaBus_FileIO;
    FileIO_WasmFpgaBus : out T_FileIO_WasmFpgaBus;
    ModuleMemory_FileIO : in T_ModuleMemory_FileIO;
    FileIO_ModuleMemory : out T_FileIO_ModuleMemory;
    StoreMemory_FileIO : in T_StoreMemory_FileIO;
    FileIO_StoreMemory : out T_FileIO_StoreMemory;
    StackMemory_FileIO : in T_StackMemory_FileIO;
    FileIO_StackMemory : out T_FileIO_StackMemory;
    Memory_FileIO : in T_Memory_FileIO;
    FileIO_Memory : out T_FileIO_Memory
  );
end tb_FileIo;

architecture Behavioural of tb_FileIo is

    signal tb_Marker : std_logic_vector(15 downto 0) := (others => '0');

    signal tempValue : std_logic_vector(31 downto 0);
    signal tempAddress : std_logic_vector(31 downto 0);

    signal RstNeg : std_logic;

    signal wb_read_start : std_logic := '0';
    signal wb_write_start : std_logic := '0';
    signal wb_write_read_end : std_logic := '0';
    signal wb_address : std_logic_vector(31 downto 0);
    signal wb_byte_enable : std_logic_vector( 3 downto 0);
    signal wb_data_read : std_logic_vector(31 downto 0);
    signal wb_data_write : std_logic_vector(31 downto 0);

    constant tco : time := 0 ns;    -- clock to output delay

begin

    RstNeg <= not Rst;

    -- Read / Write CPU -----------------READ--------------------------READ-----------------------
    readwriteCpu : process
    begin
        wb_write_read_end <= '0';
        FileIO_WasmFpgaEngine.Adr <= (others => '0');
        FileIO_WasmFpgaEngine.DatIn <= (others => '0');
        FileIO_WasmFpgaEngine.Cyc <= (others => '0');
        FileIO_WasmFpgaEngine.Sel <= "1111";
        FileIO_WasmFpgaEngine.We  <= '0';
        FileIO_WasmFpgaEngine.Stb <= '0';

        wait until Rst = '0';
        wait for 0 ns;

        while (Rst= '0') loop
        --READ--
        if wb_read_start= '1' then                 -- rising_edge(read_start) then
            wait until rising_edge(clk);       -- WishboneREAD CLOCK EDGE 0
            FileIO_WasmFpgaEngine.Adr <= std_logic_vector(wb_address(23 downto 0)) after tco;
            FileIO_WasmFpgaEngine.Sel <= wb_byte_enable after tco;
            FileIO_WasmFpgaEngine.We  <= '0' after tco;
            FileIO_WasmFpgaEngine.Stb <= '1' after tco;
            FileIO_WasmFpgaEngine.Cyc <= (others => '1') after tco;
            -- clk_delay (cRdWaitState);
            wait on WasmFpgaEngine_FileIO.Ack until WasmFpgaEngine_FileIO.Ack = '1';
            wait for tco;
            wait until rising_edge(clk);        --WishboneREAD CLOCK EDGE 1
            wb_data_read <= WasmFpgaEngine_FileIO.DatOut (31 downto 0);
            wb_write_read_end       <= '1';
            wait for 0 ns;
            wait until wb_read_start= '0';
        --WRITE--
        elsif wb_write_start= '1' then
            wait until rising_edge(clk);           --WishboneWRITE CLOCK EDGE 0
            FileIO_WasmFpgaEngine.DatIn <= wb_data_write after tco;
            FileIO_WasmFpgaEngine.Adr <= std_logic_vector(wb_address(23 downto 0)) after tco;
            FileIO_WasmFpgaEngine.Sel <= wb_byte_enable after tco;
            FileIO_WasmFpgaEngine.We  <= '1' after tco;
            FileIO_WasmFpgaEngine.Stb <= '1' after tco;
            FileIO_WasmFpgaEngine.Cyc <= (others => '1') after tco;

            -- clk_delay (cWrWaitState);
            wait on WasmFpgaEngine_FileIO.Ack until (WasmFpgaEngine_FileIO.Ack = '1');
            wait for tco;
            wait until rising_edge(clk);           --WishboneWRITE CLOCK EDGE 1
            wb_write_read_end       <= '1';
            wait until wb_write_start= '0';
        else
            wb_write_read_end <= '0';
            FileIO_WasmFpgaEngine.Adr <= (others => '0') after tco;
            FileIO_WasmFpgaEngine.Sel <= "1111"       after tco;
            FileIO_WasmFpgaEngine.We  <= '0'          after tco;
            FileIO_WasmFpgaEngine.Stb <= '0'          after tco;
            FileIO_WasmFpgaEngine.Cyc <= (others => '0') after tco;
            wait until rising_edge(clk);       --neu WishboneREAD/WRITE CLOCK EDGE 2
        end if;
        end loop;
    end process readwriteCpu;

    --------------------------------------------------------------------------------
    --! Read_file Process:

    --! This process is the main process of the testbench.  This process reads
    --! the stimulus file, parses it, creates lists of records, then uses these
    --! lists to execute user instructions.  There are two passes through the
    --! script.  Pass one reads in the stimulus text file, checks it, creates
    --! lists of valid instructions, valid list of variables and finally a list
    --! of user instructions(the sequence).  The second pass through the file,
    --! records are drawn from the user instruction list, variables are converted
    --! to integers and put through the elsif structure for exicution.

    Read_file: process
        variable wrline       : line;

        variable current_line : text_line;  -- The current input line
        variable inst_list    : inst_def_ptr;  -- the instruction list
        variable defined_vars : var_field_ptr; -- defined variables
        variable inst_sequ    : stim_line_ptr; -- the instruction sequence
        variable file_list    : file_def_ptr;  -- pointer to the list of file names
        variable last_sequ_num: integer;
        variable last_sequ_ptr: stim_line_ptr;

        variable instruction  : text_field;   -- instruction field
        variable par1         : integer;      -- parameter 1
        variable par2         : integer;      -- parameter 2
        variable par3         : integer;      -- parameter 3
        variable par4         : integer;      -- parameter 4
        variable par5         : integer;      -- parameter 5
        variable par6         : integer;      -- parameter 6
        variable txt          : stm_text_ptr;
        variable nbase        : base;         -- the number base to use
        variable len          : integer;      -- length of the instruction field
        variable file_line    : integer;      -- Line number in the stimulus file
        variable file_name    : text_line;    -- the file name the line came from
        variable v_line       : integer := 0; -- sequence number
        variable prev_v_line  : integer := 0;
        variable stack        : stack_register; -- Call stack
        variable stack_ptr    : integer  := 0;  -- call stack pointer
        variable wh_stack     : stack_register; -- while stack
        variable wh_dpth      : integer := 0;   -- while depth
        variable wh_ptr       : integer  := 0;  -- while pointer
        variable loop_num         : integer := 0;
        variable curr_loop_count  : int_array := (others => 0);
        variable term_loop_count  : int_array := (others => 0);
        variable loop_line        : int_array := (others => 0);

        variable messagelevel : integer  := 0;
        variable exit_on_verify_error : boolean  := TRUE;
        variable if_level     : integer  := 0;
        variable loop_if_enter_level : integer  := 0;
        variable if_state     : boolean_array  := (others => FALSE);
        variable NumOfIfInFalseIfLeave : int_array := (others => 0);
        variable wh_state     : boolean  := FALSE;
        variable wh_end       : boolean  := FALSE;
        variable valid        : integer;

        -- random generator seed variables
        variable Seed1        : positive := 1;
        variable Seed2        : positive := 1;

        --  scratchpad variables
        variable temp_int     : integer;
        variable temp_index   : integer;
        variable temp_str     : text_field;
        variable v_temp_vec_32_1  : std_logic_vector(31 downto 0);
        variable v_temp_vec_32_2  : std_logic_vector(31 downto 0);
        variable v_temp_vec_3  : std_logic_vector(2 downto 0);
        variable v_temp_vec_8 : std_logic_vector(7 downto 0);
        variable v_temp_vec_2 : std_logic_vector(1 downto 0);
        variable v_temp_vec_1 : std_logic_vector(0 downto 0);

        -- user variables
        type T_prev_cycle_type is(prev_cycle_type_unknown,
                                  prev_cycle_type_read,
                                  prev_cycle_type_write);

        variable prev_cycle_type : T_prev_cycle_type := prev_cycle_type_unknown;

        constant tTbClkHalfPeriodPll : time := 6.028 ns;
        constant tTbClkHalfPeriodOsc : time := 16 * 6.028 ns;

        constant tPropDelayEbiAllMin : time := 2ns;
        constant tPropDelayEbiAllMax : time := 5ns;

        constant tSetupEbiReady : time := 5ns;
        constant tHoldEbiReady : time := 5ns;

        constant tSetupEbiDab : time := 19ns;  -- 21ns minus min prop delay of nRd
        constant tHoldEbiDab : time := 2ns; -- 0ns plus min prop delay of nRd

        constant tPropDelayEbiHiZ : time := 10ns; -- guess

        variable isReady : boolean;
        variable lpCnt : integer;

        variable temp_int_minus1 : integer;
        variable temp_stdvec_a : std_logic_vector(31 downto 0);
        variable temp_stdvec_b : std_logic_vector(31 downto 0);
        variable temp_stdvec_c : std_logic_vector(31 downto 0);

        variable temp_int_a : integer;

        variable maxLoopCount : integer := 128;

        variable interrupt_in_service : boolean := false;

        variable trc_on : boolean := false;
        variable trc_temp_str : string(1 to file_name'LENGTH);

        --------------------------------------------------------------------------
        --  Area for Procedures which may be usefull to more than one instruction.
        --    By coding here commonly used  code sections ...
        --    you know the benifits.
        ---------------------------------------------------------------------

    begin  -- process Read_file

        wb_data_write <= (others => '0');

        nRst <= '1';

        FileIO_ModuleMemory.DatIn <= (others => '0');
        FileIO_ModuleMemory.Adr <= (others => '0');
        FileIO_ModuleMemory.Sel <= (others => '0');
        FileIO_ModuleMemory.Cyc <= (others => '0');
        FileIO_ModuleMemory.We <= '0';
        FileIO_ModuleMemory.Stb <= '0';

        FileIO_StoreMemory.DatIn <= (others => '0');
        FileIO_StoreMemory.Adr <= (others => '0');
        FileIO_StoreMemory.Sel <= (others => '0');
        FileIO_StoreMemory.Cyc <= (others => '0');
        FileIO_StoreMemory.We <= '0';
        FileIO_StoreMemory.Stb <= '0';

        FileIO_StackMemory.DatIn <= (others => '0');
        FileIO_StackMemory.Adr <= (others => '0');
        FileIO_StackMemory.Sel <= (others => '0');
        FileIO_StackMemory.Cyc <= (others => '0');
        FileIO_StackMemory.We <= '0';
        FileIO_StackMemory.Stb <= '0';

        FileIO_Memory.DatIn <= (others => '0');
        FileIO_Memory.Adr <= (others => '0');
        FileIO_Memory.Sel <= (others => '0');
        FileIO_Memory.Cyc <= (others => '0');
        FileIO_Memory.We <= '0';
        FileIO_Memory.Stb <= '0';

        FileIO_WasmFpgaBus.DatIn <= (others => '0');
        FileIO_WasmFpgaBus.Adr <= (others => '0');
        FileIO_WasmFpgaBus.Sel <= (others => '0');
        FileIO_WasmFpgaBus.Cyc <= (others => '0');
        FileIO_WasmFpgaBus.We <= '0';
        FileIO_WasmFpgaBus.Stb <= '0';

        tempAddress <= (others => '0');
        tempValue <= (others => '0');

        -----------------------------------------------------------------------
        --           Stimulus file instruction definition
        --  This is where the instructions used in the stimulus file are defined.
        --  Syntax is
        --     define_instruction(inst_def_ptr, instruction, paramiters)
        --           inst_def_ptr: is a record pointer defined in tb_pkg_header
        --           instruction:  the text instruction name  ie. "DEFINE_VAR"
        --           paramiters:   the number of fields or paramiters passed
        --
        --  Some basic instruction are created here, the user should create new
        --  instructions below the standard ones.
        ------------------------------------------------------------------------
        define_instruction(inst_list, "DEFINE_VAR", 2);  -- Define a variable
        define_instruction(inst_list, "DEFINE_CONST", 2);  -- Define a constant
        define_instruction(inst_list, "EQU_VAR", 2);
        define_instruction(inst_list, "ADD_VAR", 2);
        define_instruction(inst_list, "ADD_CONST", 2);
        define_instruction(inst_list, "SUB_VAR", 2);
        define_instruction(inst_list, "CALL", 1);
        define_instruction(inst_list, "RETURN_CALL", 0);
        define_instruction(inst_list, "RETURN_CALL_INTERRUPT", 0);
        define_instruction(inst_list, "BEGIN_SUB", 0);
        define_instruction(inst_list, "END_SUB", 0);
        define_instruction(inst_list, "JUMP", 1);
        define_instruction(inst_list, "LOOP", 1);
        define_instruction(inst_list, "END_LOOP", 0);
        define_instruction(inst_list, "EXIT_LOOP", 0);
        define_instruction(inst_list, "IF", 3);
        define_instruction(inst_list, "ELSEIF", 3);
        define_instruction(inst_list, "ELSE", 0);
        define_instruction(inst_list, "END_IF", 0);
        define_instruction(inst_list, "WHILE", 3);
        define_instruction(inst_list, "END_WHILE", 0);
        define_instruction(inst_list, "TRACE_ON", 0);
        define_instruction(inst_list, "TRACE_OFF", 0);
        define_instruction(inst_list, "GENERATE_ON", 0);
        define_instruction(inst_list, "GENERATE_OFF", 0);
        define_instruction(inst_list, "SET_MESSAGELEVEL", 1);
        define_instruction(inst_list, "ABORT", 0);       -- Error exit from sim
        define_instruction(inst_list, "FINISH", 0);      -- Normal exit from sim
        define_instruction(inst_list, "INCLUDE", 1);     -- Define a Variable
        define_instruction(inst_list, "LABEL", 0);

        --  User defined instructions
        define_instruction(inst_list, "SET_RANDOMSEEDS", 2);
        define_instruction(inst_list, "GET_RANDOM", 3);
        define_instruction(inst_list, "MUL_VAR", 2);
        define_instruction(inst_list, "DIV_VAR", 2);
        define_instruction(inst_list, "AND_VAR", 2);
        define_instruction(inst_list, "OR_VAR", 2);
        define_instruction(inst_list, "XOR_VAR", 2);
        define_instruction(inst_list, "ERRORPRINT", 0);
        define_instruction(inst_list, "MESSAGE", 1);
        define_instruction(inst_list, "SET_EXIT_ON_VERIFY_ERROR", 1);
        define_instruction(inst_list, "SET_MARKER", 2);
        define_instruction(inst_list, "SET_SIG", 2);
        define_instruction(inst_list, "GET_SIG", 2);
        define_instruction(inst_list, "VERIFY_SIG", 4);
        define_instruction(inst_list, "WAIT_NS", 1);
        define_instruction(inst_list, "WRITE_RAM", 3);
        define_instruction(inst_list, "READ_RAM", 3);
        define_instruction(inst_list, "VERIFY_RAM", 5);
        define_instruction(inst_list, "WRITE_FPGA", 3);
        define_instruction(inst_list, "READ_FPGA", 3);
        define_instruction(inst_list, "VERIFY_FPGA", 5);

        ------------------------------------------------------------------------
        -- Read, test, and load the stimulus file
        read_instruction_file(stimulus_path, stimulus_file, inst_list, defined_vars, inst_sequ, file_list);

        -- initialize last info
        last_sequ_num  := 0;
        last_sequ_ptr  := inst_sequ;

        ------------------------------------------------------------------------
        -- Using the Instruction record list, get the instruction and implement
        -- it as per the statements in the elsif tree.
        while(v_line < inst_sequ.num_of_lines) loop

            v_line := v_line + 1;
            access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                             par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                             last_sequ_num, last_sequ_ptr);

            if (trc_on) then
                for i in 1 to file_name'LENGTH loop
                    trc_temp_str(i) := nul;
                end loop;
                for i in 1 to file_name'LENGTH loop
                    if (file_name(i) = nul) then
                        exit;
                    end if;
                    trc_temp_str(i) := file_name(i);
                end loop;
                report "EXEC Line " & (integer'image(file_line)) & " " & instruction(1 to len) & " File " & file_name;
            end if;

            --------------------------------------------------------------------------
            --if(instruction(1 to len) = "DEFINE_VAR" or inst(1 to l) = "DEFINE_CONST" ) then
            --  null;  -- This instruction was implemented while reading the file

            --------------------------------------------------------------------------
            if(instruction(1 to len) = "LABEL") then
                null;  -- Not used

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "INCLUDE") then
                null;  -- This instruction was implemented while reading the file

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "ABORT") then
                assert (false)
                report "The test has aborted due to an error!!"
                severity failure;

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "FINISH") then
                assert (false)
                report "Test Finished with NO errors!!"
                severity failure;

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "EQU_VAR") then
                update_variable(defined_vars, par1, par2, valid);

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "ADD_VAR" or instruction(1 to len) = "ADD_CONST") then
                index_variable(defined_vars, par1, temp_int, valid);
                if(valid /= 0) then
                    temp_int  :=  temp_int + par2;
                    update_variable(defined_vars, par1, temp_int, valid);
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & " ADD_VAR or ADD_CONST Error: Not a valid Variable/Constant??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "SUB_VAR") then
                index_variable(defined_vars, par1, temp_int, valid);
                if(valid /= 0) then
                    temp_int  :=  temp_int - par2;
                    update_variable(defined_vars, par1, temp_int, valid);
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & " SUB_VAR Error: Not a valid Variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "CALL") then
                if(stack_ptr >= 31) then
                   assert (false)
                   report " Line " & (integer'image(file_line)) & " Call Error: Stack over run, calls to deeply nested!!"
                   severity failure;
                end if;
                stack(stack_ptr)  :=  v_line;
                stack_ptr  :=  stack_ptr + 1;
                -- report " Line " & (integer'image(file_line)) & "CALL stack_ptr incremented to = " & integer'image(stack_ptr);
                v_line       :=  par1 - 1;

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "RETURN_CALL") then
                if(stack_ptr <= 0) then
                    assert (false)
                    report " Line " & (integer'image(file_line)) & " Call Error: Stack under run??"
                    severity failure;
                end if;
                stack_ptr  :=  stack_ptr - 1;
                -- report " Line " & (integer'image(file_line)) & "RETURN_CALL stack_ptr decremented to = " & integer'image(stack_ptr);
                v_line  :=  stack(stack_ptr);

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "RETURN_CALL_INTERRUPT") then
                if(stack_ptr <= 0) then
                    assert (false)
                    report " Line " & (integer'image(file_line)) & " Call Error: Stack under run??"
                    severity failure;
                end if;
                interrupt_in_service := false; -- no nested interrupts are supported!
                stack_ptr  :=  stack_ptr - 1;
                -- report " Line " & (integer'image(file_line)) & "RETURN_CALL stack_ptr decremented to = " & integer'image(stack_ptr);
                v_line  :=  stack(stack_ptr);

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "BEGIN_SUB") then
                -- Intentionally left blank!!!

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "END_SUB") then
                -- Intentionally left blank!!!

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "JUMP") then
                v_line    :=  par1 - 1;
                wh_state  :=  false;
                wh_stack  := (others => 0);
                wh_dpth   := 0;
                wh_ptr    := 0;
                stack     := (others => 0);
                stack_ptr := 0;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "LOOP") then
                loop_if_enter_level := if_level;
                loop_num := loop_num + 1;
                    loop_line(loop_num) := v_line;
                    curr_loop_count(loop_num) := 0;
                    term_loop_count(loop_num) := par1;
                if(messagelevel > 8) then
                    assert (false)
                        report " Line " & (integer'image(file_line)) &  " Executing LOOP Command" &
                                LF & "  Nested Loop:" & HT & integer'image(loop_num) &
                                LF & "  Loop Length:" & HT & integer'image(par1)
                        severity note;
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "END_LOOP") then
                curr_loop_count(loop_num) := curr_loop_count(loop_num) + 1;
                if (curr_loop_count(loop_num) = term_loop_count(loop_num)) then
                    loop_num := loop_num - 1;
                else
                    v_line := loop_line(loop_num);
                end if;

           --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "EXIT_LOOP") then
               loop_num := loop_num - 1;
               if_level := loop_if_enter_level;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "IF") then
                if_level  :=  if_level + 1;
                if(messagelevel > 8) then
                    assert (false)
                        report " Line " & (integer'image(file_line)) &  " Executing IF Command" &
                                LF & "  if_level incremented to " & HT & integer'image(if_level)
                        severity note;
                end if;
                if_state(if_level)  :=  false;
                case par2 is
                    when 0 => if(par1 = par3) then if_state(if_level)  :=  true; end if;
                    when 1 => if(par1 > par3) then if_state(if_level)  :=  true; end if;
                    when 2 => if(par1 < par3) then if_state(if_level)  :=  true; end if;
                    when 3 => if(par1 /= par3) then if_state(if_level) :=  true; end if;
                    when 4 => if(par1 >= par3) then if_state(if_level) :=  true; end if;
                    when 5 => if(par1 <= par3) then if_state(if_level) :=  true; end if;
                    when others =>
                        assert (false)
                        report " Line " & (integer'image(file_line)) & " ERROR:  IF instruction got an unexpected value" &
                             LF & "  in parameter 2!" & LF &
                              "Found on line " & (ew_to_str(file_line,dec)) & " in file " & file_name
                        severity failure;
                end case;

                if(if_state(if_level) = false) then
                    v_line := v_line + 1;
                    access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                        par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                        last_sequ_num, last_sequ_ptr);
                    NumOfIfInFalseIfLeave(if_level) := 0;
                    while(NumOfIfInFalseIfLeave(if_level) /= 0 or
                        (instruction(1 to len) /= "ELSE" and
                        instruction(1 to len) /= "ELSEIF" and
                        instruction(1 to len) /= "END_IF")) loop

                        if(instruction(1 to len) = "IF") then
                             NumOfIfInFalseIfLeave(if_level) := NumOfIfInFalseIfLeave(if_level) + 1;
                        end if;

                        if(instruction(1 to len) = "END_IF") then
                            NumOfIfInFalseIfLeave(if_level) := NumOfIfInFalseIfLeave(if_level) - 1;
                        end if;


                        if(v_line < inst_sequ.num_of_lines) then
                            v_line := v_line + 1;
                            access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                                par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                                last_sequ_num, last_sequ_ptr);
                        else
                            assert (false)
                            report " Line " & (integer'image(file_line)) & " ERROR:  IF instruction unable to find terminating" &
                            LF & "    ELSE, ELSEIF or END_IF statement."
                            severity failure;
                        end if;
                    end loop;
                 v_line := v_line - 1;  -- re-align so it will be operated on.
               end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "ELSEIF") then
                if(if_state(if_level) = true) then  -- if the if_state is true then skip to the end
                    v_line := v_line + 1;
                    access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                        par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                        last_sequ_num, last_sequ_ptr);
                    while(instruction(1 to len) /= "IF") and
                        instruction(1 to len) /= "END_IF" loop
                        if(v_line < inst_sequ.num_of_lines) then
                        v_line := v_line + 1;
                        access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                            par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                            last_sequ_num, last_sequ_ptr);
                        else
                            assert (false)
                            report " Line " & (integer'image(file_line)) & " ERROR:  IF instruction unable to find terminating" &
                                LF & "    ELSE, ELSEIF or END_IF statement."
                            severity failure;
                        end if;
                    end loop;
                    v_line := v_line - 1;  -- re-align so it will be operated on.

                else
                    case par2 is
                    when 0 => if(par1 = par3) then if_state(if_level)  :=  true; end if;
                    when 1 => if(par1 > par3) then if_state(if_level)  :=  true; end if;
                    when 2 => if(par1 < par3) then if_state(if_level)  :=  true; end if;
                    when 3 => if(par1 /= par3) then if_state(if_level) :=  true; end if;
                    when 4 => if(par1 >= par3) then if_state(if_level) :=  true; end if;
                    when 5 => if(par1 <= par3) then if_state(if_level) :=  true; end if;
                    when others =>
                        assert (false)
                        report " Line " & (integer'image(file_line)) & " ERROR:  ELSEIF instruction got an unexpected value" &
                            LF & "  in parameter 2!" & LF &
                                "Found on line " & (ew_to_str(file_line,dec)) & " in file " & file_name
                        severity failure;
                    end case;

                    if(if_state(if_level) = false) then
                        v_line := v_line + 1;
                        access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                            par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                            last_sequ_num, last_sequ_ptr);
                    NumOfIfInFalseIfLeave(if_level) := 0;
                    while(NumOfIfInFalseIfLeave(if_level) /= 0 or
                        (instruction(1 to len) /= "ELSE" and
                        instruction(1 to len) /= "ELSEIF" and
                        instruction(1 to len) /= "END_IF")) loop
                            if(instruction(1 to len) = "IF") then
                                 NumOfIfInFalseIfLeave(if_level) := NumOfIfInFalseIfLeave(if_level) + 1;
                            end if;
                            if(instruction(1 to len) = "END_IF") then
                                NumOfIfInFalseIfLeave(if_level) := NumOfIfInFalseIfLeave(if_level) - 1;
                            end if;
                            if(v_line < inst_sequ.num_of_lines) then
                                v_line := v_line + 1;
                                access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                                    par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                                    last_sequ_num, last_sequ_ptr);
                            else
                                assert (false)
                                report " Line " & (integer'image(file_line)) & " ERROR:  ELSEIF instruction unable to find terminating" &
                                    LF & "    ELSE, ELSEIF or END_IF statement."
                                severity failure;
                            end if;
                        end loop;
                        v_line := v_line - 1;  -- re-align so it will be operated on.
                    end if;
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "ELSE") then
                if(if_state(if_level) = true) then  -- if the if_state is true then skip the else
                    v_line := v_line + 1;
                    access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                        par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                        last_sequ_num, last_sequ_ptr);
                    while(instruction(1 to len) /= "IF") and
                          instruction(1 to len) /= "END_IF" loop
                        if(v_line < inst_sequ.num_of_lines) then
                            v_line := v_line + 1;
                            access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                                par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                                last_sequ_num, last_sequ_ptr);
                        else
                            assert (false)
                            report " Line " & (integer'image(file_line)) & " ERROR:  IF instruction unable to find terminating" &
                                    LF & "    ELSE, ELSEIF or END_IF statement."
                            severity failure;
                        end if;
                    end loop;
                    v_line := v_line - 1;  -- re-align so it will be operated on.
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "END_IF") then
                if_level := if_level - 1;
                if(messagelevel > 8) then
                    assert (false)
                        report " Line " & (integer'image(file_line)) &  " Executing END_IF Command" &
                                LF & "  if_level decremented to " & HT & integer'image(if_level)
                        severity note;
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "WHILE") then
                wh_state  :=  false;
                case par2 is
                    when 0 => if(par1 =  par3) then wh_state :=  true; end if;
                    when 1 => if(par1 >  par3) then wh_state :=  true; end if;
                    when 2 => if(par1 <  par3) then wh_state :=  true; end if;
                    when 3 => if(par1 /= par3) then wh_state :=  true; end if;
                    when 4 => if(par1 >= par3) then wh_state :=  true; end if;
                    when 5 => if(par1 <= par3) then wh_state :=  true; end if;
                    when others =>
                        assert (false)
                        report " Line " & (integer'image(file_line)) & " ERROR:  WHILE instruction got an unexpected value" &
                            LF & "  in parameter 2!" & LF &
                            "Found on line " & (ew_to_str(file_line,dec)) & " in file " & file_name
                        severity failure;
                end case;

                if(wh_state = true) then
                    wh_stack(wh_ptr) :=  v_line;
                    wh_ptr  := wh_ptr + 1;
                else
                    wh_end := false;
                    while(wh_end /= true) loop
                    if(v_line < inst_sequ.num_of_lines) then
                        v_line := v_line + 1;
                        access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                            par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                            last_sequ_num, last_sequ_ptr);
                    else
                        assert (false)
                        report " Line " & (integer'image(file_line)) & " ERROR:  WHILE instruction unable to find terminating" &
                                LF & "    END_WHILE statement."
                        severity failure;
                    end if;

                    -- if is a while need to escape it
                    if(instruction(1 to len) = "WHILE") then
                        wh_dpth := wh_dpth + 1;
                    -- if is the end_while we are looking for
                    elsif(instruction(1 to len) = "END_WHILE") then
                        if(wh_dpth = 0) then
                        wh_end := true;
                        else
                        wh_dpth := wh_dpth - 1;
                        end if;
                    end if;
                    end loop;
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "END_WHILE") then
                if(wh_ptr > 0) then
                    v_line  :=  wh_stack(wh_ptr - 1) - 1;
                    wh_ptr  := wh_ptr - 1;
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "TRACE_ON") then
                trc_on  :=  TRUE;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "TRACE_OFF") then
                trc_on  :=  FALSE;

             --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "GENERATE_ON") then
                -- Intentionally left blank!!!

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "GENERATE_OFF") then
                -- Intentionally left blank!!!

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "SET_MESSAGELEVEL") then
                messagelevel  := par1;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "SET_EXIT_ON_VERIFY_ERROR") then
                if (par1 = 1) then
                    exit_on_verify_error := TRUE;
                else
                    exit_on_verify_error := FALSE;
                end if;

            --------------------------------------------------------------------------------
            --------------------------------------------------------------------------------
            --  USER Istruction area.  Add all user instructions below this
            --------------------------------------------------------------------------------
            elsif(instruction(1 to len) = "SET_RANDOMSEEDS") then
                if(par1 > 0 and par2 > 0 ) then
                    temp_int := 0;
                    Seed1 := par1;
                    Seed2 := par2;
                    update_variable(defined_vars, par1, temp_int, valid);
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Seeds must allow only positive values"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
           elsif(instruction(1 to len) = "GET_RANDOM") then
                index_variable(defined_vars, par1, temp_int, valid);
                if(valid /= 0) then
                    temp_int := 0;
                    GetRandInt(Seed1, Seed2, par2, par3, temp_int);
                    update_variable(defined_vars, par1, temp_int, valid);
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Not a valid Variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "MUL_VAR") then
                index_variable(defined_vars, par1, temp_int, valid);
                if(valid /= 0) then
                    temp_int  :=  temp_int * par2;
                    update_variable(defined_vars, par1, temp_int, valid);
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Not a valid Variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "DIV_VAR") then
                index_variable(defined_vars, par1, temp_int, valid);
                if(valid /= 0) then
                    if(temp_int < 0) then
                        temp_stdvec_a := std_logic_vector(to_unsigned(temp_int,32));
                        temp_stdvec_c := not temp_stdvec_a;
                        temp_int := to_integer(unsigned(temp_stdvec_c));
                        temp_int := temp_int / par2;
                        temp_stdvec_a := std_logic_vector(to_unsigned((temp_int),32));
                        temp_stdvec_c := not temp_stdvec_a;
                        temp_int := to_integer(unsigned(temp_stdvec_c));
                    else
                        temp_int := temp_int / par2;
                    end if;

                    update_variable(defined_vars, par1, temp_int, valid);
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Not a valid Variable??"
                    severity failure;
                end if;

            elsif(instruction(1 to len) = "INV_VAR") then
                index_variable(defined_vars, par1, temp_int, valid);
                if(valid /= 0) then
                    temp_stdvec_a  :=  std_logic_vector(to_unsigned(temp_int,32));
                    temp_stdvec_c  :=  not temp_stdvec_a;
                    temp_int  :=   to_integer(unsigned(temp_stdvec_c));
                    update_variable(defined_vars, par1, temp_int, valid);
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Not a valid Variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "AND_VAR") then
                index_variable(defined_vars, par1, temp_int, valid);
                if(valid /= 0) then
                    temp_stdvec_a  :=  std_logic_vector(to_unsigned(temp_int,32));
                    temp_stdvec_b  :=  std_logic_vector(to_unsigned(par2,32));
                    temp_stdvec_c  :=  temp_stdvec_a and temp_stdvec_b;
                    temp_int  :=   to_integer(unsigned(temp_stdvec_c));
                    update_variable(defined_vars, par1, temp_int, valid);
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Not a valid Variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "OR_VAR") then
                index_variable(defined_vars, par1, temp_int, valid);
                if(valid /= 0) then
                    temp_stdvec_a  :=  std_logic_vector(to_unsigned(temp_int,32));
                    temp_stdvec_b  :=  std_logic_vector(to_unsigned(par2,32));
                    temp_stdvec_c  :=  temp_stdvec_a or temp_stdvec_b;
                    temp_int  :=   to_integer(unsigned(temp_stdvec_c));
                    update_variable(defined_vars, par1, temp_int, valid);
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Not a valid Variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif(instruction(1 to len) = "XOR_VAR") then
                index_variable(defined_vars, par1, temp_int, valid);
                if(valid /= 0) then
                    temp_stdvec_a  :=  std_logic_vector(to_unsigned(temp_int,32));
                    temp_stdvec_b  :=  std_logic_vector(to_unsigned(par2,32));
                    temp_stdvec_c  :=  temp_stdvec_a xor temp_stdvec_b;
                    temp_int  :=   to_integer(unsigned(temp_stdvec_c));
                    update_variable(defined_vars, par1, temp_int, valid);
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Not a valid Variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------------
            -- ERRORPRINT
            elsif(instruction(1 to len) = "ERRORPRINT") then
                txt_print_wvar(defined_vars, txt, hex);
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Stop with ERRORPRINT"
                    severity failure;

            --------------------------------------------------------------------------------
            -- MESSAGE
            elsif(instruction(1 to len) = "MESSAGE") then
                if (par1 <= messagelevel) then
                    txt_print_wvar(defined_vars, txt, hex);
                end if;
            --------------------------------------------------------------------------------
            --  WAIT_NS
            --  par1  ns value
            elsif (instruction(1 to len) = "WAIT_NS") then

                wait for par1 * 1 ns;

            --------------------------------------------------------------------------------
            --  SET_MARKER
            --  set value of a signal
            --  par1  0  marker number
            --  par2  1  marker value
            elsif (instruction(1 to len) = "SET_MARKER") then
                if(par1 < 16) then
                    for i in 0 to 15 loop
                        if (par1 = i) then
                            if (par2 = 0) then
                                tb_marker(i) <= '0';
                            else
                                tb_marker(i) <= '1';
                            end if;
                        end if;
                    end loop;
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": 16 markers are provided only"
                    severity failure;
                end if;

            --------------------------------------------------------------------------------
            --  SET_SIG
            --  set value of a signal
            --  par1  0  signal number
            --  par2  1  signal value
            elsif (instruction(1 to len) = "SET_SIG") then
                if (par1 = 0) then
                    if(par2 = 0) then
                        nRst <= '1';
                    else
                        nRst <= '0';
                    end if;
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Signal not defined"
                    severity failure;
                end if;
                wait for 0 ns;

          --------------------------------------------------------------------------------
            --  GET_SIG
            --  get value of a signal
            --  par1  0  signal number
            --  par2  1  signal value
            --  (par4  data read) expected data for verify
            --  (par5  data read) mask data for verify ( (and read data) and (and expected) data with mask before compare)

            elsif (instruction(1 to len) = "GET_SIG" or instruction(1 to len) = "VERIFY_SIG" ) then
                if (par1 = 1) then
                    -- Get Stack Size
                    FileIO_WasmFpgaBus.Adr <= x"000108";
                    FileIO_WasmFpgaBus.Sel <= x"F";
                    FileIO_WasmFpgaBus.Cyc <= "1";
                    FileIO_WasmFpgaBus.Stb <= '1';
                    FileIO_WasmFpgaBus.We <= '0';
                    wait until rising_edge(WasmFpgaBus_FileIO.Ack);
                    temp_int := to_integer(unsigned(WasmFpgaBus_FileIO.DatOut(31 downto 0)));
                    FileIO_WasmFpgaBus.Sel <= x"0";
                    FileIO_WasmFpgaBus.Cyc <= "0";
                    FileIO_WasmFpgaBus.Stb <= '0';
                    FileIO_WasmFpgaBus.We <= '0';
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Signal not defined"
                    severity failure;
                end if;

                update_variable(defined_vars, par2, temp_int, valid);
                if(valid = 0) then
                    assert (false)
                    report "GET_SIG Error: Not a valid Variable??"
                    severity failure;
                end if;

                if (instruction(1 to len) = "VERIFY_SIG") then
                    temp_stdvec_a  :=  std_logic_vector(to_unsigned(temp_int,32));
                    temp_stdvec_b  :=  std_logic_vector(to_unsigned(par3,32));
                    temp_stdvec_c  :=  std_logic_vector(to_unsigned(par4,32));

                    if (temp_stdvec_c and temp_stdvec_a) /= (temp_stdvec_c and temp_stdvec_b) then
                        assert (false)
                        report  " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ":"
                                & ", read=0x" & to_hstring(temp_stdvec_a) & ", expected=0x"
                                & to_hstring(temp_stdvec_b) & ", mask=0x" & to_hstring(temp_stdvec_c)
                                & " File " & file_name
                        severity failure;
                    end if;
                end if;
                wait for 0 ns;

            -- READ RAM
            elsif (instruction(1 to len) = "READ_RAM" or instruction(1 to len) = "VERIFY_RAM") then
                tempAddress <= std_logic_vector(to_unsigned(par2, tempAddress'LENGTH));
                wait for 0 ns;
                wait until Clk'event and Clk = '1';

                if (par1 = 0) then
                    --
                    -- Read from Module RAM using byte-addressing
                    --
                    FileIO_ModuleMemory.Adr <= "00" & tempAddress(23 downto 2);
                    FileIO_ModuleMemory.Sel <= x"F";
                    FileIO_ModuleMemory.Cyc <= "1";
                    FileIO_ModuleMemory.Stb <= '1';
                    FileIO_ModuleMemory.We <= '0';
                    wait until rising_edge(ModuleMemory_FileIO.Ack);
                    if (tempAddress(1 downto 0) = "00") then
                        temp_int := to_integer(unsigned(ModuleMemory_FileIO.DatOut(7 downto 0)));
                    elsif (tempAddress(1 downto 0) = "01") then
                        temp_int := to_integer(unsigned(ModuleMemory_FileIO.DatOut(15 downto 8)));
                    elsif (tempAddress(1 downto 0) = "10") then
                        temp_int := to_integer(unsigned(ModuleMemory_FileIO.DatOut(23 downto 16)));
                    else
                        temp_int := to_integer(unsigned(ModuleMemory_FileIO.DatOut(31 downto 24)));
                    end if;
                    FileIO_ModuleMemory.Sel <= x"0";
                    FileIO_ModuleMemory.Cyc <= "0";
                    FileIO_ModuleMemory.Stb <= '0';
                    FileIO_ModuleMemory.We <= '0';
                    wait until Clk'event and Clk = '1';
                elsif (par1 = 1) then
                    --
                    -- Read from Store 4 byte-wise
                    --
                    FileIO_StoreMemory.Adr <= std_logic_vector(to_unsigned(par2, FileIO_StoreMemory.Adr'LENGTH));
                    FileIO_StoreMemory.Sel <= x"F";
                    FileIO_StoreMemory.Cyc <= "1";
                    FileIO_StoreMemory.Stb <= '1';
                    FileIO_StoreMemory.We <= '0';
                    wait until rising_edge(StoreMemory_FileIO.Ack);
                    temp_int := to_integer(unsigned(StoreMemory_FileIO.DatOut(31 downto 0)));
                    FileIO_StoreMemory.Sel <= x"0";
                    FileIO_StoreMemory.Cyc <= "0";
                    FileIO_StoreMemory.Stb <= '0';
                    FileIO_StoreMemory.We <= '0';
                elsif (par1 = 2) then
                    --
                    -- Read from Stack 4 byte-wise
                    --
                    FileIO_StackMemory.Adr <= std_logic_vector(to_unsigned(par2, FileIO_StackMemory.Adr'LENGTH));
                    FileIO_StackMemory.Sel <= x"F";
                    FileIO_StackMemory.Cyc <= "1";
                    FileIO_StackMemory.Stb <= '1';
                    FileIO_StackMemory.We <= '0';
                    wait until rising_edge(StackMemory_FileIO.Ack);
                    temp_int := to_integer(unsigned(StackMemory_FileIO.DatOut(31 downto 0)));
                    FileIO_StackMemory.Sel <= x"0";
                    FileIO_StackMemory.Cyc <= "0";
                    FileIO_StackMemory.Stb <= '0';
                    FileIO_StackMemory.We <= '0';
                elsif (par1 = 3) then
                    --
                    -- Read from Memory 4 byte-wise
                    --
                    FileIO_Memory.Adr <= std_logic_vector(to_unsigned(par2, FileIO_Memory.Adr'LENGTH));
                    FileIO_Memory.Sel <= x"F";
                    FileIO_Memory.Cyc <= "1";
                    FileIO_Memory.Stb <= '1';
                    FileIO_Memory.We <= '0';
                    wait until rising_edge(Memory_FileIO.Ack);
                    temp_int := to_integer(unsigned(Memory_FileIO.DatOut(31 downto 0)));
                    FileIO_Memory.Sel <= x"0";
                    FileIO_Memory.Cyc <= "0";
                    FileIO_Memory.Stb <= '0';
                    FileIO_Memory.We <= '0';
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": wrong data width or unaligned address."
                    severity failure;
                end if;

                update_variable(defined_vars, par3, temp_int, valid);

                if(valid = 0) then
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Not a valid Variable??"
                    severity failure;
                end if;

                if (instruction(1 to len) = "VERIFY_RAM") then
                    temp_stdvec_a  :=  std_logic_vector(to_unsigned(temp_int,32));
                    temp_stdvec_b  :=  std_logic_vector(to_unsigned(par4,32));
                    temp_stdvec_c  :=  std_logic_vector(to_unsigned(par5,32));

                    if (temp_stdvec_c and temp_stdvec_a) /= (temp_stdvec_c and temp_stdvec_b) then
                        assert (false)
                        report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ":"
                             & " address=0x" & to_hstring(tempAddress)
                             & ", read=0x" & to_hstring(temp_stdvec_a)
                             & ", expected=0x" & to_hstring(temp_stdvec_b)
                             & ", mask=0x" & to_hstring(temp_stdvec_c)
                        severity failure;
                    end if;
                end if;
                wait for 0 ns;

            -- WRITE_RAM
            elsif (instruction(1 to len) = "WRITE_RAM" ) then
                tempAddress <= std_logic_vector(to_unsigned(par2, tempAddress'LENGTH));
                wait for 0 ns;

                if (par1 = 0) then
                    -- Write to Module RAM byte-wise (needs to do a read-modify-write)
                    --
                    -- Read from Module RAM
                    FileIO_ModuleMemory.Adr <= "00" & tempAddress(23 downto 2);
                    FileIO_ModuleMemory.Sel <= x"F";
                    FileIO_ModuleMemory.Cyc <= "1";
                    FileIO_ModuleMemory.Stb <= '1';
                    FileIO_ModuleMemory.We <= '0';
                    wait until rising_edge(ModuleMemory_FileIO.Ack);
                    tempValue <= ModuleMemory_FileIO.DatOut;
                    FileIO_ModuleMemory.Sel <= x"0";
                    FileIO_ModuleMemory.Cyc <= "0";
                    FileIO_ModuleMemory.Stb <= '0';
                    FileIO_ModuleMemory.We <= '0';
                    wait until Clk'event and Clk = '1';
                    -- Modify value
                    if (tempAddress(1 downto 0) = "00") then
                        FileIO_ModuleMemory.DatIn <= tempValue(31 downto 8) & std_logic_vector(to_unsigned(par3, 8));
                    elsif (tempAddress(1 downto 0) = "01") then
                        FileIO_ModuleMemory.DatIn <= tempValue(31 downto 16) & std_logic_vector(to_unsigned(par3, 8)) & tempValue(7 downto 0);
                    elsif (tempAddress(1 downto 0) = "10") then
                        FileIO_ModuleMemory.DatIn <= tempValue(31 downto 24) & std_logic_vector(to_unsigned(par3, 8)) & tempValue(15 downto 0);
                    else
                        FileIO_ModuleMemory.DatIn <= std_logic_vector(to_unsigned(par3, 8)) & tempValue(23 downto 0);
                    end if;
                    wait until Clk'event and Clk = '1';
                    -- Write to Module RAM
                    FileIO_ModuleMemory.Adr <= "00" & tempAddress(23 downto 2);
                    FileIO_ModuleMemory.Sel <= x"F";
                    FileIO_ModuleMemory.Cyc <= "1";
                    FileIO_ModuleMemory.Stb <= '1';
                    FileIO_ModuleMemory.We <= '1';
                    wait until rising_edge(ModuleMemory_FileIO.Ack);
                    FileIO_ModuleMemory.Sel <= x"0";
                    FileIO_ModuleMemory.Cyc <= "0";
                    FileIO_ModuleMemory.Stb <= '0';
                    FileIO_ModuleMemory.We <= '0';
                elsif(par1 = 1) then
                    -- Write to Store (4 byte-wise)
                    FileIO_StoreMemory.DatIn <= std_logic_vector(to_unsigned(par3, FileIO_StoreMemory.DatIn'LENGTH));
                    FileIO_StoreMemory.Adr <= std_logic_vector(to_unsigned(par2, FileIO_StoreMemory.Adr'LENGTH));
                    FileIO_StoreMemory.Sel <= x"F";
                    FileIO_StoreMemory.Cyc <= "1";
                    FileIO_StoreMemory.Stb <= '1';
                    FileIO_StoreMemory.We <= '1';
                    wait until rising_edge(StoreMemory_FileIO.Ack);
                    FileIO_StoreMemory.Sel <= x"0";
                    FileIO_StoreMemory.Cyc <= "0";
                    FileIO_StoreMemory.Stb <= '0';
                    FileIO_StoreMemory.We <= '0';
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": wrong data width or unaligned address."
                    severity failure;
                end if;

            -- WRITE_FPGA
            elsif (instruction(1 to len) = "WRITE_FPGA" ) then
                tempAddress <= std_logic_vector(to_unsigned(par2, tempAddress'LENGTH));
                wait for 0 ns;
                wait until Clk'event and Clk = '1';

                if (par1 = 32) then
                    wb_data_write  <= std_logic_vector(to_unsigned(par3, wb_data_write'LENGTH));
                    wb_address <= tempAddress;
                    wb_byte_enable <= "1111";
                    wb_write_start <= '1';
                    wait until rising_edge(wb_write_read_end);
                    wb_write_start <= '0';
                    wait for 0 ns;
                    wait until Clk'event and Clk = '1';
                elsif (par1 = 16) then
                    if (tempAddress(1) = '1') then
                        wb_data_write <= std_logic_vector(to_unsigned(par3, 16) & x"0000");
                    elsif (tempAddress(1) = '0') then
                        wb_data_write  <= x"0000" & std_logic_vector(to_unsigned(par3, 16));
                    end if;
                    wb_address <= tempAddress;
                    wb_byte_enable <= "1111";
                    wb_write_start <= '1';
                    wait until rising_edge(wb_write_read_end);
                    wb_write_start <= '0';
                    wait for 0 ns;
                    wait until Clk'event and Clk = '1';
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": wrong data width or unaligned address."
                    severity failure;
                end if;

            -- READ FPGA
            elsif (instruction(1 to len) = "READ_FPGA" or instruction(1 to len) = "VERIFY_FPGA") then
                tempAddress <= std_logic_vector(to_unsigned(par2, tempAddress'LENGTH));
                wait for 0 ns;
                wait until Clk'event and Clk = '1';

                if (par1 = 32) then
                    wb_address <= tempAddress;
                    wb_byte_enable <= "1111";
                    wb_read_start <= '1';
                    wait until rising_edge(wb_write_read_end);
                    temp_int := to_integer(unsigned(wb_data_read));
                    wb_read_start <= '0';
                    wait for 0 ns;
                    wait until Clk'event and Clk = '1';
                elsif (par1 = 16) then
                    wb_address <= tempAddress;
                    wb_byte_enable <= "1111";
                    wb_read_start <= '1';
                    wait until rising_edge(wb_write_read_end);
                    if (tempAddress(1) = '1') then
                        temp_int := to_integer(unsigned(wb_data_read(31 downto 16)));
                    elsif (tempAddress(1) = '0') then
                        temp_int := to_integer(unsigned(wb_data_read(15 downto 0)));
                    end if;
                    wb_read_start <= '0';
                    wait for 0 ns;
                    wait until Clk'event and Clk = '1';
                else
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": wrong data width or unaligned address."
                    severity failure;
                end if;

                update_variable(defined_vars, par3, temp_int, valid);

                if(valid = 0) then
                    assert (false)
                    report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": Not a valid Variable??"
                    severity failure;
                end if;

                if (instruction(1 to len) = "VERIFY_FPGA") then
                    temp_stdvec_a  :=  std_logic_vector(to_unsigned(temp_int,32));
                    temp_stdvec_b  :=  std_logic_vector(to_unsigned(par4,32));
                    temp_stdvec_c  :=  std_logic_vector(to_unsigned(par5,32));

                    if (temp_stdvec_c and temp_stdvec_a) /= (temp_stdvec_c and temp_stdvec_b) then
                        assert (false)
                        report " Line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ":"
                             & " address=0x" & to_hstring(tempAddress)
                             & ", read=0x" & to_hstring(temp_stdvec_a)
                             & ", expected=0x" & to_hstring(temp_stdvec_b)
                             & ", mask=0x" & to_hstring(temp_stdvec_c)
                        severity failure;
                    end if;
                end if;
                wait for 0 ns;

            --------------------------------------------------------------------------------
            --  USER Istruction area.  Add all user instructions above this
            --------------------------------------------------------------------------------
                --------------------------------------------------------------------------
                -- catch those little mistakes
            else
                assert (false)
                report " Line " & (integer'image(file_line)) & " ERROR:  Seems the command  " & ", " & instruction(1 to len) & " was defined but" & LF &
                                "was not found in the elsif chain, please check spelling."
                severity failure;
            end if;  -- else if structure end

            -- after the instruction is finished print out any txt and sub vars
            -- txt_print_wvar(defined_vars, txt, hex);

        end loop;  -- Main Loop end

        assert (false)
        report LF & "The end of the simulation! It was not terminated as expected." & LF
        severity failure;

    end process;
end;
