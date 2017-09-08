--[[

    Author : Jonathan Els
    Version : 1.0
    
    Description:
    
        Find and replace FQDN with IP in Contact headers. Script is applied to Inbound INVITEs and all 
        Inbound INVITE responses.

    Future development:
    
        None

--]]

M = {}

trace.enable()

-- Customer-specific DNS table initialization - edit on per-script basis
local dns = {}
dns["1.1.1.1"] = "hostname1%.rootdomain%.com"
dns["2.2.2.2"] = "hostname2%.rootdomain%.com"
dns["3.3.3.3"] = "hostname3%.subdomain%.rootdomain%.com"


local function process_contact_headers

    -- Get Contact header
    local contact = msg:getHeader("Contact")
    local iptest = "@(%d+%.%d+%.%d+%.%d+)"
    
    -- Check if exists and if URI host portion is FQDN
    if contact and not contact:match(iptest) then
        trace.format(" -- Contact URI host portion matched FQDN")
        trace.format(" -- Contact header is : %s", contact)
        
        -- Iterate over domain and substitute if matched
        for ip,fqdn in pairs(dns) do
            if contact:match(fqdn) then
                contact = contact:gsub(fqdn, ip)
                trace.format(" -- Matched on : %s", fqdn)
                trace.format(" -- Modified to : %s", ip)

                -- Modify contact header
                msg:modifyHeader("Contact", contact)
                break
            end
        end
    end

end

-- Apply to INVITE request and all INVITE responses
M.inbound_INVITE = process_contact_headers
M.inbound_ANY_INVITE = process_contact_headers


return M
