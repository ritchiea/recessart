class ClientStoresController < ApplicationController
  insta_index ClientStore do |insta|
    insta.pre do |controller_dsl|
      self.pre_models = if fluxx_current_user
        search = ClientStore.where(:user_id => fluxx_current_user.id).where(:deleted_at => nil)
        if params[:client_store_type]
          search = search.where(:client_store_type => params[:client_store_type]) 
        end
        results = search.all
      else
        []
      end
    end
    
    insta.format do |format|
      format.json do |pair, outcome|
        controller_dsl, outcome = pair
        render :inline => instance_variable_get("@models").map {|model| {:client_store => (model.attributes), :url => url_for(model)}}.to_json
      end
    end
  end
  insta_post ClientStore do |insta|
    insta.dont_display_flash_message = true
    insta.pre do |conf|
      self.pre_model = ClientStore.new params[:client_store]
      pre_model.user_id = fluxx_current_user.id if fluxx_current_user
    end
  end
  insta_put ClientStore do |insta|
    insta.dont_display_flash_message = true
  end
  insta_delete ClientStore do |insta|
    insta.dont_display_flash_message = true
  end
  
  insta_show ClientStore do |insta|
    insta.template = 'client_store_show'
  end
end