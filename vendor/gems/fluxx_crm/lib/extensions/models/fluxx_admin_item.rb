module FluxxAdminItem
  extend FluxxModuleHelper

  ADMIN_ITEMS = [["Record Management", ""], ["Plug Ins", ""], ["Users & Roles", ""], ["Data Import", ""], ["Letters & Templates", ""],
                ["Emails & Alerts", "",], ["Global Settings", ""], ["Billing", ""]]

  class_methods do
    def model_search q_search, params, results_per_page, conditions
      ADMIN_ITEMS.map{ |item| self.new item[0], item[1]}
    end
    def calculate_form_name
      ""
    end
    def page_by_ids models
      models
    end
  end

  instance_methods do
    attr_accessor :name
    attr_accessor :url
    def initialize name, url
      self.name = name
      self.url = url
    end
    def id
      url.hash
    end
  end
end