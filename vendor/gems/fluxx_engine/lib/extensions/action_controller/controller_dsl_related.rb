# This allows users to express relations between objects and how they should be displayed.
# Among models, there are always objects that they have relationships with.  For example, workers work at companies,
# so if viewing a company page, there should be an easy way to jump to the list of workers at that particular company.
# To do this, a filter must be specified to limit the workers that are related to that company.
class ActionController::ControllerDslRelated < ActionController::ControllerDsl
# GETTERS/SETTERS stored here:
  # An ordered list of relations of this model to other model objects
  attr_accessor :relations

  # Sample usage o the add_related method
  # insta_related do |related_insta|
  #   insta.add_related do |block_insta|
  #     block_insta.add_related do |insta|
  #       insta.display_name = "People"
  #       for_search do |model|
  #         ... return a list of people model objects related to model_id in this case
  #       end
  #       insta.display_template = '/users/related_users'
  #     end
  #   end
  # end
  def add_related
    relationship = ActionController::ModelRelationship.new
    yield relationship if block_given?
    self.relations = [] unless relations && relations.is_a?(Array)
    relations << relationship
  end
  
  # Returns an array of formatted data per related class
  def load_related_data controller, model
    model_relations = []
    
    if relations && !relations.empty?
      model_relations = model_relations + relations
    end
    
    model_relations.map do |rd|
      if rd.show_tab.nil? || rd.show_tab.call([controller, model])
        if rd.lazy_load
          {:lazy_load_url => rd.generate_url(controller, model), :display_name => rd.display_name}
        else
          formatted_data = calculate_related_data_row(controller, model, rd).uniq_by{|element| element[:model]}
          {:formatted_data => formatted_data, :display_name => rd.display_name}
        end
      end
    end.compact
  end
  
  def calculate_related_data_row controller, model, rd
    display_template = rd.display_template    
    related_models = if rd.search_block
      rd.search_block.call model
    end || []    
    related_models.compact.map do |model|
      {:display_template => display_template, :model => model, :title => rd.generate_title(model), :model_url => rd.generate_url(controller, model)}
    end
  end
  
end


class ActionController::ModelRelationship
  # Name of the related data tab
  attr_accessor :display_name
  # block to call to search.  Expect to 
  attr_accessor :search_block
  # Template used to display the results
  attr_accessor :display_template
  # Block to translate the model into a title to be used when opening a new show card for that model object
  attr_accessor :title_block
  # Block to return the URL for a related model
  attr_accessor :url_block
  attr_accessor :lazy_load
  attr_accessor :show_tab
  
  def add_title_block &block_title
    self.title_block = block_title
  end
  
  def add_model_url_block &block_url
    self.url_block = block_url
  end

  def add_lazy_load_url &ll_url
    self.url_block = ll_url
    self.lazy_load = true
  end

  def for_search &block_search
    self.search_block = block_search
  end

  def show_tab? &block_show_tab
    self.show_tab = block_show_tab
  end
  
  def generate_title model
    if self.title_block && self.title_block.is_a?(Proc)
      self.title_block.call model
    else
      model.class.to_s.humanize
    end
  end
  
  def generate_url controller, model
    if self.url_block && self.url_block.is_a?(Proc)
      controller.instance_exec model, &self.url_block
    end
  end
end