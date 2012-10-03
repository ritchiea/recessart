class ActiveRecord::ModelDsl
  # associated model class
  attr_accessor :model_class
  # whether to really delete or just update a deleted_at column
  attr_accessor :really_delete

  def initialize model_class_param
    self.model_class = model_class_param
    self.really_delete = !(model_class.columns.map(&:name).include? 'deleted_at') rescue nil
  end
end
