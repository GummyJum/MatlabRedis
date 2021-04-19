classdef Redis < handle
    properties
        host char
        port {mustBeNumeric}
        password char = ''
        db {mustBeNumeric} = 0
        timeout = 2
        read_wait = 0.001
    end
    
    properties (Access=private)
        socket = []
        multi_stack = []
        multi_counter = 0
        read_buffer = []
        terminator = sprintf('\r\n')
    end
        
    methods (Access=private, Static)
        hashStr = sha1(str)
        p = params;
    end
    methods (Access=private)  
        send_command(obj, varargin)
        res = socket_read(obj, mode)
        response = read_response(obj)
        resp_str = command_to_resp_str(obj, varargin)
    end
    
    methods
        function obj = Redis(host, port, varargin)
            obj.host = host;
            obj.port = port;
            
            try 
                obj.socket = tcpclient(obj.host, obj.port);
            catch err
                if strcmp(err.identifier, 'MATLAB:networklib:tcpclient:cannotCreateObject')
                    error('Unable to connect to Redis')
                else
                    error(err)
                end
            end
            
            ind = find(strcmpi('password', varargin), 1);
            if ~isempty(ind)
                obj.password = varargin{ind+1};
                obj.cmd('AUTH', obj.password);
            end
            ind = find(strcmpi('db', varargin), 1);
            if ~isempty(ind)
                obj.db = varargin{ind+1};
                obj.cmd('SELECT', sprintf('%d', obj.db));
            end
        end
        
        response = cmd(obj, varargin)
        
        function output = append(obj, key, value, varargin)
            % APPEND key value
            % Append a value to a key
            output = obj.cmd('APPEND', key, value, varargin);
        end
        
        function output = auth(obj, password, varargin)
            % AUTH password
            % Authenticate to the server
            output = obj.cmd('AUTH', password, varargin);
        end
        
        function output = bgrewriteaof(obj, varargin)
            % BGREWRITEAOF
            % Asynchronously rewrite the append-only file
            output = obj.cmd('BGREWRITEAOF', varargin);
        end
        
        function output = bgsave(obj, varargin)
            % BGSAVE
            % Asynchronously save the dataset to disk
            output = obj.cmd('BGSAVE', varargin);
        end
        
        function output = bitcount(obj, key, varargin)
            % BITCOUNT key [start end]
            % Count set bits in a string
            output = obj.cmd('BITCOUNT', key, varargin);
        end
        
        function output = bitfield(obj, key, varargin)
            % BITFIELD key [GET type offset] [SET type offset value] [INCRBY type offset increment] [OVERFLOW WRAP|SAT|FAIL]
            % Perform arbitrary bitfield integer operations on strings
            output = obj.cmd('BITFIELD', key, varargin);
        end
        
        function output = bitop(obj, operation, destkey, key, varargin)
            % BITOP operation destkey key [key ...]
            % Perform bitwise operations between strings
            output = obj.cmd('BITOP', operation, destkey, key, varargin);
        end
        
        function output = bitpos(obj, key, bit, varargin)
            % BITPOS key bit [start] [end]
            % Find first bit set or clear in a string
            output = obj.cmd('BITPOS', key, bit, varargin);
        end
        
        function output = blpop(obj, key, varargin)
            % BLPOP key [key ...] timeout
            % Remove and get the first element in a list, or block until one is available
            output = obj.cmd('BLPOP', key, varargin);
        end
        
        function output = brpop(obj, key, varargin)
            % BRPOP key [key ...] timeout
            % Remove and get the last element in a list, or block until one is available
            output = obj.cmd('BRPOP', key, varargin);
        end
        
        function output = brpoplpush(obj, source, destination, timeout, varargin)
            % BRPOPLPUSH source destination timeout
            % Pop a value from a list, push it to another list and return it; or block until one is available
            output = obj.cmd('BRPOPLPUSH', source, destination, timeout, varargin);
        end
        
        function output = client(obj, varargin)
            % CLIENT KILL [ip:port] [ID client-id] [TYPE normal|master|slave|pubsub] [ADDR ip:port] [SKIPME yes/no]
            % Kill the connection of a client
            % CLIENT LIST
            % Get the list of client connections
            % CLIENT GETNAME
            % Get the current connection name
            % CLIENT PAUSE timeout
            % Stop processing commands from clients for some time
            % CLIENT REPLY ON|OFF|SKIP
            % Instruct the server whether to reply to commands
            % CLIENT SETNAME connection-name
            % Set the current connection name
            output = obj.cmd('CLIENT', varargin);
        end
        
        function output = cluster(obj, varargin)
            % CLUSTER ADDSLOTS slot [slot ...]
            % Assign new hash slots to receiving node
            % CLUSTER COUNT-FAILURE-REPORTS node-id
            % Return the number of failure reports active for a given node
            % CLUSTER COUNTKEYSINSLOT slot
            % Return the number of local keys in the specified hash slot
            % CLUSTER DELSLOTS slot [slot ...]
            % Set hash slots as unbound in receiving node
            % CLUSTER FAILOVER [FORCE|TAKEOVER]
            % Forces a slave to perform a manual failover of its master.
            % CLUSTER FORGET node-id
            % Remove a node from the nodes table
            % CLUSTER GETKEYSINSLOT slot count
            % Return local key names in the specified hash slot
            % CLUSTER INFO
            % Provides info about Redis Cluster node state
            % CLUSTER KEYSLOT key
            % Returns the hash slot of the specified key
            % CLUSTER MEET ip port
            % Force a node cluster to handshake with another node
            % CLUSTER NODES
            % Get Cluster config for the node
            % CLUSTER REPLICATE node-id
            % Reconfigure a node as a slave of the specified master node
            % CLUSTER RESET [HARD|SOFT]
            % Reset a Redis Cluster node
            % CLUSTER SAVECONFIG
            % Forces the node to save cluster state on disk
            % CLUSTER SET-CONFIG-EPOCH config-epoch
            % Set the configuration epoch in a new node
            % CLUSTER SETSLOT slot IMPORTING|MIGRATING|STABLE|NODE [node-id]
            % Bind a hash slot to a specific node
            % CLUSTER SLAVES node-id
            % List slave nodes of the specified master node
            % CLUSTER SLOTS
            % Get array of Cluster slot to node mappings
            output = obj.cmd('CLUSTER', varargin);
        end
        
        function output = command(obj, varargin)
            % COMMAND
            % Get array of Redis command details
            % COMMAND COUNT
            % Get total number of Redis commands
            % COMMAND GETKEYS
            % Extract keys given a full Redis command
            % COMMAND INFO command-name [command-name ...]
            % Get array of specific Redis command details
            output = obj.cmd('COMMAND', varargin);
        end
        
        function output = config(obj, varargin)
            % CONFIG GET parameter
            % Get the value of a configuration parameter
            % CONFIG REWRITE
            % Rewrite the configuration file with the in memory configuration
            % CONFIG SET parameter value
            % Set a configuration parameter to the given value
            % CONFIG RESETSTAT
            % Reset the stats returned by INFO
            output = obj.cmd('CONFIG', varargin);
        end
        
        function output = dbsize(obj, varargin)
            % DBSIZE
            % Return the number of keys in the selected database
            output = obj.cmd('DBSIZE', varargin);
        end
        
        function output = debug(obj, varargin)
            % DEBUG OBJECT key
            % Get debugging information about a key
            % DEBUG SEGFAULT
            % Make the server crash
            output = obj.cmd('DEBUG', varargin);
        end
        
        function output = decr(obj, key, varargin)
            % DECR key
            % Decrement the integer value of a key by one
            output = obj.cmd('DECR', key, varargin);
        end
        
        function output = decrby(obj, key, decrement, varargin)
            % DECRBY key decrement
            % Decrement the integer value of a key by the given number
            output = obj.cmd('DECRBY', key, decrement, varargin);
        end
        
        function output = del(obj, key, varargin)
            % DEL key [key ...]
            % Delete a key
            output = obj.cmd('DEL', key, varargin);
        end
        
        function output = discard(obj, varargin)
            % DISCARD
            % Discard all commands issued after MULTI
            output = obj.cmd('DISCARD', varargin);
        end
        
        function output = dump(obj, key, varargin)
            % DUMP key
            % Return a serialized version of the value stored at the specified key.
            output = obj.cmd('DUMP', key, varargin);
        end
        
        function output = echo(obj, message, varargin)
            % ECHO message
            % Echo the given string
            output = obj.cmd('ECHO', message, varargin);
        end
        
        function output = eval(obj, script, numkeys, varargin)
            % EVAL script numkeys key [key ...] arg [arg ...]
            % Execute a Lua script server side
            if numel(script) < 30
                output = obj.cmd('EVAL', script, numkeys, varargin);
            else
                % Use Redis scripts bank
                script_sha1 = obj.sha1(script);
                output = obj.evalsha(script_sha1, numkeys, varargin);
                if strcmp(output, 'NOSCRIPT No matching script. Please use EVAL.')
                    if ~strcmp(obj.script('load', script), script_sha1)
                        error('unexpected sha');
                    end
                    output = obj.evalsha(script_sha1, numkeys, varargin);
                end
            end
        end
        
        function output = evalsha(obj, sha1, numkeys, varargin)
            % EVALSHA sha1 numkeys key [key ...] arg [arg ...]
            % Execute a Lua script server side
            output = obj.cmd('EVALSHA', sha1, numkeys, varargin);
        end
        
        function output = exec(obj, varargin)
            % EXEC
            % Execute all commands issued after MULTI
            output = obj.cmd('EXEC', varargin);
        end
        
        function output = exists(obj, key, varargin)
            % EXISTS key [key ...]
            % Determine if a key exists
            output = obj.cmd('EXISTS', key, varargin);
        end
        
        function output = expire(obj, key, seconds, varargin)
            % EXPIRE key seconds
            % Set a key's time to live in seconds
            output = obj.cmd('EXPIRE', key, seconds, varargin);
        end
        
        function output = expireat(obj, key, timestamp, varargin)
            % EXPIREAT key timestamp
            % Set the expiration for a key as a UNIX timestamp
            output = obj.cmd('EXPIREAT', key, timestamp, varargin);
        end
        
        function output = flushall(obj, varargin)
            % FLUSHALL [ASYNC]
            % Remove all keys from all databases
            output = obj.cmd('FLUSHALL', varargin);
        end
        
        function output = flushdb(obj, varargin)
            % FLUSHDB [ASYNC]
            % Remove all keys from the current database
            output = obj.cmd('FLUSHDB', varargin);
        end
        
        function output = geoadd(obj, key, longitude, latitude, member, varargin)
            % GEOADD key longitude latitude member [longitude latitude member ...]
            % Add one or more geospatial items in the geospatial index represented using a sorted set
            output = obj.cmd('GEOADD', key, longitude, latitude, member, varargin);
        end
        
        function output = geohash(obj, key, member, varargin)
            % GEOHASH key member [member ...]
            % Returns members of a geospatial index as standard geohash strings
            output = obj.cmd('GEOHASH', key, member, varargin);
        end
        
        function output = geopos(obj, key, member, varargin)
            % GEOPOS key member [member ...]
            % Returns longitude and latitude of members of a geospatial index
            output = obj.cmd('GEOPOS', key, member, varargin);
        end
        
        function output = geodist(obj, key, member1, member2, varargin)
            % GEODIST key member1 member2 [unit]
            % Returns the distance between two members of a geospatial index
            output = obj.cmd('GEODIST', key, member1, member2, varargin);
        end
        
        function output = georadius(obj, key, longitude, latitude, radius, m_km_ft_mi, varargin)
            % GEORADIUS key longitude latitude radius m|km|ft|mi [WITHCOORD] [WITHDIST] [WITHHASH] [COUNT count] [ASC|DESC] [STORE key] [STOREDIST key]
            % Query a sorted set representing a geospatial index to fetch members matching a given maximum distance from a point
            output = obj.cmd('GEORADIUS', key, longitude, latitude, radius, m_km_ft_mi, varargin);
        end
        
        function output = georadiusbymember(obj, key, member, radius, m_km_ft_mi, varargin)
            % GEORADIUSBYMEMBER key member radius m|km|ft|mi [WITHCOORD] [WITHDIST] [WITHHASH] [COUNT count] [ASC|DESC] [STORE key] [STOREDIST key]
            % Query a sorted set representing a geospatial index to fetch members matching a given maximum distance from a member
            output = obj.cmd('GEORADIUSBYMEMBER', key, member, radius, m_km_ft_mi, varargin);
        end
        
        function output = get(obj, key, varargin)
            % GET key
            % Get the value of a key
            output = obj.cmd('GET', key, varargin);
        end
        
        function output = getbit(obj, key, offset, varargin)
            % GETBIT key offset
            % Returns the bit value at offset in the string value stored at key
            output = obj.cmd('GETBIT', key, offset, varargin);
        end
        
        function output = getrange(obj, key, start, range_end, varargin)
            % GETRANGE key start end
            % Get a substring of the string stored at a key
            output = obj.cmd('GETRANGE', key, start, range_end, varargin);
        end
        
        function output = getset(obj, key, value, varargin)
            % GETSET key value
            % Set the string value of a key and return its old value
            output = obj.cmd('GETSET', key, value, varargin);
        end
        
        function output = hdel(obj, key, field, varargin)
            % HDEL key field [field ...]
            % Delete one or more hash fields
            output = obj.cmd('HDEL', key, field, varargin);
        end
        
        function output = hexists(obj, key, field, varargin)
            % HEXISTS key field
            % Determine if a hash field exists
            output = obj.cmd('HEXISTS', key, field, varargin);
        end
        
        function output = hget(obj, key, field, varargin)
            % HGET key field
            % Get the value of a hash field
            output = obj.cmd('HGET', key, field, varargin);
        end
        
        function output = hgetall(obj, key, varargin)
            % HGETALL key
            % Get all the fields and values in a hash
            output = obj.cmd('HGETALL', key, varargin);
        end
        
        function output = hincrby(obj, key, field, increment, varargin)
            % HINCRBY key field increment
            % Increment the integer value of a hash field by the given number
            output = obj.cmd('HINCRBY', key, field, increment, varargin);
        end
        
        function output = hincrbyfloat(obj, key, field, increment, varargin)
            % HINCRBYFLOAT key field increment
            % Increment the float value of a hash field by the given amount
            output = obj.cmd('HINCRBYFLOAT', key, field, increment, varargin);
        end
        
        function output = hkeys(obj, key, varargin)
            % HKEYS key
            % Get all the fields in a hash
            output = obj.cmd('HKEYS', key, varargin);
        end
        
        function output = hlen(obj, key, varargin)
            % HLEN key
            % Get the number of fields in a hash
            output = obj.cmd('HLEN', key, varargin);
        end
        
        function output = hmget(obj, key, field, varargin)
            % HMGET key field [field ...]
            % Get the values of all the given hash fields
            output = obj.cmd('HMGET', key, field, varargin);
        end
        
        function output = hmset(obj, key, field, value, varargin)
            % HMSET key field value [field value ...]
            % Set multiple hash fields to multiple values
            output = obj.cmd('HMSET', key, field, value, varargin);
        end
        
        function output = hset(obj, key, field, value, varargin)
            % HSET key field value
            % Set the string value of a hash field
            output = obj.cmd('HSET', key, field, value, varargin);
        end
        
        function output = hsetnx(obj, key, field, value, varargin)
            % HSETNX key field value
            % Set the value of a hash field, only if the field does not exist
            output = obj.cmd('HSETNX', key, field, value, varargin);
        end
        
        function output = hstrlen(obj, key, field, varargin)
            % HSTRLEN key field
            % Get the length of the value of a hash field
            output = obj.cmd('HSTRLEN', key, field, varargin);
        end
        
        function output = hvals(obj, key, varargin)
            % HVALS key
            % Get all the values in a hash
            output = obj.cmd('HVALS', key, varargin);
        end
        
        function output = incr(obj, key, varargin)
            % INCR key
            % Increment the integer value of a key by one
            output = obj.cmd('INCR', key, varargin);
        end
        
        function output = incrby(obj, key, increment, varargin)
            % INCRBY key increment
            % Increment the integer value of a key by the given amount
            output = obj.cmd('INCRBY', key, increment, varargin);
        end
        
        function output = incrbyfloat(obj, key, increment, varargin)
            % INCRBYFLOAT key increment
            % Increment the float value of a key by the given amount
            output = obj.cmd('INCRBYFLOAT', key, increment, varargin);
        end
        
        function output = info(obj, varargin)
            % INFO [section]
            % Get information and statistics about the server
            output = obj.cmd('INFO', varargin);
        end
        
        function output = keys(obj, pattern, varargin)
            % KEYS pattern
            % Find all keys matching the given pattern
            output = obj.cmd('KEYS', pattern, varargin);
        end
        
        function output = lastsave(obj, varargin)
            % LASTSAVE
            % Get the UNIX time stamp of the last successful save to disk
            output = obj.cmd('LASTSAVE', varargin);
        end
        
        function output = lindex(obj, key, index, varargin)
            % LINDEX key index
            % Get an element from a list by its index
            output = obj.cmd('LINDEX', key, index, varargin);
        end
        
        function output = linsert(obj, key, BEFORE_AFTER, pivot, value, varargin)
            % LINSERT key BEFORE|AFTER pivot value
            % Insert an element before or after another element in a list
            output = obj.cmd('LINSERT', key, BEFORE_AFTER, pivot, value, varargin);
        end
        
        function output = llen(obj, key, varargin)
            % LLEN key
            % Get the length of a list
            output = obj.cmd('LLEN', key, varargin);
        end
        
        function output = lpop(obj, key, varargin)
            % LPOP key
            % Remove and get the first element in a list
            output = obj.cmd('LPOP', key, varargin);
        end
        
        function output = lpush(obj, key, value, varargin)
            % LPUSH key value [value ...]
            % Prepend one or multiple values to a list
            output = obj.cmd('LPUSH', key, value, varargin);
        end
        
        function output = lpushx(obj, key, value, varargin)
            % LPUSHX key value
            % Prepend a value to a list, only if the list exists
            output = obj.cmd('LPUSHX', key, value, varargin);
        end
        
        function output = lrange(obj, key, start, stop, varargin)
            % LRANGE key start stop
            % Get a range of elements from a list
            output = obj.cmd('LRANGE', key, start, stop, varargin);
        end
        
        function output = lrem(obj, key, count, value, varargin)
            % LREM key count value
            % Remove elements from a list
            output = obj.cmd('LREM', key, count, value, varargin);
        end
        
        function output = lset(obj, key, index, value, varargin)
            % LSET key index value
            % Set the value of an element in a list by its index
            output = obj.cmd('LSET', key, index, value, varargin);
        end
        
        function output = ltrim(obj, key, start, stop, varargin)
            % LTRIM key start stop
            % Trim a list to the specified range
            output = obj.cmd('LTRIM', key, start, stop, varargin);
        end
        
        function output = mget(obj, key, varargin)
            % MGET key [key ...]
            % Get the values of all the given keys
            output = obj.cmd('MGET', key, varargin);
        end
        
        function output = migrate(obj, host, port, key, destination_db, timeout, varargin)
            % MIGRATE host port key|"" destination-db timeout [COPY] [REPLACE] [KEYS key [key ...]]
            % Atomically transfer a key from a Redis instance to another one.
            output = obj.cmd('MIGRATE', host, port, key, destination_db, timeout, varargin);
        end
        
        function output = monitor(obj, varargin)
            % MONITOR
            % Listen for all requests received by the server in real time
            output = obj.cmd('MONITOR', varargin);
        end
        
        function output = move(obj, key, db, varargin)
            % MOVE key db
            % Move a key to another database
            output = obj.cmd('MOVE', key, db, varargin);
        end
        
        function output = mset(obj, key, value, varargin)
            % MSET key value [key value ...]
            % Set multiple keys to multiple values
            output = obj.cmd('MSET', key, value, varargin);
        end
        
        function output = msetnx(obj, key, value, varargin)
            % MSETNX key value [key value ...]
            % Set multiple keys to multiple values, only if none of the keys exist
            output = obj.cmd('MSETNX', key, value, varargin);
        end
        
        function output = multi(obj, varargin)
            % MULTI
            % Mark the start of a transaction block
            output = obj.cmd('MULTI', varargin);
        end
        
        function output = object(obj, subcommand, varargin)
            % OBJECT subcommand [arguments [arguments ...]]
            % Inspect the internals of Redis objects
            output = obj.cmd('OBJECT', subcommand, varargin);
        end
        
        function output = persist(obj, key, varargin)
            % PERSIST key
            % Remove the expiration from a key
            output = obj.cmd('PERSIST', key, varargin);
        end
        
        function output = pexpire(obj, key, milliseconds, varargin)
            % PEXPIRE key milliseconds
            % Set a key's time to live in milliseconds
            output = obj.cmd('PEXPIRE', key, milliseconds, varargin);
        end
        
        function output = pexpireat(obj, key, milliseconds_timestamp, varargin)
            % PEXPIREAT key milliseconds-timestamp
            % Set the expiration for a key as a UNIX timestamp specified in milliseconds
            output = obj.cmd('PEXPIREAT', key, milliseconds_timestamp, varargin);
        end
        
        function output = pfadd(obj, key, element, varargin)
            % PFADD key element [element ...]
            % Adds the specified elements to the specified HyperLogLog.
            output = obj.cmd('PFADD', key, element, varargin);
        end
        
        function output = pfcount(obj, key, varargin)
            % PFCOUNT key [key ...]
            % Return the approximated cardinality of the set(s) observed by the HyperLogLog at key(s).
            output = obj.cmd('PFCOUNT', key, varargin);
        end
        
        function output = pfmerge(obj, destkey, sourcekey, varargin)
            % PFMERGE destkey sourcekey [sourcekey ...]
            % Merge N different HyperLogLogs into a single one.
            output = obj.cmd('PFMERGE', destkey, sourcekey, varargin);
        end
        
        function output = ping(obj, varargin)
            % PING [message]
            % Ping the server
            output = obj.cmd('PING', varargin);
        end
        
        function output = psetex(obj, key, milliseconds, value, varargin)
            % PSETEX key milliseconds value
            % Set the value and expiration in milliseconds of a key
            output = obj.cmd('PSETEX', key, milliseconds, value, varargin);
        end
        
        function output = psubscribe(obj, pattern, varargin)
            % PSUBSCRIBE pattern [pattern ...]
            % Listen for messages published to channels matching the given patterns
            output = obj.cmd('PSUBSCRIBE', pattern, varargin);
        end
        
        function output = pubsub(obj, subcommand, varargin)
            % PUBSUB subcommand [argument [argument ...]]
            % Inspect the state of the Pub/Sub subsystem
            output = obj.cmd('PUBSUB', subcommand, varargin);
        end
        
        function output = pttl(obj, key, varargin)
            % PTTL key
            % Get the time to live for a key in milliseconds
            output = obj.cmd('PTTL', key, varargin);
        end
        
        function output = publish(obj, channel, message, varargin)
            % PUBLISH channel message
            % Post a message to a channel
            output = obj.cmd('PUBLISH', channel, message, varargin);
        end
        
        function output = punsubscribe(obj, varargin)
            % PUNSUBSCRIBE [pattern [pattern ...]]
            % Stop listening for messages posted to channels matching the given patterns
            output = obj.cmd('PUNSUBSCRIBE', varargin);
        end
        
        function output = quit(obj, varargin)
            % QUIT
            % Close the connection
            output = obj.cmd('QUIT', varargin);
        end
        
        function output = randomkey(obj, varargin)
            % RANDOMKEY
            % Return a random key from the keyspace
            output = obj.cmd('RANDOMKEY', varargin);
        end
        
        function output = readonly(obj, varargin)
            % READONLY
            % Enables read queries for a connection to a cluster slave node
            output = obj.cmd('READONLY', varargin);
        end
        
        function output = readwrite(obj, varargin)
            % READWRITE
            % Disables read queries for a connection to a cluster slave node
            output = obj.cmd('READWRITE', varargin);
        end
        
        function output = rename(obj, key, newkey, varargin)
            % RENAME key newkey
            % Rename a key
            output = obj.cmd('RENAME', key, newkey, varargin);
        end
        
        function output = renamenx(obj, key, newkey, varargin)
            % RENAMENX key newkey
            % Rename a key, only if the new key does not exist
            output = obj.cmd('RENAMENX', key, newkey, varargin);
        end
        
        function output = restore(obj, varargin)
            % RESTORE key ttl serialized-value [REPLACE]
            % Rename a key, only if the new key does not exist
            % RESTORE key ttl serialized-value [REPLACE]
            % Create a key using the provided serialized value, previously obtained using DUMP.
            output = obj.cmd('RESTORE', varargin);
        end
        
        function output = role(obj, varargin)
            % ROLE
            % Return the role of the instance in the context of replication
            output = obj.cmd('ROLE', varargin);
        end
        
        function output = rpop(obj, key, varargin)
            % RPOP key
            % Remove and get the last element in a list
            output = obj.cmd('RPOP', key, varargin);
        end
        
        function output = rpoplpush(obj, source, destination, varargin)
            % RPOPLPUSH source destination
            % Remove the last element in a list, prepend it to another list and return it
            output = obj.cmd('RPOPLPUSH', source, destination, varargin);
        end
        
        function output = rpush(obj, key, value, varargin)
            % RPUSH key value [value ...]
            % Append one or multiple values to a list
            output = obj.cmd('RPUSH', key, value, varargin);
        end
        
        function output = rpushx(obj, key, value, varargin)
            % RPUSHX key value
            % Append a value to a list, only if the list exists
            output = obj.cmd('RPUSHX', key, value, varargin);
        end
        
        function output = sadd(obj, key, member, varargin)
            % SADD key member [member ...]
            % Add one or more members to a set
            output = obj.cmd('SADD', key, member, varargin);
        end
        
        function output = save(obj, varargin)
            % SAVE
            % Synchronously save the dataset to disk
            output = obj.cmd('SAVE', varargin);
        end
        
        function output = scard(obj, key, varargin)
            % SCARD key
            % Get the number of members in a set
            output = obj.cmd('SCARD', key, varargin);
        end
        
        function output = script(obj, varargin)
            % SCRIPT DEBUG YES|SYNC|NO
            % Set the debug mode for executed scripts.
            % SCRIPT EXISTS sha1 [sha1 ...]
            % Check existence of scripts in the script cache.
            % SCRIPT FLUSH
            % Remove all the scripts from the script cache.
            % SCRIPT KILL
            % Kill the script currently in execution.
            % SCRIPT LOAD script
            % Load the specified Lua script into the script cache.
            output = obj.cmd('SCRIPT', varargin);
        end
        
        function output = sdiff(obj, key, varargin)
            % SDIFF key [key ...]
            % Subtract multiple sets
            output = obj.cmd('SDIFF', key, varargin);
        end
        
        function output = sdiffstore(obj, destination, key, varargin)
            % SDIFFSTORE destination key [key ...]
            % Subtract multiple sets and store the resulting set in a key
            output = obj.cmd('SDIFFSTORE', destination, key, varargin);
        end
        
        function output = select(obj, index, varargin)
            % SELECT index
            % Change the selected database for the current connection
            output = obj.cmd('SELECT', index, varargin);
        end
        
        function output = set(obj, key, value, varargin)
            % SET key value [EX seconds] [PX milliseconds] [NX|XX]
            % Set the string value of a key
            output = obj.cmd('SET', key, value, varargin);
        end
        
        function output = setbit(obj, key, offset, value, varargin)
            % SETBIT key offset value
            % Sets or clears the bit at offset in the string value stored at key
            output = obj.cmd('SETBIT', key, offset, value, varargin);
        end
        
        function output = setex(obj, key, seconds, value, varargin)
            % SETEX key seconds value
            % Set the value and expiration of a key
            output = obj.cmd('SETEX', key, seconds, value, varargin);
        end
        
        function output = setnx(obj, key, value, varargin)
            % SETNX key value
            % Set the value of a key, only if the key does not exist
            output = obj.cmd('SETNX', key, value, varargin);
        end
        
        function output = setrange(obj, key, offset, value, varargin)
            % SETRANGE key offset value
            % Overwrite part of a string at key starting at the specified offset
            output = obj.cmd('SETRANGE', key, offset, value, varargin);
        end
        
        function output = shutdown(obj, varargin)
            % SHUTDOWN [NOSAVE|SAVE]
            % Synchronously save the dataset to disk and then shut down the server
            output = obj.cmd('SHUTDOWN', varargin);
        end
        
        function output = sinter(obj, key, varargin)
            % SINTER key [key ...]
            % Intersect multiple sets
            output = obj.cmd('SINTER', key, varargin);
        end
        
        function output = sinterstore(obj, destination, key, varargin)
            % SINTERSTORE destination key [key ...]
            % Intersect multiple sets and store the resulting set in a key
            output = obj.cmd('SINTERSTORE', destination, key, varargin);
        end
        
        function output = sismember(obj, key, member, varargin)
            % SISMEMBER key member
            % Determine if a given value is a member of a set
            output = obj.cmd('SISMEMBER', key, member, varargin);
        end
        
        function output = slaveof(obj, host, port, varargin)
            % SLAVEOF host port
            % Make the server a slave of another instance, or promote it as master
            output = obj.cmd('SLAVEOF', host, port, varargin);
        end
        
        function output = slowlog(obj, subcommand, varargin)
            % SLOWLOG subcommand [argument]
            % Manages the Redis slow queries log
            output = obj.cmd('SLOWLOG', subcommand, varargin);
        end
        
        function output = smembers(obj, key, varargin)
            % SMEMBERS key
            % Get all the members in a set
            output = obj.cmd('SMEMBERS', key, varargin);
        end
        
        function output = smove(obj, source, destination, member, varargin)
            % SMOVE source destination member
            % Move a member from one set to another
            output = obj.cmd('SMOVE', source, destination, member, varargin);
        end
        
        function output = sort(obj, key, varargin)
            % SORT key [BY pattern] [LIMIT offset count] [GET pattern [GET pattern ...]] [ASC|DESC] [ALPHA] [STORE destination]
            % Sort the elements in a list, set or sorted set
            output = obj.cmd('SORT', key, varargin);
        end
        
        function output = spop(obj, key, varargin)
            % SPOP key [count]
            % Remove and return one or multiple random members from a set
            output = obj.cmd('SPOP', key, varargin);
        end
        
        function output = srandmember(obj, key, varargin)
            % SRANDMEMBER key [count]
            % Get one or multiple random members from a set
            output = obj.cmd('SRANDMEMBER', key, varargin);
        end
        
        function output = srem(obj, key, member, varargin)
            % SREM key member [member ...]
            % Remove one or more members from a set
            output = obj.cmd('SREM', key, member, varargin);
        end
        
        function output = strlen(obj, key, varargin)
            % STRLEN key
            % Get the length of the value stored in a key
            output = obj.cmd('STRLEN', key, varargin);
        end
        
        function output = subscribe(obj, channel, varargin)
            % SUBSCRIBE channel [channel ...]
            % Listen for messages published to the given channels
            output = obj.cmd('SUBSCRIBE', channel, varargin);
        end
        
        function output = sunion(obj, key, varargin)
            % SUNION key [key ...]
            % Add multiple sets
            output = obj.cmd('SUNION', key, varargin);
        end
        
        function output = sunionstore(obj, destination, key, varargin)
            % SUNIONSTORE destination key [key ...]
            % Add multiple sets and store the resulting set in a key
            output = obj.cmd('SUNIONSTORE', destination, key, varargin);
        end
        
        function output = swapdb(obj, index1, index2, varargin)
            % SWAPDB index index
            % Swaps two Redis databases
            output = obj.cmd('SWAPDB', index1, index2, varargin);
        end
        
        function output = sync(obj, varargin)
            % SYNC
            % Internal command used for replication
            output = obj.cmd('SYNC', varargin);
        end
        
        function output = time(obj, varargin)
            % TIME
            % Return the current server time
            output = obj.cmd('TIME', varargin);
        end
        
        function output = touch(obj, key, varargin)
            % TOUCH key [key ...]
            % Alters the last access time of a key(s). Returns the number of existing keys specified.
            output = obj.cmd('TOUCH', key, varargin);
        end
        
        function output = ttl(obj, key, varargin)
            % TTL key
            % Get the time to live for a key
            output = obj.cmd('TTL', key, varargin);
        end
        
        function output = type(obj, key, varargin)
            % TYPE key
            % Determine the type stored at key
            output = obj.cmd('TYPE', key, varargin);
        end
        
        function output = unsubscribe(obj, varargin)
            % UNSUBSCRIBE [channel [channel ...]]
            % Stop listening for messages posted to the given channels
            output = obj.cmd('UNSUBSCRIBE', varargin);
        end
        
        function output = unlink(obj, key, varargin)
            % UNLINK key [key ...]
            % Delete a key asynchronously in another thread. Otherwise it is just as DEL, but non blocking.
            output = obj.cmd('UNLINK', key, varargin);
        end
        
        function output = unwatch(obj, varargin)
            % UNWATCH
            % Forget about all watched keys
            output = obj.cmd('UNWATCH', varargin);
        end
        
        function output = wait(obj, numslaves, timeout, varargin)
            % WAIT numslaves timeout
            % Wait for the synchronous replication of all the write commands sent in the context of the current connection
            output = obj.cmd('WAIT', numslaves, timeout, varargin);
        end
        
        function output = watch(obj, key, varargin)
            % WATCH key [key ...]
            % Watch the given keys to determine execution of the MULTI/EXEC block
            output = obj.cmd('WATCH', key, varargin);
        end
        
        function output = zadd(obj, key, varargin)
            % ZADD key [NX|XX] [CH] [INCR] score member [score member ...]
            % Add one or more members to a sorted set, or update its score if it already exists
            output = obj.cmd('ZADD', key, varargin);
        end
        
        function output = zcard(obj, key, varargin)
            % ZCARD key
            % Get the number of members in a sorted set
            output = obj.cmd('ZCARD', key, varargin);
        end
        
        function output = zcount(obj, key, min, max, varargin)
            % ZCOUNT key min max
            % Count the members in a sorted set with scores within the given values
            output = obj.cmd('ZCOUNT', key, min, max, varargin);
        end
        
        function output = zincrby(obj, key, increment, member, varargin)
            % ZINCRBY key increment member
            % Increment the score of a member in a sorted set
            output = obj.cmd('ZINCRBY', key, increment, member, varargin);
        end
        
        function output = zinterstore(obj, destination, numkeys, key, varargin)
            % ZINTERSTORE destination numkeys key [key ...] [WEIGHTS weight [weight ...]] [AGGREGATE SUM|MIN|MAX]
            % Intersect multiple sorted sets and store the resulting sorted set in a new key
            output = obj.cmd('ZINTERSTORE', destination, numkeys, key, varargin);
        end
        
        function output = zlexcount(obj, key, min, max, varargin)
            % ZLEXCOUNT key min max
            % Count the number of members in a sorted set between a given lexicographical range
            output = obj.cmd('ZLEXCOUNT', key, min, max, varargin);
        end
        
        function output = zrange(obj, key, start, stop, varargin)
            % ZRANGE key start stop [WITHSCORES]
            % Return a range of members in a sorted set, by index
            output = obj.cmd('ZRANGE', key, start, stop, varargin);
        end
        
        function output = zrangebylex(obj, key, min, max, varargin)
            % ZRANGEBYLEX key min max [LIMIT offset count]
            % Return a range of members in a sorted set, by lexicographical range
            output = obj.cmd('ZRANGEBYLEX', key, min, max, varargin);
        end
        
        function output = zrevrangebylex(obj, key, max, min, varargin)
            % ZREVRANGEBYLEX key max min [LIMIT offset count]
            % Return a range of members in a sorted set, by lexicographical range, ordered from higher to lower strings.
            output = obj.cmd('ZREVRANGEBYLEX', key, max, min, varargin);
        end
        
        function output = zrangebyscore(obj, key, min, max, varargin)
            % ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT offset count]
            % Return a range of members in a sorted set, by score
            output = obj.cmd('ZRANGEBYSCORE', key, min, max, varargin);
        end
        
        function output = zrank(obj, key, member, varargin)
            % ZRANK key member
            % Determine the index of a member in a sorted set
            output = obj.cmd('ZRANK', key, member, varargin);
        end
        
        function output = zrem(obj, key, member, varargin)
            % ZREM key member [member ...]
            % Remove one or more members from a sorted set
            output = obj.cmd('ZREM', key, member, varargin);
        end
        
        function output = zremrangebylex(obj, key, min, max, varargin)
            % ZREMRANGEBYLEX key min max
            % Remove all members in a sorted set between the given lexicographical range
            output = obj.cmd('ZREMRANGEBYLEX', key, min, max, varargin);
        end
        
        function output = zremrangebyrank(obj, key, start, stop, varargin)
            % ZREMRANGEBYRANK key start stop
            % Remove all members in a sorted set within the given indexes
            output = obj.cmd('ZREMRANGEBYRANK', key, start, stop, varargin);
        end
        
        function output = zremrangebyscore(obj, key, min, max, varargin)
            % ZREMRANGEBYSCORE key min max
            % Remove all members in a sorted set within the given scores
            output = obj.cmd('ZREMRANGEBYSCORE', key, min, max, varargin);
        end
        
        function output = zrevrange(obj, key, start, stop, varargin)
            % ZREVRANGE key start stop [WITHSCORES]
            % Return a range of members in a sorted set, by index, with scores ordered from high to low
            output = obj.cmd('ZREVRANGE', key, start, stop, varargin);
        end
        
        function output = zrevrangebyscore(obj, key, max, min, varargin)
            % ZREVRANGEBYSCORE key max min [WITHSCORES] [LIMIT offset count]
            % Return a range of members in a sorted set, by score, with scores ordered from high to low
            output = obj.cmd('ZREVRANGEBYSCORE', key, max, min, varargin);
        end
        
        function output = zrevrank(obj, key, member, varargin)
            % ZREVRANK key member
            % Determine the index of a member in a sorted set, with scores ordered from high to low
            output = obj.cmd('ZREVRANK', key, member, varargin);
        end
        
        function output = zscore(obj, key, member, varargin)
            % ZSCORE key member
            % Get the score associated with the given member in a sorted set
            output = obj.cmd('ZSCORE', key, member, varargin);
        end
        
        function output = zunionstore(obj, destination, numkeys, key, varargin)
            % ZUNIONSTORE destination numkeys key [key ...] [WEIGHTS weight [weight ...]] [AGGREGATE SUM|MIN|MAX]
            % Add multiple sorted sets and store the resulting sorted set in a new key
            output = obj.cmd('ZUNIONSTORE', destination, numkeys, key, varargin);
        end
        
        function output = scan(obj, cursor, varargin)
            % SCAN cursor [MATCH pattern] [COUNT count]
            % Incrementally iterate the keys space
            output = obj.cmd('SCAN', cursor, varargin);
        end
        
        function output = sscan(obj, key, cursor, varargin)
            % SSCAN key cursor [MATCH pattern] [COUNT count]
            % Incrementally iterate Set elements
            output = obj.cmd('SSCAN', key, cursor, varargin);
        end
        
        function output = hscan(obj, key, cursor, varargin)
            % HSCAN key cursor [MATCH pattern] [COUNT count]
            % Incrementally iterate hash fields and associated values
            output = obj.cmd('HSCAN', key, cursor, varargin);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%% New Functionality %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = list2json(obj, list_name)
            % Get a list from redis in json format.
            lua_code = 'return cjson.encode(redis.call(''LRANGE'', KEYS[1], 0, -1));';
            output = obj.eval(lua_code, 1, list_name);
        end
    end
end