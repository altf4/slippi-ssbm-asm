.include "Common/Common.s"

################################################################################
# Address: FN_MultiplyRWithF
################################################################################
# Inputs:
# r3 - Integer Value
# f2 - Float Value
################################################################################
# Output:
# f1 - Multiplication Result
################################################################################
# Description:
# Multiplies r3=int with f2=float
################################################################################

backup
branchl r12, FN_IntToFloat # returns f1
fmuls f1, f1, f2
restore
blr