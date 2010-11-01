class HgrantsController < ApplicationController
  skip_before_filter :authenticate_user!
  
  def index
    @request_ids = Request.search_for_ids '', :with => {:grant => 1}, :limit => 1000, :order => 'id desc'
    @requests = Request.find_by_sql ["select requests.*, 
        program.name program_name,
        program_organization.name program_org_name, 
        program_organization.street_address program_org_street_address, program_organization.street_address2 program_org_street_address2, program_organization.city program_org_city,
        program_org_country_states.name program_org_state_name, program_org_countries.name program_org_country_name, program_organization.postal_code program_org_postal_code,
        program_org_countries.iso3 program_org_country_iso3,
        program_organization.url program_org_url
      FROM requests
      LEFT OUTER JOIN programs program ON program.id = requests.program_id
      LEFT OUTER JOIN organizations program_organization ON program_organization.id = requests.program_organization_id
      left outer join geo_states as program_org_country_states on program_org_country_states.id = program_organization.geo_state_id
      left outer join geo_countries as program_org_countries on program_org_countries.id = program_organization.geo_country_id
      WHERE requests.id in (?)
    ", @request_ids]
    
    
    # respond_to do |format|
    #   format.html {render :action => 'index.html.haml'}
    #   format.xml {render :action => 'index_xml.html.haml'}
    # end
    
    
    # render :text => Proc.new { |response, output|
    #   def output.<<(*args)  
    #     write(*args)  
    #   end  
    #   
    #   render_requests_to_xml @requests, output
    # }
  end
  
  def show
    @request = Request.find params[:id]
  end

protected  

    
    
end
