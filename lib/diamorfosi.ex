defmodule Diamorfosi do
  use Application.Behaviour

  @etcd "http://my.host.name:8080/v2/keys"
  @timeout 5000
  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Diamorfosi.Supervisor.start_link
  end

  defp body_encode(list) do
  	Keyword.keys(list) 
  		|> Stream.map(fn key ->
  			"#{key}=#{list[key]}"
  		end)
  		|> Enum.join("&")
  end

  def get(path, options \\ []) do
  	timeout = Keyword.get options, :timeout, @timeout
  	options = Keyword.delete options, :timeout
  	case HTTPoison.get "#{@etcd}#{path}", [], [timeout: timeout] do
  		HTTPoison.Response[status_code: 200, body: body] -> body |> JSEX.decode!
  		err -> false
  	end
  end
  def set(path, value, options \\ []) do
  	timeout = Keyword.get options, :timeout, @timeout
  	options = Keyword.delete options, :timeout
  	case HTTPoison.request :put, "#{@etcd}#{path}", body_encode([value: value] ++ options), [{"Content-Type", "application/x-www-form-urlencoded"}], [timeout: timeout] do
  		HTTPoison.Response[status_code: code, body: body] when code in [200, 201] -> body |> JSEX.decode!
  		HTTPoison.Response[status_code: 307] -> set path, value, options
      response -> false
  	end
  end
  def wait(path, options \\ []) do 
  	case options[:waitIndex] do
  		nil -> 
		  	get("#{path}", options)
		  	|> (fn reply ->
		  		wait path, Keyword.update(options, :waitIndex, (reply["modifiedIndex"] + 1), &(&1))
		  	end).()
		 value when is_integer(value) ->
		 	options = Keyword.delete options, :waitIndex
		 	get("#{path}?wait=true&waitIndex=#{value}", options)
	end
  end
end
