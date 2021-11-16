%%%----------------------------------------------------------------------
%%% File    : stun_listener.erl
%%% Author  : Feliks Pobiedzinski <feliks.pobiedzinski@gmail.com>
%%% Purpose :
%%% Created : 15 Aug 2021 by Feliks Pobiedzinski <feliks.pobiedzinski@gmail.com>
%%%
%%%
%%% Copyright 2021 Software Mansion
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
%%%
%%%----------------------------------------------------------------------

-module(turn_starter).

-export([start/2, stop/3]).

-include("stun.hrl").

start(Secret, Opts) ->
    IP = proplists:get_value(ip, Opts, {127, 0, 0, 1}),
    Transport = proplists:get_value(transport, Opts, udp),
    {ClientMinPort, ClientMaxPort} =
        proplists:get_value(client_port_range, Opts, {50_000, 50_499}),
    {AllocMinPort, AllocMaxPort} =
        proplists:get_value(alloc_port_range, Opts, {50_500, 50_999}),
    Auth_fun =
        fun(User, _Realm) ->
           Hash = crypto:mac(hmac, sha, Secret, User),
           base64:encode(Hash)
        end,
    PeerPid = proplists:get_value(peer_pid, Opts),
    TurnOpts =
        [{use_turn, true},
         {auth_fun, Auth_fun},
         {auth_realm, "turn.stun.localhost"},
         {turn_ipv4_address, IP},
         {turn_min_port, AllocMinPort},
         {turn_max_port, AllocMaxPort},
         {peer_pid, PeerPid}],
    stun_listener:add_listener(IP, ClientMinPort, ClientMaxPort, Transport, TurnOpts).

stop(IP, Port, Transport) ->
    stun_listener:del_listener(IP, Port, Transport).
