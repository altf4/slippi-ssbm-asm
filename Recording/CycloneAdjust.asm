################################################################################
# Address: 80068f30
################################################################################

.include "Common/Common.s"
.include "Playback/Playback.s"
.include "TASBot.s"

.set REG_FighterData, 30

# is this all-star major scene?
  load r4,0x80479d30
  lbz r3,0x0(r4)
  cmpwi r3,5
  bne Exit
# is this the x'th match?
  lbz r3,0x3(r4)
  cmpwi r3,0x38
  bne Exit
# am i ply X
  lbz r3,0xC(REG_FighterData)
  cmpwi r3,0
  bne Exit
# am i luigi
  lwz r3,0x4(REG_FighterData)
  cmpwi r3,7
  bne Exit
# init the luigi cyclone variable
  li r3,1
  stw r3,0x234C(REG_FighterData)

Exit:
  lis	r3, 0x803C