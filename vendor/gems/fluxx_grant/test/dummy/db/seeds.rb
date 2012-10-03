

tax_class_group = MultiElementGroup.create :name => 'tax_classes', :description => 'TaxClass', :target_class_name => 'Organization'
MultiElementValue.create :multi_element_group_id => tax_class_group.id, :value => '509a1'
MultiElementValue.create :multi_element_group_id => tax_class_group.id, :value => '509a2'
MultiElementValue.create :multi_element_group_id => tax_class_group.id, :value => '509a3'
MultiElementValue.create :multi_element_group_id => tax_class_group.id, :value => 'Private Foundation'
MultiElementValue.create :multi_element_group_id => tax_class_group.id, :value => '501c4'
MultiElementValue.create :multi_element_group_id => tax_class_group.id, :value => '501c6'
MultiElementValue.create :multi_element_group_id => tax_class_group.id, :value => 'non-US'
MultiElementValue.create :multi_element_group_id => tax_class_group.id, :value => 'Non-Exempt'

expenditure_group = MultiElementGroup.create :name => 'expenditure_types', :description => 'ExpenditureType', :target_class_name => 'Request'
MultiElementValue.create :multi_element_group_id => expenditure_group.id, :value => 'grant'
MultiElementValue.create :multi_element_group_id => expenditure_group.id, :value => 'fip project'
MultiElementValue.create :multi_element_group_id => expenditure_group.id, :value => 'fip consulting agreement'

initiative_type_group = MultiElementGroup.create :name => 'initiative_types', :description => 'InitiativeType', :target_class_name => 'Request'
MultiElementValue.create :multi_element_group_id => initiative_type_group.id, :value => 'Mature'
MultiElementValue.create :multi_element_group_id => initiative_type_group.id, :value => 'Developing'
MultiElementValue.create :multi_element_group_id => initiative_type_group.id, :value => 'Higher Risk'
MultiElementValue.create :multi_element_group_id => initiative_type_group.id, :value => 'Former Allocation'

constituents_group = MultiElementGroup.create :name => 'constituents', :description => 'Constituents', :target_class_name => 'Request'
MultiElementValue.create :multi_element_group_id => constituents_group.id, :value => 'Agriculture'
MultiElementValue.create :multi_element_group_id => constituents_group.id, :value => 'Business'
MultiElementValue.create :multi_element_group_id => constituents_group.id, :value => 'Consumer and Low Income'
MultiElementValue.create :multi_element_group_id => constituents_group.id, :value => 'Faith'
MultiElementValue.create :multi_element_group_id => constituents_group.id, :value => 'Military/Security'
MultiElementValue.create :multi_element_group_id => constituents_group.id, :value => 'Sportsman'
MultiElementValue.create :multi_element_group_id => constituents_group.id, :value => 'Environment'
MultiElementValue.create :multi_element_group_id => constituents_group.id, :value => 'Conservation/Lands'
MultiElementValue.create :multi_element_group_id => constituents_group.id, :value => 'Minority'
MultiElementValue.create :multi_element_group_id => constituents_group.id, :value => 'Labor'

means_usa_group = MultiElementGroup.create :name => 'usa_means', :description => 'MeansUsa', :target_class_name => 'Request'
MultiElementValue.create :multi_element_group_id => means_usa_group.id, :value => 'Technical Analysis'
MultiElementValue.create :multi_element_group_id => means_usa_group.id, :value => 'Economic Analysis'
MultiElementValue.create :multi_element_group_id => means_usa_group.id, :value => 'Legal Intervention'
MultiElementValue.create :multi_element_group_id => means_usa_group.id, :value => 'Regulatory Intervention'
MultiElementValue.create :multi_element_group_id => means_usa_group.id, :value => 'Grassroots Organization'
MultiElementValue.create :multi_element_group_id => means_usa_group.id, :value => 'Constituency Building'
MultiElementValue.create :multi_element_group_id => means_usa_group.id, :value => 'Grasstops Organizing'
MultiElementValue.create :multi_element_group_id => means_usa_group.id, :value => 'Media/PR'
MultiElementValue.create :multi_element_group_id => means_usa_group.id, :value => 'Capacity Building'
MultiElementValue.create :multi_element_group_id => means_usa_group.id, :value => 'Workshop/Conference'
MultiElementValue.create :multi_element_group_id => means_usa_group.id, :value => 'Strategy Development'
MultiElementValue.create :multi_element_group_id => means_usa_group.id, :value => 'Pilot Demonstration'

means_china_group = MultiElementGroup.create :name => 'china_means', :description => 'MeansChina', :target_class_name => 'Request'
MultiElementValue.create :multi_element_group_id => means_china_group.id, :value => 'Chinese Academic'
MultiElementValue.create :multi_element_group_id => means_china_group.id, :value => 'Chinese Research Institute'
MultiElementValue.create :multi_element_group_id => means_china_group.id, :value => 'China-based expert consultant'
MultiElementValue.create :multi_element_group_id => means_china_group.id, :value => 'China-based NGO'
MultiElementValue.create :multi_element_group_id => means_china_group.id, :value => 'International Academic'
MultiElementValue.create :multi_element_group_id => means_china_group.id, :value => 'International Research Institute'
MultiElementValue.create :multi_element_group_id => means_china_group.id, :value => 'International-based expert'
MultiElementValue.create :multi_element_group_id => means_china_group.id, :value => 'consultant'
MultiElementValue.create :multi_element_group_id => means_china_group.id, :value => 'International NGO'
MultiElementValue.create :multi_element_group_id => means_china_group.id, :value => 'Other'

user_salutation_group = MultiElementGroup.create :name => 'user_salutations', :description => 'UserSalutation', :target_class_name => 'User'
MultiElementValue.create :multi_element_group_id => user_salutation_group.id, :value => 'Dr.'
MultiElementValue.create :multi_element_group_id => user_salutation_group.id, :value => 'M.'
MultiElementValue.create :multi_element_group_id => user_salutation_group.id, :value => 'Mr.'
MultiElementValue.create :multi_element_group_id => user_salutation_group.id, :value => 'Ms.'
MultiElementValue.create :multi_element_group_id => user_salutation_group.id, :value => 'Prof.'
MultiElementValue.create :multi_element_group_id => user_salutation_group.id, :value => 'Rev.'


fip_type_group = MultiElementGroup.create :name => 'fip_types', :description => 'Fip Types', :target_class_name => 'Request'
MultiElementValue.create :multi_element_group_id => fip_type_group.id, :value => 'Contract'
MultiElementValue.create :multi_element_group_id => fip_type_group.id, :value => 'Meeting'
MultiElementValue.create :multi_element_group_id => fip_type_group.id, :value => 'Other'

employee_profile = UserProfile.create :name => 'Employee'
board_profile = UserProfile.create :name => 'Board'
consultant_profile = UserProfile.create :name => 'Consultant'
grantee_profile = UserProfile.create :name => 'Grantee'
reviewer_profile = UserProfile.create :name => 'Reviewer'

# define employee
UserProfileRule.create :user_profile => employee_profile, :permission_name => 'create_all'
UserProfileRule.create :user_profile => employee_profile, :permission_name => 'update_all'
UserProfileRule.create :user_profile => employee_profile, :permission_name => 'view_all'
UserProfileRule.create :user_profile => employee_profile, :permission_name => 'delete_all'

# define board
UserProfileRule.create :user_profile => board_profile, :permission_name => "view" , :model_type => "User"
UserProfileRule.create :user_profile => board_profile, :permission_name => "view", :model_type => "Organization"
UserProfileRule.create :user_profile => board_profile, :permission_name => "view", :model_type => "Request"
UserProfileRule.create :user_profile => board_profile, :permission_name => "view", :model_type => "RequestReport"
UserProfileRule.create :user_profile => board_profile, :permission_name => "listview", :model_type => "User"
UserProfileRule.create :user_profile => board_profile, :permission_name => "listview", :model_type => "Organization"
UserProfileRule.create :user_profile => board_profile, :permission_name => "listview", :model_type => "Request"
UserProfileRule.create :user_profile => board_profile, :permission_name => "listview", :model_type => "RequestReport"
UserProfileRule.create :user_profile => board_profile, :permission_name => "listview", :model_type => "ClientStore"
UserProfileRule.create :user_profile => board_profile, :permission_name => "create", :model_type => "ClientStore"
UserProfileRule.create :user_profile => board_profile, :permission_name => "update", :model_type => "ClientStore"

# define consultant
UserProfileRule.create :user_profile => consultant_profile, :permission_name => 'view_organization'
UserProfileRule.create :user_profile => consultant_profile, :permission_name => 'view_request'
UserProfileRule.create :user_profile => consultant_profile, :permission_name => 'view_grant'
UserProfileRule.create :user_profile => consultant_profile, :permission_name => 'view_report'
UserProfileRule.create :user_profile => consultant_profile, :permission_name => 'view_transaction'
UserProfileRule.create :user_profile => consultant_profile, :permission_name => 'create_request'

# define grantee
UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'create_own', :model_type => 'Request'
UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'view_own', :model_type => 'Request'
UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'update_own', :model_type => 'Request'
UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'delete_own', :model_type => 'Request'
UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'create_own', :model_type => 'ModelDocument'
UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'delete', :model_type => 'ModelDocument'
UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'update_own', :model_type => 'RequestReport'
UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'listview', :model_type => 'ModelDocument'
Role.create :name => 'Grantee', :roleable_type => 'Program'

# define reviewer
UserProfileRule.create :user_profile => reviewer_profile, :permission_name => 'view', :model_type => 'Request'
UserProfileRule.create :user_profile => reviewer_profile, :permission_name => 'create', :model_type => 'RequestReview'
UserProfileRule.create :user_profile => reviewer_profile, :permission_name => 'update_own', :model_type => 'RequestReview'

