module FluxxProjectsController
  ICON_STYLE = 'style-projects'
  def self.included(base)
    base.insta_index Project do |insta|
      insta.template = 'project_list'
      insta.filter_title = "Project Filter"
      insta.filter_template = 'projects/project_filter'
      insta.order_clause = 'created_at desc'
      insta.icon_style = ICON_STYLE
    end
    base.insta_show Project do |insta|
      insta.template = 'project_show'
      insta.footer_template = 'projects/project_footer'
      insta.icon_style = ICON_STYLE
    end
    base.insta_new Project do |insta|
      insta.template = 'project_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit Project do |insta|
      insta.template = 'project_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post Project do |insta|
      insta.template = 'project_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put Project do |insta|
      insta.template = 'project_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_delete Project do |insta|
      insta.template = 'project_form'
      insta.icon_style = ICON_STYLE
    end
    
    base.insta_related Project do |insta|
      insta.add_related do |related|
        related.display_name = 'Orgs'
        related.add_title_block do |model|
          model.name if model
        end
        related.for_search do |model|
          model.related_organizations
        end
        related.display_template = '/organizations/related_organization'
      end
      insta.add_related do |related|
        related.display_name = 'People'
        related.for_search do |model|
          model.related_users
        end
        related.add_title_block do |model|
          model.full_name if model
        end
        related.display_template = '/users/related_users'
      end
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