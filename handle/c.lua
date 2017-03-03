local print = print
local json = require "cjson.safe"
local string = string
local ipairs = ipairs
local assert = assert
local collectgarbage = collectgarbage
local socket = require "socket.core"
local os = os
local zlib = require "zlib"
local stream = require "fan.stream"
local config = require "config"
local lru = require "lru"

local connmap = connmap
local _S = _S

local ctxpool = require "ctxpool"

local function getcities(ctx)
  local db = getmetatable(ctx).db
  local cur = db:execute("select * from City order by ID limit 1000")
  local list = {}
  while true do
    local row = cur:fetch()
    if not row then
      break
    else
      table.insert(list, row)
    end
  end
  cur:close()

  return list
end

local function onGet(req, resp)
  local list = ctxpool:safe(getcities)

  return resp:reply("200", "OK", json.encode(list))
end

return {
  route = "/c",
  onGet = onGet,
  onPost = onPost,
}
