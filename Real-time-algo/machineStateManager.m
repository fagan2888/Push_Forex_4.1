classdef machineStateManager < handle
    
    properties
        
        statusNotification;
        machineStatus;
        realMode;
        lastOperation;
        lastOpenValue;
        lastCloseValue;
        stopLoss;
        takeProfit;
        minReturn;
        openTicket;
        closeTicket;
        
        
        tElapsedOpeningRequest;
        tElapsedClosingRequest;
        
    end
    
end