################################################################################
# Address: 801b4398
# Notifies the device of which TAS run is being performed
################################################################################

.include "Common/Common.s"
.include "Playback/Playback.s"
.include "TASBot.s"

.set REG_MajorData, 30
.set REG_Buffer, 29

backup

# alloc temp buffer
  li r3, REQ_ADV_BUFSIZE    # this is larger, using this to alloc the buffer
  branchl r0, HSD_MemAlloc
  mr REG_Buffer, r3

# get this players data
  lbz r12,-0x49B0(r13)
  mulli r12,r12,0x24
  add r12,r12,REG_MajorData

RequestRNG:
# cmd
  li r3,CMD_REQ_ADV_DATA
  stb r3,REQ_ADV_CMD_OFFSET(REG_Buffer)
# ckind
  lbz r3, 0x70 (r12)
  stb r3,REQ_ADV_CKIND_OFFSET(REG_Buffer)
# costume
  lbz r3, 0x73 (r12)
  stb r3,REQ_ADV_COSTUME_OFFSET(REG_Buffer)
# difficulty
  lbz r3, 0x7F (r12)
  stb r3,REQ_ADV_DIFFICULTY_OFFSET(REG_Buffer)
# stock
  lbz r3, 0x72 (r12)
  stb r3,REQ_ADV_DIFFICULTY_OFFSET(REG_Buffer)
# req
  mr r3,REG_Buffer
  li  r4,REQ_ADV_BUFSIZE                #Length
  li  r5,CONST_ExiWrite
  branchl r12,FN_EXITransferBuffer
# no response, only notifying the device of which run is being performed

Exit:
# free buffer
  mr r3, REG_Buffer
  branchl r0, 0x8037f1b0

  restore
  addi	r3, r30, 0