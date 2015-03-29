require 'service/common_gem/version'
require 'memcached'
require 'digest'
require 'yaml'
require 'service/custom_logger'


puts "LOOK AT ME!!"

module Service
  module CommonGem
    @authconfig = nil
    @mem_cache = nil
    @rails_root = nil
    @custom_logger =  nil

    def self.set_authconfig(authconfig)
      @authconfig = authconfig
    end

    def self.set_mem_cache(mem_cache)
      @mem_cache = mem_cache
    end

    def self.set_rails_root(rails_root)
      @rails_root = rails_root
      config_dir = 'log/'
      logpath = @rails_root.join(config_dir, 'custom.log')
      @custom_logger =  Service::CustomLogger.new(logpath, shift_age = 7, shift_size = 1048576)  #constant accessible anywhere
    end

    def self.not_authorized_response
      {AuthorizationError: 'Not Authorized'}
    end

    # check authenticated session
    # return the result in Array: [is_authorized, userInfo]
    # [is_authorized] boolean value indication authorization status
    # [userInfo] display name for the user
    def self.check_auth(key)
      is_authorized = true
      user_info = nil

      unless key
        is_authorized = false
        return [is_authorized, user_info]
      end
      val = fetch_session_key(key)
      unless val
        is_authorized = false
        return [is_authorized, user_info]
      end # deny the request
      user_info = val['displayName'] || "`displayName' not found"

      [is_authorized, user_info]
    end

    def self.store_session_key(key,data)
      @mem_cache.set create_key(key), data.to_json
    end

    def self.erase_session_key(key)
      store_session_key(key,'')
    end

    def self.create_key(key)
      "#{@authconfig['heimdall']['prefix']}-#{key}"
    end

    def self.fetch_session_key(key)
      kk = create_key key
      val = @mem_cache.get kk
      data = val ? JSON.parse(val) : nil

      if data
        ts = data['timestamp']
        timeout = data['timeout']
        now = Time.now.to_i
        since = now - ts
        if since > timeout
          @mem_cache.set key,nil
          return nil
        end
        data['timestamp'] = now
        store_session_key key, data
        return data
      end
      nil
    end

    def self.generate_message_id(payload,user)
      if user
        md5 = Digest::MD5.new
        md5 << payload.inspect << user << Time.now.inspect
        md5.hexdigest
      else
        nil
      end
    end

    def self.create_response_object(payload,user,headers,start_time)
      hash = Hash.new
      hash[:messageID] = generate_message_id(payload,user)
      hash[:username] = user
      hash[:payload] = payload
      hash[:headers] = headers
      hash[:timestamp] = @start_time.to_i
      #		hash[:currentTime] = Time.now.to_i / 1000
      hash[:currentTime] = Time.now.inspect
      hash[:executionTime] = Time.now - start_time
      hash
    end

    def self.custom_log(flag, message_id, msg)
      unless message_id
        message_id = 'XXXXX'
      end
      if flag
        @custom_logger.info("#{Time.now.inspect}:#{message_id}: #{msg}")
      end
    end
  end
end