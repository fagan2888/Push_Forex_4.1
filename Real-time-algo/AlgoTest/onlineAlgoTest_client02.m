function [topicPub,messagePub] = onlineAlgoTest_client02(topicSub,messageSub,password)


% DESCRIPTION:
% -------------------------------------------------------------
% This function runs an Algo within the online trading system.
% It takes in input a topic and a relative message from the
% server. It handles the message received and send back an output
% to the server.
%
% INPUT parameters:
% -------------------------------------------------------------
% topicSub:             topic of the message received or
%                       sent. The topic acts as a key for the
%                       following message.
% messageSub:           message attached to the relative topic.
% password:             ask to the administrator
%
% OUTPUT parameters:
% -------------------------------------------------------------
% topicSub:             topic of the message to send to the
%                       server. The topic acts as a key for the
%                       following message.
% messageSub:           message sent to the server.
%
% EXAMPLE of use:
% -------------------------------------------------------------
% clear all;
% StartAlgo(IP,password);
%
% NOTE
% -------------------------------------------------------------
% please ask to the administrator the IP of the server and the
% password.
% For more details about the trading system read the documents:
% - Build AlgoV2
% - ManualeBuild AlgoV2.pdf
%


persistent matrix;
persistent newTimeScalePoint;
persistent newTimeScalePointEnd;
persistent startingOperation;
persistent numberOf1minPoints;
persistent openValueReal;
persistent trialClose;
persistent ticket;
persistent ms;
persistent tStartClosingRequest;
persistent tStartOpeningRequest;
persistent nFile
persistent logFileDimension
persistent logFile
persistent LogObj
persistent logFolderName
persistent timeSeriesProperties


nameAlgo          = 'AlgoTest';
algoTopicPub      = 'OPERATIONS@ACTIVTRADES@AUDCAD@9999';
algoMagic         = 9999;
nData             = 100;
operLots          = 1;
operOpenSlippage  = 1.5;
operCloseSlippage = 0.2;
tOpenRequest      = 300;
tCloseRequest     = 90;

topicPub = '';
messagePub = '';
closingTimeScale = 1;
openingTimeScale = 1;
server_exe = 0; % set to 1 when the Algo is running on the server as an .exe

indexOpen = 0;
indexClose = 0;

if(isempty(matrix))
    matrix = zeros(nData+1,6);
    startingOperation = 0;
    ticket = -1;
    newTimeScalePoint = 0;
    numberOf1minPoints = 0;
    ms = machineStateManager;
    ms.machineStatus = 'closed';
    ms.lastOperation = 0;
    nFile=0;
    logFileDimension=0;
    timeSeriesProperties=indicators;
end

ms.statusNotification = 0;

if(isempty (openValueReal))
    openValueReal = 0;
end

if nFile == 0
    nFile=nFile+1;
    logFolderName ='C:\Users\alericci\Desktop\Forex 4.0 noShared\test Logs\';
    if server_exe == 0 && isdir(logFolderName)
        [LogObj,logFile] = createLogFile (logFolderName,nameAlgo,nFile);
    else
        currentFolder = pwd;
        logFolderName = strcat(currentFolder,'\','logfile_',nameAlgo,'\');
        mkdir(logFolderName);
        [LogObj,logFile] = createLogFile (logFolderName,nameAlgo,nFile);
    end
elseif logFileDimension > 10000000
    nFile=nFile+1;
    fclose('all');
    [LogObj,logFile] = createLogFile (logFolderName,nameAlgo,nFile);
end

listener1 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@AUDCAD@m1@v100');
listener2 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@AUDCAD@m1@v1');
listener3 = strcmp(topicSub,'STATUS@AUDCAD@9999');

if listener1 && ( strcmp(ms.machineStatus,'closed') || strcmp(ms.machineStatus,'open') ) %new 30minutes data array
    
    LogObj.info('MATLAB info','new data array at 30min received');
    myData = strsplit(messageSub, ';');
    newTimeScalePoint = 1;
    
    for i = 1:length(myData)
        
        cells = strsplit(myData{i},',');
        matrix(i,1:5) = str2double(cells(1:5));
        matrix(i, 6) = datenum(cells{6},'mm/dd/yyyy HH:MM');
        
    end
    
    matrix(:,end)=matrix(:,end-1); % copio l'ultima mezz ora cm se fosse il dato al minuto
    
elseif listener2 && ( strcmp(ms.machineStatus,'closed') || strcmp(ms.machineStatus,'open') ) %new 1minute data point
    
    numberOf1minPoints = numberOf1minPoints + 1 ;
    
    LogObj.info('MATLAB info','new data point at 1min received');
    newData = textscan(messageSub,'%d %d %d %d %d %s','Delimiter',','); % messageSub: open,max,min,close,volume,data
    newDataMatrix = cell2mat(newData(1:5));
    matrix(end,1)= newDataMatrix(:,1);
    matrix(end,2)= newDataMatrix(:,2);
    matrix(end,3)= newDataMatrix(:,3);
    matrix(end,4)= newDataMatrix(:,4);
    matrix(end,5)= newDataMatrix(:,5);
    matrix(end,6)=datenum(newData{6}(:),'mm/dd/yyyy HH:MM');
    
    
elseif listener3 && ( strcmp(ms.machineStatus,'closing') || strcmp(ms.machineStatus,'opening') )%new status
    
    LogObj.trace('Status received',num2str(cell2mat(strcat('Topic:',{' '}, topicSub))) );
    LogObj.trace('Status received',num2str(cell2mat(strcat('Message:',{' '}, messageSub))) );
    newStatus = textscan(messageSub,'%d %s %d %d','Delimiter',','); % messageSub: status(1,-1),type(open,close),price,ticket
    status= newStatus{1};
    type= newStatus{2};
    price= newStatus{3};
    abc= newStatus{4};
    ticket = abc;
    
    LogObj.info('MATLAB info',num2str(cell2mat(strcat('STATUS received for the Ticket:',{' '}, num2str(ticket)))) );
    
    open  = strcmp(type,'open');
    close = strcmp(type,'close');
    
    ms.statusNotification = 1;
    
    if open
        
        StatusOpen  = status;
        
        if StatusOpen == 1
            
            openValueReal = price ;
            LogObj.info('MT4 info',num2str(cell2mat(strcat('MT4 opened the requested operation',{' '},num2str(ticket),{' '},' at the price ',{' '},num2str(price)))) );
            ms.machineStatus = 'open';
            LogObj.trace('machine status',ms.machineStatus);
            trialClose=1;
            
            pause(30) % wait the next 1 min data point
            
        elseif StatusOpen == -1
            
            LogObj.info('MT4 info','MT4 failed in opening the requested operation. Won t try again');
            openValueReal = -1 ;
            startingOperation = 0;
            ms.machineStatus = 'closed';
            LogObj.trace('machine status',ms.machineStatus);
            ms.statusNotification = 0;
            
        end
        
    elseif close
        
        StatusClose = status;
        
        if StatusClose == 1 && price > 0
            
            LogObj.info('MT4 info',num2str(cell2mat(strcat('MT4 closed the requested operation ',{' '},num2str(ticket),{' '},' at the price ',{' '},num2str(price)))) );
            ms.machineStatus = 'closed';
            LogObj.trace('machine status',ms.machineStatus);
            
        elseif StatusClose == -1 || price < 0
            
            if StatusClose == 1 && price < 0
                LogObj.error( 'MT4 error',num2str(cell2mat(strcat('MT4 tried to close the requested operation',{' '}, num2str(ticket),{' '},'at the price',{' '},num2str(price)))) );
            else
                LogObj.warn('MT4 warn',num2str(cell2mat(strcat('MT4 failed in closing the operation',{' '}, num2str(ticket)))) );
            end
            
            if trialClose < 5
                trialClose=trialClose+1;
                [topicPub,messagePub,startingOperation] = onlineClose(ms.lastCloseValue,operLots,operCloseSlippage,ticket,algoTopicPub,algoMagic,indexClose);
                
                LogObj.trace('problems',num2str(cell2mat(strcat('Matlab trial #',{' '},num2str(trialClose),{' '},' to close the operation:', {' '},num2str(ticket)))) );
                LogObj.trace('machine status',ms.machineStatus);
                
            else
                
                receiver = '4castersltd@gmail.com';
                mail     = '4castersltd@gmail.com';
                subject  = num2str(cell2mat( strcat(nameAlgo,': MT4 failed in closing the operation',{' '}, num2str(ticket)) ));
                content  = num2str(cell2mat( strcat('Please close the operation',{' '},num2str(ticket),{' '},'manually. Matlab will consider it closed') ));
                sendgmail(receiver, subject, content, mail, password)
                
                LogObj.error('MT4 error',num2str(cell2mat(strcat('MT4 was not able to close the operation',{' '},num2str(ticket),{' '},'please check e-mail and close it manually'))) );
                ms.machineStatus = 'closed';
                LogObj.trace('machine status',ms.machineStatus);
                
            end
            
        end
        
    else
        
        LogObj.warn('warn',num2str(cell2mat(strcat('problems in the received status format, please check if MT4 operated the request and proceed manually',{' '}, messageSub))) );
        LogObj.trace('MATLAB info','Matlab will be resetted' )
        openValueReal = -1 ;
        startingOperation = 0;
        ms.machineStatus = 'closed';
        LogObj.trace('machine status',ms.machineStatus);
        
    end
    
elseif listener1 && ( strcmp(ms.machineStatus,'closing') || strcmp(ms.machineStatus,'opening'))
    
    LogObj.trace('MATLAB info',num2str(cell2mat(strcat('skipping data point at',{' '}, num2str(openingTimeScale),'min'))) );
    LogObj.info('MATLAB info',num2str(cell2mat(strcat('still waiting for the Status ...',{' '},ms.machineStatus))) );
    
elseif listener2 && ( strcmp(ms.machineStatus,'closing') || strcmp(ms.machineStatus,'opening'))
    
    numberOf1minPoints = numberOf1minPoints + 1 ;
    
    LogObj.trace('MATLAB info',num2str(cell2mat(strcat('skipping data point at',{' '}, num2str(closingTimeScale),'min'))) );
    LogObj.info('MATLAB info',num2str(cell2mat(strcat('still waiting for the Status ...',{' '},ms.machineStatus))) );
    
elseif listener3 && ( strcmp(ms.machineStatus,'closed') || strcmp(ms.machineStatus,'open'))
    
    LogObj.warn('warn',num2str(cell2mat(strcat('WTF? Received message of Status even if the machine state is ...',{' '},ms.machineStatus, topicSub))) );
    
else
    
    LogObj.warn('warn',num2str(cell2mat(strcat('WTF? Received message on unknown topic',{' '}, topicSub))) );
    
end


if strcmp(ms.machineStatus,'closing')
    
    ms.tElapsedClosingRequest = toc(tStartClosingRequest);
    
    if (ms.tElapsedClosingRequest) > tCloseRequest
        
        LogObj.error('error',num2str(cell2mat(strcat('no Status message received for closing the position',{' '},num2str(ticket),{' '},'after',{' '}, num2str(tCloseRequest),{' '},'seconds'))));
        LogObj.info('MATLAB info',num2str(cell2mat(strcat('We suppose that the operation',{' '},num2str(ticket),{' '},'has been closed by MT4'))) );
        
        receiver = '4castersltd@gmail.com';
        mail     = '4castersltd@gmail.com';
        subject  = num2str(cell2mat( strcat(nameAlgo,': no Status message received for closing the position',{' '}, num2str(ticket)) ));
        content  = num2str(cell2mat( strcat('We suppose that the operation',{' '},num2str(ticket),{' '},'has been closed by MT4, please check if it is true') ));
        sendgmail(receiver, subject, content, mail, password)
        
        ms.machineStatus = 'closed';
        LogObj.trace('machine status',ms.machineStatus);
        
    end
end


if strcmp(ms.machineStatus,'opening')
    
    ms.tElapsedOpeningRequest = toc(tStartOpeningRequest);
    
    if (ms.tElapsedOpeningRequest) > tOpenRequest
        
        LogObj.error('error',num2str(cell2mat(strcat('no Status message received for opening the requested position after',{' '}, num2str(tOpenRequest),{' '},'seconds'))));
        LogObj.info('MATLAB info','We suppose that the requested operation has not been opened by MT4');                                 
        
        receiver = '4castersltd@gmail.com';
        mail     = '4castersltd@gmail.com';
        subject  = strcat(nameAlgo,': no Status message received for opening the requested position');
        content  = 'We suppose that the requested operation has not been opened by MT4, please check what happened';
        sendgmail(receiver, subject, content, mail, password)
        
        LogObj.info('MATLAB info','The status of the Algo will be resetted to closed');
        openValueReal = -1 ;
        startingOperation = 0;
        ms.machineStatus = 'closed';
        LogObj.trace('machine status',ms.machineStatus);
        ms.statusNotification = 0;
        
    end
end


if numberOf1minPoints == openingTimeScale;
    newTimeScalePointEnd = 1;
    numberOf1minPoints   = 0;
else
    newTimeScalePointEnd = 0;
end

if ( ( strcmp(ms.machineStatus,'closed') || strcmp(ms.machineStatus,'open') ) && ms.statusNotification == 0 )
    t=now;
    timeMin=t*60*24;
    [oper,openValue, closeValue, stopLoss, takeProfit, minReturn] = Algo_000_test(matrix,newTimeScalePoint,newTimeScalePointEnd,openValueReal,timeSeriesProperties,timeMin);
    
%     newState{1} = oper;
%     newState{2} = openValue;
%     newState{3} = closeValue;
%     newState{4} = stopLoss;
%     newState{5} = takeProfit;
%     newState{6} = minReturn;
    
    ms.lastOperation   = oper;
    ms.lastOpenValue   = openValue;
    ms.lastCloseValue  = closeValue;
    ms.stopLoss        = stopLoss;
    ms.takeProfit      = takeProfit;
    ms.minReturn       = minReturn;
    
    newTimeScalePoint = 0;
    
    if abs(ms.lastOperation) == 1
        LogObj.trace( 'MATLAB info', num2str(cell2mat(strcat(  'TP =',{' '},num2str(ms.takeProfit),{' '},'-',{' '},'SL =',{' '},num2str(ms.stopLoss)  ))) ) ;
    end
    
end

if abs(ms.lastOperation) > 0 && startingOperation == 0
    % Opening request
    % ACHTUNG: The SL and TP values are sent as tenths of pips, so we have
    % to multiply by 10 to get the correct pips. I also incremented the
    % numbers to avoid Metatrader to close automatically
    MT4stopL = 1000; %(stopLoss + 20) * 10;
    MT4takeP = 1500; %(takeProfit + 20) * 10;
    [topicPub,messagePub,startingOperation] = onlineOpen(ms.lastOperation,ms.lastOpenValue,operLots,operOpenSlippage,MT4stopL,MT4takeP,algoTopicPub,algoMagic,indexOpen);
    
    tStartOpeningRequest = tic;
    
    LogObj.info( 'MATLAB info', num2str(cell2mat(strcat( 'Matalb requests to open a new operation at the price',{' '},num2str(ms.lastOpenValue) ))) ) ;
    ms.machineStatus = 'opening';
    LogObj.trace('machine status',ms.machineStatus);
    
elseif (ms.lastOperation) == 0 && abs(startingOperation) > 0
    % Closing request
    [topicPub,messagePub,startingOperation] = onlineClose(ms.lastCloseValue,operLots,operCloseSlippage,ticket,algoTopicPub,algoMagic,indexClose);
    
    tStartClosingRequest = tic;
    
    LogObj.info( 'MATLAB info', num2str(cell2mat(strcat( 'Matalb requests to close the operation ',{' '},num2str(ticket),{' '},'at the price',{' '},num2str(ms.lastCloseValue) ))) ) ;
    ms.machineStatus = 'closing';
    LogObj.trace('machine status',ms.machineStatus);
    
end

logFileProperties=dir(logFile);
logFileDimension=logFileProperties.bytes;

clear newState
clear newStatus

% M = inmem;
% display (M);

end


