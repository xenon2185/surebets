require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

module Clockwork

  every 5.minute, 'pinnacle' do
    PinnacleWorker.perform_async
  end

end 