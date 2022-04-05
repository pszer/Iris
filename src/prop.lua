--[[
-- type checked table of properties with input validation and default values
-- ]]
--

Props = {}
Props.__index = Prop

-- creates a prototype property table that can
-- be reused several times
-- takes in a variable number of arguments, with each
-- argument being a table for a row in the property table
-- {key, type, default, valid}
-- key       - key for the property
-- type      - lua type for the property, if nil then there is no type checking
-- default   - default value for the property
-- valid     - function called when setting the value of a property to check validity
--             if nil then there is no input validity checking
--
-- validity checking functions work as follows
-- they take 1 argument, which is what the property is being asked to be set to
-- they should return true/false and the value that the property will be set to
-- if it returns false then an error is raised
--
function Props:prototype(arg)
	local p = {}

	for _,row in pairs(arg) do
		-- the property will be stored in p as
		-- p[key] = {type, default, valid}
		local property = {row[2], row[3], row[4]}
		setmetatable(property, PropsPrototypeRowMeta)
		p[row[1]] = property
	end

	setmetatable(p, Props)

	return p
end

-- this metatable allows for accessing the info for a row
-- in a property prototype as follows
-- prototype.key.type
-- prototype.key.default
-- prototype.key.valid
PropsPrototypeRowMeta = {
	type = 1, default = 2, valid = 3}
PropsPrototypeRowMeta.__index = function (row, k)
	return rawget(row, rawget(PropsPrototypeRowMeta, k))
end

proto = Props:prototype{ {"test" , "number", 100, function (a)
                                                  if a >= 0 then
												  	return true,a
												  else
												  	return true,0
												  end
												  end},
                         {"test2", "string", "str", nil},
						 {"test3", nil, true, nil}}

-- once a prototype is created, it can be called like a function
-- to give an instance of a prototype table
-- initial values of properties can be given through the optional init argument
-- i.e init = {"prop1" = 0, "prop2" = 1} will assign 0 and 1 to properties prop0 and prop1
--
-- all instances of a property table have ["__proto"] that points to their prototype
-- if that information is required
--
-- an instance of a property table can be read and written to like a regular table but
-- it has the type checking and validity checking of the prototype table in place
Props.__call = function (proto, init)
	local props = { __proptabledata = {} }

	props.__proto = proto
	props.__newindex = function (p, key, val)
		local row = proto[key]
		if row == nil then
			print("property [" .. tostring(key) .. "] does not exist")
			return
		end

		if row.type ~= nil and row.type ~= type(val) then
			print("property [" .. tostring(key) .. "] is a " .. row.type .. ", tried to assign a " .. type(val)
			       .. " (" .. tostring(val) .. ")")
			return
		end

		if row.valid then
			print("checking validity")

			local good, validvalue = row.valid(val)
			if not good then
				print("value " .. tostring(val) .. " is invalid for property [" .. tostring(key) .. "]")
			end

			rawset(p.__proptabledata, key, validvalue)
		else
			rawset(p.__proptabledata, key, val)
		end
	end

	props.__index = function (p, key)
		return rawget(p.__proptabledata, key)
	end

	setmetatable(props, props)

	for key,row in pairs(proto) do
		props[key] = (init and init[key]) or proto[key].default
		print("key",tostring(key)," val",tostring(props[key]))
	end

	return props
end
