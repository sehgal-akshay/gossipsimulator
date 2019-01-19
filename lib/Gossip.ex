defmodule GossipWorker do
	use GenServer

	def start_link() do
		GenServer.start_link(__MODULE__, [])
	end

	def init(_) do
		IO.puts "GossipWorker is starting" 
		state = %{:next_pids => [], :counter => 0}#pid is pid of next process
    	{:ok, state}
	end

	def handle_call(:get_pid, _, state) do
		current_pid = Map.get(state, :next_pids)
	    {:reply, current_pid, state}
	end

	def handle_call(:get_counter, _, state) do
		current_counter = Map.get(state, :counter)
	    {:reply, current_counter, state}
	end

	def handle_call(:call_gossip, _, state) do #sets counter when gossip is received
		# IO.puts ("Received #{Map.get(state, :counter)+1} gossip at #{inspect self()} ")
		# :timer.sleep 1000
		new_state = Map.put(state, :counter, Map.get(state, :counter)+1)
		gossip_count = Map.get(state, :counter)		
		if Map.get(state, :next_pids) != 0 do
			# IO.inspect Map.get(state, :next_pids)
			next_pids = Map.get(state, :next_pids)
			Enum.each next_pids, fn p ->
				if p != nil do
					GossipWorkerCoordinator.gossip p
				end
			end
		end
		if gossip_count == 10 do
			IO.puts "Received maximum gossips. Shutting down process with pid #{inspect self()} "
			terminate()
		end
	    {:reply, new_state, new_state}
	end

	def handle_call({:set_pid, new_pid}, _, state) do
		new_state = Map.put(state, :next_pids, new_pid)
	    {:reply, new_state, new_state}
	end

	def handle_cast(:gossip, state) do #sets counter when gossip is received
		gossip_count = Map.get(state, :counter)+1
		# IO.puts ("Received #{gossip_count} gossip at #{inspect self()} ")
		# :timer.sleep 1000
		new_state = Map.put(state, :counter, gossip_count)
		if Map.get(state, :next_pids) != nil do
			# IO.inspect Map.get(state, :next_pids)
			next_pids = Map.get(state, :next_pids)
			Enum.each next_pids, fn p ->
				if p != nil do
					GossipWorkerCoordinator.gossip p
				end
			end
		end
		if gossip_count == 10 do
			IO.puts "Received maximum gossips. Shutting down process with pid #{inspect self()} "
			# :init.stop
			terminate()
		end
	    {:noreply, new_state}
	end

	defp terminate(_ \\ 1) do
	    # IO.inspect :terminating
	    Process.exit self(), :normal
	end
end

defmodule GossipWorkerCoordinator do

	def get_pid(pid) do
		GenServer.call(pid, :get_pid)
	end

	def get_counter(pid) do
		GenServer.call(pid, :get_counter)
	end

	def set_pid(pid, next_pid) do
		GenServer.call(pid, {:set_pid, next_pid})
	end

	def gossip(pid) do
		# IO.puts "Gossipping to #{inspect pid} ...."
		GenServer.cast(pid, :gossip)
	end

end

defmodule GossipInitiator do
	
	def activate(topoMap) do

		# topology =  Map.get(topoMap, :topology)
		topoMap = Map.delete(topoMap, :topology)
		Enum.each topoMap, fn {current_pid, next_pid} ->
			GossipWorkerCoordinator.set_pid(current_pid, next_pid)
		end
		{firstNode, _} = Enum.at(topoMap, 0)
		if firstNode != nil do
			GossipWorkerCoordinator.gossip(firstNode)
		end	
	end
end