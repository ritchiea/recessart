# -*- coding: utf-8 -*-
module Rack
  class HgrantRack
    def initialize app
      @app = app
    end
    def call env
      hgrant_response = if env["PATH_INFO"] =~ /^\/hgrantrss\/(\d*)/
        requests = load_records '', {:sphinx_internal_id => $1}
        if requests && requests.num_rows > 0
          [200, {"Content-Type" => "text/html"}, ::RenderHgrantsRssResponse.new(requests, env['rack.url_scheme'] + '://' + Utils.unescape(env['HTTP_HOST']), true)]
        end
      elsif env["PATH_INFO"] =~ /^\/hgrantrss/
        @requests = load_records ''
        [200, {"Content-Type" => "application/rss+xml"}, ::RenderHgrantsRssResponse.new(@requests, env['rack.url_scheme'] + '://' + Utils.unescape(env['HTTP_HOST']))]
      end
      
      if hgrant_response
        ActiveRecord::Base.logger.debug "In HgrantRack with path_info=#{env["PATH_INFO"]}"
        hgrant_response
      else
        response, headers, content = @app.call env
        [response, headers, content]
      end
    end
    
    def load_records sphinx_search, sphinx_conditions={}
      ends_at_sql = if Fluxx.config(:dont_use_duration_in_requests) == "1"
        'grant_closed_at'
      else
        'date_add(date_add(grant_begins_at, interval duration_in_months MONTH), interval -1 DAY)'
      end
      
      @request_ids = ::Request.search_for_ids sphinx_search, :with => {:granted => 1, :deleted_at => 0, :filter_type => "GrantRequest".to_crc32}.merge(sphinx_conditions), :limit => 100000, :order => 'id desc'
      @requests = GrantRequest.connection.execute(GrantRequest.send(:sanitize_sql, ["select requests.*, 
          #{ends_at_sql} grant_ends_at,
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
      ", @request_ids]))
      
    end
  end
end

class RenderHgrantsRssResponse
  
  def initialize rss_response, hostname, render_as_html=false
    @resp = rss_response
    @host = hostname
    @as_html = render_as_html
  end
  
  def each &block
    if @as_html
      block.call(DisplayRssFeedGrantHTML.generate_grant_html(@resp.fetch_hash)) if @resp
    else
      render_requests_to_xml @resp, block
    end
  end
  def render_requests_to_xml grants, block
    block.call '<?xml version="1.0" encoding="UTF-8"?>'
    block.call '<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/">'
    block.call "  <channel>\n"
    block.call "    <title>EnergyFoundation hGrant Feed</title>\n"
    block.call "    <description>EnergyFoundation hGrant Feed</description>\n"
    # TODO ESH: find a way to call paths from within rack middleware
    # block.call "    <link>#{hgrants_path}</link>\n"
    block.call "    <pubDate>#{Time.now.rfc2822}</pubDate>\n"
    block.call "    <language>en</language>\n"
    while hash = grants.fetch_hash
      hash['host'] = @host
      render_request_to_xml hash, block
    end
    block.call "  </channel>\n"
    block.call "</rss>\n"
  end

  def render_request_to_xml hash, block
    block.call "<item>\n"
    block.call "  <title><![CDATA[#{hash['program_org_name']} #{hash['granted'] == '1' ? hash['grant_id'] : hash['request_id']} #{((hash['amount_recommended'] || hash['amount_requested']).to_i rescue 0).to_currency} ]]></title>\n".gsub("€", "&euro;")
  
    block.call "<description>\n"
    block.call "  <![CDATA[\n"
    block.call(DisplayRssFeedGrantHTML.generate_grant_html(hash))
    block.call "]]>"
    block.call "</description>\n"
    begins_at = Time.parse( hash['grant_begins_at']) rescue nil if hash['grant_begins_at']

    block.call "  <pubDate>#{begins_at ? begins_at.rfc2822 : ''}</pubDate>\n"
    block.call "  <link>/hgrantrss/#{hash['id']}</link>\n"
    block.call "  <guid>/hgrantrss/#{hash['id']}</guid>\n"
    block.call "</item>\n"
  end  
end

class DisplayRssFeedGrantHTML
  def self.grantor_hash
    if defined? @@hash_for_grantor
      @@hash_for_grantor
    else
      if grantor = Organization.current_grantor
        grantor = {
          :name => grantor.name,
          :street_address => grantor.street_address,
          :street_address2 => grantor.street_address2,
          :city => grantor.city,
          :geo_state => { 
            :name => grantor.geo_state.name, 
            :abbr => grantor.geo_state.abbreviation },
          :url => grantor.url,
          :postal_code => grantor.postal_code
        }
      else
        grantor = {
          :name => 'Energy Foundation',
          :street_address => '301 Battery Street',
          :street_address2 => '5th Floor',
          :city => 'San Francisco',
          :geo_state => {
            :name => 'California',
            :abbr => 'CA' },
          :url => 'http://ef.org',
          :postal_code => '94111'
        }
      end
      @@hash_for_grantor = grantor
    end
    
  end
  def self.generate_grant_html hash

    output = StringIO.new
    output.write "    <div class='hgrant'>\n"
    output.write "      <h2 class='title' name='grant-#{hash['id']}'>\n"
    output.write "        <a class='url' href='#{hash['host']}/hgrantrss/#{hash['id']}'>\n"
    output.write "          #{hash['program_org_name']} #{hash['granted'] == '1' ? hash['grant_id'] : hash['request_id']} #{((hash['amount_recommended'] || hash['amount_requested']).to_i rescue 0).to_currency(:precision => 0)}\n"
    output.write "        </a>\n"
    output.write "      </h2>\n"
    output.write "      <div>\n"
    output.write "        <span class='sector'>\n"
    output.write "          #{hash['program_name']}\n"
    output.write "        </span>\n"
    output.write "      </div>\n"
    output.write "      <div class='grantor vcard'>\n"
    output.write "        <h3>Grantor</h3>\n"
    output.write "        <span class='fn org'>\n"
    output.write "          <a class='url' href='#{grantor_hash[:url]}'>#{grantor_hash[:name]}</a></a>\n"
    output.write "        </span>\n"
    output.write "        <p class='adr'>\n"
    output.write "          <span class='street-address'>#{grantor_hash[:street_address]}</span>\n"
    output.write "          <span class='extended-address'>#{grantor_hash[:street_address2]}</span>\n"
    output.write "          <span class='locality'>#{grantor_hash[:city]}</span>\n"
    output.write "          ,\n"
    output.write "          <abbr class='region' title='#{grantor_hash[:geo_state][:name]}'>#{grantor_hash[:geo_state][:abbr]}</abbr>\n"
    output.write "          <span class='postal-code'>#{grantor_hash[:postal_code]}</span>\n"



    output.write "        </p>\n"
    output.write "      </div>\n"
    output.write "      <div class='geo-focus vcard'>\n"
    output.write "        <a class='url' href='#{hash['host']}/hgrantrss/#{hash['id']}'>permalink</a>\n"
    output.write "      </div>\n"
    output.write "      <div class='grantee vcard'>\n"
    output.write "        <h3>\n"
    output.write "          Grantee\n"
    output.write "          <span class='fn org'>\n"
    output.write "            #{hash['program_org_name']}\n"
    output.write "            <p class='adr'>\n"
    output.write "              <span class='street-address'>#{hash['program_org_street_address']}</span>\n"
    output.write "              <span class='extended-address'>#{hash['program_org_street_address2']}</span>\n"
    output.write "              <span class='locality'>#{hash['program_org_city']}</span>\n"
    output.write "              <span class='region' title='#{hash['program_org_state_name']}'>#{hash['program_org_state_name']}</span>\n"
    output.write "              <span class='country_name' title='#{hash['program_org_country_name']}'>#{hash['program_org_country_iso3']}</span>\n"
    output.write "              <span class='postal-code'>#{hash['program_org_postal_code']}</span>\n"
    output.write "            </p>\n"
    output.write "          </span>\n"
    output.write "        </h3>\n"
    output.write "      </div>\n"
    output.write "      <p class='amount'>\n"
    output.write "        <abbr class='currency' title='#{CurrencyHelper.current_short_name.downcase == 'dollar' ? 'USD' : CurrencyHelper.current_short_name}'>#{CurrencyHelper.current_symbol}</abbr>\n"
    output.write "        <abbr class='amount' title='#{(hash['amount_recommended'].to_i rescue 0)}'>#{(hash['amount_recommended'] ? (hash['amount_recommended'].to_i rescue 0).to_currency(:precision => 2, :separator => '.', :delimiter => ',', :unit => '') : '')}</abbr>\n"
    output.write "      </p>\n"
    output.write "      <p class='period'>\n"
    output.write "        Grant Period:\n"
    begins_at = Time.parse( hash['grant_begins_at']) rescue nil if hash['grant_begins_at']
    ends_at = Time.parse( hash['grant_ends_at']) rescue nil if hash['grant_ends_at']
    output.write "        <abbr class='dtstart' title='#{(begins_at ? begins_at.hgrant : '')}'>#{begins_at ? begins_at.abbrev_month_year : ''}</abbr>\n"
    output.write "        <abbr class='dtend' title='#{ends_at ? ends_at.hgrant : ''}'>#{ends_at ? ends_at.abbrev_month_year : ''}</abbr>\n"
    output.write "      </p>\n"
    output.write "      <div class='description'>#{hash['project_summary']}</div>\n"
    output.write "     </div>\n"
    output.string.gsub("€", "&euro;")
  end
end
