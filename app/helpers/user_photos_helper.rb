module UserPhotosHelper
  def add_photo_message(album)
    msg = String.new
    if album.user_photos.empty?
      msg << "No photos have been added to this album yet. "
    end
    msg << link_to("Add a photo to '#{h(album.title)}'", new_user_album_photo_path(album.user, album)) if album.user == current_user
  end
end