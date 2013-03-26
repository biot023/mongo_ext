require "rspec"
$: << File.join( File.dirname( __FILE__ ), "..", "..", "..", "lib" )

require "b23/mongo_ext"

describe B23::MongoExt::ActiveCollection, "construction" do
  
  describe "with basic params" do
    let( :connstr ) { "mongodb://localhost" }
    let( :dbname )  { "the-db" }
    let( :name )    { "my_name" }
    subject { described_class.new( connstr, dbname, name ) }

    its( :connstr ) { should == connstr }
    its( :dbname )  { should == dbname }
    its( :name )    { should == name }
  end

  describe "with another active collection" do
    let( :other ) do
      mock( :is_a?   => true,
            :connstr => "mongodb://otherhost",
            :dbname  => "other-db",
            :client  => mock( :active? => true ),
            :db      => mock )
    end
    let( :name ) { "my_name" }
    subject { described_class.new( other, name ) }

    its( :connstr ) { should == other.connstr }
    its( :dbname )  { should == other.dbname }
    its( :name )    { should == name }
    its( :client )  { should == other.client }
    its( :db )      { should == other.db }
  end
  
end

describe B23::MongoExt::ActiveCollection do
  let( :connstr ) { "mongodb://hostyhost" }
  let( :dbname )  { "terence" }
  let( :name )    { "trent_darbies" }
  let( :coll ) { described_class.new( connstr, dbname, name ) }

  describe "delegation" do
    specify { described_class.ancestors.should include( SimpleDelegator ) }
    
    it "should get the collection as the object to delegate to" do
      obj = mock
      coll.instance_variable_set( :@collection, obj )
      coll.instance_variable_set( :@client, mock( :active? => true ) )
      coll.__getobj__.should == obj
    end
  end

  describe "getting the client" do
    subject { coll.client }

    context "when the client has not been memoised" do
      let( :client ) { mock }

      before do
        Mongo::MongoClient.stub( :from_uri ).and_return( client )
      end
      
      it "should create a new client from connstr" do
        Mongo::MongoClient.should_receive( :from_uri ).with( connstr )
        subject
      end

      it "should return the new client" do
        subject.should == client
      end

      it "should memoise the new client" do
        expect { subject }.to change { coll.instance_eval { @client } }.to( client )
      end
    end

    context "when the client has been memoised, but is no longer active" do
      let( :old_client ) { mock( :active? => false ) }
      let( :new_client ) { mock }

      before do
        coll.instance_variable_set( :@client, old_client )
        Mongo::MongoClient.stub( :from_uri ).and_return( new_client )
      end

      it "should create a new client from connstr" do
        Mongo::MongoClient.should_receive( :from_uri ).with( connstr )
        subject
      end

      it "should return the new client" do
        subject.should == new_client
      end

      it "should memoise the new client" do
        expect { subject }.to change { coll.instance_eval { @client } }.to( new_client )
      end
    end

    context "when the client has been memoised, and is still active" do
      let( :client ) { mock( :active? => true ) }

      before do
        coll.instance_variable_set( :@client, client )
      end

      it "should return the existing client" do
        subject.should == client
      end

      it "should not change the memoised client" do
        expect { subject }.to_not change { coll.instance_eval { @client } }.from( client )
      end
    end
  end

  describe "getting the db" do
    subject { coll.db }

    context "when no db has been memoised" do
      let( :client ) { mock }
      let( :db )     { mock }

      before do
        coll.stub( :client ).and_return( client )
        client.stub( :db ).and_return( db )
      end
      
      it "should get the client" do
        coll.should_receive( :client )
        subject
      end

      it "should get the db from the client" do
        client.should_receive( :db ).with( dbname )
        subject
      end

      it "should return the db" do
        subject.should == db
      end

      it "should memoise the db" do
        expect { subject }.to change { coll.instance_eval { @db } }.to( db )
      end
    end

    context "when the db has been memoised, but the client is no longer active" do
      let( :old_client ) { mock( :active? => false ) }
      let( :old_db )     { mock }
      let( :new_client ) { mock }
      let( :new_db )     { mock }

      before do
        coll.instance_variable_set( :@client, old_client )
        coll.instance_variable_set( :@db, old_db )
        coll.stub( :client ).and_return( new_client )
        new_client.stub( :db ).and_return( new_db )
      end
      
      it "should get a new client" do
        coll.should_receive( :client )
        subject
      end

      it "should get the db from the new client" do
        new_client.should_receive( :db ).with( dbname )
        subject
      end

      it "should return the db" do
        subject.should == new_db
      end

      it "should memoise the db" do
        expect { subject }.to change { coll.instance_eval { @db } }.to( new_db )
      end
    end

    context "when the db has been memoised, and the client is still active" do
      let( :client ) { mock( :active? => true ) }
      let( :db )     { mock }

      before do
        coll.instance_variable_set( :@client, client )
        coll.instance_variable_set( :@db, db )
      end

      it "should return the memoised db" do
        subject.should == db
      end

      it "should preserve the memoised db" do
        expect { subject }.to_not change { coll.instance_eval { @db } }.from( db )
      end
    end
  end

  describe "getting the collection" do
    subject { coll.collection }

    context "when there is no memoised collection" do
      let( :db )         { mock }
      let( :collection ) { mock }

      before do
        coll.stub( :db ).and_return( db )
        db.stub( :collection ).and_return( collection )
      end

      it "should get the db" do
        coll.should_receive( :db )
        subject
      end

      it "should get the collection by name from the db" do
        db.should_receive( :collection ).with( name )
        subject
      end

      it "should return the collection" do
        subject.should == collection
      end

      it "should memoise the collection" do
        expect { subject }.to change { coll.instance_eval { @collection } }.to( collection )
      end
    end

    context "when there is a memoised collection, but the client is no longer active" do
      let( :client )         { mock( :active? => false ) }
      let( :old_collection ) { mock }
      let( :db )             { mock }
      let( :new_collection ) { mock }

      before do
        coll.instance_variable_set( :@client, client )
        coll.instance_variable_set( :@collection, old_collection )
        coll.stub( :db ).and_return( db )
        db.stub( :collection ).and_return( new_collection )
      end

      it "should get the db" do
        coll.should_receive( :db )
        subject
      end

      it "should get the collection by name from the db" do
        db.should_receive( :collection ).with( name )
        subject
      end

      it "should return the collection" do
        subject.should == new_collection
      end

      it "should memoise the collection" do
        expect { subject }.to change { coll.instance_eval { @collection } }.to( new_collection )
      end
    end

    context "when there is a memoised collection, and the client is still active" do
      let( :client )     { mock( :active? => true ) }
      let( :collection ) { mock }

      before do
        coll.instance_variable_set( :@client, client )
        coll.instance_variable_set( :@collection, collection )
      end

      it "should return the memoised collection" do
        subject.should == collection
      end

      it "should preserve the memoised collection" do
        expect { subject }.to_not change { coll.instance_eval { @collection } }.from( collection )
      end
    end
  end

  describe "safely performing operations on the collection" do
    let( :op ) { lambda { |koll| koll.find( "_id" => "abc123" ) } }
    subject { coll.safe_do( &op ) }

    context "when the collection has not been memoised" do
      let( :new_collection ) { mock }
      let( :findresult )     { mock }

      before do
        coll.stub( :collection ).and_return( new_collection )
        new_collection.stub( :find ).and_return( findresult )
      end

      it "should get the new collection" do
        coll.should_receive( :collection )
        subject
      end

      it "should perform the operation with the new collection" do
        new_collection.should_receive( :find )
        subject.should == findresult
      end
    end

    context "when the collection has been memoised, but there is an issue with it" do
      let( :old_collection ) { mock }
      let( :new_collection ) { mock }
      let( :findresult )     { mock }

      before do
        old_collection.stub( :find ).and_raise( Mongo::ConnectionError )
        coll.instance_variable_set( :@collection, old_collection )
        coll.stub( :collection ).and_return( new_collection )
        new_collection.stub( :find ).and_return( findresult )
      end

      it "should get the new collection" do
        coll.should_receive( :collection )
        subject
      end

      it "should perform the operation with the new collection" do
        new_collection.should_receive( :find )
        subject.should == findresult
      end
    end

    context "when the collection has been memoised, but there is a persistent issue with it" do
      let( :collection ) { mock }

      before do
        collection.stub( :find ).and_raise( Mongo::ConnectionError )
        coll.instance_variable_set( :@collection, collection )
        coll.stub( :collection ).and_return( collection )
      end

      it "should raise the error" do
        expect { subject }.to raise_error( Mongo::ConnectionError )
      end
    end

    context "when the collection has been memoised, and it is ready to work" do
      let( :collection ) { mock( :memoised ) }
      let( :findresult ) { mock }

      before do
        collection.stub( :find ).and_return( findresult )
        coll.instance_variable_set( :@collection, collection )
      end

      it "should perform the operation with the memoised collection" do
        collection.should_receive( :find )
        subject.should == findresult
      end
    end
  end
  
end
