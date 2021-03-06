require 'pe_rbac'
begin
  # get all users
  resp = PeRbac::get_users
  puts resp

  # get user by ID
  resp = PeRbac::get_user('4765c077-3675-4a2d-85c0-0c76b82d15cb')
  puts resp

  # Lookup the ID for a user
  resp = PeRbac::get_user_id('admin')
  puts "FOUND: " + resp

  # get all roles
  resp = PeRbac::get_roles
  puts resp

  # get role by ID
  resp = PeRbac::get_role(1)
  puts resp

  # create user (works - commented out to preven conflict error)
  #resp = PeRbac::create_user('test','test@test.com', 'mr test test')
  #puts resp

  # update user
  resp = PeRbac::update_user('test','test@test.com.au', 'mrs test test')
  puts resp.code

  # reset/change password
  resp = PeRbac::reset_password('test','12345678')
  puts resp.code

  # get an API token
  resp = PeRbac::token('test', '12345678')
  puts resp

  # create or update a user with role access and write a token
  role_id = PeRbac::get_role_id('Code Deployers')
  perms = {
    "objectType" => "tokens",
    "action"     => "override_lifetime",
    "instance"   => nil,
  }
  PeRbac::update_role('Code Deployers', permissions=perms)
  PeRbac::ensure_user('psquared', 'root@localhost', 'psquared', 't0ps3cret', role_id)
  PeRbac::login('psquared', 't0ps3cret', '10y')

  # what permissions are there?
  resp = PeRbac::get_permissions
  puts resp.body

  # Manage groups
  require 'pe_rbac/group'
  require 'json'

  # Get all groups
  puts JSON.pretty_generate PeRbac::Group.get_groups

  # Create group
  resp = PeRbac::Group.ensure_group('test-group', 2)
  puts resp.code

  # Get one group
  test_group = PeRbac::Group.get_group(PeRbac::Group.get_group_id('test-group'))

  # Update role in group
  resp = PeRbac::Group.ensure_group('test-group', [1,2])
  puts resp.code

  # Remove group
  resp = PeRbac::Group.delete_group('test-group')
  puts resp.code

rescue Exception => e
  puts e.message
  puts e.backtrace
end
