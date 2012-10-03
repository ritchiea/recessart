module FluxxCrmAlertRecipient
  extend FluxxModuleHelper

  when_included do
    belongs_to :user
    belongs_to :alert

    validates :alert, :presence => true
  end
end
