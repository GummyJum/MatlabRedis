# MatlabRedis
Pure Matlab Redis interface for Matlab>=2014B

## API:
`r = redis.init(<host>, <port>, ['password', password=''], ['db', db=0]);`
`r.ping;`
`r.send(<cmd>, <args...>);`
`r.set('tmp', 1);`
`tmp = r.get('tmp');`

## Related Projects
There are three similar packages out there that we have seen
- https://github.com/svdev/redis-matlab-mex
- https://github.com/markuman/go-redis
- https://github.com/dantswain/redis-matlab

of those the former two packages are based on the Hiredis library and the third is a Matlab implementation of the Hiredis library interface.

This project gives an object-like interface for Redis without any other requirement or setup other then matlab itself.