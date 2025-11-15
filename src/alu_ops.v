`define ALU_CTRL_ADD		8'b00000000 // y = a + b
`define ALU_CTRL_SUB		8'b10000010 // y = a - b
`define ALU_CTRL_SUB2		8'b10001000 // y = b - a

`define ALU_CTRL_AND		8'b00010000 // y = a & b
`define ALU_CTRL_OR		8'b10011010 // y = a | b
`define ALU_CTRL_XOR		8'b00100000 // y = a ^ b

`define ALU_CTRL_LSFT		8'b01000001 // y = a << b
`define ALU_CTRL_RSFT		8'b01000010 // y = a >> b
`define ALU_CTRL_RSFTA		8'b01000011 // y = a >>> b

`define ALU_CTRL_LESS_SIGN	8'b01010000 // y = (signed) a < b
// `define ALU_CTRL_GRTEQ_SIGN	8'b01010001 // y = (signed) a >= b

`define ALU_CTRL_LESS		8'b01010010 // y = a < b
// `define ALU_CTRL_GRTEQ		8'b01010011 // y = a >= b

// `define ALU_CTRL_EQ		8'b01010100 // y = a == b
// `define ALU_CTRL_NEQ		8'b01010101 // y = a != b

`define ALU_CTRL_B		8'b00000001 // y = b
`define ALU_CTRL_A		8'b00000100 // y = a
