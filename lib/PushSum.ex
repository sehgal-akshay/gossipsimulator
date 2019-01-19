defmodule PushSumWorker do
	use GenServer

	def start_link() do
		GenServer.start_link(__MODULE__, [])
	end

	def init(_) do
		IO.puts "PushSumWorker is starting" 
		state = %{:next_pids => [], :counter => 0, :s => 1, :w => 1, :ratio => 1, :topology => nil}#pid is pid of next process
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

	def handle_call(:call_pushsum, _, state) do #sets counter when gossip is received
		
	    {:reply, state, state}
	end

	def handle_call({:set_s, s}, _, state) do
		new_state = Map.put(state, :s, s)
	    {:reply, new_state, new_state}
	end

	def handle_call({:set_w, w}, _, state) do
		new_state = Map.put(state, :w, w)
	    {:reply, new_state, new_state}
	end

	def handle_call({:set_ratio, ratio}, _, state) do
		new_state = Map.put(state, :ratio, ratio)
	    {:reply, new_state, new_state}
	end

	def handle_call({:set_topology, topology}, _, state) do
		new_state = Map.put(state, :topology, topology)
	    {:reply, new_state, new_state}
	end

	def handle_cast({:set_pid, new_pid}, state) do
		new_state = Map.put(state, :next_pids, new_pid)
	    {:noreply, new_state}
	end

	def handle_cast({:add_s, s}, state) do
		new_state = Map.put(state, :s, Map.get(state, :s)+s)
	    {:noreply, new_state}
	end

	def handle_cast({:add_w, w}, state) do
		new_state = Map.put(state, :w, Map.get(state, :w)+w)
	    {:noreply, new_state}
	end

	def handle_cast(:pushsum, state) do #sets counter when gossip is received
		
		#Revised s and w values
		s = Map.get(state, :s)/2
		w = Map.get(state, :w)/2

		#s and w will have new values
		new_state = Map.put(state, :s, s)
		new_state = Map.put(new_state, :w, w)
		new_state = Map.put(new_state, :ratio, s/w)

		#Sending remaining s and w values to all the neighbours
		if Map.get(state, :next_pids) != nil do
			next_pids = Map.get(state, :next_pids)
			# Enum.each next_pids, fn p ->
			# 	if p != nil do
			# 		#Adding the remaining s and w values to neighbours
			# 		PushSumWorkerCoordinator.add_s(p, s)
			# 		PushSumWorkerCoordinator.add_w(p, w)
			# 		PushSumWorkerCoordinator.pushsum p
			# 	end
			# end
			# Pick a random neighbour and send the message to it. 
			next_pids = Enum.filter(next_pids, & !is_nil(&1))
			if next_pids != nil && next_pids != [] do
				p = Enum.random next_pids
				#Adding the remaining s and w values to random neighbour
				PushSumWorkerCoordinator.add_s(p, s)
				PushSumWorkerCoordinator.add_w(p, w)
				PushSumWorkerCoordinator.pushsum p
			end
		end
		
		new_state = 
		if abs(Map.get(new_state, :ratio) - Map.get(state, :ratio)) < :math.pow(10, -10) do
			Map.put(new_state, :counter, Map.get(state, :counter)+1)
		else
			Map.put(new_state, :counter, 0)
		end
		pushsum_count = Map.get(new_state, :counter)
		IO.puts ("Received #{pushsum_count} pushsum at #{inspect self()} 
					current s value = #{s}
					current w value = #{w}
					(s/w) ratio = #{Map.get(new_state, :ratio)}
					")
		:timer.sleep 1000
		if pushsum_count == 3 do
			
				IO.puts "s/w ratio has not changed more than pow(10, -10) in 3 consecutive runs. Shutting down process with pid #{inspect self()} "
				# :init.stop
				topology = Map.get state, :topology
				reinitializeNeighbours topology
				terminate()
		end
	    {:noreply, new_state}
	end

	def terminate(_ \\ 1) do
	    # IO.inspect :terminating
	    Process.exit self(), :normal
	end

	defp reinitializeNeighbours(topology) do
		IO.puts "Reinitializing Neighbours for #{inspect self()}"
		child_pids = Supervisor.which_children(:GPSupervisor) |> Enum.map( fn item -> elem(item, 1) end)
		child_pids = List.delete child_pids, self()
		topoMap = TopologyBuilder.__init__ child_pids, topology
		topoMap = Map.delete(topoMap, :topology)
		IO.inspect topoMap
		topoMap |> Enum.each( fn {current_pid,next_pid} ->
			PushSumWorkerCoordinator.set_pid(current_pid, next_pid)
		end)
		{firstNode, _} = Enum.at(topoMap, 0)
		if firstNode != nil do
			PushSumWorkerCoordinator.pushsum(firstNode)
		end
	end

end

defmodule PushSumWorkerCoordinator do

	def get_pid(pid) do
		GenServer.call(pid, :get_pid)
	end

	def get_counter(pid) do
		GenServer.call(pid, :get_counter)
	end

	def get_s(pid) do
		GenServer.call(pid, :get_s)
	end

	def set_s(pid, s) do
		GenServer.call(pid, {:set_s, s})
	end

	def get_w(pid) do
		GenServer.call(pid, :get_w)
	end

	def set_w(pid, w) do
		GenServer.call(pid, {:set_w, w})
	end

	def set_ratio(pid, ratio) do
		GenServer.call(pid, {:set_ratio, ratio})
	end

	def set_pid(pid, next_pid) do
		GenServer.cast(pid, {:set_pid, next_pid})
	end

	def set_topology(pid, topology) do
		GenServer.call(pid, {:set_topology, topology})
	end

	def add_s(pid, s) do
		GenServer.cast(pid, {:add_s, s})
	end

	def add_w(pid, w) do
		GenServer.cast(pid, {:add_w, w})
	end

	def pushsum(pid) do
		IO.puts "PushSum to #{inspect pid} from #{inspect self()}"
		GenServer.cast(pid, :pushsum)
	end

end

defmodule PushSumInitiator do
	
	def activate(topoMap) do
		topology =  Map.get(topoMap, :topology)
		topoMap = Map.delete(topoMap, :topology)
		topoMap |> Enum.with_index |> Enum.each( fn {{current_pid,next_pid}, i} ->
			PushSumWorkerCoordinator.set_pid(current_pid, next_pid)
			PushSumWorkerCoordinator.set_s(current_pid, i+1)
			PushSumWorkerCoordinator.set_ratio(current_pid, i+1)
			PushSumWorkerCoordinator.set_topology(current_pid, topology)
		end)
		{firstNode, _} = Enum.at(topoMap, 0)
		if firstNode != nil do
			PushSumWorkerCoordinator.pushsum(firstNode)
		end	
	end
end