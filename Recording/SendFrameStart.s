# Required Includes (A file that includes this header must also include these)
# Recording/Recording.s

.macro Macro_SendFrameStart

CreateFrameStartProc:
#Create GObj
  li	r3,4	    	#GObj Type (4 is the player type, this should ensure it runs before any player animations)
  li	r4,7	  	  #On-Pause Function (dont run on pause)
  li	r5,0        #some type of priority
  branchl	r12,GObj_Create

#Create Proc
  bl  SendFrameStart
  mflr r4         #Function
  li  r5,0        #Priority
  branchl	r12,GObj_AddProc

b CreateFrameStartProc_Exit

################################################################################
# Routine: SendFrameStart
# ------------------------------------------------------------------------------
# Description: Sends the RNG seed that is needed for the very rare case of throws
# causing the DamageFlyTop state
################################################################################

SendFrameStart:
blrl

.set REG_PlayerData,31
.set REG_Buffer,29
.set REG_BufferOffset,28
.set REG_PlayerSlot,27
.set REG_GameEndID,26
.set REG_SceneThinkStruct,25

.set EXI_ITEM_COMMAND_BUF_SIZE, 32

backup

# ------------- Crowd Control -----------------
# The incoming message is expected to be 8 bytes:
#   0x12345678 0x000000NN
#     Where NN is the item type ID

# Alloc buffer to transfer into
  li r3, EXI_ITEM_COMMAND_BUF_SIZE
  branchl r12, HSD_MemAlloc
  mr REG_Buffer, r3
  # Init data to 0
  load r4, 0x00000000
  stw r4, 0x0(REG_Buffer) 

# request data from EXI
  mr r3, REG_Buffer
  li r4, EXI_ITEM_COMMAND_BUF_SIZE
  li r5, CONST_ExiRead
  branchl r12, FN_EXITransferBuffer

# Check if we should spawn an item or not
  lwz r4, 0x0(REG_Buffer)
  load r5, 0x41414141 # marker
  cmpw r4, r5
  beq SpawnItem

DontSpawnItem:
  li r5, 120 # arbitrary value > 1
  # Apparently the game doesn't like being told to spawn item 0x00
  #   even when the timer isn't ready yet. So always set this to something valid
  li r4, 0x06 # bob-omb. 
  b SpawnItemDone
SpawnItem:
  li r5, 1
  # lwz r4, 0x4(REG_Buffer)
  li r4, 0x06 # just do a bob-omb for now. TODO Change this back later
SpawnItemDone:

# Set itemspawn var
# 804a0e30 is the address for the item spawn countdown timer thing
  load r3,0x804a0e30
  stw r5, 0x0(r3)

  lwz r3, primaryDataBuffer(r13)
  stw r4, RDB_ITEM_SPAWN_TYPE(r3)

# Free up the EXI buffer
  mr r3, REG_Buffer
  branchl r12, HSD_Free

#------------- INITIALIZE -------------
# here we want to initalize some variables we plan on using throughout
# get current offset in buffer
  lwz r3, primaryDataBuffer(r13)
  lwz REG_Buffer, RDB_TXB_ADDRESS(r3)
  lwz REG_BufferOffset,bufferOffset(r13)
  add REG_Buffer,REG_Buffer,REG_BufferOffset

# initial RNG command byte
  li r3, CMD_INITIAL_RNG
  stb r3,0x0(REG_Buffer)

# send frame count
  lwz r3,frameIndex(r13)
  stw r3,0x1(REG_Buffer)

# store RNG seed
  lis r3, 0x804D
  lwz r3, 0x5F90(r3) #load random seed
  stw r3,0x5(REG_Buffer)

# store scene frame counter
  loadGlobalFrame r3
  stw r3, 0x9(REG_Buffer)

#------------- Increment Buffer Offset ------------
  lwz REG_BufferOffset,bufferOffset(r13)
  addi REG_BufferOffset,REG_BufferOffset,(GAME_FRAME_START_PAYLOAD_LENGTH+1)
  stw REG_BufferOffset,bufferOffset(r13)

SendFrameStart_Exit:
  restore
  blr

CreateFrameStartProc_Exit:

.endm
