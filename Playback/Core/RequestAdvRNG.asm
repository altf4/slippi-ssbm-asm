################################################################################
# Address: 801b4398
################################################################################

.include "Common/Common.s"
.include "Playback/Playback.s"
.include "TASBot.s"

.set REG_MajorData, 30
.set REG_Buffer, 29

backup

# alloc temp buffer
  li r3, GET_ADV_BUFSIZE    # this is larger, using this to alloc the buffer
  branchl r0, HSD_MemAlloc
  mr REG_Buffer, r3

RequestRNG:
# cmd
  li r3,CMD_REQ_ADV_DATA
  stb r3,REQ_ADV_CMD_OFFSET(REG_Buffer)
# req
  mr r3,REG_Buffer
  li  r4,REQ_ADV_BUFSIZE                #Length
  li  r5,CONST_ExiWrite
  branchl r12,FN_EXITransferBuffer
ReceiveOrder:
  mr r3,REG_Buffer
  li  r4,GET_ADV_BUFSIZE                #Length
  li  r5,CONST_ExiRead
  branchl r12,FN_EXITransferBuffer
  cmpwi r3, 1
  beq RestoreRNG
  cmpwi r3, -4                               # keep checking
  ble ReceiveOrder
  b Exit

RestoreRNG:
# update seed
  lwz	r3, -0x570C (r13)
  lwz r0, GET_ADV_RNG_OFFSET (REG_Buffer)
  stw r0,0x0(r3)

Exit:
# free buffer
  mr r3, REG_Buffer
  branchl r0, 0x8037f1b0

  restore
  addi	r3, r30, 0