defmodule AppSupervisor do

	#This is the supervisor that coordinates the work among all the workers
	use Supervisor

	def start_link(topology) do
		Supervisor.start_link(__MODULE__, [topology], name: :GPSupervisor)
	end
	def init([topology]) do
		worker = 
			case topology do
				:gossip -> GossipWorker
				:pushsum -> PushSumWorker
				_ -> raise ArgumentError, message: "Invalid topology"
			end
		children = [
			worker(worker, [], restart: :temporary)
		]
		supervise(children, strategy: :simple_one_for_one)
	end
end