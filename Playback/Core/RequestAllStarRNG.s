################################################################################
# Address: 801b5990
################################################################################

.include "Common/Common.s"
.include "Playback/Playback.s"
.include "TASBot.s"

.set REG_MajorData, 26
.set REG_Buffer, 30

backup

# alloc temp buffer
  li r3, REQ_ALLSTAR_NUM_BUFSIZE    # this is larger, using this to alloc the buffer
  branchl r0, HSD_MemAlloc
  mr REG_Buffer, r3

RequestOrder:
# cmd
  li r3,CMD_REQ_ALLSTAR_RNG
  stb r3,REQ_ALLSTAR_CMD_OFFSET(REG_Buffer)
# difficulty
  lbz r3, 0x0 (REG_MajorData)
  rlwinm	r3, r3, 29, 27, 31
  stb r3,REQ_ALLSTAR_RNG_NUM_OFFSET(REG_Buffer)
# req
  mr r3,REG_Buffer
  li  r4,REQ_ALLSTAR_NUM_BUFSIZE                #Length
  li  r5,CONST_ExiWrite
  branchl r12,FN_EXITransferBuffer
ReceiveOrder:
  mr r3,REG_Buffer
  li  r4,GET_ALLSTAR_RNG_BUFSIZE                #Length
  li  r5,CONST_ExiRead
  branchl r12,FN_EXITransferBuffer

# update seed
  lwz	r3, -0x570C (r13)
  lwz r0, GET_ALLSTAR_RNG_OFFSET (REG_Buffer)
  stw r0,0x0(r3)

# free buffer
  mr r3, REG_Buffer
  branchl r0, 0x8037f1b0

Exit:
  restore
  lmw	r26, 0x0058 (sp)