module NeedsHelper

  def barter_label(willing_to_barter)
    if willing_to_barter
      "The user is willing to barter"
    else
      "The user is NOT willing to barter"
    end
  end
end
