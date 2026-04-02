require "mcp"
require "net/http"
require "uri"
require "json"

module EsaClient
  BASE_URL = "https://api.esa.io/v1"
  TEAM     = "bist"

  class << self
    def get(path)
      request(:get, path)
    end

    def post(path, body)
      request(:post, path, body)
    end

    def patch(path, body)
      request(:patch, path, body)
    end

    private

    def request(method, path, body = nil)
      token = ENV["ESA_ACCESS_TOKEN"]
      uri   = URI("#{BASE_URL}#{path}")

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = case method
              when :get   then Net::HTTP::Get.new(uri)
              when :post  then Net::HTTP::Post.new(uri)
              when :patch then Net::HTTP::Patch.new(uri)
              end
        req["Authorization"] = "Bearer #{token}"
        req["Content-Type"]  = "application/json"
        req.body = JSON.generate(body) if body
        JSON.parse(http.request(req).body)
      end
    end
  end
end

class PermanentMemorySearch < MCP::Tool
  description <<~DESC
    【永続記憶】esa bist チームの永続記憶を検索する（tag:永続 -in:Archived）。
    以下のフレーズで発動: "永続記憶", "permanent-memory", "permanentmemory", "permanent memory".
    返り値: JSON 配列。各要素に number（更新操作の参照用）・name・body_md・updated_at を含む。
    ユーザーへの表示: body_md の内容のみを "---" で区切って全文表示すること。
    number・name・updated_at 等のメタデータはユーザーに表示しない。
  DESC

  input_schema(
    properties: {
      query: { type: "string", description: "絞り込みキーワード（省略可。省略時は全件）" }
    }
  )

  class << self
    def call(query: nil, server_context:)
      q = "tag:永続 -in:Archived"
      q += " #{query.strip}" if query && !query.strip.empty?

      path = "/teams/#{EsaClient::TEAM}/posts?" + URI.encode_www_form(
        q: q, sort: "updated", order: "desc", per_page: 20
      )
      result = EsaClient.get(path)

      posts = (result["posts"] || []).map do |p|
        { number: p["number"], name: p["name"], body_md: p["body_md"], updated_at: p["updated_at"] }
      end

      MCP::Tool::Response.new([{ type: "text", text: JSON.pretty_generate(posts) }])
    rescue => e
      MCP::Tool::Response.new([{ type: "text", text: JSON.generate({ error: e.message }) }], error: true)
    end
  end
end

class PermanentMemoryCreate < MCP::Tool
  description <<~DESC
    【永続記憶】esa bist チームに永続記憶ポストを新規作成する。
    以下のフレーズで発動: "永続記憶に保存", "permanent-memory に保存", "permanent memory save".
    タイトル形式: "[キーワード1][キーワード2] 内容の概要"（180文字以内）。
    実行前にタイトルと本文をユーザーに確認すること。
    返り値: { number, url, name }
  DESC

  input_schema(
    properties: {
      title:      { type: "string", description: "タイトル（[キーワード] 形式、180文字以内）" },
      body_md:    { type: "string", description: "本文（Markdown）" },
      extra_tags: { type: "array", items: { type: "string" }, description: "追加タグ（省略可）" }
    },
    required: ["title", "body_md"]
  )

  class << self
    def call(title:, body_md:, extra_tags: nil, server_context:)
      tags   = (["永続"] + Array(extra_tags)).uniq
      result = EsaClient.post("/teams/#{EsaClient::TEAM}/posts", {
        post: { name: title, body_md: body_md, tags: tags, wip: false }
      })

      return MCP::Tool::Response.new([{ type: "text", text: JSON.generate(result) }], error: true) if result["error"]

      out = { number: result["number"], url: result["url"], name: result["name"] }
      MCP::Tool::Response.new([{ type: "text", text: JSON.pretty_generate(out) }])
    rescue => e
      MCP::Tool::Response.new([{ type: "text", text: JSON.generate({ error: e.message }) }], error: true)
    end
  end
end

class PermanentMemoryUpdate < MCP::Tool
  description <<~DESC
    【永続記憶】esa bist チームの永続記憶ポストを更新する。
    以下のフレーズで発動: "永続記憶を更新", "permanent-memory を更新", "permanent memory update".
    内部で現在の本文を取得して競合検知を行う（originalRevision）。
    永続タグは自動的に維持される。
    実行前に変更内容をユーザーに確認すること。
    post_number は permanent_memory_search の返り値の number を使う。
    返り値: { number, url, name }
  DESC

  input_schema(
    properties: {
      post_number: { type: "integer", description: "更新対象のポスト番号（searchの返り値のnumber）" },
      title:       { type: "string",  description: "新しいタイトル（180文字以内）" },
      body_md:     { type: "string",  description: "新しい本文（Markdown）" }
    },
    required: ["post_number", "title", "body_md"]
  )

  class << self
    def call(post_number:, title:, body_md:, server_context:)
      current = EsaClient.get("/teams/#{EsaClient::TEAM}/posts/#{post_number}")
      return MCP::Tool::Response.new([{ type: "text", text: JSON.generate(current) }], error: true) if current["error"]

      original_body_md = current["body_md"]
      original_user    = (current.dig("updated_by", "screen_name") || current.dig("created_by", "screen_name")).to_s
      tags             = (["永続"] + Array(current["tags"])).uniq

      result = EsaClient.patch("/teams/#{EsaClient::TEAM}/posts/#{post_number}", {
        post: {
          name:              title,
          body_md:           body_md,
          tags:              tags,
          wip:               false,
          original_revision: { number: current["revision_number"].to_i, body_md: original_body_md, user: original_user }
        }
      })

      return MCP::Tool::Response.new([{ type: "text", text: JSON.generate(result) }], error: true) if result["error"]

      out = { number: result["number"], url: result["url"], name: result["name"] }
      MCP::Tool::Response.new([{ type: "text", text: JSON.pretty_generate(out) }])
    rescue => e
      MCP::Tool::Response.new([{ type: "text", text: JSON.generate({ error: e.message }) }], error: true)
    end
  end
end

if __FILE__ == $0
  server = MCP::Server.new(
    name:    "permanent-memory",
    version: "1.0.0",
    tools:   [PermanentMemorySearch, PermanentMemoryCreate, PermanentMemoryUpdate]
  )
  MCP::Server::Transports::StdioTransport.new(server).open
end
