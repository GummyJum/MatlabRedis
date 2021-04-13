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
            r = obj.send('ping');
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
            crnl = sprintf('\r\n');
            buff = sprintf('*%d\r\n', numel(varargin));
            args = cellfun(@(x) {[sprintf('$%d\r\n', numel(x)), x]}, varargin);
            buff = [buff, strjoin(args, crnl), crnl];
            fprintf('sending:\r\n%s', buff);
            obj.socket.write(uint8(buff));            
        end
        
        function r = recv_async(obj, varargin)
            % we have 5 possible responses first char +-:$*
            obj.dump_recv_buffer;
            r = obj.recv_buffer;
            obj.recv_buffer = [];
            % we should now have
            fprintf('received:\r\n%s', r);            
        end
        function r = send(obj, varargin)
            obj.send_async(varargin{:});
            r = obj.recv_async(varargin{:});
        end
        function r = set(obj, varargin)
            r = obj.send('set', varargin);
        end
        function r = get(obj, varargin)
            r = obj.send('get', varargin);
        end
   end
end