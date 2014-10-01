require 'twitter'
require 'mongo'
require 'hashie'
require 'yaml'

module TwitterTools
  class Fetcher
    def initialize(setting_file_name:)
      setting = Hashie::Mash.new(YAML.load_file(setting_file_name))

      @client = Twitter::REST::Client.new do |config|
        config.consumer_key        = setting.consumer_key
        config.consumer_secret     = setting.consumer_secret
        config.access_token        = setting.access_token
        config.access_token_secret = setting.access_token_secret
      end

      @posts = Mongo::Connection.new.db("twitter").collection("my_timeline")
    end

    def fetch_my_timeline
      @client.user_timeline.each do |post|
        post_to_store = post.to_h
        post_to_store[:created_at] = Time.parse(post_to_store[:created_at])
        @posts.update({id: post.id}, post_to_store, upsert: true)
      end
    end

    def self.prepare_database
      Mongo::Connection.new.db("twitter").collection("my_timeline"). \
        create_index({id: Mongo::ASCENDING}, unique: true)
    end
  end
end
