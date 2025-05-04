FROM elixir:1.17.1


COPY /lib /lib 
COPY mix.exs mix.exs
COPY mix.lock mix.lock

CMD ["mix", "compile"]
CMD ["iex", "-S", "mix"]


