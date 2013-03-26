require "delegate"
require "mongo"

module B23
  module MongoExt

    class ActiveCollection < SimpleDelegator
      attr_reader :connstr, :dbname, :name

      def initialize( *args )
        if args.first.is_a?( ActiveCollection )
          @connstr, @dbname, @client, @db, @name =
            args.first.connstr, args.first.dbname, args.first.client, args.first.db, args[1]
        else
          @connstr, @dbname, @name = *args
        end
      end

      def client
        @client = Mongo::MongoClient.from_uri( connstr ) if ! @client || ! @client.active?
        @client
      end

      def db
        @db = client.db( dbname ) if ! @db || ! @client.active?
        @db
      end

      def collection
        @collection = db.collection( name ) if ! @collection || ! @client.active?
        @collection
      end
      alias_method( :__getobj__, :collection )

      def safe_do( &block )
        block.call( @collection || collection )
      rescue Mongo::MongoRubyError
        retries ||= 0
        retries += 1
        @collection = nil
        retry if retries < 2
        raise
      end
    end
    
  end
end
