@tool
@icon("customModificationIcon.png")
extends SoupStackPart
class_name SoupMod

## Parent node for modification stacks.
##
## Not intended for actual use.

@onready var requests: Array[ModificationRequest] = []

func parent_enable_check() -> bool:
	if !(ModStack is SoupStack):
		return false
	if (SubStack is SoupSubStack):
		return (ModStack.Enabled) #and (SubStack.Enabled)
	else:
		return ModStack.Enabled

func free_request(requestIdx: int, boneIdx: int)->void:
	ModStack.BoneData[boneIdx].modifications.erase(requests[requestIdx].modStruct)

func initialize_request(requestIdx: int, boneIdx: int, mode: int)->void:
	# Resize the requests array to the needed size
	requests.resize(maxi(requests.size(),requestIdx+1))

	# Remove the previous Modification Struct from the array in Modification Manager
	if requests[requestIdx] is ModificationRequest:
		free_request(requestIdx, requests[requestIdx].targetBoneIdx)
	if ModStack is SoupStack and ModStack.BoneData.size()>0:
		# Add a new Modification Struct to the array in Modification Manager
		ModStack.BoneData[boneIdx].modifications.append(SoupStack.Modification.new(mode))
		# Package the Modification Struct as Modification Request and add to the local array
		requests[requestIdx] = ModificationRequest.new(boneIdx\
		, ModStack.BoneData[boneIdx].modifications.back())

class ModificationRequest:
	
	var targetBoneIdx: int
	var modStruct: SoupStack.Modification
	func _init(boneIdx: int, mStruct: SoupStack.Modification):
		targetBoneIdx = boneIdx
		modStruct = mStruct

