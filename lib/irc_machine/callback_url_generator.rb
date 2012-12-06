module IrcMachine::CallbackUrlGenerator

  def new_callback
    callback = {}
    callback[:url] = URI(settings["callback_base"]).tap do |uri|
      callback[:path] = "#{callback_path}/#{@uuid.generate}"
      uri.path = callback[:path]
    end
    callback
  end

  def juici_url
    settings["juici_url"]
  end

end
