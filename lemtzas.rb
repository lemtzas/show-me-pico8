require 't'
require 'yaml'

begin
	t_conf = YAML.load_file(ENV['HOME']+'/.trc')
	profile_name = t_conf['configuration']['default_profile'][0]
	profile_id = t_conf['configuration']['default_profile'][1]
	profile_data = t_conf['profiles'][profile_name][profile_id]
rescue
	puts $!, $@
	fail "Probalby run `t authorize`"
end

client = Twitter::REST::Client.new do |c|
	c.consumer_key        = profile_data['consumer_key']
	c.consumer_secret     = profile_data['consumer_secret']
	c.access_token        = profile_data['token']
	c.access_token_secret = profile_data['secret']
end

tweet_id = ARGV[0]
result = nil # initialize

# puts "Original #{tweet_id}"

begin
	tweet = client.status(tweet_id)
	result = tweet # default to the original tweet
	parent_id = tweet.in_reply_to_status_id
	parent_tweet = client.status(parent_id)

	has_parent_tweet = !parent_id.is_a?(Twitter::NullObject)
	parent_is_owntweet = parent_tweet.user.name.upcase != profile_name.upcase
	if has_parent_tweet && !parent_is_owntweet
		result = parent_tweet unless parent_id.is_a? Twitter::NullObject
	end
rescue
	# crush exceptions without mercy
end

# if result.quote?
# 	puts "#{result.id}\nQUOTE TWEET"
# 	exit(-1)
# end

# to make multi-line tweets work properly?
def escape(s)
  s.inspect[1..-2]
end

puts "#{result.id}\n#{escape(result.text)}"
