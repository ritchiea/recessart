class FluxxGrantPopulateOriginalRequestAmendments < ActiveRecord::Migration
  def self.up
    Request.where(:granted => true).each { |r|
      amendment = r.request_amendments.build(
        :original => true,
        :amount_recommended => r.amount_recommended,
        :start_date => r.grant_begins_at,
        :end_date => r.grant_closed_at,
        :duration => r.duration_in_months
      )
      amendment.save
    }
  end

  def self.down
    RequestAmendment.where(:original => true).destroy
  end
end
