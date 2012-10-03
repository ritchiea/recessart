module FluxxGroupMembersController
  def self.included(base)
    base.insta_index GroupMember do |insta|
      insta.template = 'group_member_list'
    end
    base.insta_show GroupMember do |insta|
      insta.template = 'group_member_show'
    end
    base.insta_new GroupMember do |insta|
      insta.template = 'group_member_form'
    end
    base.insta_post GroupMember do |insta|
      insta.template = 'group_member_form'
    end
    base.insta_delete GroupMember do |insta|
      insta.template = 'group_member_form'
    end

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
  end
end