class RealtimeUpdate < ActiveRecord::Base
  def model
    type_name.constantize.find(model_id)
  end
end
