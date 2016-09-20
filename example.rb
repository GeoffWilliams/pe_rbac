require 'pe_rbac'
begin
  # get all users
  resp = PeRbac::get_users
  puts resp.code

  # get user by ID
  resp = PeRbac::get_user('4765c077-3675-4a2d-85c0-0c76b82d15cb')
  puts resp.code
	puts resp.body

  # get all roles
  resp = PeRbac::get_roles
  puts resp.code

  # get role by ID
  resp = PeRbac::get_role(1)
  puts resp.code

  # create user (works - commented out to preven conflict error)
  #resp = PeRbac::create_user('test','test@test.com', 'mr test test')
  #puts resp.code

  # update user
  resp = PeRbac::update_user('test','test@test.com.au', 'mrs test test')
  puts resp.code

  # change password
  resp = PeRbac::change_password('test','12345678')
  puts resp.code

  # get an API token
  resp = PeRbac::token('test', '12345678')
  puts resp.code
  puts resp.body

rescue Exception => e
  puts e.message
  puts e.backtrace
end
