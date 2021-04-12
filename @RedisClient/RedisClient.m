classdef RedisClient
   properties
       host char
       port {mustBeNumeric}
       password char = ''
       db {mustBeNumeric} = 0
   end
   methods
        function obj = RedisClient(host, port, varargin)

        end
        function r = ping(obj)
        end
        function r = send(obj, varargin)
        end
        function r = set(obj, varargin)
        end
        function r = get(obj, varargin)
        end
   end
end