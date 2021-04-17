classdef TestRedis < matlab.unittest.TestCase
    % type "runtests;" to run tests
    properties
        redis_connection
    end
    
    methods(TestClassSetup)
        function setup(testCase)
            testCase.redis_connection = Redis('localhost', 6379, 'password', 'foobared', 'db', 0);
            disp('setup')
        end
    end
    
    methods (Test)
        function test_set_get(testCase)
            testCase.redis_connection.set('x', 51);
            x = testCase.redis_connection.get('x');
            testCase.verifyEqual(x, '51');
            testCase.redis_connection.set('x', 'asd');
            x = testCase.redis_connection.get('x');
            testCase.verifyEqual(x, 'asd');
            testCase.redis_connection.set('x', 'a a');
            x = testCase.redis_connection.get('x');
            testCase.verifyEqual(x, 'a a');
            testCase.redis_connection.set('x', ['a' newline 'a']);
            x = testCase.redis_connection.get('x');
            testCase.verifyEqual(x, ['a' newline 'a']);
        end
        
        function test_hset(testCase)
            testCase.redis_connection.hset('x_hash', 'field', 'value 1');
            v = testCase.redis_connection.hget('x_hash', 'field');
            testCase.verifyEqual(v, 'value 1');
            
            testCase.redis_connection.hset('x_hash', 'field_numeric', 20);
            v = testCase.redis_connection.hget('x_hash', 'field_numeric');
            testCase.verifyEqual(v, '20');
            
            testCase.redis_connection.hmset('x_hash', 'field_A', 'value 12', 'field_B', 35, 'field_C', 'v a\"\nl\ue"C');
            v = testCase.redis_connection.hmget('x_hash', 'field_A', 'field_B', 'field_C');
            testCase.verifyEqual(v{1}, 'value 12');
            testCase.verifyEqual(v{2}, '35');
            testCase.verifyEqual(v{3}, 'v a\"\nl\ue"C');
        end
        function test_multi(testCase)
            testCase.redis_connection.multi();
            testCase.redis_connection.set('x', 2);
            testCase.redis_connection.incr('x');
            Output = testCase.redis_connection.exec;
            testCase.verifyEqual(Output{1}, 'OK');
            testCase.verifyEqual(Output{2}, '3');
            Output = testCase.redis_connection.incr('x');
            testCase.verifyEqual(Output, '4');
        end
    end
end