require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  def setup
    @organization = Organization.make
  end
  
  test "Organization validation" do
    org = Organization.create
    assert_equal 2, org.errors.size
    org = Organization.make :name => 'freddie mac'
    assert_not_nil org.id
  end
  
  test "make sure that updating the name of an org updates its satellites if any" do
    sat = Organization.make :parent_org_id => @organization.id
    @organization.name = @organization.name + 'fred'
    @organization.save
    assert_equal @organization.name, sat.reload.name
  end
  
  test "Adding organizations to users" do
    u = User.make :first_name => 'Eric', :login => random_login, :email => random_email
    org = Organization.make :name => 'freddie mac'
    assert_equal 0, u.organizations.size
    assert_equal 0, org.users.size
    u.organizations << org
    assert_equal 1, u.organizations.size
    assert_equal 1, org.reload().users.size
  end

  test "Setting up hq/satellite organizations" do
    hq_org = Organization.make :name => 'freddie mac'
  end

  # test "merge remove duplicated organization" do
  #   # build organizations
  #   org1 = Organization.make
  #   org1_duplicate = Organization.make(:name => org1.name)
  #   # Merge
  #   assert org1.merge(org1_duplicate)
  #   # Check duplicates doesnt exists anymore
  #   assert_nil Organization.find_by_id(org1_duplicate.id)
  # end
  # 
  # test "merge move users to point at representant" do
  #   # build organizations
  #   org1, org2, org3 = Organization.make, Organization.make, Organization.make
  #   org1_duplicate = Organization.make(:name => org1.name)
  #   # build users
  #   u1 = User.make :first_name => 'Marcelo', :login => random_login, :email => random_email
  #   u2 = User.make :first_name => 'Eric', :login => random_login, :email => random_email
  #   u3 = User.make :first_name => 'Michael', :login => random_login, :email => random_email
  #   # set associations between orgs and users
  #   u1.organizations << org1
  #   u1.update_attribute(:primary_user_organization_id, u1.user_organizations.first.id)
  #   u1.organizations << org2
  #   u2.organizations << org1_duplicate
  #   u2.update_attribute(:primary_user_organization_id, u2.user_organizations.first.id)
  #   u2.organizations << org3
  #   u3.organizations << org3
  #   u3.organizations << org1_duplicate
  #   u3.update_attribute(:primary_user_organization_id, u3.user_organizations.first.id)
  #   # Merge
  #   assert org1.merge(org1_duplicate)
  #   # reload user models
  #   u1.reload
  #   u2.reload
  #   u3.reload
  #   # Validate successfull transition of users to the organization representant
  #   assert u2.organizations.include?(org1)
  #   assert u3.organizations.include?(org1)
  #   # check existing associations did not changed
  #   assert u1.organizations.include?(org1)
  #   assert u1.organizations.include?(org2)
  #   assert u2.organizations.include?(org3)
  #   assert u3.organizations.include?(org3)
  #   # also check that primary_organization changed
  #   assert_equal UserOrganization.find(u2.primary_user_organization_id).organization_id, org1.id
  #   # but for the case of primary is not merged, then it shouldn't change
  #   assert_equal UserOrganization.find(u3.primary_user_organization_id).organization_id, org3.id
  # end
  # 
  # test "switch an org from being a child to being a parent using force_headquarters" do
  #   org1 = Organization.make
  #   org2, org3 = Organization.make(:parent_org_id => org1.id), Organization.make(:parent_org_id => org1.id)
  #   assert_equal org1, org2.parent_org
  #   assert_equal org1, org3.parent_org
  #   org3.force_headquarters = '1'
  #   org3.save
  #   assert_equal org3, org1.reload.parent_org
  #   assert_equal org3, org2.reload.parent_org
  #   assert org3.reload.parent_org.nil?
  # end
end