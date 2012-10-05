require File.expand_path("../../spec_helper", File.dirname(__FILE__))
require 'active_record'

ActiveRecord.load_all! if ActiveRecord.respond_to?(:load_all!)  # Lazy loading of active_record was added to rails 2.3.2
                                                                # so we have to explicitly load it this way for cpk to work.
require 'composite_primary_keys' if SqtCpk.test_cpk?

describe "SchemaQualifiedTables" do
  before(:all) do
    establish_connection
  end

  after(:all) do
    remove_connection
  end

  before(:each, :without_connection => true) do
    remove_connection
  end

  after(:each, :without_connection => true) do
    establish_connection
  end

  after do
    Object.class_eval do
      %w(ReadingMaterialBase Book Magazine Newspaper Pamphlet).each do |clazz|
        remove_const clazz if const_defined? clazz
      end
    end
  end

  describe "tables" do
    describe "with no schema name" do
      it "uses the inferred table name" do
        class Book < ActiveRecord::Base
        end

        Book.table_name.should == 'books'
      end

      it "uses just the explicit tablename" do
        class Novel < ActiveRecord::Base
          sqt_table_name("books")
        end

        Novel.table_name.should == 'books'
      end
    end

    describe "with schema name" do
      it "uses the inferred table name" do
        class Magazine < ActiveRecord::Base
          sqt_schema_name(:reading_material)
        end

        Magazine.table_name.should == 'reading_material.magazines'
      end

      it "uses the explicit table name, if first" do
        class Magazine < ActiveRecord::Base
          sqt_table_name("some_magazines")
          sqt_schema_name(:reading_material)
        end

        Magazine.table_name.should == "reading_material.some_magazines"
      end

      it "uses the explicit table name, if second" do
        class Magazine < ActiveRecord::Base
          sqt_schema_name(:reading_material)
          sqt_table_name("some_magazines")
        end

        Magazine.table_name.should == "reading_material.some_magazines"
      end

      it "preserves the schema name if the table name is set several times" do
        class Magazine < ActiveRecord::Base
          sqt_schema_name(:reading_material)
          sqt_table_name("some_magazines")

          sqt_table_name("other_magazines")
        end

        Magazine.table_name.should == "reading_material.other_magazines"
      end

      it "uses the last schema if set several times" do
        class Magazine < ActiveRecord::Base
          sqt_schema_name(:reading_material)
          sqt_table_name("some_magazines")
          sqt_schema_name(:periodicals)
        end

        Magazine.table_name.should == "periodicals.some_magazines"
      end

      it "works if set_schema is called without a connection", :without_connection do
        lambda {
          class Magazine < ActiveRecord::Base
            sqt_schema_name(:periodicals)
          end
        }.should_not raise_error

        Magazine.table_name.should == "periodicals.magazines"
      end

      describe "from the parent" do
        before do
          class ReadingMaterialBase < ActiveRecord::Base
            self.abstract_class = true
            sqt_schema_name(:reading_material)
          end
        end

        it "inherits the schema from its parent class" do
          class Magazine < ReadingMaterialBase
            sqt_table_name("some_magazines")
          end

          Magazine.schema.should == :reading_material
          Magazine.table_name.should == "reading_material.some_magazines"
        end

        it "uses the inferred table name for a child" do
          unless active_record_32_or_greater?
            pending "bug in ActiveRecord::Base.reset_table_name"
                  # Fails because the first call to reset_table_name
                  # always returns just the inferred table name.  Usually
                  # the first call is during set_table_name or set_schema.
                  # In this spec, it is in the call to table_name, below.
          end

          class Newspaper < ReadingMaterialBase; end

          Newspaper.schema.should == :reading_material
          Newspaper.table_name.should == "reading_material.newspapers"
        end

        it "uses separate schemas for subclasses" do
          class Magazine < ReadingMaterialBase
            sqt_table_name("some_magazines")
            sqt_schema_name(:periodicals)
          end
          class Newspaper < ReadingMaterialBase
            sqt_schema_name(:deprecated)
          end

          Magazine.table_name.should == "periodicals.some_magazines"
          Newspaper.table_name.should == "deprecated.newspapers"
        end
      end

      describe "with name overrides" do
        before do
          ActiveRecord::Base.schemas = {
            :reading_material => 'reading_material_test'
          }
        end

        after do
          ActiveRecord::Base.schemas.clear
        end

        it "uses the inferred table name" do
          class Pamphlet < ActiveRecord::Base
            sqt_schema_name(:reading_material)
          end

          Pamphlet.table_name.should == 'reading_material_test.pamphlets'
        end

        it "uses the explicit table name, if first" do
          class Pamphlet < ActiveRecord::Base
            sqt_table_name("some_pamphlets")
            sqt_schema_name(:reading_material)
          end

          Pamphlet.table_name.should == "reading_material_test.some_pamphlets"
        end

        it "uses the explicit table name, if second" do
          class Pamphlet < ActiveRecord::Base
            sqt_schema_name(:reading_material)
            sqt_table_name("some_pamphlets")
          end

          Pamphlet.table_name.should == "reading_material_test.some_pamphlets"
        end

        it "applies name overrides that come after the model is loaded" do
          class Newspaper < ActiveRecord::Base
            sqt_table_name("newspaperos")
            sqt_schema_name(:periodicals)
          end

          ActiveRecord::Base.schemas = { :periodicals => "periodicals_test" }

          Newspaper.table_name.should == "periodicals_test.newspaperos"
        end

        it "applies name overrides that come after the model is loaded when using the inferred table name" do
          class Newspaper < ActiveRecord::Base
            sqt_schema_name(:periodicals)
          end

          ActiveRecord::Base.schemas = { :periodicals => "periodicals_test" }

          Newspaper.table_name.should == "periodicals_test.newspapers"
        end
      end
    end
  end

  # TODO: bad, bad, bad copying
  describe "sequences" do
    def inferred(table_name='foo')
      ActiveRecord::Base.connection.default_sequence_name(table_name)
    end

    describe "with no schema name" do
      it "uses the inferred sequence name" do
        class Book < ActiveRecord::Base
        end

        Book.sequence_name.should == inferred('books')
      end

      it "uses just the explicit sequencename" do
        class Novel < ActiveRecord::Base
          sqt_sequence_name("books")
        end

        Novel.sequence_name.should == 'books'
      end

      it "gives nil if the adapter doesn't specify a default sequence name" do
        pending 'Adapter does have a default' if inferred

        class Book < ActiveRecord::Base
        end

        Book.sequence_name.should be_nil
      end
    end

    describe "with schema name" do
      it "uses the inferred sequence name" do
        class Magazine < ActiveRecord::Base
          sqt_schema_name(:reading_material)
        end

        Magazine.sequence_name.should == "reading_material.#{inferred 'magazines'}"
      end

      it "gives nil if the adapter doesn't specify a default sequence name" do
        pending 'Adapter does have a default' if inferred

        class Book < ActiveRecord::Base
          sqt_schema_name(:reading_material)
        end

        Book.sequence_name.should be_nil
      end

      describe "with CPK" do
        before do
          pending 'Not testing CPK' unless test_cpk?
        end

        it "doesn't fail when setting the schema" do
          class Newspaper < ActiveRecord::Base
            sqt_primary_keys("address", "telephone")
            sqt_schema_name(:reading_material)
          end
        end
      end

      it "uses the explicit sequence name, if first" do
        class Magazine < ActiveRecord::Base
          sqt_sequence_name("some_magazines_seq")
          sqt_schema_name(:reading_material)
        end

        Magazine.sequence_name.should == "reading_material.some_magazines_seq"
      end

      it "uses the explicit sequence name, if second" do
        class Magazine < ActiveRecord::Base
          sqt_schema_name(:reading_material)
          sqt_sequence_name("some_magazines_seq")
        end

        Magazine.sequence_name.should == "reading_material.some_magazines_seq"
      end

      it "preserves the schema name if the sequence name is set several times" do
        class Magazine < ActiveRecord::Base
          sqt_schema_name(:reading_material)
          sqt_sequence_name("some_magazines_seq")

          sqt_sequence_name("other_magazines_seq")
        end

        Magazine.sequence_name.should == "reading_material.other_magazines_seq"
      end

      it "uses the last schema if set several times" do
        class Magazine < ActiveRecord::Base
          sqt_schema_name(:reading_material)
          sqt_sequence_name("some_magazines_seq")
          sqt_schema_name(:periodicals)
        end

        Magazine.sequence_name.should == "periodicals.some_magazines_seq"
      end

      it "works if set_schema is called without a connection", :without_connection do
        lambda {
          class Magazine < ActiveRecord::Base
            sqt_schema_name(:periodicals)
            sqt_sequence_name("mag_seq")
          end
        }.should_not raise_error

        Magazine.sequence_name.should == "periodicals.mag_seq"
      end

      describe "with name overrides" do
        before do
          ActiveRecord::Base.schemas = {
            :reading_material => 'rm_test'
          }
        end

        after do
          ActiveRecord::Base.schemas.clear
        end

        it "uses the inferred sequence name" do
          class Pamphlet < ActiveRecord::Base
            sqt_schema_name(:reading_material)
          end

          Pamphlet.sequence_name.should == "rm_test.#{inferred 'pamphlets'}"
        end

        it "uses the explicit sequence name, if first" do
          class Pamphlet < ActiveRecord::Base
            sqt_sequence_name("some_pamphlets")
            sqt_schema_name(:reading_material)
          end

          Pamphlet.sequence_name.should == "rm_test.some_pamphlets"
        end

        it "uses the explicit sequence name, if second" do
          class Pamphlet < ActiveRecord::Base
            sqt_schema_name(:reading_material)
            sqt_sequence_name("some_pamphlets")
          end

          Pamphlet.sequence_name.should == "rm_test.some_pamphlets"
        end
      end
    end
  end
end

