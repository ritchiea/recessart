module FluxxBankAccountsController
  ICON_STYLE = 'style-bank-accounts'
  def self.included(base)
    base.insta_index BankAccount do |insta|
      insta.template = 'bank_account_list'
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
    end
    base.insta_show BankAccount do |insta|
      insta.template = 'bank_account_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new BankAccount do |insta|
      insta.template = 'bank_account_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit BankAccount do |insta|
      insta.template = 'bank_account_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post BankAccount do |insta|
      insta.template = 'bank_account_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put BankAccount do |insta|
      insta.template = 'bank_account_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete BankAccount do |insta|
      insta.template = 'bank_account_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related BankAccount do |insta|
      insta.add_related do |related|
      end
    end
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
  end
end