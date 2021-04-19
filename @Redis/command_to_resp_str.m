function resp_str = command_to_resp_str(obj, varargin)
    resp_str = sprintf('*%d%s', numel(varargin), obj.terminator);
    redis_strings = cellfun(@(x)  to_redis_string(x), varargin, 'UniformOutput', false);
    redis_strings(cellfun(@isempty, redis_strings)) = [];
    args = cellfun(@(x) {[sprintf('$%d%s', numel(x), obj.terminator), x]}, redis_strings);
    resp_str = [resp_str, strjoin(args, obj.terminator), obj.terminator];
end

function redis_str = to_redis_string(redis_str)
    if isstring(redis_str)
        redis_str = char(redis_str);
    end
    if isnumeric(redis_str)
        redis_str = num2str(redis_str);
    end
end            