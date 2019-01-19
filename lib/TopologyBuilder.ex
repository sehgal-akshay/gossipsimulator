defmodule TopologyBuilder do

## This is the TopologyBuilder that builds the topology on the basis of the topology input given by user 

	def __init__(lpids, topology)  do
		
		#Supporting below topology types
		case topology do 
			:DD -> build2DTopo lpids
			:full -> buildFullTopo lpids
			:DDD -> build3DTopo lpids
			:rand2D -> buildRand2DTopo lpids
			:torus -> buildTorusTopo lpids
			:line -> buildLineTopo lpids
			:imp2D -> imp2D lpids
			:impLine -> buildImpLineTopo lpids	

			:circle -> buildCircularTopo lpids
			_ -> raise ArgumentError, message: "Invalid topology"
		end
	end

	def buildLineTopo(lpids) do
		
		dataplane =  lpids |> Enum.with_index |> Enum.reduce(%{}, fn {x, i}, acc ->
				
				next_el = Enum.at(lpids, i+1)
				acc = 
				if i+1 <= length(lpids) do	
				     if Map.has_key?(acc, x) do
				     	 ltemp = Enum.concat Map.get(acc, x), [next_el]
				 		 Map.put(acc, x, ltemp)
				 	 else
				 	 	 Map.put(acc, x, [next_el])
				 	 end
				end
				if next_el != nil do
					Map.put(acc, next_el, [x])
				else
					acc
				end

		end)

		# IO.inspect dataplane
		dataplane
	end

	def buildCircularTopo(lpids) do
		
		dataplane =  lpids |> Enum.with_index |> Enum.reduce(%{}, fn {x, i}, acc ->
				
				next_el = Enum.at(lpids, i+1)
				if i+1 < length(lpids) do	
				     
				 	Map.put(acc, x, [next_el])
				else
					Map.put(acc, x, [Enum.at(lpids, 0)])
				end

		end)

		IO.inspect dataplane
		dataplane
	end

	def build2DTopo(lpids) do
	
		root =:math.pow(length(lpids),1/2)
		nextRoot = trunc(root+1)
		reqNum = :math.pow(nextRoot,2)
		iter = trunc(reqNum - length(lpids))
		lpids = 
		Enum.reduce 1..iter, lpids, fn _,acc -> Enum.concat acc, [nil]  end	
		
		if (trunc(:math.sqrt(length(lpids)))==:math.sqrt(length(lpids))) do  
				dataplane =  lpids |> Enum.with_index |> Enum.reduce(%{}, fn {x, i}, acc ->
					n= trunc(:math.sqrt(length(lpids)))		

					  right_el =
						 cond do
						  	i==n-1 -> nil	
						 	i==length(lpids)-1 -> nil
						 	rem(i,n)==n-1 -> nil
						 	true -> Enum.at(lpids, i+1)
						 end
					  down_el =
						  cond do
						 	i==length(lpids)-1 -> nil
						 	i==length(lpids)-n -> nil
						 	i==length(lpids)-n..length(lpids)-1 -> nil
						 	true -> Enum.at(lpids, i+n)
						 end
					  left_el =
						  cond do
						 	i==0 -> nil
						 	i==length(lpids)-n -> nil
						 	rem(i,n)==0 -> nil
						 	true -> Enum.at(lpids, i-1)
						 end
					  up_el =
						  cond do
						 	i==0 -> nil
						 	i==n-1 -> nil	
						 	i==1..n-2 -> nil
						 	true -> Enum.at(lpids, i-n)
						 end
					
					if i+1 <= length(lpids) do	
					     if Map.has_key?(acc, x) do
					    	 ltemp = Enum.filter((Enum.concat Map.get(acc, x), [right_el, left_el, up_el, down_el]), fn x -> x != nil end)		
					     	 Map.put(acc, x, ltemp)
					 	 else
					 	 	 Map.put(acc, x, Enum.filter([right_el, left_el, up_el, down_el], fn x -> x != nil end)) 	 
					 	 end
					 else
						acc |> Map.filter(fn{_,v}->v != nil end) |> Map.into(%{})
					
					end
					
				end)
				dataplane = Map.delete dataplane, nil
				IO.inspect dataplane
				dataplane
		#else
		#	raise ArgumentError, message: "Please enter a perfect square for processes" 
		end
		
	end


	def buildFullTopo(lpids) do

		root =:math.pow(length(lpids),1/2)
		nextRoot = trunc(root+1)
		reqNum = :math.pow(nextRoot,2)
		iter = trunc(reqNum - length(lpids))
		lpids = 
		Enum.reduce 1..iter, lpids, fn _,acc -> Enum.concat acc, [nil]  end	
		
		if (trunc(:math.sqrt(length(lpids)))==:math.sqrt(length(lpids))) do  
				dataplane =  lpids |> Enum.with_index |> Enum.reduce(%{}, fn {x, i}, acc ->
					list1 =
					for x <- 0..i-1 do
						 Enum.at(lpids, x)
					end
					list2 =
					for x <- i+1..length(lpids)-1 do
						 Enum.at(lpids, x)
					end
						list = list1 ++ list2
					if i+1 <= length(lpids) do	
					     if Map.has_key?(acc, x) do
					    	 ltemp = Enum.concat Map.get(acc, x), list	
					     	 Map.put(acc, x, ltemp)
					 	 else
					 	 	 Map.put(acc, x, list) 	 
					 	 end
					 else
						acc |> Map.filter(fn{_,v}->v != nil end) |> Map.into(%{})
					
					end
					
				end)

				dataplane = Map.delete dataplane, nil
				IO.inspect dataplane
				dataplane
		else
			raise ArgumentError, message: "Please enter a perfect square for processes" 
		end
		
	end

def buildImpLineTopo(lpids) do
		
		dataplane =  lpids |> Enum.with_index |> Enum.reduce(%{}, fn {x, i}, acc ->
				
				next_el = Enum.at(lpids, i+1)
				rand = Enum.random(lpids)
				acc = 
				if i+1 <= length(lpids) do	
				     if Map.has_key?(acc, x) do
				     	 ltemp = Enum.filter((Enum.concat Map.get(acc, x), [next_el, rand]), fn x -> x != nil end)
				 		 Map.put(acc, x, ltemp)
				 		 #IO.inspect ltemp
				 	 else
				 	 	 Map.put(acc, x, Enum.filter([next_el, rand], fn x -> x != nil end))
				 	 end
				end
				if next_el != nil do
					Map.put(acc, next_el, [x])
				else
					acc 
				end

		end)

		dataplane = Map.delete dataplane, nil
		IO.inspect dataplane
		dataplane
	end


def buildRand2DTopo(lpids) do
	
	root =:math.pow(length(lpids),1/2)
	nextRoot = trunc(root+1)
	reqNum = :math.pow(nextRoot,2)
	iter = trunc(reqNum - length(lpids))
	lpids = 
	Enum.reduce 1..iter, lpids, fn _,acc -> Enum.concat acc, [nil]  end
		
		if (trunc(:math.sqrt(length(lpids)))==:math.sqrt(length(lpids))) do  
				dataplane =  lpids |> Enum.with_index |> Enum.reduce(%{}, fn {x, i}, acc ->
					n= trunc(:math.sqrt(length(lpids)))

					  right_el =
						 cond do
						 	i==n-1 -> nil	
						 	i==length(lpids)-1 -> nil
						 	rem(i,n)==n-1 -> nil
						 	true -> Enum.at(lpids, i+1)
						 end
					  down_el =
						  cond do	
						 	i==length(lpids)-1 -> nil
						 	i==length(lpids)-n -> nil
						 	true -> Enum.at(lpids, i+n)
						 end
					  left_el =
						  cond do
						 	i==0 -> nil
						 	i==length(lpids)-n -> nil
						 	rem(i,n)==0 -> nil
						 	true -> Enum.at(lpids, i-1)
						 end
					  up_el =
						  cond do
						 	i==0 -> nil
						 	i==n-1 -> nil	
						 	i==1..n-2 -> nil
						 	true -> Enum.at(lpids, i-n)
						 end
						rand = Enum.random(lpids)
					
					if i+1 <= length(lpids) do	
					     if Map.has_key?(acc, x) do
					    	 #ltemp = Enum.concat Map.get(acc, x), [right_el, left_el, up_el, down_el, rand]	
					     	 ltemp = Enum.filter((Enum.concat Map.get(acc, x), [right_el, left_el, up_el, down_el, rand]), fn x -> x != nil end)	
					     	 Map.put(acc, x, ltemp)
					 	 else
					 	 	 Map.put(acc, x, Enum.filter([right_el, left_el, up_el, down_el, rand], fn x -> x != nil end)) 	 
					 	 end
					 else
						acc |> Map.filter(fn{_,v}->v != nil end) |> Map.into(%{})
					
					end
					
				end)

				dataplane = Map.delete dataplane, nil
				IO.inspect dataplane
				dataplane
		#else
			#raise ArgumentError, message: "Please enter a perfect square for processes" 
		end	
	end

	def imp2D(lpids) do
	
	root =:math.pow(length(lpids),1/2)
	nextRoot = trunc(root+1)
	reqNum = :math.pow(nextRoot,2)
	iter = trunc(reqNum - length(lpids))
	lpids = 
	Enum.reduce 1..iter, lpids, fn _,acc -> Enum.concat acc, [nil]  end
		
		if (trunc(:math.sqrt(length(lpids)))==:math.sqrt(length(lpids))) do  
				dataplane =  lpids |> Enum.with_index |> Enum.reduce(%{}, fn {x, i}, acc ->
					n= trunc(:math.sqrt(length(lpids)))

					  right_el =
						 cond do
						 	i==n-1 -> nil	
						 	i==length(lpids)-1 -> nil
						 	rem(i,n)==n-1 -> nil
						 	true -> Enum.at(lpids, i+1)
						 end
					  down_el =
						  cond do	
						 	i==length(lpids)-1 -> nil
						 	i==length(lpids)-n -> nil
						 	true -> Enum.at(lpids, i+n)
						 end
					  left_el =
						  cond do
						 	i==0 -> nil
						 	i==length(lpids)-n -> nil
						 	rem(i,n)==0 -> nil
						 	true -> Enum.at(lpids, i-1)
						 end
					  up_el =
						  cond do
						 	i==0 -> nil
						 	i==n-1 -> nil	
						 	i==1..n-2 -> nil
						 	true -> Enum.at(lpids, i-n)
						 end
						rand = Enum.random(lpids)
					
					if i+1 <= length(lpids) do	
					     if Map.has_key?(acc, x) do
					    	 #ltemp = Enum.concat Map.get(acc, x), [right_el, left_el, up_el, down_el, rand]	
					     	 ltemp = Enum.filter((Enum.concat Map.get(acc, x), [right_el, left_el, up_el, down_el, rand]), fn x -> x != nil end)	
					     	 Map.put(acc, x, ltemp)
					 	 else
					 	 	 Map.put(acc, x, Enum.filter([right_el, left_el, up_el, down_el, rand], fn x -> x != nil end)) 	 
					 	 end
					 else
						acc |> Map.filter(fn{_,v}->v != nil end) |> Map.into(%{})
					
					end
					
				end)

				dataplane = Map.delete dataplane, nil
				IO.inspect dataplane
				dataplane
		#else
			#raise ArgumentError, message: "Please enter a perfect square for processes" 
		end	
	end

	def buildImp2DTopo (lpids) do
		
		mapCoord = Enum.map(lpids, fn x -> Map.put(%{}, x, [:rand.uniform(100)] ++ [:rand.uniform(100)]) end) 	
		dataplanefinal = Enum.reduce(mapCoord, [], fn k, lacc ->
		[listkeys] = Map.keys(k)
		listvalues = Map.values(k)

		dataplane = [] ++ Enum.map(mapCoord, fn x -> 
			if areConnected(listvalues, Map.values(x)) do
				Enum.at(Map.keys(x), 0)
			end
		end) 
			
			dataplane = Enum.filter(dataplane, &(!is_nil(&1)))
			dataplane = dataplane -- [listkeys]
			lacc ++ [dataplane]
		end)

		IO.inspect(dataplanefinal)
		#dataplanefinal = dataplanefinal |> Enum.filter(fn{_,v}->v != nil end) |> Map.put(%{})
		#Map.delete dataplanefinal, nil
		
	end

	def areConnected(l1, l2) do
		l1 = Enum.at(l1,0)
		l2 = Enum.at(l2,0)
			x_diff = :math.pow(Enum.at(l2, 0) - Enum.at(l1, 0), 2)
	 		y_diff = :math.pow(Enum.at(l2, 1) - Enum.at(l1, 1), 2)
			
	 		distance = round(:math.pow((x_diff + y_diff),1/2))

	 		cond do
	 					distance < 10 -> true
	 					distance > 10 -> false
	 					true -> nil	
	 				end
	end
	
def build3DTopo(lpids) do
root =:math.pow(length(lpids),1/3)
nextRoot = trunc(root+1)
	reqNum = :math.pow(nextRoot,3)
	iter = trunc(reqNum - length(lpids))
	lpids = 
	Enum.reduce 1..iter, lpids, fn _,acc -> Enum.concat acc, [nil]  end


		# if (trunc(:math.pow(length(lpids),1/3))==:math.pow(length(lpids),1/3)) do  
				dataplane =  lpids |> Enum.with_index |> Enum.reduce(%{}, fn {x, i}, acc ->
					n= trunc(:math.ceil(:math.pow(length(lpids),1/3)))
					# IO.inspect "n========#{n}"
					nLength = n*n

					  		right_el =
						 		cond do
							 		i in 0..nLength-1 ->
										 cond do
										 	rem(i,n)==n-1 -> nil
										 	true -> Enum.at(lpids, i+1)
										 end
								
									i in nLength..2*nLength-1 ->
										 cond do	
										 	rem(i,n)==n-1 -> nil
										 	true -> Enum.at(lpids, i+1)
										 end
							
									i in 2*nLength..3*nLength-1 ->
										 cond do
										 	rem(i,n)==n-1 -> nil
										 	true -> Enum.at(lpids, i+1)
										 end

									true -> nil
								end	
							left_el=
								cond do
									i in 0..nLength-1 ->
										 cond do
										 	rem(i,n)==0 -> nil
										 	true -> Enum.at(lpids, i-1)
										 end

									i in nLength..2*nLength-1 ->
										 cond do
										 	rem(i,n)==0 -> nil
										 	true -> Enum.at(lpids, i-1)
										 end

									i in 2*nLength..3*nLength-1 ->
										 cond do
										 	rem(i,n)==0 -> nil
										 	true -> Enum.at(lpids, i-1)
										 end

									true -> nil
								end
							up_el=
								cond do
									i in 0..nLength-1 ->
										 cond do
										 	i in 0..n-1 -> nil
										 	true -> Enum.at(lpids, i-n)
										 end
		
									i in nLength..2*nLength-1 ->
										 cond do
										 	i in nLength..nLength+n -> nil
										 	true -> Enum.at(lpids, i-n)
										 end
									
									i in 2*nLength..3*nLength-1 ->
										 cond do
										 	i in 2*nLength..2*nLength+n -> nil
										 	true -> Enum.at(lpids, i-n)
										 end
						
									i in 0..nLength-1 ->
										 cond do
										 	i in nLength-1-n..nLength-1 -> nil
										 	true -> Enum.at(lpids, i+n)
										 end

									true -> nil
								end
							down_el=
								cond do
																			
									i in nLength..2*nLength-1 ->
										 cond do
										 	i in (2*nLength-1-n..2*nLength-1) -> nil
										 	true -> Enum.at(lpids, i+n)
										 end
								
									i in 2*nLength..3*nLength-1 ->
										 cond do
										 	i in 3*nLength-1-n..3*nLength-1 -> nil
										 	true -> Enum.at(lpids, i+n)
										 end
			
									i in 0..nLength-1 ->
										 	cond do
										 		i in nLength-n..nLength-1 -> nil
										 		true -> Enum.at(lpids, i+n)
										 	end

									true -> nil

								end
							front_el=
								cond do
									 										
									i in 0..nLength-1 -> nil
										 
									i in nLength..2*nLength-1 -> Enum.at(lpids, i-nLength)
										 									
									i in 2*nLength..3*nLength-1 -> Enum.at(lpids, i-nLength)

									true -> nil
								end
							back_el=
								cond do
																															
									i in 0..nLength-1 -> Enum.at(lpids, i+nLength)
										 									
									i in nLength..2*nLength-1 -> Enum.at(lpids, i+nLength)
										 									
									i in 2*nLength..3*nLength-1 -> nil

									true -> nil
										 								   
								end	

					if i+1 <= length(lpids) do	
					     if Map.has_key?(acc, x) do
					    	 ltemp = Enum.filter((Enum.concat Map.get(acc, x), [right_el, left_el, up_el, down_el, front_el, back_el]), fn x -> x != nil end)	
					     	 #Enum.filter(ltemp, & !is_nil(&1))
					     	 Map.put(acc, x, ltemp)
					 	 else 
					 	 	 Map.put(acc, x, Enum.filter([right_el, left_el, up_el, down_el, front_el, back_el], fn x -> x != nil end)) 	 
					 	 end
					 else
						acc |> Map.filter(fn{_,v}->v != nil end) |> Map.into(%{})
					
					end
					
				end)
				dataplane = Map.delete dataplane, nil
				IO.inspect dataplane
				dataplane
			#else
				#raise ArgumentError, message: "Please enter a perfect cube for the number of processes" 
		# end
		
	end
	def buildTorusTopo(lpids) do
	root =:math.pow(length(lpids),1/2)
	nextRoot = trunc(root+1)
	reqNum = :math.pow(nextRoot,2)
	iter = trunc(reqNum - length(lpids))
	lpids = 
	Enum.reduce 1..iter, lpids, fn _,acc -> Enum.concat acc, [nil]  end
		
		if (trunc(:math.sqrt(length(lpids)))==:math.sqrt(length(lpids))) do  
				dataplane =  lpids |> Enum.with_index |> Enum.reduce(%{}, fn {x, i}, acc ->
					n= trunc(:math.sqrt(length(lpids)))
					l= length(lpids)

					  right_el =
						 cond do
						 	rem(i,n)==n-1 -> Enum.at(lpids,i-n+1)
						 	true -> Enum.at(lpids, i+1)
						 end
					  down_el =

						 cond do	
							 i in l-n..l-1   -> 
							 	Enum.at(lpids, i-(n-1)*n)
							 true -> Enum.at(lpids, i+n)
						 end
					  left_el =
						  cond do
						 	i==0 -> Enum.at(lpids, i+n-1)	
						 	i==length(lpids)-n -> Enum.at(lpids, i+n-1)
						 	rem(i,n)==0 -> Enum.at(lpids, i+n-1)
						 	true -> Enum.at(lpids, i-1)
						 end
					  up_el =
						  cond do
						 	i==0 -> Enum.at(lpids, i+(n-1)*n)
						 	i==n-1 -> Enum.at(lpids, i+(n-1)*n)	
						 	i in 1..n-2 -> Enum.at(lpids, i+(n-1)*n)
						 	true -> Enum.at(lpids, i-n)
						 end
					
					if i+1 <= length(lpids) do	
					     if Map.has_key?(acc, x) do
					    	 ltemp = Enum.filter((Enum.concat Map.get(acc, x), [right_el, left_el, up_el, down_el]), fn x -> x != nil end)	
					     	 Map.put(acc, x, ltemp)
					 	 else
					 	 	 Map.put(acc, x, Enum.filter([right_el, left_el, up_el, down_el], fn x -> x != nil end)) 	 
					 	 end
					 else
						acc |> Map.filter(fn{_,v}->v != nil end) |> Map.into(%{})
					
					end
					
				end)
				dataplane = Map.delete dataplane, nil
				IO.inspect dataplane
				dataplane
		#else
		#	raise ArgumentError, message: "Please enter a perfect square for processes" 
		end		
	end
end
 # TopologyBuilder.build3DTopo([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27])