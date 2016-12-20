function testAlgo(name,id,vectorOperations,from,to,platform,broker)


%dataOrigin = {'@EURGBP@m1@v5','@EURUSD@m5@v10'};
%finalString = 'SKIP@ACTIVTRADES@9999 ';
finalString = '';
dataForConsole = '';
arrCross = {};
for data = vectorOperations
  fprintf('%s\n',data{1});
  partialString = '';
  C = strsplit(data{1},'@');
  partialStringForDataConsole = sprintf('$%s@%s@%s',C{1},C{2},C{3} );
  isMember = any(ismember(C{1},arrCross));
  if isMember == 1
    partialString = sprintf(' TIMEFRAMEQUOTE@MT4@ACTIVTRADES@%s@%s@%s ',C{1},C{2},C{3} );
    %partialString = strcat(partialString,partialString2);
  else
    arrCross{end+1} = C{1};
    display(arrCross);
    partialString = sprintf(' OPERATIONS@ACTIVTRADES@%s@9999 STATUS@%s@9999 TIMEFRAMEQUOTE@MT4@ACTIVTRADES@%s@%s@%s SKIP@ACTIVTRADES@%s@9999 ',C{1},C{1},C{1},C{2},C{3},C{1} );
  end
    %finalString = strcat(finalString,partialString);
    finalString = strcat(finalString,partialString);
    dataForConsole = strcat(dataForConsole,partialStringForDataConsole);
end
fprintf('%s\n',finalString);
%OPERATIONS@ACTIVTRADES@EURUSD@9999 STATUS@EURUSD@9999 TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v5 SKIP@ACTIVTRADES@EURUSD@9999


context = zmq.core.ctx_new();
socket = zmq.core.socket(context, 'ZMQ_SUB');
zmq.core.setsockopt(socket, 'ZMQ_SUBSCRIBE', 'STARTBACKTESTSETPORTS');
zmq.core.setsockopt(socket, 'ZMQ_SUBSCRIBE', 'BACKTESTDATAREADY');
contextPub = zmq.core.ctx_new();
socket_pub = zmq.core.socket(contextPub, 'ZMQ_PUB');
% SET SUBSCRIBE SOCKET
port = 68998;
net = '127.0.0.1';
add = strcat('tcp://',net,':%d');
address = sprintf(add, port);
zmq.core.connect(socket, address);
%SET PUBLISHER SOCKET
portPub = 68909;
pubPortStartBacktest = '';
subPortStartBacktest = '';
addressPub = sprintf(add, portPub);
zmq.core.connect(socket_pub, addressPub);

pause(5);

newTopicPub = 'STARTBACKTESTFROMCLIENT';
%paramArr = [{'cross':'EURGBP','timeFrame':'m1','dataLenght':'v5'}];
%$scope.startBacktest( paramArr, '2016-01-20 13:47', '2016-02-05 14:04', 'MT4', 'ACTIVTRADES' );
partialStringConsoleSetting = sprintf('%s@%s@%s@%s@',platform,broker,from,to);
messageBody = strcat(partialStringConsoleSetting,dataForConsole);
zmq.core.send(socket_pub, uint8(newTopicPub), 'ZMQ_SNDMORE');
zmq.core.send(socket_pub, uint8(messageBody)); 

ready = true;
while ready
    try
        message = char(zmq.core.recv(socket, 102400));
    catch ME
        display(ME.identifier);
        zmq.core.disconnect(socket, address);
        zmq.core.disconnect(socket_pub, addressPub);
        
        zmq.core.connect(socket, address);
        zmq.core.connect(socket_pub, addressPub);
        display('Reconnecting...');
        continue;
    end
    topicName = message;
    listener1 = strcmp(topicName,'STARTBACKTESTSETPORTS');
    if listener1 == 1
        messageBody = char(zmq.core.recv(socket, 102400));
        fprintf('%s\n',messageBody);
        % 1234@5678
        ports = strsplit(messageBody,'@');
        pubPortStartBacktest = ports{1};
        subPortStartBacktest = ports{2};  
        fprintf('%s %s\n',pubPortStartBacktest,subPortStartBacktest);
    end
    listener2 = strcmp(topicName,'BACKTESTDATAREADY');
    if listener2 == 1
        messageBody = char(zmq.core.recv(socket, 102400));
        fprintf('%s\n',messageBody);
  
        ready = false;
        
        executionStringParamsPartial = sprintf('C:\\Users\\FX64\\Desktop\\matlab_algo_1474108596023\\TEST2\\for_redistribution_files_only\\TEST2.exe 127.0.0.1 %s %s ',pubPortStartBacktest,subPortStartBacktest);
        executionStringParams = strcat([executionStringParamsPartial,' ',finalString]);

        %output=system('C:\Users\FX64\Desktop\matlab_algo_1474108596023\TEST1\for_redistribution_files_only\TEST1.exe 127.0.0.1 53651 53652 OPERATIONS@ACTIVTRADES@EURGBP@9999 STATUS@EURGBP@9999 TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURGBP@m1@v5 SKIP')
        fprintf('%s \n',executionStringParams);
        output=system(executionStringParams);
        fprintf('%s \n',output);
        %'
         %"C:\Users\FX64\Desktop\matlab_algo_1474108596023\TEST1\for_redistribution_files_only\TEST1.exe"
         %127.0.0.1 
         %53651 
         %53652 
         %OPERATIONS@ACTIVTRADES@EURGBP@9999 
         %STATUS@EURGBP@9999 
         %TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURGBP@m1@v5 
         %SKIP@ACTIVTRADES@EURGBP@9999   
    end
    
end



end