class Scheduler::Shift < ActiveRecord::Base
  belongs_to :shift_group
  belongs_to :county, class_name: 'Roster::County'


  has_and_belongs_to_many :positions, class_name: 'Roster::Position'
  has_many :shift_assignments

  validates :max_signups, numericality: true, presence: true
  validates_presence_of :name, :abbrev

  def can_sign_up_on_day(date)
    return false if date < Date.current
    return false if signups_frozen_before and date < signups_frozen_before
    return true if max_signups == 0

    assignments = shift_assignments.where(date: date).count
    return assignments < max_signups
  end

  def active_on_day?(date)
    return (shift_begins.nil? || shift_begins < date) && (shift_ends.nil? || shift_ends < date)
  end

  def can_be_taken_by?(person)
    if person.counties.include? county
      pos = positions & person.positions
      !pos.blank?
    else
      false
    end
  end

  def shifts_taken_by_day(month, include_zeroes: true)
    days = include_zeroes ? (month..(month.end_of_month)).inject({}){|hash, date| hash[date]=0; hash} : {}
    shift_assignments.where("date >= ? and date <= ?", month, month.end_of_month).group(:date).select('count(id) as count, date').order(:date).inject(days){|hash, el| hash[el.date] = el.count; hash}
  end

  def shift_available_by_day(month, include_partial: true)
    shifts_taken_by_day(month).tap{|h|
      h.merge!(h){|k, v| v == 0 || (include_partial and v < max_signups)}
    }
  end

  def count_shifts_available_for_month(month, include_partial: true, only_future: true)
    shift_available_by_day(month).map{|date, avail| (!only_future or date >= Date.today) && avail ? 1 : 0}.sum
  end

  def total_shifts_for_month(month)
    ((month.end_of_month)-month).to_i
  end
end
