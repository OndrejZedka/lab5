-- Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus II License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 15.0.0 Build 145 04/22/2015 SJ Web Edition"
-- CREATED		"Sat Jan 30 11:41:35 2016"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY CPU IS 
	PORT
	(
		reset_n :  IN  STD_LOGIC;
		clk :  IN  STD_LOGIC;
		irq :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		rddata :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		write :  OUT  STD_LOGIC;
		read :  OUT  STD_LOGIC;
		address :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		wrdata :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END CPU;

ARCHITECTURE bdf_type OF CPU IS 

COMPONENT alu
	PORT(a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 op : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 s : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT control_registers
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 write_n : IN STD_LOGIC;
		 backup_n : IN STD_LOGIC;
		 restore_n : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 irq : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wrdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ipending : OUT STD_LOGIC;
		 rddata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT controller
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 ipending : IN STD_LOGIC;
		 op : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 opx : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 branch_op : OUT STD_LOGIC;
		 imm_signed : OUT STD_LOGIC;
		 ir_en : OUT STD_LOGIC;
		 pc_add_imm : OUT STD_LOGIC;
		 pc_en : OUT STD_LOGIC;
		 pc_sel_a : OUT STD_LOGIC;
		 pc_sel_imm : OUT STD_LOGIC;
		 rf_wren : OUT STD_LOGIC;
		 sel_addr : OUT STD_LOGIC;
		 sel_b : OUT STD_LOGIC;
		 sel_mem : OUT STD_LOGIC;
		 sel_pc : OUT STD_LOGIC;
		 sel_ra : OUT STD_LOGIC;
		 sel_rC : OUT STD_LOGIC;
		 write : OUT STD_LOGIC;
		 pc_sel_ih : OUT STD_LOGIC;
		 ctl_backup_n : OUT STD_LOGIC;
		 ctl_restore_n : OUT STD_LOGIC;
		 ctl_write_n : OUT STD_LOGIC;
		 sel_ctl : OUT STD_LOGIC;
		 read : OUT STD_LOGIC;
		 op_alu : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		 rf_retaddr : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT extend
	PORT(signed : IN STD_LOGIC;
		 imm16 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 imm32 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ir
	PORT(clk : IN STD_LOGIC;
		 enable : IN STD_LOGIC;
		 D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux2x16
	PORT(sel : IN STD_LOGIC;
		 i0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 i1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux2x5
	PORT(sel : IN STD_LOGIC;
		 i0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 o : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux2x32
	PORT(sel : IN STD_LOGIC;
		 i0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 en : IN STD_LOGIC;
		 sel_a : IN STD_LOGIC;
		 sel_imm : IN STD_LOGIC;
		 add_imm : IN STD_LOGIC;
		 sel_ihandler : IN STD_LOGIC;
		 a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT register_file
	PORT(clk : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 aa : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ab : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 aw : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 wrdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 a : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 b : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	a :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	alu_res :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	aw :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	b :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	branch_op :  STD_LOGIC;
SIGNAL	branch_taken :  STD_LOGIC;
SIGNAL	ctl_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	imm :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	imm_signed :  STD_LOGIC;
SIGNAL	instr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ipending :  STD_LOGIC;
SIGNAL	ir_en :  STD_LOGIC;
SIGNAL	irq_backup :  STD_LOGIC;
SIGNAL	irq_restore :  STD_LOGIC;
SIGNAL	irq_write :  STD_LOGIC;
SIGNAL	op_alu :  STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL	op_b :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	pc_add_imm :  STD_LOGIC;
SIGNAL	pc_addr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	pc_en :  STD_LOGIC;
SIGNAL	pc_sel_a :  STD_LOGIC;
SIGNAL	pc_sel_ihandler :  STD_LOGIC;
SIGNAL	pc_sel_imm :  STD_LOGIC;
SIGNAL	pc_wren :  STD_LOGIC;
SIGNAL	rf_retaddr :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	rf_wren :  STD_LOGIC;
SIGNAL	sel_addr :  STD_LOGIC;
SIGNAL	sel_b :  STD_LOGIC;
SIGNAL	sel_ctl :  STD_LOGIC;
SIGNAL	sel_mem :  STD_LOGIC;
SIGNAL	sel_pc :  STD_LOGIC;
SIGNAL	sel_ra :  STD_LOGIC;
SIGNAL	sel_rC :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);


BEGIN 



b2v_alu_0 : alu
PORT MAP(a => a,
		 b => op_b,
		 op => op_alu,
		 s => alu_res);


branch_taken <= branch_op AND alu_res(0);


b2v_control_registers_0 : control_registers
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 write_n => irq_write,
		 backup_n => irq_backup,
		 restore_n => irq_restore,
		 address => instr(8 DOWNTO 6),
		 irq => irq,
		 wrdata => a,
		 ipending => ipending,
		 rddata => ctl_data);


b2v_controller_0 : controller
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 ipending => ipending,
		 op => instr(5 DOWNTO 0),
		 opx => instr(16 DOWNTO 11),
		 branch_op => branch_op,
		 imm_signed => imm_signed,
		 ir_en => ir_en,
		 pc_add_imm => pc_add_imm,
		 pc_en => pc_wren,
		 pc_sel_a => pc_sel_a,
		 pc_sel_imm => pc_sel_imm,
		 rf_wren => rf_wren,
		 sel_addr => sel_addr,
		 sel_b => sel_b,
		 sel_mem => sel_mem,
		 sel_pc => sel_pc,
		 sel_ra => sel_ra,
		 sel_rC => sel_rC,
		 write => write,
		 pc_sel_ih => pc_sel_ihandler,
		 ctl_backup_n => irq_backup,
		 ctl_restore_n => irq_restore,
		 ctl_write_n => irq_write,
		 sel_ctl => sel_ctl,
		 read => read,
		 op_alu => op_alu,
		 rf_retaddr => rf_retaddr);


b2v_extend_0 : extend
PORT MAP(signed => imm_signed,
		 imm16 => instr(21 DOWNTO 6),
		 imm32 => imm);


b2v_IR_0 : ir
PORT MAP(clk => clk,
		 enable => ir_en,
		 D => rddata,
		 Q => instr);


b2v_mux_addr : mux2x16
PORT MAP(sel => sel_addr,
		 i0 => pc_addr(15 DOWNTO 0),
		 i1 => alu_res(15 DOWNTO 0),
		 o => address);


b2v_mux_aw : mux2x5
PORT MAP(sel => sel_rC,
		 i0 => instr(26 DOWNTO 22),
		 i1 => instr(21 DOWNTO 17),
		 o => SYNTHESIZED_WIRE_3);


b2v_mux_b : mux2x32
PORT MAP(sel => sel_b,
		 i0 => imm,
		 i1 => b,
		 o => op_b);


b2v_mux_ctl : mux2x32
PORT MAP(sel => sel_ctl,
		 i0 => alu_res,
		 i1 => ctl_data,
		 o => SYNTHESIZED_WIRE_1);


b2v_mux_data : mux2x32
PORT MAP(sel => SYNTHESIZED_WIRE_0,
		 i0 => SYNTHESIZED_WIRE_1,
		 i1 => SYNTHESIZED_WIRE_2,
		 o => SYNTHESIZED_WIRE_4);


b2v_mux_mem : mux2x32
PORT MAP(sel => sel_mem,
		 i0 => pc_addr,
		 i1 => rddata,
		 o => SYNTHESIZED_WIRE_2);


b2v_mux_ra : mux2x5
PORT MAP(sel => sel_ra,
		 i0 => SYNTHESIZED_WIRE_3,
		 i1 => rf_retaddr,
		 o => aw);


pc_en <= pc_wren OR branch_taken;


b2v_PC_0 : pc
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 en => pc_en,
		 sel_a => pc_sel_a,
		 sel_imm => pc_sel_imm,
		 add_imm => pc_add_imm,
		 sel_ihandler => pc_sel_ihandler,
		 a => a(15 DOWNTO 0),
		 imm => instr(21 DOWNTO 6),
		 addr => pc_addr);


SYNTHESIZED_WIRE_0 <= sel_pc OR sel_mem;


b2v_register_file_0 : register_file
PORT MAP(clk => clk,
		 wren => rf_wren,
		 aa => instr(31 DOWNTO 27),
		 ab => instr(26 DOWNTO 22),
		 aw => aw,
		 wrdata => SYNTHESIZED_WIRE_4,
		 a => a,
		 b => b);

wrdata <= b;

END bdf_type;