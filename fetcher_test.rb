require_relative 'fetcher'

TwitterTools::Fetcher.new(setting_file_name: 'setting.yml').fetch_my_timeline
t = Mongo::Connection.new.db("twitter").collection("my_timeline").find.to_a
puts "Size: #{t.size}"
puts "Last Tweet: #{t.last['text']}"
