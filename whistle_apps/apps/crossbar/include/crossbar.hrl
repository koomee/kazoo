-ifndef(CROSSBAR_HRL).

-include_lib("cowboy/include/http.hrl").

-include_lib("whistle/include/wh_types.hrl").
-include_lib("whistle/include/wh_amqp.hrl").
-include_lib("whistle/include/wh_log.hrl").
-include_lib("whistle/include/wh_databases.hrl").

-include("include/crossbar_types.hrl").

-define(CONFIG_CAT, <<"crossbar">>).

-define(TOKEN_DB, <<"token_auth">>).

-define(MAINTENANCE_VIEW_FILE, <<"views/maintenance.json">>).
-define(ACCOUNTS_AGG_VIEW_FILE, <<"views/accounts.json">>).

-define(APP_NAME, <<"crossbar">>).
-define(APP_VERSION, <<"0.8.0">>).

-define(CACHE_TTL, whapps_config:get_integer(<<"crossbar">>, <<"cache_ttl">>, 300)).

-define(CROSSBAR_DEFAULT_CONTENT_TYPE, {<<"application">>, <<"json">>, []}).

-define(CONTENT_PROVIDED, [{to_json, [{<<"application">>, <<"json">>},{<<"application">>, <<"x-json">>}]}]).
-define(CONTENT_ACCEPTED, [{from_json, [{<<"application">>, <<"json">>},{<<"application">>, <<"x-json">>}]}
                           ,{from_form, [{<<"application">>, <<"x-www-form-urlencoded">>}]}
                           ,{from_binary, [{<<"text">>, <<"csv">>}]}
                          ]).
-define(ALLOWED_METHODS, ['GET'
                          ,'POST'
                          ,'PUT'
                          ,'DELETE'
                          ,'OPTIONS'
                          ,'HEAD'
                          ,'PATCH'
                         ]).

-define(CROSSBAR_CACHE, crossbar_cache).

-define(USERS_QCALL_NOUNS, [{<<"users">>, [_UserId, <<"quickcall">>, _Number]}
                            ,{?WH_ACCOUNTS_DB, [_]}
                           ]).
-define(DEVICES_QCALL_NOUNS, [{<<"devices">>, [_DeviceId, <<"quickcall">>, _Number]}
                              ,{?WH_ACCOUNTS_DB, [_]}
                             ]).

-record(cb_context, {
           content_types_provided = [] :: crossbar_content_handlers()
          ,content_types_accepted = [] :: crossbar_content_handlers()
          ,allowed_methods = ?ALLOWED_METHODS :: http_methods()
          ,allow_methods = ?ALLOWED_METHODS :: http_methods()
          ,languages_provided = [<<"en">>, <<"en-us">>] :: ne_binaries() %% english by default
          ,charsets_provided = [<<"iso-8859-1">>] :: ne_binaries() %% all charsets provided
          ,encodings_provided = [<<"gzip;q=1.0">>,<<"identity;q=0.5">>] :: ne_binaries() %% gzip and identity
          ,auth_token = <<>> :: binary()
          ,auth_account_id :: ne_binary()
          ,auth_doc :: wh_json:object()
          ,req_verb = <<"get">> :: ne_binary() % <<"get">>, <<"post">>, <<"put">>, <<"delete">>, <<"head">>
          ,req_nouns = [{<<"404">>, []}] :: [{ne_binary(), wh_json:json_strings()},...] | [] % {module, [id]} most typical
          ,req_json = wh_json:new() :: wh_json:object() | {'malformed', binary()} %% the request JSON envelope
          ,req_files = [] :: [{ne_binary(), wh_json:object()},...] | [] %% {file_name, {"contents":<<bin>>, "headers":{"content-type":"", "content-length":1}}}
          ,req_data :: wh_json:json_term()  % the "data" from the request JSON envelope
          ,query_json = wh_json:new() :: wh_json:object()
          ,account_id :: ne_binary()
          ,db_name :: ne_binary()
          ,doc :: wh_json:object() | wh_json:objects()
          ,resp_expires = {{1999,1,1},{0,0,0}} :: wh_datetime()
          ,resp_etag :: 'automatic' | string() | ne_binary()
          ,resp_status = 'error' :: crossbar_status()
          ,resp_error_msg :: wh_json:json_string()
          ,resp_error_code :: pos_integer()
          ,resp_data :: wh_json:object() | wh_json:objects() | binary() | wh_json:json_term()
          ,resp_headers = [] :: wh_proplist() %% allow the modules to set headers (like Location: XXX to get a 201 response code)
          ,start = erlang:now() :: wh_now()
          ,req_id = <<"000000000000">> :: ne_binary()
          ,storage = [] :: wh_proplist()
          ,raw_host = <<>> :: binary()
          ,port = 8000 :: integer()
          ,raw_path = <<>> :: binary()
          ,raw_qs = <<>> :: binary()
          ,method = 'GET' :: http_method()
          ,validation_errors = wh_json:new() :: wh_json:object()
         }).

-define(CROSSBAR_HRL, true).
-endif.
