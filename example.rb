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

  # change password
  resp = PeRbac::change_password('test','12345678')
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
  PeRbac::ensure_user('psquared', 'root@localhost', 'psquared', 'changeme', role_id)
  PeRbac::login('psquared', 'changeme', '10y')

  # what permissions are there?
  resp = PeRbac::get_permissions
  puts resp.body

rescue Exception => e
  puts e.message
  puts e.backtrace
end
