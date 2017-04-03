#!/usr/bin/env bash
##这儿在写的时候 曾经写错 SERVER_DIR="~/..." 这样写是不行的， 其实我觉的sh的"" 只是作为一个标界符号使用
SERVER_DIR=~/Projects/tcp_server
cd "$SERVER_DIR/proto"
erl -pa "$SERVER_DIR/ebin/" -s make_proto -s erlang halt
exit 0
