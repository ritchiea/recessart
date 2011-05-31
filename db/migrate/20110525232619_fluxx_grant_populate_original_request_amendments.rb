class FluxxGrantPopulateOriginalRequestAmendments < ActiveRecord::Migration
  def self.fill_in_amendment(amendment, changes)
    amendment.amount_recommended = changes["amount_recommended"] if changes["amount_recomended"]
          
    unless (FLUXX_CONFIGURATION[:dont_use_duration_in_requests])
      amendment.duration = changes["duration_in_months"] if changes["duration_in_months"]
    else
      amendment.start_at = changes["grant_begins_at"] if changes["grant_begins_at"]
      amendment.end_at = changes["grant_closed_at"] if changes["grant_closed_at"]
    end

    return !!(changes["grant_begins_at"] || changes["grant_closed_at"] || 
      changes["duration_in_months"] || changes["amount_recommended"])
  end

  def self.up
    RequestAmendment.delete_all
    Request.where(:granted => 1).each { |request|
      original = request.request_amendments.build(:original => true)
      fill_in_amendment(original, request.attributes);

      request.audits.each { |audit|
        changes = audit.audit_changes
        changes.each {|x,v| changes[x] = v.last if v && v.is_a?(Array) }

        if original.new_record?
          fill_in_amendment(original, changes)
          original.save if state = changes["state"] and state =~ /(granted|closed|rejected)/i
        else
          amendment = request.request_amendments.build(:original => false)
          amendment.save if fill_in_amendment(amendment, changes)
        end
      }

      original.save if original.new_record?
    }
  end

  def self.down
    RequestAmendment.delete_all
  end
end
