--[[

    Source:
    
        http://info.stack8.com/blog/using-lua-script-to-allow-sip-based-phones-to-dial-from-the-cucm-corporate-directory

    Description:
    
        Parsing of Corp. Dir for SIP-based phones, prior to CUCM call initiation.
        
    Deployment:

        Appied to SIP Profile of SIP Phone in CUCM.
    
    Future development:
    
        None

--]]

M={}

function M.inbound_INVITE(msg)
    --[[  Extract data from SIP INVITE  --]]
    local to = msg:getHeader("To")
    local method, ruri, ver = msg:getRequestLine()
    
    --[[  Isolate both side of "@" in variables  --]]
    local to_left_side, to_right_side = string.match(to, "<sip:(.*)@(.*)")
    local ruri_left_side, ruri_right_side = string.match(ruri, "sip:(.*)@(.*)")

    --[[  Search and replace for "To" Header and Request URI --]]
    to_left_side = string.gsub(to_left_side , "%%20", "")
    to_left_side = string.gsub(to_left_side , "-", "")
    to_left_side = string.gsub(to_left_side , "x", "")
    ruri_left_side = string.gsub(ruri_left_side , "%%20", "")
    ruri_left_side = string.gsub(ruri_left_side , "-", "")
    ruri_left_side = string.gsub(ruri_left_side , "x", "")

    --[[  If the left side of "@" contain only numbers and begin OR not begin
            with "+", then update the "To" Header and Request URI  --]]
    if string.find(to_left_side, "^+?%d*$") then
        msg:modifyHeader("To", "<sip:" .. to_left_side .. "@" .. to_right_side)
    end

    if string.find(ruri_left_side, "^+?%d*$") then
        msg:setRequestUri("sip:" .. ruri_left_side .. "@" .. ruri_right_side)
    end
end

return M
