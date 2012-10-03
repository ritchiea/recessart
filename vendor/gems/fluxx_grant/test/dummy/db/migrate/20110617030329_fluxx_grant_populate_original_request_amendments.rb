class FluxxGrantPopulateOriginalRequestAmendments < ActiveRecord::Migration
  def self.normalize_attributes(attrs)
    return {} if attrs.is_a?(String)

    attrs["start_date"] ||= attrs["grant_begins_at"]
    attrs["end_date"]   ||= attrs["grant_closed_at"]
    attrs["duration"]   ||= attrs["duration_in_months"]
    
    attrs.reject { |k,v| v.nil? or not %w[start_date end_date duration amount_recommended].include?(k.to_s) }
  end

  def self.up
    RequestAmendment.delete_all
    Request.where(:granted => 1).each { |request|
      original = request.request_amendments.build(:original => true)
      original.attributes = normalize_attributes(request.attributes)

      request.audits.each { |audit|
        changes = audit.audit_changes
        changes = normalize_attributes(changes)
        changes.each { |k,v| changes[k] = v.last if v && v.is_a?(Array) }

        if original.new_record? && %w[granted closed rejected].include?(changes["state"].to_s)
          original.attributes = changes
          original.save
        end

        unless changes.empty?
          amendment = request.request_amendments.build(changes.merge(:original => false))
          amendment.save
        end
      }

      original.save if original.new_record?
    }
  end

  def self.down
    RequestAmendment.delete_all
  end
end
