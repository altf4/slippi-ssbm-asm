################################################################################
# Address: 8026c8d8
################################################################################

.include "Common/Common.s"
.include "Recording/Recording.s"

  lwz r3, primaryDataBuffer(r13)
  lwz r3, RDB_ITEM_SPAWN_TYPE(r3)

Exit:
    stw r3, 0x0014(sp)
