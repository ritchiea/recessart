class RealtimeUpdatesController < ApplicationController

  def index
    if params[:ts]
      delta_ts
    else
      deltas = if params[:last_id]
        last_id = (params[:last_id].to_i)
        RealtimeUpdate.find :all, :conditions => [
          'id > ?', last_id
        ], :order => 'id asc'
      else
        []
      end
    
      # remove dupes; take last state of each model
      delta_map = {}
      deltas.each do |delt|
        delta_map[delt.model_class + delt.model_id.to_s] = delt
      end
      deltas = delta_map.values
    
      converted_deltas = deltas.map do |delta|
        delta.attributes
      end
      last_id, last_ts = current_ts
      render :inline => {:last_id => last_id, :ts => last_ts.to_i, :deltas => (converted_deltas)}.to_json
    end
  end
  
  protected
  def current_ts
    # We need the current because it's based on what's
    # happened since the last ping from the requesting user.
    # Time.now
    last_model_delta = RealtimeUpdate.find(:last, :select => 'created_at, id')
    
    # Make sure this is always UTC
    last_model_delta ? [last_model_delta.id, (last_model_delta.created_at.to_i)] : [0, (Time.now.to_i + (-1 * Time.now.gmt_offset))]
  end

  def delta_ts
    last_id, last_ts = current_ts
    render :inline => {:last_id => last_id, :ts => last_ts.to_i}.to_json
  end
end