--[[

    Source:
    
        https://ccie45333.wordpress.com/tag/lua/

    Description:

        Modify CMS address spaces to overcome conflicts with user addressing for MeetingApp

    Requires:

        CMS space provisioning with prefix - in this  script currently is "cmr"

    Usage:

        Integration between CUCM and CMS only - VCS integrations should use VCS-based normalization 
    
    Future development:

        Clean-up of "find" and harcoding in match criteria
        Remove reliance on "sip" find
        Migrate prefix and domain to script params for increased usability

--]]


M = {}

-- hard coded - can be moved to script param instead
local cmrDomain = "meet.domain.tld" 

function M.outbound_INVITE(msg)
    
    local method, ruri, ver = msg:getRequestLine()
    
    if string.find(ruri, cmrDomain)
    then
        -- refactor - clean up with gsub
        startTo_str = string.find(ruri, "sip:") -- assumes "sip" only - potential defect for sips 
        endTo_str = string.find(ruri, "@", startTo_str + 1)
        toUserPart_str = string.sub(ruri, startTo_str + 4, endTo_str - 1)
    
        if not string.sub(toUserPart_str, 0,3):match("cmr-")
        then
            changedToUserPart_str = "cmr-" .. toUserPart_str
            changedRuri_str = string.gsub(ruri, toUserPart_str, changedToUserPart_str)
            msg:setRequestUri(changedRuri_str)
        end
    end
end

return M