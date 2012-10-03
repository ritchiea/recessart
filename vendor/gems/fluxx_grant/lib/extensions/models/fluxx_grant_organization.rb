module FluxxGrantOrganization
  require 'rexml/document'
  require 'rexml/xpath'
  require 'net/https'
  include REXML

  SEARCH_ATTRIBUTES = [:parent_org_id, :grant_program_ids, :grant_sub_program_ids, :state, :updated_at, :request_ids, :grant_ids, :favorite_user_ids, :related_org_ids]

  def self.included(base)
    base.send :include, ::FluxxOrganization

    base.has_many :grants, :class_name => 'GrantRequest', :foreign_key => :program_organization_id, :conditions => {:granted => 1}
    base.has_many :grant_requests, :class_name => 'Request', :foreign_key => :program_organization_id
    base.has_many :fiscal_requests, :class_name => 'Request', :foreign_key => :fiscal_organization_id
    base.has_many :program_grantees, :class_name => 'Program', :finder_sql => 'select * from programs where id in (select program_id from requests where program_organization_id = #{id} group by program_id)'

    base.insta_search
    base.insta_export
    base.insta_export do |insta|
      insta.filename = 'organization'
      insta.headers = [['Date Created', :date], ['Date Updated', :date], 'name', 'street_address', 'street_address2', 'city', 'state_name',
                  'country_name', 'postal_code', 'phone', 'other_contact', 'fax', 'email', 'url', 'blog_url', 'twitter_url', 'acronym', 'tax_class']
      insta.sql_query = "organizations.created_at, organizations.updated_at, organizations.name, street_address, street_address2, city, geo_states.name state_name,
                  geo_countries.name country_name,
                  postal_code, phone, other_contact, fax, email, url, blog_url, twitter_url, acronym, mev_tax_class.value tax_class_value
                  from organizations
                  left outer join geo_states on geo_states.id = geo_state_id
                  left outer join geo_countries on geo_countries.id = organizations.geo_country_id
                  left outer join multi_element_groups meg_tax_class on meg_tax_class.name = 'tax_classes'
                  left outer join multi_element_values mev_tax_class on multi_element_group_id = meg_tax_class.id and tax_class_id = mev_tax_class.id
                  WHERE
                  organizations.id IN (?)"
    end

    base.insta_search do |insta|
      insta.derived_filters = {
        :grant_program_ids => (lambda do |search_with_attributes, request_params, name, val|
          program_id_strings = val
          programs = Program.where(:id => program_id_strings).all.compact
          program_ids = programs.map do |program|
            children = program.children_programs
            if children.empty?
              program
            else
              [program] + children
            end
          end.compact.flatten.map &:id
          if program_ids && !program_ids.empty?
            search_with_attributes[:grant_program_ids] = program_ids
          end
        end),
      }
    end
    base.insta_multi
    base.insta_lock
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES + [:group_ids, :multi_element_value_ids]
    end
    base.insta_realtime do |insta|
      insta.delta_attributes = SEARCH_ATTRIBUTES
      insta.updated_by_field = :updated_by_id
    end

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
    base.add_sphinx if base.respond_to?(:sphinx_indexes) && !(base.connection.adapter_name =~ /SQLite/i)
  end

  module ModelClassMethods
    def add_sphinx
      define_index :organization_first do
        # fields
        indexes "lower(organizations.name)", :as => :name, :sortable => true
        indexes "lower(organizations.acronym)", :as => :acronym, :sortable => true
        indexes :vendor_number

        # attributes
        has created_at, updated_at, deleted_at, state, parent_org_id
        has 'null', :type => :multi, :as => :grant_program_ids
        has 'null', :type => :multi, :as => :grant_sub_program_ids
        has grants(:id), :as => :grant_ids
        has 'null', :type => :multi, :as => :request_ids
        has 'null', :type => :multi, :as => :fiscal_request_ids
        has request_organizations.request(:id), :type => :multi, :as => :org_request_ids
        has favorites.user(:id), :as => :favorite_user_ids
        has 'null', :type => :multi, :as => :user_ids
        has 'null', :type => :multi, :as => :group_ids
        has satellite_orgs(:id), :as => :satellite_org_ids
        has "CONCAT(organizations.id, ',', IFNULL(organizations.parent_org_id, '0'))", :as => :related_org_ids, :type => :multi
        has multi_element_choices.multi_element_value(:id), :type => :multi, :as => :multi_element_value_ids

        set_property :delta => :delayed
      end

      define_index :organization_second do
        indexes "lower(organizations.name)", :as => :name, :sortable => true
        indexes "lower(organizations.acronym)", :as => :acronym, :sortable => true

        # attributes
        has created_at, updated_at, deleted_at, state, parent_org_id
        has grants.program(:id), :as => :grant_program_ids
        has grants.sub_program(:id), :as => :grant_sub_program_ids
        has 'null', :type => :multi, :as => :grant_ids
        has 'null', :type => :multi, :as => :request_ids
        has 'null', :type => :multi, :as => :fiscal_request_ids
        has 'null', :type => :multi, :as => :org_request_ids
        has 'null', :type => :multi, :as => :favorite_user_ids
        has users(:id), :as => :user_ids
        has 'null', :type => :multi, :as => :group_ids
        has 'null', :type => :multi, :as => :satellite_org_ids
        has 'null', :type => :multi, :as => :related_org_ids
        has 'null', :type => :multi, :as => :multi_element_value_ids

        set_property :delta => :delayed
      end

      define_index :organization_third do
        indexes "lower(organizations.name)", :as => :name, :sortable => true
        indexes "lower(organizations.acronym)", :as => :acronym, :sortable => true

        # attributes
        has created_at, updated_at, deleted_at, state, parent_org_id
        has 'null', :type => :multi, :as => :grant_program_ids
        has 'null', :type => :multi, :as => :grant_sub_program_ids
        has 'null', :type => :multi, :as => :grant_ids
        has grant_requests(:id), :as => :request_ids
        has fiscal_requests(:id), :as => :fiscal_request_ids
        has 'null', :type => :multi, :as => :org_request_ids
        has 'null', :type => :multi, :as => :favorite_user_ids
        has 'null', :type => :multi, :as => :user_ids
        has 'null', :type => :multi, :as => :group_ids
        has 'null', :type => :multi, :as => :satellite_org_ids
        has 'null', :type => :multi, :as => :related_org_ids
        has 'null', :type => :multi, :as => :multi_element_value_ids

        set_property :delta => :delayed
      end

      define_index :organization_fourth do
        indexes "lower(organizations.name)", :as => :name, :sortable => true
        indexes "lower(organizations.acronym)", :as => :acronym, :sortable => true

        # attributes
        has created_at, updated_at, deleted_at, state, parent_org_id
        has 'null', :type => :multi, :as => :grant_program_ids
        has 'null', :type => :multi, :as => :grant_sub_program_ids
        has 'null', :type => :multi, :as => :grant_ids
        has 'null', :type => :multi, :as => :request_ids
        has 'null', :type => :multi, :as => :fiscal_request_ids
        has 'null', :type => :multi, :as => :org_request_ids
        has 'null', :type => :multi, :as => :favorite_user_ids
        has 'null', :type => :multi, :as => :user_ids
        has group_members.group(:id), :type => :multi, :as => :group_ids
        has 'null', :type => :multi, :as => :satellite_org_ids
        has 'null', :type => :multi, :as => :related_org_ids
        has 'null', :type => :multi, :as => :multi_element_value_ids

        set_property :delta => :delayed
      end
    end

    def sorted_tax_classes
      MultiElementGroup.find_values Organization, 'tax_classes'
    end
    
    def non_profit_tax_statuses
      ['509a1', '509a2', '509a3', '501c3']
    end
    
    def charity_check_api service, ein
      # Authenticate and retrieve the cookie
      begin
        response = HTTPI.post "https://www2.guidestar.org/WebServiceLogin.asmx/Login", "userName=#{Fluxx.config :username, :charity_check}&password=#{Fluxx.config :password, :charity_check}"
        cookie = response.headers["Set-Cookie"]

        # Call the GetCCPDF webservice
        request = HTTPI::Request.new "https://www2.guidestar.org/WebService.asmx/#{service}"
        request.body =  "ein=#{ein}"
        request.headers["Cookie"] = cookie
        HTTPI.post request
      rescue Exception => e
        nil
      end
    end
    

    def charity_check_enabled
      Fluxx.config(:enabled, :charity_check) == "1"
    end

    # Return an array of grants related to an organization
    def foundation_center_api ein=nil, pagenum=nil
      if ein
        begin
          response = HTTPI.get "http://gis.foundationcenter.org/web_services/fluxx/getRecipientGrants.php?ein=#{ein.strip.sub('-', '')}#{pagenum.nil? ? '' : '&pagenum=' + pagenum.to_s}"
          Crack::JSON.parse(response.body)
        rescue Exception => e
        end
      end
    end
  end

  module ModelInstanceMethods
    def request_ids
      grant_requests.map{|request| request.id}.flatten.compact
    end

    def grant_ids
      grants.map{|grant| grant.id}.flatten.compact
    end

    def auto_complete_name
      if is_headquarters?
        "#{name} - headquarters"
      else
        "#{name} - #{[street_address, city].compact.join ', '}"
      end
    end

    # Check if this is a satellite location and if so grab the tax class from the headquarters
    def hq_tax_class
      if is_satellite? && parent_org
        parent_org.tax_class
      else
        tax_class
      end
    end

    def grant_program_ids
      grants.map{|grant| grant.program.id if grant.program}.flatten.compact
    end

    def grant_sub_program_ids
      grants.map{|grant| grant.sub_program.id if grant.sub_program}.flatten.compact
    end

    def related_org_ids
      []
    end

    def related_requests look_for_granted=false, limit_amount=20
      granted_param = look_for_granted ? 1 : 0
      query = <<-SQL
        SELECT requests.*
          FROM requests
          WHERE deleted_at IS NULL AND (program_organization_id = ? or fiscal_organization_id = ?) AND granted = ?
          UNION
        SELECT requests.*
          FROM requests, request_organizations
          WHERE deleted_at IS NULL AND requests.id = request_organizations.request_id AND request_organizations.organization_id = ?
          AND granted = ?
        GROUP BY requests.id
        ORDER BY grant_agreement_at DESC, request_received_at DESC
        LIMIT ?
      SQL
      Request.find_by_sql([query, self.id, self.id, granted_param, self.id, granted_param, limit_amount])
    end

    def related_grants limit_amount=20
      related_requests true, limit_amount
    end

    def related_transactions limit_amount=20
      grants = related_grants limit_amount
      RequestTransaction.where(:deleted_at => nil).where(:request_id => grants.map(&:id)).order('due_at asc').limit(limit_amount)
    end

    def related_reports limit_amount=20
      grants = related_grants limit_amount
      # (current_user.is_board_member? ? RequestReport.where(:state => "approved") : RequestReport).where(:deleted_at => nil).where(:request_id => grants.map(&:id)).order('due_at asc').limit(limit_amount)
      (RequestReport).where(:deleted_at => nil).where(:request_id => grants.map(&:id)).order('due_at asc').limit(limit_amount)
    end

    def is_trusted?
      !grants.empty?
    end
    
    def is_er?
      tax_class_value = self.hq_tax_class ? self.hq_tax_class.value : ''
      !(tax_class_value && Organization.non_profit_tax_statuses.include?(tax_class_value))
    end
    
    def charity_check_applicable?
       Organization.charity_check_enabled && self.tax_id && !self.tax_id.empty?
    end
    
    # Update information about an organization using the Charity Check service
    def update_charity_check
      if charity_check_applicable?
        response = Organization.charity_check_api("GetCCInfo", self.tax_id);
        if response && response.code == 200
          # Charity Check seems to incorrectly return the XML encoding as utf-16
          xml = Crack::XML.parse(response.body)["string"].sub('<?xml version="1.0" encoding="utf-16"?>', '<?xml version="1.0" encoding="utf-8"?>')
          hash = Crack::XML.parse(xml)
          type = hash["GuideStarCharityCheckWebService"]["IRSBMFDetails"]["IRSBMFSubsection"] rescue nil
          self.update_attributes(
            :c3_serialized_response => xml,
            :c3_status_approved => type && (Organization.non_profit_tax_statuses.any?{|status|(type.gsub('(', '').gsub(')', '').strip =~ /#{status}/)}))
        end
      end
      hash
    end

    # Return the charity check pdf
    def charity_check_pdf
      if charity_check_applicable?
        response = Organization.charity_check_api("GetCCPDF", self.tax_id);
        if response && response.code == 200
          return Base64.decode64(Crack::XML.parse(response.body)["base64Binary"]) rescue nil
        end
      end
    end

    # Return values from the charity check response using XPath
    def charity_check key
      xmldoc = REXML::Document.new(c3_serialized_response)
      REXML::XPath.first(xmldoc, "//#{key}/text()") rescue nil
    end

    def outside_grants pagenum
      if (self.tax_id && !self.tax_id.empty?)
        Organization.foundation_center_api self.tax_id, pagenum
      end
    end
  end
end
