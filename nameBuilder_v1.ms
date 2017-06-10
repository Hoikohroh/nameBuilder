/*
	nameBuilder_v1

Description:
	Rename object
	
Log:
	2017/6/10 release

*/

try (destroyDialog Roll_RenameSuffix)	catch()

-- Dialog

rollout Roll_RenameSuffix""(
	-- Struct
	struct nameStr (baseName, type, res, rev, count)
	
	-- Regular expressions
	local re = Python.Import "re"
	-- Revision
	local pattern = "Rev\d*$"
	local revPattern =re.compile(pattern)
	-- Resolution
	local typeStr = #("Hpr","Root","Mdl","Obj","Guid","Lin","Shape")
	local typePatterns = for i in typeStr collect  re.compile( i + "\d*$")
	-- Type
	local resStr = #("High","Low")
	local resPatterns = for i in resStr collect  re.compile( i + "\d*$")
	
	
	
	-- Functions
	function checkWord str mode= (
		-- Flags
		local stopFlag = False
		local round, patterns, check
		case mode of(
			"Type":(
				round = typePatterns.count
				patterns = typePatterns
			)
			"Res":(
				round = resPatterns.count
				patterns = resPatterns
			)
			"Rev":(
				round = 1
				patterns = #(revPattern)
			)
		)
		
		if round != undefined do(
			while not stopFlag do(
				check = patterns[round].match(str)
				if  check != undefined do(
					check = round
					stopFlag = True
				)
				round -= 1
				if round <= 0 do (stopFlag = True)
			)
		)
		check
	)	
	function checkSentence obj= (
		-- function
		function pickLastElment nameArray fromArray =(
			local last = fromArray.count
			local picked = undefined
			-- if you want remove multiple management strings, comment out the follow block.
			-- from here
			if last > 1 do(
				for i = 1 to (last - 1) do(
					append nameArray fromArray[i]
				)
			)
			-- to here
			if last != 0 do(
				picked = fromArray[last]
			)
			picked
		)
		
		-- Flags
		local skipFlag = False
		
		-- Variables
		local nameArray = filterString obj.name "_"
		local nums = 1
		local check = undefined
		local typeArray = #()
		local resArray = #()
		local revArray = #()
		
		-- Struct
		local theStr =  nameStr baseName:#() count:(nameArray.count)
		
		-- Check words
		for i in nameArray do(
			skipFlag = False
			
			-- Revision
			check = checkWord i "Rev"
			if check != undefined do(
				append revArray #(nums,  i)
				skipFlag = True
			)
			-- Resolution
			if not skipFlag do(
				check = checkWord i "Res"
				if check != undefined do(
					append resArray #(nums, resStr[check])
					skipFlag = True
				)
			)
			-- Type
			if not skipFlag do(
				check = checkWord i "Type"
				if check != undefined do(
					append typeArray #(nums, typeStr[check])
					skipFlag = True
				)
			)
			-- ObjectName
			if not skipFlag do(
				append theStr.baseName #(nums,i)
			)
			nums += 1
		)
		theStr.type = pickLastElment theStr.baseName typeArray
		theStr.res = pickLastElment theStr.baseName resArray
		
		check = pickLastElment theStr.baseName revArray
		if check != undefined do(
			num = filterString check[2] "Rev"
			num = num [1] as Integer
			check[2] = num
		)
		theStr.rev = check
		theStr
	)
	function setDigit int digit=(
		local str = int as string
		if str.count < digit do(
			while str.count < digit do(
				str = "0" + str
			)
		)
		str
	)
	function replaceStr str renameArray: =(
		
		function replaceFn property replacer =(
			if property != undefined then(
				property[2] = replacer
			)else(
				property = #(0,  replacer)				
			)
			property
		)
		
		case renameArray[1] of(
			"baseName":(
				str.baseName = #(#(0, renameArray[2]))
			)
			"type": (
				str.type = replaceFn str.type renameArray[2]
			)
			"res":(
				str.res = replaceFn str.res renameArray[2]
			)
			"rev":(
				if str.rev != undefined then(					
					case renameArray[2] of(
						"+":str.rev[2] += 1
						"-":(
							if str.rev[2] > 0 do(str.rev[2] -= 1)
						)
					)
				)else(
					str.rev = #(0, 1)
				)
			)
		)
		str
	)
	function removeStr str mode: =(
		case mode of(
			"type": (
				if str.type != undefined do(
					str.type = undefined
				)
			)
			"res":(
				if str.res != undefined do(
					str.res = undefined
				)
			)
			"rev":(
				if str.rev != undefined do(		
					str.rev = undefined
				)
			)
		)
		str
	)
	function buildNewName str=(
		function compareFN v1 v2 =(
			local d = v1[1] - v2[1]
			case of(
				(d < 0.): -1
				(d > 0.): 1
				default: 0
			)
		)
		local newName = ""
		
		-- baseName
		qsort str.baseName compareFN
		for i in str.baseName do(
			newName = newName + i[2] + "_"
		)
		-- Type
		if str.type != undefined do(
			newName = newName + str.type[2] + "_"
		)
		-- Resolution
		if str.res != undefined do(
			newName = newName + str.res[2] + "_"
		)
		-- Revision
		if str.rev != undefined do(
			newName = newName + "Rev" + (setDigit str.rev[2] 3) + "_"
		)
		newName = substring newName 1 (newName.count - 1)
		newName
	)
	function renameSelected executeMode: =(
		
		local check,newName
		
		for i in selection  as array do(
			
			check = checkSentence i
			
			if executeMode[2] != undefined then(
				replaceStr check renameArray:executeMode
			)else(
				removeStr check mode:executeMode[1]
			)
			newName = buildNewName check
			i.name = newName
		)
	)
	
	-- GUI
	group"BaseName"(
		edittext BaseName_etxt ""
	)
	group"Type"(
		button Hpr_btn "Hpr"width: 50 across:2
		button Root_btn "Root"width: 50
		button Mdl_btn "Mdl"width: 50 across:2
		button Obj_btn "Obj"	width: 50
		button Guid_btn "Guid"	width: 50
		button Shape_btn "Shape"width: 50
		button DeleteType_btn "Å~"width: 90
	)
	group"Resolution"(
		button High_btn "High"width: 50 across:2
		button Low_btn "Low"width: 50
		button DeleteRes_btn "Å~"width: 90
	)
	group"Revision"(
		button Rev_btn "Rev"width: 50
		button RevIncrement_btn "+"width: 50 across:2
		button RevDecrement_btn "-"width: 50
		button DeleteRev_btn "Å~"width: 90
	)
	
	
	-- Event
	on BaseName_etxt entered text do(
		if text != "" do(
			renameSelected executeMode:#("baseName",text)
		)
	)

	on Hpr_btn pressed do(
		renameSelected executeMode:#("type","Hpr")
	)
	on Root_btn pressed do(
		renameSelected executeMode:#("type","Root")
	)
	on Mdl_btn pressed do(
		renameSelected executeMode:#("type","Mdl")
	)
	on Obj_btn pressed do(
		renameSelected executeMode:#("type","Obj")
	)
	on Guid_btn pressed do(
		renameSelected executeMode:#("type","Guid")
	)
	on Shape_btn pressed do(
		renameSelected executeMode:#("type","Shape")
	)
	on DeleteType_btn pressed do(
		renameSelected executeMode:#("type", undefined)
	)
	
	on High_btn pressed do(
		renameSelected executeMode:#("res","High")
	)
	on Low_btn pressed do(
		renameSelected executeMode:#("res","Low")
	)
	on DeleteRes_btn pressed do(
		renameSelected executeMode:#("res", undefined)
	)
	
	on Rev_btn pressed do(
		renameSelected executeMode:#("rev", 1)
	)
	on RevIncrement_btn pressed do(
		renameSelected executeMode:#("rev", "+")		
	)
	on RevDecrement_btn pressed do(
		renameSelected executeMode:#("rev", "-")		
	)
	on DeleteRev_btn pressed do(
		renameSelected executeMode:#("rev", undefined)
	)
)



createDialog	Roll_RenameSuffix	140 400
