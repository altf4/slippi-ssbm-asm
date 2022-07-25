################################################################################
# Address: 0x801a4fa4
################################################################################

################################################################################
# Routine: SendMenuFrame
# ------------------------------------------------------------------------------
# Description: Gets menu information and sends it to the Slippi device
################################################################################

.include "Common/Common.s"
.include "Recording/Recording.s"

.set PAYLOAD_LEN, 0x49
.set EXI_BUF_LEN, PAYLOAD_LEN + 1 + 64

# .set STACK_FREE_SPACE, EXI_BUF_LEN + 0x20 # Add 0x20 to deal with byte alignment
.set STACK_FREE_SPACE, EXI_BUF_LEN + 64 # Add 64 to deal with byte alignment

.set STACK_OFST_EXI_BUF, BKP_FREE_SPACE_OFFSET

backup STACK_FREE_SPACE

# Allocate ourselves a buffer
li  r3, EXI_BUF_LEN
branchl r12,HSD_MemAlloc
mr r31, r3

# check if NOT VS Mode
getMinorMajor r8
cmpwi r8, 0x0202
beq Injection_Exit
cmpwi r8, 0x0208
beq Injection_Exit

# addi r31, sp, STACK_OFST_EXI_BUF # This is the start address for the free space
# byteAlign32 r31, r31

li r4, CMD_MENU_FRAME # Command byte
stb r4, 0x0(r31)

# Two bytes for major / minor scene
sth r8, 0x1(r31)

# send player 1 cursor x position
# Each player has a heap-allocated struct, make sure the ptr is not NULL before reading

load r4, CSS_CURSOR_STRUCT_PTR_P1
lwz r4, 0(r4)
cmpwi r4, 0
bne SendP1Cursor

# set cursor values to 0
load r5, 0x00000000
stw r5, 0x3(r31)
stw r5, 0x7(r31)
b P2_Cursor

SendP1Cursor:
# Load cursor x position
lwz r5, 0x0c(r4)
stw r5, 0x3(r31)
# Load cursor y position
lwz r5, 0x10(r4)
stw r5, 0x7(r31)

P2_Cursor:
load r4, CSS_CURSOR_STRUCT_PTR_P2
lwz r4, 0(r4)
cmpwi r4, 0
bne SendP2Cursor

# set cursor values to 0
load r5, 0x00000000
stw r5, 0xB(r31)
stw r5, 0xF(r31)
b P3_Cursor

SendP2Cursor:
# Load cursor x position
lwz r5, 0x0c(r4)
stw r5, 0xB(r31)
# Load cursor y position
lwz r5, 0x10(r4)
stw r5, 0xF(r31)

P3_Cursor:
load r4, CSS_CURSOR_STRUCT_PTR_P3
lwz r4, 0(r4)
cmpwi r4, 0
bne SendP3Cursor

# set p1 cursor values to 0
load r5, 0x00000000
stw r5, 0x13(r31)
stw r5, 0x17(r31)
b P4_Cursor

SendP3Cursor:
# Load cursor x position
lwz r5, 0x0c(r4)
stw r5, 0x13(r31)
# Load cursor y position
lwz r5, 0x10(r4)
stw r5, 0x17(r31)

P4_Cursor:
load r4, CSS_CURSOR_STRUCT_PTR_P4
lwz r4, 0(r4)
cmpwi r4, 0
bne SendP4Cursor

# set p1 cursor values to 0
load r5, 0x00000000
stw r5, 0x1B(r31)
stw r5, 0x1F(r31)
b CURSORS_DONE

SendP4Cursor:
# Load cursor x position
lwz r5, 0x0c(r4)
stw r5, 0x1B(r31)
# Load cursor y position
lwz r5, 0x10(r4)
stw r5, 0x1F(r31)

CURSORS_DONE:

# Ready to fight banner visible (one byte)
# banner "swoops in" frame by frame
#   value of 10 is fully invisible (not ready to play)
#   value of 0 is fully visible (ready to play)
load r4 0x804d6cf2
lbz r4, 0(r4)
stb r4, 0x23(r31)

# Stage selected (one byte)
load r4 0x804D6CAD
lbz r4, 0(r4)
stb r4, 0x24(r31)

# controller port statuses at CSS (each one byte)
# 0 == Human
# 1 == CPU
# 3 == Off
# Player 1
load r4 0x803F0E08
lbz r4, 0(r4)
stb r4, 0x25(r31)
# Player 2
load r4 0x803F0E2C
lbz r4, 0(r4)
stb r4, 0x26(r31)
# Player 3
load r4 0x803F0E50
lbz r4, 0(r4)
stb r4, 0x27(r31)
# Player 4
load r4 0x803F0E74
lbz r4, 0(r4)
stb r4, 0x28(r31)

# Character selected (each one byte)
# Player 1
load r4 0x803F0E0A
lbz r4, 0(r4)
stb r4, 0x29(r31)
# Player 2
load r4 0x803F0E2E
lbz r4, 0(r4)
stb r4, 0x2A(r31)
# Player 3
load r4 0x803F0E52
lbz r4, 0(r4)
stb r4, 0x2B(r31)
# Player 4
load r4 0x803F0E76
lbz r4, 0(r4)
stb r4, 0x2C(r31)

# Coin down
# 0 == No coin
# 1 == Coin in hand
# 2 == Coin down
# 3 == Not plugged in

# Reading this value involves needing to follow a dynamic pointer
# This can segfault when not in the right scene
# So just return 0's when not in there and don't follow the pointers

# Load 0's into player coins
load r4 0x00000000
stw r4, 0x2D(r31)

cmpwi r8, 0x0002
bne Not_CSS

# Player 1
load r4 0x804a0bc0
lwz r4, 0(r4)
addi r4, r4, 5
lbz r4, 0(r4)
stb r4, 0x2D(r31)
# Player 2
load r4 0x804a0bc4
lwz r4, 0(r4)
addi r4, r4, 5
lbz r4, 0(r4)
stb r4, 0x2E(r31)
# Player 3
load r4 0x804a0bc8
lwz r4, 0(r4)
addi r4, r4, 5
lbz r4, 0(r4)
stb r4, 0x2F(r31)
# Player 4
load r4 0x804a0bcc
lwz r4, 0(r4)
addi r4, r4, 5
lbz r4, 0(r4)
stb r4, 0x30(r31)

Not_CSS:

# Reading this value involves needing to follow a dynamic pointer
# This can segfault when not in the right scene
# So just return 0's when not in there and don't follow the pointers

# Load 0's into cursors
load r4 0x00000000
stw r4, 0x31(r31)
load r4 0x00000000
stw r4, 0x35(r31)

# 0x0102 is offline SSS
# 0x0108 is online SSS
cmpwi r8, 0x0102
beq Is_SSS
cmpwi r8, 0x0108
beq Is_SSS
b Not_SSS

Is_SSS:

# Stage Select Cursor X
# 4-byte float
load r4 0x804D7820
lwz r4, 0(r4)
addi r4, r4, 0x10
lwz r4, 0(r4)
addi r4, r4, 0x28
lwz r4, 0(r4)
addi r4, r4, 0x38
lwz r4, 0(r4)
stw r4, 0x31(r31)

# Stage Select Cursor y
# 4-byte float
load r4 0x804D7820
lwz r4, 0(r4)
addi r4, r4, 0x10
lwz r4, 0(r4)
addi r4, r4, 0x28
lwz r4, 0(r4)
addi r4, r4, 0x3C
lwz r4, 0(r4)
stw r4, 0x35(r31)

Not_SSS:

# Frame count
load r4 0x80479D60
lwz r4, 0(r4)
stw r4, 0x39(r31)

# Sub-menu
load r4 0x804A04F0
lbz r4, 0(r4)
stb r4, 0x3D(r31)

# Menu selection index
load r4 0x804A04F3
lbz r4, 0(r4)
stb r4, 0x3E(r31)

# Online character costume
load r4 0x803F0E09
lbz r4, 0(r4)
stb r4, 0x3F(r31)

# Is in nametag entry? 0x5 for true
load r4 0x804d6cf6
lbz r4, 0(r4)
stb r4, 0x40(r31)

# CPU Level for all 4 players
load r4 0x8048082F
lbz r4, 0(r4)
stb r4, 0x41(r31)
load r4 0x80480853
lbz r4, 0(r4)
stb r4, 0x42(r31)
load r4 0x80480877
lbz r4, 0(r4)
stb r4, 0x43(r31)
load r4 0x8048089B
lbz r4, 0(r4)
stb r4, 0x44(r31)

# Is Holding CPU Slider for all 4 players
load r4 0x803F0E0E
lbz r4, 0(r4)
stb r4, 0x45(r31)
load r4 0x803F0E32
lbz r4, 0(r4)
stb r4, 0x46(r31)
load r4 0x803F0E56
lbz r4, 0(r4)
stb r4, 0x47(r31)
load r4 0x803F0E7A
lbz r4, 0(r4)
stb r4, 0x48(r31)

#------------- Transfer Buffer ------------
mr r3, r31
li r4, EXI_BUF_LEN
li r5, CONST_ExiWrite
branchl r12, FN_EXITransferBuffer

Injection_Exit:

mr r3, r31
branchl r12, HSD_Free

restore STACK_FREE_SPACE
lwz r3, 0(r25) # replaced code line
