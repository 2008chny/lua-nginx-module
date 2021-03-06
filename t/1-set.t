# vi:ft=

use lib 'lib';
use Test::Nginx::Socket;

repeat_each(2);

plan tests => blocks() * repeat_each() * 2;

run_tests();

__DATA__

=== TEST 1: simple set (integer)
--- config
    location /lua {
        set_by_lua $res "return 1+1";
        echo $res;
    }
--- request
GET /lua
--- response_body
2



=== TEST 2: simple set (string)
--- config
    location /lua {
        set_by_lua $res "return 'hello' .. 'world'";
        echo $res;
    }
--- request
GET /lua
--- response_body
helloworld



=== TEST 3: internal only
--- config
    location /lua {
        set_by_lua $res "function fib(n) if n > 2 then return fib(n-1)+fib(n-2) else return 1 end end return fib(10)";
        echo $res;
    }
--- request
GET /lua
--- response_body
55



=== TEST 4: internal script with argument
--- config
    location /lua {
        set_by_lua $res "return ngx.arg[1]+ngx.arg[2]" $arg_a $arg_b;
        echo $res;
    }
--- request
GET /lua?a=1&b=2
--- response_body
3



=== TEST 5: fib by arg
--- config
    location /fib {
        set_by_lua $res "function fib(n) if n > 2 then return fib(n-1)+fib(n-2) else return 1 end end return fib(tonumber(ngx.arg[1]))" $arg_n;
        echo $res;
    }
--- request
GET /fib?n=10
--- response_body
55



=== TEST 6: adder
--- config
    location = /adder {
        set_by_lua $res
            "local a = tonumber(ngx.arg[1])
             local b = tonumber(ngx.arg[2])
             return a + b" $arg_a $arg_b;

        echo $res;
    }
--- request
GET /adder?a=25&b=75
--- response_body
100

