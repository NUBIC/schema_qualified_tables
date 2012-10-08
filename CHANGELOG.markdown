schema_qualified_tables history
===============================

1.1.1
-----

1.1.0
-----

- ActiveRecord 3.2 support. (#3)
  Previous versions worked with AR 3.2 but this version eliminates the
  deprecation warnings arising from the use of `set_table_name`, etc.

1.0.1
-----
- ActiveRecord 3.1 support. (#1)
- Add top-level require -- you can now require
  `'schema_qualified_tables'` instead of always having to use
  `'bcdatabase/active_record/schema_qualified_tables'`. (#2)

1.0.0
-----
- Split out from NUBIC internal `bcdatabase` project.
  (Changelog entries below reflect the relevant changes & version numbers from that project.)

Bcdatabase history
==================

0.6.2
-----
- Fix infinite recursion bug when schema-qualified tables are enabled on a
  database which doesn't support sequences.

0.6.1
-----
- Schema-qualified names are dynamically determined, removing the order
  dependency between setting ActiveRecord::Base.schemas and defining any
  particular model.  Side effect: schema-qualified names do not work with
  anonymous models at all (previously they only worked in certain
  circumstances).

0.6.0
-----
- Make the schema part of SchemaQualifiedTables inherited so that it can be
  set just once in a base class for a whole hierarchy.
- Ensure that set_schema does not throw an exception when invoked before the
  connection is established.

0.5.2
-----
- Works with CPKs

0.5.1
-----
- Support schema-qualified sequence names in SchemaQualifiedTables, too

0.5.0
-----
- Extension Bcdatabase:Rails::SchemaQualifiedTables to add schema-qualified
  table name support to active record.
