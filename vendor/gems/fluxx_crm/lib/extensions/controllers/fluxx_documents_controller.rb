module FluxxDocumentsController
  def self.included(base)
    base.insta_index Document do |insta|
      insta.suppress_model_iteration = true
      insta.template = 'document_list'
    end

    base.insta_post Document do |insta|
      insta.pre do |conf|
        if params[:name]
          # Need to grab the file and add it to the document
          self.pre_model = Document.new params[:document]
          f = Tempfile.new params[:name]
          f.write request.body.read
          pre_model.document = f
          f.close
          pre_model.document_file_name = params[:name]
        end
      end
      
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          render :text => outcome
        end
      end
    end
    base.insta_delete Document do |insta|
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          render :text => outcome
        end
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