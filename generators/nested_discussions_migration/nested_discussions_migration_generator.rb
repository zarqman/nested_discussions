class NestedDiscussionsMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # m.directory "lib"
      # m.template 'README', "README"
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "nested_discussions_migration"
    end
  end
end
