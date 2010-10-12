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
  def render_requests_to_xml requests, output
    output.write '<?xml version="1.0" encoding="UTF-8"?>\n'
    output.write '<rss version="2.0">\n'
    output.write "  <channel>\n"
    output.write "    <title>EnergyFoundation hGrant Feed</title>\n"
    output.write "    <description>EnergyFoundation hGrant Feed</description>\n"
    output.write "    <link>#{hgrants_path}</link>\n"
    output.write "    <pubDate>#{Time.now}</pubDate>\n"
    output.write "    <language>en</language>\n"
    for model in @requests
      render_request_to_xml model, output
    end
    output.write "  </channel>\n"
    output.write "</rss>\n"
  end
  
  def render_request_to_xml model, output
    output.write "<item>\n"
    output.write "  <title>#{model.program_org_name} #{model.granted ? model.grant_id : model.request_id} #{(model.amount_recommended || model.amount_requested).to_currency(:precision => 0)} </title>\n"
    
    output.write "<description>\n"
    output.write "  <![[CDATA\n"
    output.write "    <div class='hgrant'>\n"
    output.write "      <h2 class='title' name='grant-#{model.id}'>\n"
    output.write "        <a class='url' href='#{url_for(model)}'>\n"
    output.write "          #{model.program_org_name} #{model.granted ? model.grant_id : model.request_id} #{(model.amount_recommended || model.amount_requested).to_currency(:precision => 0)}\n"
    output.write "        </a>\n"
    output.write "      </h2>\n"
    output.write "      <div>\n"
    output.write "        <span class='sector'>\n"
    output.write "          model.program_name\n"
    output.write "        </span>\n"
    output.write "      </div>\n"
    output.write "      <div class='grantor vcard'>\n"
    output.write "        <h3>Grantor</h3>\n"
    output.write "        <span class='fn org'>\n"
    output.write "          <a class='url' href='http://ef.org'>Energy Foundation</a></a>\n"
    output.write "        </span>\n"
    output.write "        <p class='adr'>\n"
    output.write "          <span class='street-address'>301 Battery Street</span>\n"
    output.write "          <span class='extended-address'>5th Floor</span>\n"
    output.write "          <span class='locality'>San Francisco</span>\n"
    output.write "          ,\n"
    output.write "          <abbr class='region' title='California'>CA</abbr>\n"
    output.write "          <span class='postal-code'>94111</span>\n"



    output.write "        </p>\n"
    output.write "      </div>\n"
    output.write "      <div class='geo-focus vcard'>\n"
    output.write "        <a class='url' href='#{url_for(model)}'>permalink</a>\n"
    output.write "      </div>\n"
    output.write "      <div class='grantee vcard'>\n"
    output.write "        <h3>\n"
    output.write "          Grantee\n"
    output.write "          <span class='fn org'>\n"
    output.write "            #{model.program_org_name}\n"
    output.write "            <p class='adr'>\n"
    output.write "              <span class='street-address'>#{model.program_org_street_address}</span>\n"
    output.write "              <span class='extended-address'>#{model.program_org_street_address2}</span>\n"
    output.write "              <span class='locality'>#{model.program_org_city}</span>\n"
    output.write "              <span class='region' title='#{model.program_org_state_name}'>#{model.program_org_state_name}</span>\n"
    output.write "              <span class='country_name' title='#{model.program_org_country_name}'>#{model.program_org_country_iso3}</span>\n"
    output.write "              <span class='postal-code'>#{model.program_org_postal_code}</span>\n"
    output.write "            </p>\n"
    output.write "          </span>\n"
    output.write "        </h3>\n"
    output.write "      </div>\n"
    output.write "      <p class='amount'>\n"
    output.write "        <abbr class='currency' title='USD'>$</abbr>\n"
    output.write "        <abbr class='amount' title='#{model.amount_recommended}'>#{(model.amount_recommended ? model.amount_recommended.number_with_precision(:precision => 2, :separator => '.', :delimiter => ',') : '')}</abbr>\n"
    output.write "      </p>\n"
    output.write "      <p class='period'>\n"
    output.write "        Grant Period:\n"
    output.write "        <abbr class='dtstart' title='#{(model.grant_begins_at ? model.grant_begins_at.hgrant : '')}'>(model.grant_begins_at ? model.grant_begins_at.abbrev_month_year : '')</abbr>\n"
    output.write "        <abbr class='dtend' title='#{(model.grant_ends_at ? model.grant_ends_at.hgrant : '')}'>(model.grant_ends_at ? model.grant_ends_at.abbrev_month_year : '')</abbr>\n"
    output.write "      </p>\n"
    output.write "      <div class='description'>#{model.project_summary}</div>\n"
    output.write "     </div>\n"
    output.write "  ]]>\n"
    output.write "</description>\n"
    
    output.write "  <pubDate></pubDate>\n"
    output.write "  <link>/grant_requests/7</link>\n"
    output.write "  <guid>7</guid>\n"
    output.write "</item>\n"
  end  
    
    
    
end
