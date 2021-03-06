class Volunteer::Registration < ActiveRecord::Base
  has_many :assignments, dependent: :destroy
  has_many :positions, through: :assignments
  has_many :roles, through: :positions
  belongs_to :profile
  belongs_to :event

  attr_accessible :event_id, :will_setup, :will_teardown

  validates_presence_of :event
  #validates_presence_of :profile

  delegate :first_name, :last_name, :full_name, to: :profile

  enum_attr :status, %w(^registered withdrew no_show checked_in)

  def not_attending?
    status_is_withdrew? || status_is_no_show?
  end

  def reports_to
    Volunteer::Registration.includes([:event, :profile, :roles]).
      where(volunteer_roles: { id: roles.select(:reports_to_id) }).
      where({:events => { id: event.id }})
  end

  def self.active
    includes(:profile).where({status: [:registered, :checked_in]}).order("profiles.first_name ASC, profiles.last_name ASC")
  end
end
