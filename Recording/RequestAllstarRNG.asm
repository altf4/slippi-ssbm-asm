################################################################################
# Address: 801b5990
################################################################################

.include "Common/Common.s"
.include "Playback/Playback.s"
.include "TASBot.s"

.set REG_MajorData, 26
.set REG_Buffer, 30

backup

# get index and store in r3
  lbz r3, 0x0 (REG_MajorData)
  rlwinm	r3, r3, 29, 27, 31

# get the appropriate RNG seed into r0
  bl data          # branch to label
  mflr r4          # get ptr to address after the blrl instruction
  mulli r3,r3,0x4  # multiple index by 4, since each RNG seed is 4 bytes long
  lwzx r0,r3,r4    # access the r3'rd of the array

  b past_data           # don't execute the data as an instruction!

# THANK YOU UnclePunch!
data:
  blrl                                    # instantly return
  .long 0xC88F4F11, 0xBB048EE8, 0x5939db62, 0x05c986e0, 0x5aa0be8c, 0x8b86cd40, 0xc8b6cbc9, 0x7584f37b, 0x9844996a, 0xc5d6059e, 0x9d077f22, 0xe6615017, 0x1084a48e
  .align 2                                # align so assembler doesnt complain

past_data:
# update seed
  lwz	r3, -0x570C (r13)
  stw r0,0x0(r3)

Exit:
  restore
  lmw	r26, 0x0058 (sp)
  