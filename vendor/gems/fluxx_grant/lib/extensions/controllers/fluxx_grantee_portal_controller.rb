module FluxxGranteePortalController
  def self.included(base)
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    ITEMS_PER_PAGE = 10
    def index
      if current_user.is_grantee?
        org_ids = current_user.primary_organization.id

        client_store = ClientStore.where(:user_id => fluxx_current_user.id, :client_store_type => 'grantee portal').first ||
                       ClientStore.create(:user_id => fluxx_current_user.id, :client_store_type => 'grantee portal', :data => {:pages => {:requests => 1, :grants => 1, :reports => 1, :transactions => 1}}.to_json, :name => "Default")

        settings = client_store.data.de_json

        all = !params[:requests] && !params[:grants] && ! params[:reports] && !params[:transactions]
        table = params[:table] ? (["requests", "grants", "reports", "transactions"].index(params[:table]) ? params[:table] : :all) : :all
        page = params[:page] ? params[:page] : settings["pages"][table]
        settings["pages"][table] = page if (table != :all)

        requests = Request.where("(requests.program_organization_id in (?) OR requests.fiscal_organization_id in (?)) AND requests.type = ? AND requests.deleted_at IS NULL", org_ids, org_ids, "GrantRequest")
        request_ids = requests.map { |request| request.id }

        if table == :all || table == "requests"
          @requests = requests.where(:granted => false).order("created_at desc").paginate :page => settings["pages"]["requests"], :per_page => ITEMS_PER_PAGE
          @title = "Requests"
          template = "_grant_request_list"
        end

        if table == :all || table == "grants"
          @grants = requests.where(:granted => true).order("created_at desc").paginate :page => settings["pages"]["grants"], :per_page => ITEMS_PER_PAGE
          @title = "Grants"
          template = "_grant_request_list"
        end

        if table == :all || table == "reports"
          @reports = RequestReport.where(:request_id => request_ids).order("created_at desc").paginate :page => settings["pages"]["reports"], :per_page => ITEMS_PER_PAGE
          template = "_report_list"
        end

        if table == :all || table == "transactions"
          @transactions = RequestTransaction.where(:request_id => request_ids).order("created_at desc").paginate :page => settings["pages"]["transactions"], :per_page => ITEMS_PER_PAGE
          template = "_transaction_list"
        end

        if table != :all
          client_store.data = settings.to_json
          client_store.save
          @data = @requests || @grants || @reports || @transactions
          render template, :layout => false
        end
      else
       redirect_back_or_default dashboard_index_path
      end
    end
  end
end