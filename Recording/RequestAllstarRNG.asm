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
# save a copy of the index in r5
  addi r5, r3, 0

# get the appropriate RNG seed into r0
  bl data          # branch to label
  mflr r4          # get ptr to address after the blrl instruction
  mulli r3,r3,0x4  # multiple index by 4, since each RNG seed is 4 bytes long
  lwzx r0,r3,r4    # access the r3'rd of the array

# update luigi cyclone flag if necessary
  #cmpwi r5, 7 # index 7 is the stage we want to intercept
  #bne past_data # if it's not stage 7, move along
  # update luigi cyclone flag
  #load r3, 0x80453080 # p1 data block
  #lwz r3, 0xB0(r3) # entity struct
  #lwz r3, 0x2C(r3) # character data
  #load r0, 0x00000000 # set the value to write
  #stw r0, 0x222C(r3) # save the value to the misc_flags offset
  b past_data           # don't execute the data as an instruction!

# THANK YOU UnclePunch!
data:
  blrl                                    # instantly return
  .long 0xC88F4F11, 0xB1C6920B, 0xBCFC16D1, 0x98E3A1B5, 0x7e225291, 0xe105b595, 0x74bd6922, 0xa6e1d15c, 0xfae86527, 0x98fc85e9, 0xa43b295d, 0xc5c0b749, 0xf7f86919
  #        marth     bowser       kirby        yoshi       peach      gannon       doc          ness      y link       pichu       mario         ics      gnw
  .align 2                                # align so assembler doesnt complain

past_data:
# update seed
  lwz	r3, -0x570C (r13)
  stw r0,0x0(r3)
  
Exit:
  restore
  lmw	r26, 0x0058 (sp)
