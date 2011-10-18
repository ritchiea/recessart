class FluxxGrantAddOldValueFieldsToRequestAmendmentsTable < ActiveRecord::Migration
  def self.up
    change_table :request_amendments do |t|
      t.integer :old_duration
      t.datetime :old_start_date
      t.datetime :old_end_date
      t.decimal :old_amount_recommended, :scale => 2, :precision => 15
    end

    execute "create temporary table original_amendment_values select request_amendments.id, ra_orig.amount_recommended old_amount_recommended,
            ra_orig.duration old_duration,
            ra_orig.start_date old_start_date,
            ra_orig.end_date old_end_date

            from request_amendments
            LEFT OUTER JOIN request_amendments ra_orig on ra_orig.request_id = request_amendments.request_id and ra_orig.original = 1
            where request_amendments.original <> 1"


      execute "update request_amendments ra, original_amendment_values ora
      set ra.old_amount_recommended = ora.old_amount_recommended,
      ra.old_duration = ora.old_duration,
      ra.old_start_date = ora.old_start_date,
      ra.old_end_date = ora.old_end_date
      where ra.id = ora.id"
  end

  def self.down
    change_table :request_amendments do |t|
      t.remove :old_duration
      t.remove :old_start_date
      t.remove :old_end_date
      t.remove :old_amount_recommended
    end
  end
end