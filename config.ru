require 'app'
require 'lib/canonical_host'

use CanonicalHost do
  case (ENV["RACK_ENV"]||"development").to_sym
    when :production then 'www.germanforblack.com'
  end
end

use Rack::ETag
run Germanforblack::Application