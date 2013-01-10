module ActiveRecord
  class Base
    # Overriding ActiveRecord::Base.mysql2_connection
    # method to allow passing options from database.yml
    #
    # Example of database.yml
    #
    #   login: &login
    #     socket: /tmp/mysql.sock
    #     adapter: mysql2
    #     host: localhost
    #     encoding: utf8
    #     flags: 131072
    #
    # @param [Hash] config hash that you define in your
    #   database.yml
    # @return [Mysql2Adapter] new MySQL adapter object
    #
    def self.mysql2_connection(config)
      config[:username] = 'root' if config[:username].nil?

      if Mysql2::Client.const_defined? :FOUND_ROWS
        config[:flags] = config[:flags] ? config[:flags] | Mysql2::Client::FOUND_ROWS : Mysql2::Client::FOUND_ROWS
      end

      client = Mysql2::Client.new(config.symbolize_keys)
      options = [config[:host], config[:username], config[:password], config[:database], config[:port], config[:socket], 0]
      ConnectionAdapters::Mysql2Adapter.new(client, logger, options, config)
    end
  end
end