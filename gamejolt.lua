
GameJolt = function (game_id, private_key)
    local username, user_token

    local http     = require("socket.http")
    local ltn12    = require("ltn12")
    local md5      = require("md5")
    local base_url = "http://gamejolt.com/api/game/v1"

    function urlencode(str)
        if (str) then
            str = string.gsub (str, "\n", "\r\n")
            str = string.gsub (str, "([^%w ])",
            function (c) return string.format ("%%%02X", string.byte(c)) end)
            str = string.gsub (str, " ", "+")
        end
        return str
    end

    local http_request = function ( args )
        if private_key == nil then
            print("ALERT: private key is nil")
            return { response = nil }
        end
        local resp, r = {}, {}
        if args.endpoint then
            local params = ""
            if args.method == nil or args.method == "GET" then
                -- prepare query parameters like http://xyz.com?q=23&a=2
                if args.params then
                    for i, v in pairs(args.params) do
                        params = params .. i .. "=" .. v .. "&"
                    end
                end
            end
            params = string.sub(params, 1, -2)
            local url = ""
            if params then url = base_url .. args.endpoint .. "?" .. params else url = base_url .. args.endpoint end
            local signature = md5.sumhexa(url .. private_key)
            url = url .. "&signature=" .. signature

            client, code, headers, status = http.request{url=url, sink=ltn12.sink.table(resp),
                                                    method=args.method or "GET", headers=args.headers, source=args.source,
                                                    step=args.step,     proxy=args.proxy, redirect=args.redirect, create=args.create }
            r['code'], r['headers'], r['status'], r['response'] = code, headers, status, resp
        else
            error("endpoint is missing")
        end
        return r
    end

    local authenticate = function ()
        print("AUTHENTICATING WITH GAMEJOLT")

        local result = ""
        local response = http_request({
            endpoint = "/users/auth/",
            params   = {
                game_id    = game_id,
                username   = username,
                user_token = user_token
            }
        }).response

        if response ~= nil then
            local unpacked = unpack(response)

            if unpacked ~= nil then
                local result = string.find(unpack(response), 'success:"true"') -- TODO ha ha ha, until I find a JSON parser I like

                if result then
                    print("  YEAH, YOU'RE GOOD")
                else
                    print("  NOPE, CHECK YOUR SETTINGS")
                    return false
                end
            else
                print("  NOPE, CHECK YOUR CONNECTION")
                return false
            end
        else
            print("AUTHENTICATION FAILED")
        end

        return result
    end

    local add_score = function (score, sort)
        if not authenticate() then return end

        print("UPLOADING SCORE...")
        -- TODO get the player's current high score
        -- update the average with the new score and sort

        return http_request({
            endpoint = "/scores/add/",
            params   = {
                game_id    = game_id,
                username   = username,
                user_token = user_token,
                score      = urlencode(score),
                sort       = sort
            }
        })
    end

    local connect_user = function (name, token)
        username   = name
        user_token = token
    end

    return {
        http_request = http_request,
        connect_user = connect_user,
        add_score    = add_score
    }
end

return GameJolt
