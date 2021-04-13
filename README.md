# MatlabRedis
Pure Matlab Redis interface for Matlab>=2014B

## API:
```Matlab
r = RedisClient(<host>, <port>, ['password', password=''], ['db', db=0])
>>
r.ping
>>
r.send(<cmd>, <args...>)
>>
r.set('tmp', 1)
>>
tmp = r.get('tmp')
>>
```

## Related Projects
There are few similar packages
- [GNU Octave redis client (go-redis - the official redis matlab/octave interface)](https://github.com/markuman/go-redis)
- [redis-mex (similar to the above but has different interface)](https://github.com/svdev/redis-matlab-mex)
- [Redis Matlab (pure Matlab implementation)](https://github.com/dantswain/redis-matlab)

The former two packages are based on the Hiredis library and require compilation. 
The third is a Matlab implementation is not supported on newer versions of Matlab (>=2014B) 
while also is not fully consistent with the RESP protocol.

This project implements an intuitive object-like interface for Redis without any other requirement or setup other then matlab itself.

## References

- [Redis Protocol specification](https://redis.io/topics/protocol)
- [How to talk raw Redis](https://www.compose.com/articles/how-to-talk-raw-redis/)
