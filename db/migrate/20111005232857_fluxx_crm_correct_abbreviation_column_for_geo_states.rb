class FluxxCrmCorrectAbbreviationColumnForGeoStates < ActiveRecord::Migration
  def self.up
    execute "update geo_states set abbreviation = fips_10_4 
    where fips_10_4 not like '%0' and fips_10_4 not like '%1' and fips_10_4 not like '%2' and fips_10_4 not like '%3' and 
    fips_10_4 not like '%4' and fips_10_4 not like '%5' and fips_10_4 not like '%6' and fips_10_4 not like '%7' and fips_10_4 not like '%8' and 
    fips_10_4 not like '%9'"
  end

  def self.down
    
  end
end