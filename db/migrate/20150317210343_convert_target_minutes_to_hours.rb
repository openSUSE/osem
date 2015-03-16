class ConvertTargetMinutesToHours < ActiveRecord::Migration
  class TempTarget < ActiveRecord::Base
    self.table_name = 'targets'
    attr_accessible :target_count, :unit
  end

  def up
    targets = TempTarget.where(unit: 'Program minute').where.not(target_count: nil)
    targets.each do |target|
      new_target_count = (target.target_count / 60.to_f).round
      target.update_attributes(target_count: new_target_count, unit: 'Program hours')
    end
  end

  def down
    targets = TempTarget.where(unit: 'Program hours').where.not(target_count: nil)
    targets.each do |target|
      new_target_count = (target.target_count * 60.to_f).round
      target.update_attributes(target_count: new_target_count, unit: 'Program minute')
    end
  end
end
