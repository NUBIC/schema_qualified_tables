SchemaQualifiedTables
=====================

`Bcdatabase::ActiveRecord::SchemaQualifiedTables` is a mix-in for
[ActiveRecord][] 2.3.x and 3.0+.  It makes it easier to use AR in an
application which contains models which map to tables in different
schemas.

[ActiveRecord]: http://api.rubyonrails.org/files/vendor/rails/activerecord/README.html

For example
-----------

Say you have an application using a legacy schema that has models like this:

    class Surgery < ActiveRecord::Base
      belongs_to :surgeon, :class_name => "Person", :foreign_key => "surgeon_id"
      set_table_name "t_surgeries"
    end

    class Person < ActiveRecord::Base
      set_table_name "hr.t_personnel"
    end

These models map to tables in two schemas: the default schema, which
contains `t_surgeries`; and the schema `hr`, which contains
`t_personnel`.

### Contention

Being explicit about the schema name works for production, but what
about development?  You'll need separate database instances for
development deployment and for test.  Depending on what database
you're using, this can be more or less fun (I'm looking at you,
Oracle).

Also consider continuous integration: if you have several applications
in CI which all refer to the `hr` schema, their test data sets will
stomp all over each other if you try to run them in parallel.

### Solution

`SchemaQualifiedTables` solves this problem by letting you configure a
logical schema name for your models which is resolved into the actual
schema name based on runtime configuration.  In this case, you'd
re-write `Person` like so:

    class Person < ActiveRecord::Base
      set_schema :hr
      set_table_name :t_personnel
    end

Then, if you need to override the actual schema name in some
environments, configure `ActiveRecord::Base.schemas`:

    # in test.rb
    config.after_initialize do
      ActiveRecord::Base.schemas = {
        :hr => 'hr_test',
      }
    end

This way in the test environment, AR will map `Person` to
`hr_test.t_personnel`.  In any environment where you don't provide an
explicit override, the logical schema name will be used as the actual
schema name &mdash; i.e., in development and production, AR will map
`Person` to `hr.t_personnel`.

Using
-----

Install the gem:

    $ gem install schema_qualified_tables

If you're using Rails 2.3, configure it in environment.rb:

    config.gem 'schema_qualified_tables', :version => '>= 1.0.0',
      :lib => 'bcdatabase/active_record/schema_qualified_tables'

If you're using Bundler (e.g., with Rails 3), add it to your Gemfile:

    gem 'schema_qualified_tables', '~> 1.0.0',
      :require => 'bcdatabase/active_record/schema_qualified_tables'

Otherwise, just require
'bcdatabase/active_record/schema_qualified_tables' sometime during
initialization (before your models are loaded).

Problems?
---------

Report bugs or request features on the project's [github issue
tracker][issues].

Send any other questions or feedback to Rhett Sutphin
(rhett@detailedbalance.net).

[issues]: http://github.com/rsutphin/schema_qualified_tables/issues

Development
-----------

This library uses bundler to provide an isolated gem environment for
its tests. Use `bundle update` before attempting to run the tests.

In order to test all the features of `schema_qualified_tables`,
ActiveRecord must be given a connection to a database on an RDBMS that
supports sequences. The test harness uses [Bcdatabase][] to acquire
the credentials for the test database. By default, it looks for the
Bcdatabase group `:local_postgresql` and the configuration
`:schema_qualified_tables_test`. You can override these by setting
environment variables when you run the tests, e.g.:

    SQT_DB_GROUP=local_oracle
    SQT_DB_ENTRY=sqt_tester

The test harness supports using PostgreSQL or Oracle. Adding support
for another database should be as easy as adding its adapter (or its
adapter's dependencies, if it has an adapter built into AR) to the
development dependencies in the gemspec and running `bundle
update`. The test suite can only be run without failures on a database
that supports sequences.

### On JRuby

If you want to run the tests on JRuby using a database whose JDBC
drivers are not available as a gem (i.e., Oracle), ensure that the
JDBC driver is on JRuby's classpath before running the tests. The
easiest way to do that is by setting the CLASSPATH environment
variable.

[Bcdatabase]: http://rubydoc.info/gems/bcdatabase/frames

Credits
-------

`SchemaQualifiedTables` was developed at the [Northwestern University
Biomedical Informatics Center][NUBIC].

[NUBIC]: http://www.nucats.northwestern.edu/centers/nubic/index.html

### Copyright

Copyright (c) 2009 Rhett Sutphin and Peter Nyberg. See LICENSE for details.
