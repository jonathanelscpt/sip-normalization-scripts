--[[
    Author : Jonathan Els
    Version : 0.1
    
    Description:
    
        Sanitize contact heard to strip attributes and prefix a "q value" 
        for inbound REGISTER messages.  The "q = 1" suffix is hard-coded.

        Converts this:

            Contact: <sip: 3001@10.0.1.56: 50772>; + sip.instance = "<urn: uuid: 832028f41e6258c46e8de1e8dd3d6723360b5c74>"; reg-id = 1

        To this:

            Contact: <sip: 3001@10.0.1.56: 50772>; q = 1

    Limitations:

        This was written on community request.  
        Not personally tested for support with REGISTER messages.
--]]


M = {}

trace.disable()

function M.inbound_REGISTER(msg)
    local contact = msg:getHeader("Contact")
    if contact
    then
        local qval = "q = 1"
        contact = contact:gsub("(.*<sip:.*>);.*", "%1" .. "; " .. qval)
        trace.format("Found contact header... modifying to: %s", contact)
        msg:modifyHeader ("Contact", contact)
    end
end

return M
