--[[

    Author : Jonathan Els
    Version : 1.0
    
    Description:
    
        Mask outbound INVITE headers for After-Hours Call Re-Direct
        
    Notes:
    
        Call flow is used from CUC Call Handler, transferring to a CTIRP that has CFA to ITSP.  
        Workflow allows for re-masking the Diversion Header from internal DN on CTIRP to the Main number DID.

    Future development:
    
        None
--]] 

M = {}

trace.enable()

function M.outbound_INVITE(msg)

    -- Input for script
    local ctirpdn = scriptParameters.getValue("ctirpdn")
    local mainnumber = scriptParameters.getValue("mainnumber")
    local rdnis = scriptParameters.getValue("rdnis")
    
    -- Get Diversion header
    local diversion = msg:getHeader("Diversion") 
    
    trace.format("CTI RP DN is : %s", ctirpdn)
    trace.format("Main Number is : %s", mainnumber)
     
    -- Check if Diversion Header exists and if the CTI RP DN is matched
    if diversion and diversion:find(ctirpdn) then
        trace.format("Successful match on diversion - applying masking")
    
        -- Apply masking to affected headers - From, PAI, RPID, Contact
        msg:applyNumberMask("From", mainnumber)
        msg:applyNumberMask("P-Asserted-Identity", mainnumber)
        msg:applyNumberMask("Remote-Party-ID", mainnumber)
        msg:applyNumberMask("Contact", mainnumber)
        -- Apply masking to Diversion to mask internal CTI RP DN
        msg:applyNumberMask("Diversion", rdnis)
    
    end
 end
 
 return M