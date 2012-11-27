class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    @user = user || User.new(:role => 'none') # guest user (not logged in)

    can [:read, :update, :edit], User, :id => @user.id

    if @user.user?
      cancan_user
    end

    # no one except superadmins can admin
    cannot :admin, :all
  end

  def cancan_user
  end

end
