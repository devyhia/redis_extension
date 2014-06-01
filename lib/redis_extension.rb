require "redis_extension/version"

require 'active_support'
require 'active_record'

class Configuration
	attr_accessor :redis

	def initialize
	  self.redis = nil
	end
end

module RedisExtension
	def self.configuration
	  @configuration ||=  Configuration.new
	end

	def self.configure
	  yield(configuration) if block_given?
	end
end

module RedisExtension
	extend ActiveSupport::Concern

	included do
		after_save {
			begin
				key = self.model_key
				self.class.set_cache(key, self)
				ap "#{key} re-cached" if defined?(ap)
			rescue TypeError => e
				if defined?(ap)
					ap e
					ap "We ignore those 'can't dumpt errors' :D"
				end
			end
		}

		after_destroy {
			key = self.model_key
			RedisExtension.configuration.redis.del(key)
			# self.class.set_cache(key, self)
			ap "#{key} cached deleted!" if defined?(ap)
		}

	    def self.model_key(id, *args)
	    	key = "#{self.to_s.underscore}:#{id}"
	    	if args.length > 0
	    		key << ":" << args.join(':')
	    	end
	    	key
	    end

	    def model_key(*args)
	    	self.class.model_key(self.id, *args)
	    end

	    def self.set_cache(key, obj, field=nil)
	    	if obj.is_a?(Array) || obj.is_a?(ActiveRecord::Relation)
	    		ap "This is a fucking array" if defined?(ap)
				obj.each { |item| RedisExtension.configuration.redis.zadd(key, item.created_at.to_i, (field ? item[field] : item.id)) }
	    	else
	    		RedisExtension.configuration.redis.set(key, Marshal.dump(obj))
	    	end
	    end

	    def self.get_cache(key, first=0, last=-1)
	    	if RedisExtension.configuration.redis.type(key) == "zset"
	    		RedisExtension.configuration.redis.zrange(key, first, last)
	    	elsif RedisExtension.configuration.redis.type(key) == "string"
	    		Marshal.load(RedisExtension.configuration.redis.get(key))
	    	end
	    end

	    def self.cache(key, field=nil)
	    	if !RedisExtension.configuration.redis.exists(key)
	    		obj = yield
	    		set_cache(key, obj, field)
	    	end

	    	get_cache(key)
	    end

	    def self.find(*args)
	    	key = model_key(args[0])
	    	cache(key) do
	    		ap "Caching #{key}" if defined?(ap)
		    	super(*args)
		    end
	    end

	    # def self.find_by(db, args=nil)
	    # 	args = args ? args.merge!(db: db) : db
	    # 	super(args)
	    # end

	    # def self.create(db, args=nil)
		   #  args = args ? args.merge!(db: db) : db
		   #  super(args)
	    # end

	    # def self.where(db, opts=nil, *rest)
	    # 	if db.is_a?(Integer)
	    # 		if opts.is_a? Hash
	    # 			opts.merge!(db: db)
	    # 		elsif opts.is_a? String
	    # 			opts << ' AND db = ?'
	    # 			rest <<  db
	    # 		end
	    # 	else
	    # 		if opts
	    # 			rest.unshift(opts)
	    # 		end

	    # 		opts = db
	    # 	end
	    	
	    # 	ap "db: #{db}"
	    # 	ap "opts: #{opts}"
	    # 	ap "rest: #{rest}"
	    	
	    # 	super(opts, *rest)
	    # end
	end
end
ActiveRecord::Base.send :include, RedisExtension