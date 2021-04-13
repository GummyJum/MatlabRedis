classdef RedisClient < handle
   properties
       host char
       port {mustBeNumeric}
       password char = ''
       db {mustBeNumeric} = 0
       socket = []
       recv_buffer = []
       timeout = 2
       buffer_wait = 0.001
       CRNL = sprintf('\r\n')
   end
   methods
        function obj = RedisClient(host, port, varargin)
            obj.host = host;
            obj.port = port;
            
            obj.socket = tcpclient(obj.host, obj.port);
            
            ind = find(strcmpi('password', varargin), 1);
            if ~isempty(ind)
                obj.password = varargin{ind+1};
                obj.send('AUTH', obj.password);
            end
            ind = find(strcmpi('db', varargin), 1);
            if ~isempty(ind)
                obj.db = varargin{ind+1};
                obj.send('SELECT', sprintf('%d', obj.db));
            end
        end
        function r = ping(obj)
            r = obj.send('PING');
        end
        
        function dump_recv_buffer(obj)
            buff = [];
            total_wait = 0;
            while total_wait < obj.timeout                
                pause(obj.buffer_wait);
                while obj.socket.BytesAvailable
                    buff = [buff, obj.socket.read];
                end
                if ~isempty(buff)
                    obj.recv_buffer = [obj.recv_buffer, char(buff)];
                    return
                end
                total_wait = total_wait + obj.buffer_wait;
            end
            warning('redis timeout reached without any answer');
        end        
        
        function send_async(obj, varargin)
            buff = sprintf('*%d\r\n', numel(varargin));
            args = cellfun(@(x) {[sprintf('$%d\r\n', numel(x)), x]}, varargin);
            buff = [buff, strjoin(args, obj.CRNL), obj.CRNL];
            obj.socket.write(uint8(buff));            
        end
               
        function [r, status] = recv_async(obj, varargin)
            % we have 5 possible responses first char +-:$*
            r = [];
            status = 0;
            if isempty(obj.recv_buffer)
                obj.dump_recv_buffer;
            end
            lines = strsplit(obj.recv_buffer, obj.CRNL);
            
            while ~isempty(lines) && isempty(lines{1})
                lines = lines(2:end);
            end
            if isempty(lines)
                return;
            end
            
            if any(lines{1}(1) == '+-:')
                r = lines{1}(2:end);
                if lines{1}(1) == '-'
                    status = 1;
                end
                if lines{1}(1) == ':'
                    r = str2double(r);
                end
                obj.recv_buffer = strjoin(lines(2:end), obj.CRNL);
                return
            end
            
            if lines{1}(1) == '$'
                assert(length(lines) >= 2, 'data was not received as expected');
                r = lines{2};
                obj.recv_buffer = strjoin(lines(3:end), obj.CRNL);
                return
            end
            
            if lines{1}(1) == '*'
                n = str2double(lines{1}(2:end));
                obj.recv_buffer = strjoin(lines(2:end), obj.CRNL);
                r = cell(1, n);
                for ind = 1:n
                    r{ind} = obj.recv_async;
                end
                return
            end
                
            status = 1;
            r = obj.recv_buffer;
            obj.recv_buffer = [];   
            warning('could not parse RESP return raw response');
        end
        
        function [r, status] = send(obj, varargin)
            obj.send_async(varargin{:});
            [r, status] = obj.recv_async(varargin{:});
        end
        
        function r = set(obj, varargin)
            r = obj.send('SET', varargin{:});
        end
        
        function r = get(obj, varargin)
            r = obj.send('GET', varargin{:});
        end
   end
end