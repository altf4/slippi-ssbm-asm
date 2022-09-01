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
  li r3, REQ_ALLSTAR_BUFSIZE    # this is larger, using this to alloc the buffer
  branchl r0, HSD_MemAlloc
  mr REG_Buffer, r3

RequestOrder:
# get this players data
  lbz r12,-0x49B0(r13)
  mulli r12,r12,0x24
  add r12,r12,REG_MajorData
# cmd
  li r3,CMD_REQ_ALLSTAR_ORDER
  stb r3,REQ_ALLSTAR_CMD_OFFSET(REG_Buffer)
# ckind
  lbz r3, 0x70 (r12)
  stb r3,REQ_ALLSTAR_CKIND_OFFSET(REG_Buffer)
# costume
  lbz r3, 0x73 (r12)
  stb r3,REQ_ALLSTAR_COSTUME_OFFSET(REG_Buffer)
# difficulty
  lbz r3, 0x7F (r12)
  stb r3,REQ_ALLSTAR_DIFFICULTY_OFFSET(REG_Buffer)
# req
  mr r3,REG_Buffer
  li  r4,REQ_ALLSTAR_BUFSIZE                #Length
  li  r5,CONST_ExiWrite
  branchl r12,FN_EXITransferBuffer
ReceiveOrder:
  mr r3,REG_Buffer
  li  r4,GET_ALLSTAR_BUFSIZE                #Length
  li  r5,CONST_ExiRead
  branchl r12,FN_EXITransferBuffer
  cmpwi r3, 1
  beq RestoreRNG
  cmpwi r3, -4                               # keep checking
  ble ReceiveOrder
  b Exit

/*
RestoreRNG:
# update seed
  lwz	r3, -0x570C (r13)
  lwz r0, GET_ALLSTAR_RNG_OFFSET (REG_Buffer)
  stw r0,0x0(r3)
*/

SetOrder:
.set REG_Loop, 12
.set REG_GameOrder, 11
.set REG_BufferOrder, 10
  li REG_Loop, 0
  load REG_GameOrder, 0x803debe8
  addi REG_BufferOrder, REG_Buffer, GET_ALLSTAR_STAGE_OFFSET
SetOrder_Loop:
# stage
  lbz r3,GET_ALLSTAR_STAGE_OFFSET(REG_BufferOrder)
  stb r3,0x2(REG_GameOrder)
# ckind
  lbz r3,GET_ALLSTAR_CKIND_OFFSET(REG_BufferOrder)
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