module FluxxNotesController
  def self.included(base)
    base.insta_index Note do |insta|
      insta.template = 'note_list'
      insta.suppress_model_iteration = true
    end
    base.insta_show Note do |insta|
      insta.template = 'note_show'
    end
    base.insta_new Note do |insta|
      insta.template = 'note_form'
    end
    base.insta_edit Note do |insta|
      insta.template = 'note_form'
    end
    base.insta_post Note do |insta|
      insta.template = 'note_form'
    end
    base.insta_put Note do |insta|
      insta.template = 'note_form'
    end
    base.insta_delete Note do |insta|
      insta.template = 'note_form'
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