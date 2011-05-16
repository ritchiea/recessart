class FluxxGrantUseClassNamesForModalReports < ActiveRecord::Migration
  def self.up
    ClientStore.all.each do |client_store|
      if client_store.data
        data = client_store.data.de_json

        data['cards'].to_a.each do |card|
          if detail = card['detail'] and detail['url'].to_s =~ %r{^/modal_reports/\d+}
            data.delete(card)
          end
        end

        client_store.update_attributes :data => data.to_json
      end
    end
  end

  def self.down
  end
end
