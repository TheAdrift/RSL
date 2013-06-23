STRICT = true
DEBUG = true

require 'zoetrope'
--require 'test'
require 'GameLogic'

the.app = App:new
{
	onRun = function (self)
		self.view = Game:new()
	end
}
