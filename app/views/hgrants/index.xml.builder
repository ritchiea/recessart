xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "EnergyFoundation hGrant Feed"
    xml.description "EnergyFoundation hGrant Feed"
    xml.link hgrants_path
    xml.pubDate Time.now
    xml.language 'en'

    for request in @requests
      xml.item do
        xml.title "#{request.program_org_name} #{request.granted ? request.grant_id : request.request_id} #{(request.amount_recommended || request.amount_requested).to_currency(:precision => 0)}"
        xml << render(:partial => 'hgrants/request_detail.html.haml', :locals => { :model => request })
        xml.pubDate (request.grant_begins_at ? request.grant_begins_at.date_time_seconds : '')
        xml.link url_for(request)
        xml.guid request.id
      end
    end
  end
end
