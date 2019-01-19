defmodule MainController do

	def start do
		args = System.argv()
	    numNodes = String.to_integer(Enum.at(args, 0))     
	    topology = String.to_atom(Enum.at(args, 1))     
	    algorithm = String.to_atom(Enum.at(args, 2)) 
	    IO.puts "

	    #########################################

	    		topology  : #{topology}
	    		algorithm : #{algorithm}

	    #########################################
	    "
	    :timer.sleep 20
	    IO.puts "Starting #{numNodes} workers, initiating topology and initiating #{algorithm}"
	    :timer.sleep 3000
	    __init__ numNodes, topology, algorithm
	    
	end

	defp __init__(numNodes, topology, algorithm) do
		
		AppSupervisor.start_link algorithm #Registers with :GPSupervisor
		Enum.map(1..numNodes, fn _ -> Supervisor.start_child(:GPSupervisor, []) end)
		child_pids = Supervisor.which_children(:GPSupervisor) |> Enum.map( fn item -> elem(item, 1) end)
		IO.inspect child_pids
		#Initializes the topology
		topoMap = TopologyBuilder.__init__ child_pids, topology
		topoMap = Map.put topoMap, :topology, topology
		IO.inspect topoMap
	    case algorithm do 
			
			:gossip -> GossipInitiator.activate topoMap
			:pushsum -> PushSumInitiator.activate topoMap
			_ -> raise ArgumentError, message: "Invalid topology"
		end
		poll(numNodes, algorithm)
	end

	defp poll(numNodes, algorithm) do
		#Just shows how many children managed by the supervisor are alive
		# IO.puts "No of workers that are alive = #{inspect length(Supervisor.which_children(:GPSupervisor))}"
		child_pids = Supervisor.which_children(:GPSupervisor) |> Enum.map( fn item -> elem(item, 1) end)
		# old_len = length(child_pids)
		if algorithm == :gossip do
			if length(child_pids) == 0 do
				IO.inspect :main_terminating
				System.halt
			end
	   	else
	   		# new_length = length(Supervisor.which_children(:GPSupervisor) |> Enum.map( fn item -> elem(item, 1) end))
			# :timer.sleep 1000
			# if new_length - old_len == 0 && new_length < numNodes do
			if length(child_pids) == 0 do
				IO.inspect :maini_terminating
				System.halt
			end
	   	end
		poll(numNodes, algorithm)
	end
end
MainController.start


