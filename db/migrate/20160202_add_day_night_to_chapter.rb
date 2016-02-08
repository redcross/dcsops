class AddDayNightToChapter < ActiveRecord::Migration
  def change
    add_column :roster_chapters, :scheduler_flex_day_start, :integer
    add_column :roster_chapters, :scheduler_flex_night_start, :integer
  end
end
