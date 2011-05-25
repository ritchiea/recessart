class FluxxGrantPopulateOriginalRequestAmendments < ActiveRecord::Migration
  def self.up
    Request.where(:state => "granted").each { |r|
      amendment = r.request_amendments.build(
        :original => true,
        :amount_recommended => r.amount_recommended,
        :grant_begins_at => r.grant_begins_at,
        :grant_closed_at => r.grant_closed_at,
        :duration => r.duration_in_months
      )
      amendment.save
    }
  end

  def self.down
    RequestAmendment.where(:original => true).destroy
  end
end
