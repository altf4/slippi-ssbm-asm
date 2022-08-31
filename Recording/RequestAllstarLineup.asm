################################################################################
# Address: 801b6000
################################################################################

.include "Common/Common.s"
.include "Playback/Playback.s"
.include "TASBot.s"

.set REG_MajorData, 31
.set REG_Buffer, 30

backup

# alloc temp buffer
  li r3, GET_ALLSTAR_BUFSIZE    # this is larger, using this to alloc the buffer
  branchl r0, HSD_MemAlloc
  mr REG_Buffer, r3

# statically simulate the results of the EXI transaction(s)
  load r3,0xc88f4f11
  stw r3,0x0(REG_Buffer)
  load r3,0xc009c205
  stw r3,0x4(REG_Buffer)
  load r3,0xb604b511
  stw r3,0x8(REG_Buffer)
  load r3,0xbe0cbe0a
  stw r3,0xc(REG_Buffer)
  load r3,0xc919c907
  stw r3,0x10(REG_Buffer)
  load r3,0xc316c30f
  stw r3,0x14(REG_Buffer)
  load r3,0xbb0bbb12
  stw r3,0x18(REG_Buffer)
  load r3,0xc415c417
  stw r3,0x1c(REG_Buffer)
  load r3,0xc414c618
  stw r3,0x20(REG_Buffer)
  load r3,0xc600c606
  stw r3,0x24(REG_Buffer)
  load r3,0xb108b102
  stw r3,0x28(REG_Buffer)
  load r3,0xb10dbd0e
  stw r3,0x2c(REG_Buffer)
  load r3,0xbd10bd01
  stw r3,0x30(REG_Buffer)

RestoreRNG:
# update RNG seed
  lwz	r3, -0x570C (r13)
  lwz r0, GET_ALLSTAR_RNG_OFFSET (REG_Buffer)
  stw r0,0x0(r3)

SetOrder:
.set REG_Loop, 12
.set REG_GameOrder, 11
.set REG_BufferOrder, 10
  li REG_Loop, 0
  load REG_GameOrder, 0x803debe8
  addi REG_BufferOrder, REG_Buffer, GET_ALLSTAR_STAGE_OFFSET
SetOrder_Loop:
# stage
  lbz r3,0x0(REG_BufferOrder)
  stb r3,0x2(REG_GameOrder)
# ckind
  lbz r3,0x1(REG_BufferOrder)
  stb r3,0x3(REG_GameOrder)
SetOrder_LoopInc:
  addi REG_Loop,REG_Loop,1
  addi REG_GameOrder, REG_GameOrder, 4
  addi REG_BufferOrder, REG_BufferOrder, 2
SetOrder_LoopCheck:
  cmpwi REG_Loop, 24
  blt SetOrder_Loop

Exit:
# free buffer
  mr r3, REG_Buffer
  branchl r0, 0x8037f1b0

  restore
  addi	r3, r31, 0