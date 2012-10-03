class OutsideGrantsController < ApplicationController
  def index
    org = Organization.find(params[:id])    
    @data = org.outside_grants(params[:pagenum])
    if @data && @data.is_a?(Array) && @data.count > 0
      @show_paging = @data.first["total_pages_available"].to_i > 1
      @pagenum = @data.first["page_num"]
      @total_pages = @data.first["total_pages_available"]    
      @show_prev_link = @pagenum.to_i > 1
      @show_next_link = @pagenum.to_i < @data.first["total_pages_available"].to_i    
    end
    render :index, :layout => nil
  end
end
